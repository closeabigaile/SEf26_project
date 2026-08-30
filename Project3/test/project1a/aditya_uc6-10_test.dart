import 'dart:convert';
import 'dart:typed_data';

import 'package:fake_cloud_firestore/fake_cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_core_platform_interface/test.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:image_picker_platform_interface/image_picker_platform_interface.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/receipt_scanner_screen.dart';
import 'package:wolfbite/screens/scan_screen.dart';
import 'package:wolfbite/services/apl_service.dart';
import 'package:wolfbite/state/app_state.dart';
import 'package:wolfbite/utils/nutritional_utils.dart';
import 'package:wolfbite/widgets/nutritional_badges.dart';

import '../mocks/mocks.mocks.dart';

class _TestUser extends Mock implements User {
  @override
  String get uid => 'aditya-uc6-10-user';
}

class _FakeImagePicker extends ImagePickerPlatform {
  _FakeImagePicker(this.result);

  final XFile? result;

  @override
  Future<XFile?> getImageFromSource({
    required ImageSource source,
    ImagePickerOptions options = const ImagePickerOptions(),
  }) async => result;
}

Map<String, dynamic> _nutritionProduct({
  required String name,
  required String category,
  required int fdcId,
  required num energy,
  bool eligible = true,
  String? upc,
}) {
  return {
    'name': name,
    'category': category,
    'fdcId': fdcId,
    'eligible': eligible,
    if (upc != null) 'upc': upc,
    'foodNutrients': [
      {'name': 'Energy', 'amount': energy},
    ],
  };
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  setupFirebaseCoreMocks();

  setUpAll(() async {
    await Firebase.initializeApp();
  });

  group('UC6 - Review product nutrition', () {
    test('UC6-T1 identified product -> normalized nutrition', () {
      final product = {
        'eligible': true,
        'foodNutrients': [
          {'name': 'Energy', 'amount': 120},
          {'name': 'Total lipid (fat)', 'amount': 3},
          {'name': 'Fatty acids, total saturated', 'amount': 1},
          {'name': 'Sodium, Na', 'amount': 140},
          {'name': 'Total Sugars', 'amount': 5},
          {'name': 'Protein', 'amount': 10},
        ],
      };

      final nutrition = NutritionalUtils.buildNutritionFromFoodNutrients(
        product,
      );

      expect(nutrition['calories'], 120.0);
      expect(nutrition['totalFat'], 3.0);
      expect(nutrition['saturatedFat'], 1.0);
      expect(nutrition['sodium'], 140.0);
      expect(nutrition['sugar'], 5.0);
      expect(nutrition['protein'], 10.0);
      expect(nutrition['wicEligible'], isTrue);
    });

    test('UC6-T2 missing or nonnumeric nutrients -> zero defaults', () {
      final nutrition = NutritionalUtils.buildNutritionFromFoodNutrients({
        'foodNutrients': [
          {'name': 'Energy', 'amount': 'unknown'},
        ],
      });

      expect(nutrition['calories'], 0.0);
      expect(nutrition['totalFat'], 0.0);
      expect(nutrition['sodium'], 0.0);
      expect(nutrition['protein'], 0.0);
    });

    test('UC6-T3 exact thresholds -> all inclusive qualities apply', () {
      final badges = NutritionalUtils.getBadges({
        'calories': 120,
        'totalFat': 3,
        'saturatedFat': 1,
        'sodium': 140,
        'sugar': 5,
        'protein': 10,
        'wicEligible': false,
      });

      expect(
        badges,
        containsAll(<NutritionalBadge>[
          NutritionalBadge.lowFat,
          NutritionalBadge.lowSodium,
          NutritionalBadge.lowSugar,
          NutritionalBadge.highProtein,
          NutritionalBadge.lowCalorie,
          NutritionalBadge.heartHealthy,
        ]),
      );
    });

    test('UC6-T4 nutrition matching no rule -> no qualities', () {
      final badges = NutritionalUtils.getBadges({
        'calories': 121,
        'totalFat': 4,
        'saturatedFat': 2,
        'sodium': 141,
        'sugar': 6,
        'protein': 9,
        'wicEligible': false,
      });

      expect(badges, isEmpty);
    });

    testWidgets(
      'UC6-T5 more than three qualities -> compact view shows three',
      (tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: NutritionalBadgesCompact(
                nutrition: {
                  'calories': 0,
                  'totalFat': 0,
                  'saturatedFat': 0,
                  'sodium': 0,
                  'sugar': 0,
                  'protein': 20,
                  'wicEligible': false,
                },
              ),
            ),
          ),
        );

        expect(find.byType(Tooltip), findsNWidgets(3));
      },
    );
  });

  group('UC7 - Compare healthier alternatives', () {
    late FakeFirebaseFirestore firestore;
    late AplService service;

    setUp(() {
      firestore = FakeFirebaseFirestore();
      service = AplService(db: firestore);
    });

    test(
      'UC7-T1 eligible same-category candidates -> ranked healthier list',
      () async {
        final base = _nutritionProduct(
          name: 'Base',
          category: 'CEREAL',
          fdcId: 1,
          energy: 500,
          upc: 'base',
        );
        await firestore
            .collection('apl')
            .doc('best')
            .set(
              _nutritionProduct(
                name: 'Best',
                category: 'CEREAL',
                fdcId: 2,
                energy: 100,
              ),
            );
        await firestore
            .collection('apl')
            .doc('good')
            .set(
              _nutritionProduct(
                name: 'Good',
                category: 'CEREAL',
                fdcId: 3,
                energy: 200,
              ),
            );
        await firestore
            .collection('apl')
            .doc('worse')
            .set(
              _nutritionProduct(
                name: 'Worse',
                category: 'CEREAL',
                fdcId: 4,
                energy: 600,
              ),
            );

        final results = await service.healthierSubstitutes(
          category: 'CEREAL',
          baseProduct: base,
        );

        expect(results.map((item) => item['upc']), ['best', 'good']);
        expect(
          results.first['healthScore'],
          lessThan(results.last['healthScore']),
        );
      },
    );

    test(
      'UC7-T2 candidate pool -> excludes original, ineligible, and other category',
      () async {
        final base = _nutritionProduct(
          name: 'Base',
          category: 'MILK',
          fdcId: 10,
          energy: 500,
          upc: 'base-upc',
        );
        await firestore.collection('apl').doc('base-upc').set(base);
        await firestore
            .collection('apl')
            .doc('same-fdc')
            .set(
              _nutritionProduct(
                name: 'Same FDC',
                category: 'MILK',
                fdcId: 10,
                energy: 0,
              ),
            );
        await firestore
            .collection('apl')
            .doc('ineligible')
            .set(
              _nutritionProduct(
                name: 'Ineligible',
                category: 'MILK',
                fdcId: 11,
                energy: 0,
                eligible: false,
              ),
            );
        await firestore
            .collection('apl')
            .doc('other')
            .set(
              _nutritionProduct(
                name: 'Other category',
                category: 'JUICE',
                fdcId: 12,
                energy: 0,
              ),
            );

        final results = await service.healthierSubstitutes(
          category: 'MILK',
          baseProduct: base,
        );

        expect(results, isEmpty);
      },
    );

    test(
      'UC7-T3 more than maximum healthier candidates -> first five ranked',
      () async {
        final base = _nutritionProduct(
          name: 'Base',
          category: 'JUICE',
          fdcId: 20,
          energy: 1000,
        );
        for (var index = 1; index <= 7; index++) {
          await firestore
              .collection('apl')
              .doc('candidate-$index')
              .set(
                _nutritionProduct(
                  name: 'Candidate $index',
                  category: 'JUICE',
                  fdcId: 20 + index,
                  energy: index * 10,
                ),
              );
        }

        final results = await service.healthierSubstitutes(
          category: 'JUICE',
          baseProduct: base,
          max: 5,
        );

        expect(results, hasLength(5));
        expect(
          results.map((item) => item['healthScore']),
          orderedEquals(<double>[0.1, 0.2, 0.3, 0.4, 0.5]),
        );
      },
    );

    test(
      'UC7-T4 candidate missing nutrition -> zero-score candidate can qualify',
      () async {
        final base = _nutritionProduct(
          name: 'Base',
          category: 'BREAD',
          fdcId: 30,
          energy: 100,
        );
        await firestore.collection('apl').doc('missing').set({
          'name': 'Missing nutrition',
          'category': 'BREAD',
          'fdcId': 31,
          'eligible': true,
        });

        final results = await service.healthierSubstitutes(
          category: 'BREAD',
          baseProduct: base,
        );

        expect(results.single['upc'], 'missing');
        expect(results.single['healthScore'], 0.0);
      },
    );

    test('UC7-T5 no better candidate -> empty alternatives', () async {
      final base = _nutritionProduct(
        name: 'Base',
        category: 'CHEESE',
        fdcId: 40,
        energy: 100,
      );
      await firestore
          .collection('apl')
          .doc('equal')
          .set(
            _nutritionProduct(
              name: 'Equal',
              category: 'CHEESE',
              fdcId: 41,
              energy: 100,
            ),
          );

      final results = await service.healthierSubstitutes(
        category: 'CHEESE',
        baseProduct: base,
      );

      expect(results, isEmpty);
    });

    test('UC7-T6 blank category -> no search results', () async {
      await firestore.collection('apl').doc('blank-category').set({
        'name': 'Unexpected result',
        'category': '',
        'fdcId': 50,
        'eligible': true,
        'foodNutrients': const [],
      });

      final results = await service.healthierSubstitutes(
        category: '',
        baseProduct: _nutritionProduct(
          name: 'Base',
          category: '',
          fdcId: 51,
          energy: 100,
        ),
      );

      expect(results, isEmpty);
    });
  });

  group('UC8 - Add product to basket', () {
    late FakeFirebaseFirestore firestore;
    late AppState appState;

    setUp(() async {
      firestore = FakeFirebaseFirestore();
      appState = AppState(db: firestore);
      appState.updateUser(_TestUser());
      await Future<void>.delayed(Duration.zero);
    });

    test('UC8-T1 identified covered product -> basket and usage increment', () {
      appState.balances['MILK'] = {'allowed': 3, 'used': 0};

      final added = appState.addItem(
        upc: '111111111111',
        name: 'Milk',
        category: 'MILK',
      );

      expect(added, isTrue);
      expect(appState.basket, hasLength(1));
      expect(appState.basket.single['qty'], 1);
      expect(appState.balances['MILK']!['used'], 1);
    });

    test('UC8-T2 exhausted allowance -> unchanged basket and usage', () {
      appState.balances['MILK'] = {'allowed': 1, 'used': 1};

      final added = appState.addItem(
        upc: '222222222222',
        name: 'More Milk',
        category: 'MILK',
      );

      expect(added, isFalse);
      expect(appState.basket, isEmpty);
      expect(appState.balances['MILK']!['used'], 1);
    });

    test('UC8-T3 existing UPC -> quantity flow without duplicate line', () {
      appState.balances['MILK'] = {'allowed': 3, 'used': 0};
      appState.addItem(upc: '333333333333', name: 'Milk', category: 'MILK');

      final createdNewLine = appState.addItem(
        upc: '333333333333',
        name: 'Milk',
        category: 'MILK',
      );

      expect(createdNewLine, isFalse);
      expect(appState.basket, hasLength(1));
      expect(appState.basket.single['qty'], 2);
      expect(appState.balances['MILK']!['used'], 2);
    });

    test('UC8-T4 signed-out shopper -> rejected unchanged basket', () {
      appState.updateUser(null);

      final added = appState.addItem(
        upc: '444444444444',
        name: 'Milk',
        category: 'MILK',
      );

      expect(added, isFalse);
      expect(appState.basket, isEmpty);
      expect(appState.balances, isEmpty);
    });

    test('UC8-T5 raw category -> canonical in-memory basket state', () {
      final added = appState.addItem(
        upc: '555555555555',
        name: 'Yogurt',
        category: '  milk   products ',
      );

      expect(added, isTrue);
      expect(appState.basket.single['category'], 'MILK PRODUCTS');
      expect(appState.balances, contains('MILK PRODUCTS'));
    });
  });

  group('UC9 - Choose healthier alternative', () {
    late MockAplService aplService;
    late MockAppState appState;
    late MockFirebaseAuth auth;
    late MockGoRouter router;

    setUp(() {
      aplService = MockAplService();
      appState = MockAppState();
      auth = MockFirebaseAuth();
      router = MockGoRouter();
      when(appState.canAdd(any)).thenReturn(true);
    });

    Future<void> pumpAlternative(
      WidgetTester tester, {
      required bool addResult,
    }) async {
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      addTearDown(tester.view.resetPhysicalSize);
      addTearDown(tester.view.resetDevicePixelRatio);

      final base = _nutritionProduct(
        name: 'Base cereal',
        category: 'CEREAL',
        fdcId: 60,
        energy: 500,
      );
      final alternative = _nutritionProduct(
        name: 'Better cereal',
        category: 'CEREAL',
        fdcId: 61,
        energy: 100,
        upc: '666666666666',
      )..['healthScore'] = 1.0;

      when(aplService.findByUpc('base')).thenAnswer((_) async => base);
      when(
        aplService.healthierSubstitutes(
          category: 'CEREAL',
          baseProduct: base,
          max: 5,
        ),
      ).thenAnswer((_) async => [alternative]);
      when(
        appState.addItem(
          upc: anyNamed('upc'),
          name: anyNamed('name'),
          category: anyNamed('category'),
          nutrition: anyNamed('nutrition'),
        ),
      ).thenReturn(addResult);

      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: router,
              child: ScanScreen(aplService: aplService, auth: auth),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), 'base');
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      await tester.tap(find.byIcon(Icons.eco));
      await tester.pumpAndSettle();
    }

    testWidgets('UC9-T1 available alternative -> exact product submitted', (
      tester,
    ) async {
      await pumpAlternative(tester, addResult: true);

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      verify(
        appState.addItem(
          upc: '666666666666',
          name: 'Better cereal',
          category: 'CEREAL',
          nutrition: anyNamed('nutrition'),
        ),
      ).called(1);
      expect(find.text('Added healthier item: Better cereal'), findsOneWidget);
    });

    testWidgets('UC9-T2 rejected alternative -> must not report success', (
      tester,
    ) async {
      await pumpAlternative(tester, addResult: false);

      await tester.tap(find.byIcon(Icons.add_circle_outline));
      await tester.pumpAndSettle();

      expect(find.text('Added healthier item: Better cereal'), findsNothing);
    });
  });

  group('UC10 - Scan receipt', () {
    late ImagePickerPlatform originalPicker;
    late MockAppState appState;
    late MockGoRouter router;

    setUp(() {
      originalPicker = ImagePickerPlatform.instance;
      appState = MockAppState();
      router = MockGoRouter();
    });

    tearDown(() {
      ImagePickerPlatform.instance = originalPicker;
    });

    Future<void> pumpReceipt(WidgetTester tester) async {
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: router,
              child: const ReceiptScannerScreen(),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    Future<void> chooseGallery(WidgetTester tester) async {
      await tester.tap(find.text('Select Image'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Gallery / Upload'));
      await tester.pump();
    }

    testWidgets('UC10-T1 ready -> source dialog cancelled -> ready unchanged', (
      tester,
    ) async {
      await pumpReceipt(tester);
      await tester.tap(find.text('Select Image'));
      await tester.pumpAndSettle();

      Navigator.of(tester.element(find.text('Choose Source'))).pop();
      await tester.pumpAndSettle();

      expect(find.text('Tap button to upload receipt'), findsOneWidget);
      expect(find.text('Select Image'), findsOneWidget);
    });

    testWidgets('UC10-T2 source chosen -> image selection cancelled -> ready', (
      tester,
    ) async {
      ImagePickerPlatform.instance = _FakeImagePicker(null);
      await pumpReceipt(tester);
      await chooseGallery(tester);
      await tester.pumpAndSettle();

      expect(find.text('Select Image'), findsOneWidget);
      expect(find.text('Uploading & Analyzing...'), findsOneWidget);
    });

    testWidgets('UC10-T3 OCR failure -> visible error and ready state', (
      tester,
    ) async {
      ImagePickerPlatform.instance = _FakeImagePicker(
        XFile.fromData(Uint8List.fromList([1, 2, 3]), mimeType: 'image/jpeg'),
      );
      await http.runWithClient(() async {
        await pumpReceipt(tester);
        await chooseGallery(tester);
        await tester.pumpAndSettle();
      }, () => MockClient((_) async => http.Response('failure', 500)));

      expect(
        find.textContaining('Error: Exception: API Error: 500'),
        findsOneWidget,
      );
      expect(find.text('Select Image'), findsOneWidget);
    });

    testWidgets('UC10-T4 OCR text without candidate -> zero-candidate status', (
      tester,
    ) async {
      ImagePickerPlatform.instance = _FakeImagePicker(
        XFile.fromData(Uint8List.fromList([1, 2, 3]), mimeType: 'image/jpeg'),
      );
      final response = jsonEncode({
        'IsErroredOnProcessing': false,
        'ParsedResults': [
          {'ParsedText': 'Receipt with no product code'},
        ],
      });
      await http.runWithClient(() async {
        await pumpReceipt(tester);
        await chooseGallery(tester);
        await tester.pumpAndSettle();
      }, () => MockClient((_) async => http.Response(response, 200)));

      expect(find.textContaining('No UPC candidates found.'), findsOneWidget);
      expect(find.text('Select Image'), findsOneWidget);
    });

    testWidgets('UC10-T5 spaced or hyphenated code -> no candidate', (
      tester,
    ) async {
      ImagePickerPlatform.instance = _FakeImagePicker(
        XFile.fromData(Uint8List.fromList([1, 2, 3]), mimeType: 'image/jpeg'),
      );
      final response = jsonEncode({
        'IsErroredOnProcessing': false,
        'ParsedResults': [
          {'ParsedText': '0123 4567 8901 and 0123-4567-8901'},
        ],
      });
      await http.runWithClient(() async {
        await pumpReceipt(tester);
        await chooseGallery(tester);
        await tester.pumpAndSettle();
      }, () => MockClient((_) async => http.Response(response, 200)));

      expect(find.textContaining('No UPC candidates found.'), findsOneWidget);
    });
  });
}
