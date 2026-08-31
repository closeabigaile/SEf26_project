import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:go_router/go_router.dart';
import 'package:mockito/mockito.dart';
import 'package:provider/provider.dart';
import 'package:wolfbite/screens/balances_screen.dart';
import 'package:wolfbite/screens/login_screen.dart';
import 'package:wolfbite/screens/scan_screen.dart';
import 'package:wolfbite/screens/signup_page.dart';
import 'package:wolfbite/state/app_state.dart';

// These generated mocks already belong to WolfBite. Reusing them keeps this
// suite offline without editing or regenerating inherited project files.
import '../mocks/mocks.mocks.dart';

// This file contains 25 independent tests for UC1 through UC5.
// Widget tests exercise real WolfBite screens with injected mock dependencies;
// No test contacts Firebase or changes inherited code.
void main() {
  // group labels related tests in Flutter's output. setUp below creates fresh
  // mocks before each test so no call history leaks between cases.
  group('UC1 — Create account', () {
    late MockFirebaseAuth auth;
    late MockFirebaseFirestore db;
    late MockGoRouter router;
    late MockUserCredential credential;
    late MockUser user;
    late MockCollectionReference<Map<String, dynamic>> users;
    late MockDocumentReference<Map<String, dynamic>> profile;

    setUp(() {
      auth = MockFirebaseAuth();
      db = MockFirebaseFirestore();
      router = MockGoRouter();
      credential = MockUserCredential();
      user = MockUser();
      users = MockCollectionReference<Map<String, dynamic>>();
      profile = MockDocumentReference<Map<String, dynamic>>();

      // when(...).thenReturn(...) gives a synchronous mock getter a known
      // value. thenAnswer is used below because Firebase methods return Future
      // objects that complete asynchronously.
      when(user.uid).thenReturn('test-user-123');
      when(credential.user).thenReturn(user);
      when(
        auth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenAnswer((_) async => credential);
      when(auth.signOut()).thenAnswer((_) async {});
      when(db.collection('users')).thenReturn(users);
      when(users.doc(any)).thenReturn(profile);
      when(profile.set(any)).thenAnswer((_) async {});
    });

    // pumpWidget builds the real screen in the test environment while
    // dependency injection supplies safe mock services.
    Future<void> pumpSignup(WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: router,
            child: SignupPage(auth: auth, firestore: db),
          ),
        ),
      );
    }

    Future<void> validForm(WidgetTester tester) async {
      // find.byType locates the real form fields in display order. enterText
      // behaves like user input while remaining deterministic in a widget test.
      await tester.enterText(find.byType(TextFormField).at(0), 'Abigail Test');
      await tester.enterText(
        find.byType(TextFormField).at(1),
        'abigail.test@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(2), 'password123');
      await tester.enterText(
        find.byType(TextFormField).at(3),
        '123 Test Street',
      );
    }

    testWidgets('test_uc01_valid_registration_creates_account_and_profile', (
      WidgetTester tester,
    ) async {
      // ARRANGE: build the screen and provide valid shopper information.
      await pumpSignup(tester);
      await validForm(tester);

      // ACT: submit the real form.
      await tester.tap(find.text('Sign Up'));
      // pumpAndSettle waits for async stubs and resulting widget rebuilds.
      await tester.pumpAndSettle();

      // ASSERT: verify checks service interactions and called(1) prevents an
      // accidental duplicate account request from passing unnoticed.
      verify(
        auth.createUserWithEmailAndPassword(
          email: 'abigail.test@example.com',
          password: 'password123',
        ),
      ).called(1);
      verify(users.doc('test-user-123')).called(1);
      verify(
        profile.set(
          argThat(
            isA<Map<String, dynamic>>()
                .having((p) => p['name'], 'name', 'Abigail Test')
                .having((p) => p['email'], 'email', 'abigail.test@example.com')
                .having((p) => p['address'], 'address', '123 Test Street'),
          ),
        ),
      ).called(1);
      verify(auth.signOut()).called(1);
      verify(router.go('/login')).called(1);
    });

    testWidgets('test_uc01_blank_fields_prevent_submission', (
      WidgetTester tester,
    ) async {
      // ARRANGE/ACT: build a clean form and submit without entering data.
      await pumpSignup(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      // ASSERT: visible messages prove validation ran; verifyNever proves the
      // invalid form did not reach authentication or persistence services.
      expect(find.text('Enter your name'), findsOneWidget);
      expect(find.text('Enter a valid email'), findsOneWidget);
      expect(find.text('Use at least 6 characters'), findsOneWidget);
      expect(find.text('Enter your address'), findsOneWidget);
      verifyNever(
        auth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
      verifyNever(profile.set(any));
    });

    testWidgets('test_uc01_invalid_email_prevents_submission', (
      WidgetTester tester,
    ) async {
      // Begin with an otherwise valid form so email is the sole failure reason.
      await pumpSignup(tester);
      await validForm(tester);
      await tester.enterText(find.byType(TextFormField).at(1), 'invalid-email');
      await tester.tap(find.text('Sign Up'));
      await tester.pump();

      expect(find.text('Enter a valid email'), findsOneWidget);
      verifyNever(
        auth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
      verifyNever(profile.set(any));
    });

    testWidgets('test_uc01_rejected_registration_displays_error', (
      WidgetTester tester,
    ) async {
      // thenThrow simulates a realistic Firebase rejection without creating a
      // real account or requiring network access.
      when(
        auth.createUserWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'email-already-in-use',
          message: 'Email already in use',
        ),
      );

      await pumpSignup(tester);
      await validForm(tester);
      await tester.tap(find.text('Sign Up'));
      await tester.pumpAndSettle();

      expect(find.text('Email already in use'), findsOneWidget);
      expect(find.text('Create account'), findsOneWidget);
      verifyNever(profile.set(any));
      verifyNever(auth.signOut());
      verifyNever(router.go('/login'));
    });

    testWidgets(
      'test_uc01_profile_save_failure_does_not_complete_registration_flow',
      (WidgetTester tester) async {
        // Authentication succeeds, then the distinct Firestore operation
        // fails. This separates partial registration from auth rejection.
        when(profile.set(any)).thenThrow(
          FirebaseException(
            plugin: 'cloud_firestore',
            message: 'Profile save failed',
          ),
        );
        await pumpSignup(tester);
        await validForm(tester);
        await tester.tap(find.text('Sign Up'));
        await tester.pump();

        // The inherited screen does not catch this exception. Flutter reports
        // that uncaught error as a failure; the remaining assertions preserve
        // UC1's predetermined expectation that an error message should appear.
        verify(
          auth.createUserWithEmailAndPassword(
            email: 'abigail.test@example.com',
            password: 'password123',
          ),
        ).called(1);
        verify(profile.set(any)).called(1);
        expect(find.byType(SnackBar), findsOneWidget);
        verifyNever(auth.signOut());
        verifyNever(router.go('/login'));
      },
    );
  });

  group('UC2 — Sign in', () {
    late MockFirebaseAuth auth;
    late MockGoRouter router;

    setUp(() {
      auth = MockFirebaseAuth();
      router = MockGoRouter();
    });

    Future<void> pumpLogin(WidgetTester tester) async {
      // The real LoginScreen receives mock auth and navigation dependencies,
      // making the screen behavior testable without a real Firebase session.
      await tester.pumpWidget(
        MaterialApp(
          home: InheritedGoRouter(
            goRouter: router,
            child: LoginScreen(auth: auth),
          ),
        ),
      );
    }

    Future<void> validLogin(WidgetTester tester) async {
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'shopper@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
    }

    testWidgets(
      'test_uc02_valid_credentials_authenticate_and_open_shopping_features',
      (WidgetTester tester) async {
        // ARRANGE: make the asynchronous Firebase sign-in Future succeed.
        when(
          auth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) async => MockUserCredential());
        await pumpLogin(tester);
        await validLogin(tester);
        // ACT: submit the credentials and wait for navigation-related rebuilds.
        await tester.tap(find.text('Sign In'));
        await tester.pumpAndSettle();

        // ASSERT: check both the exact backend interaction and protected route.
        verify(
          auth.signInWithEmailAndPassword(
            email: 'shopper@example.com',
            password: 'password123',
          ),
        ).called(1);
        verify(router.go('/scan')).called(1);
      },
    );

    testWidgets('test_uc02_invalid_email_prevents_authentication', (
      WidgetTester tester,
    ) async {
      // Only the email is invalid, isolating extension 2a from password rules.
      await pumpLogin(tester);
      await tester.enterText(find.byType(TextFormField).at(0), 'invalid-email');
      await tester.enterText(find.byType(TextFormField).at(1), 'password123');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Invalid email'), findsOneWidget);
      verifyNever(
        auth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
      verifyNever(router.go('/scan'));
    });

    testWidgets('test_uc02_short_password_prevents_authentication', (
      WidgetTester tester,
    ) async {
      // Five characters tests the boundary immediately below the six-character
      // minimum instead of using an obviously empty password.
      await pumpLogin(tester);
      await tester.enterText(
        find.byType(TextFormField).at(0),
        'shopper@example.com',
      );
      await tester.enterText(find.byType(TextFormField).at(1), '12345');
      await tester.tap(find.text('Sign In'));
      await tester.pump();
      expect(find.text('Min 6 chars'), findsOneWidget);
      verifyNever(
        auth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      );
      verifyNever(router.go('/scan'));
    });

    testWidgets('test_uc02_rejected_credentials_leave_shopper_signed_out', (
      WidgetTester tester,
    ) async {
      // Valid-looking input reaches Firebase, which then rejects the account.
      when(
        auth.signInWithEmailAndPassword(
          email: anyNamed('email'),
          password: anyNamed('password'),
        ),
      ).thenThrow(
        FirebaseAuthException(
          code: 'invalid-credential',
          message: 'Invalid credentials',
        ),
      );
      await pumpLogin(tester);
      await validLogin(tester);
      await tester.tap(find.text('Sign In'));
      await tester.pumpAndSettle();
      expect(find.text('Invalid credentials'), findsOneWidget);
      expect(find.text('Welcome back'), findsOneWidget);
      verifyNever(router.go('/scan'));
    });

    testWidgets(
      'test_uc02_second_submission_is_blocked_while_sign_in_is_pending',
      (WidgetTester tester) async {
        // Completer provides a Future that remains pending until this test
        // explicitly completes it, allowing the loading state to be inspected.
        final pending = Completer<UserCredential>();
        when(
          auth.signInWithEmailAndPassword(
            email: anyNamed('email'),
            password: anyNamed('password'),
          ),
        ).thenAnswer((_) => pending.future);
        await pumpLogin(tester);
        await validLogin(tester);
        await tester.tap(find.text('Sign In'));
        await tester.pump();

        // While the Future is pending, the UI must expose loading state and
        // remove the actionable button. The single verify call proves that a
        // duplicate backend request was not started.
        expect(find.byType(CircularProgressIndicator), findsOneWidget);
        expect(find.text('Sign In'), findsNothing);
        verify(
          auth.signInWithEmailAndPassword(
            email: 'shopper@example.com',
            password: 'password123',
          ),
        ).called(1);
        // Complete the controlled Future so no asynchronous work leaks into
        // the next test.
        pending.complete(MockUserCredential());
        await tester.pumpAndSettle();
      },
    );
  });

  group('UC3 — Sign out', () {
    late MockFirebaseAuth auth;
    late MockGoRouter router;
    late MockAppState state;

    setUp(() {
      auth = MockFirebaseAuth();
      router = MockGoRouter();
      state = MockAppState();
      when(state.balancesLoaded).thenReturn(true);
      when(state.balances).thenReturn({});
    });

    Future<void> pumpBalances(WidgetTester tester) async {
      // Provider supplies the AppState dependency read by BalancesScreen.
      // InheritedGoRouter supplies a mock navigation target for verification.
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: router,
              child: BalancesScreen(auth: auth),
            ),
          ),
        ),
      );
    }

    testWidgets('test_uc03_logout_action_requests_authentication_sign_out', (
      WidgetTester tester,
    ) async {
      // The test interacts with the visible logout icon rather than calling a
      // private sign-out method, preserving the user's actual trigger.
      when(auth.signOut()).thenAnswer((_) async {});
      await pumpBalances(tester);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      verify(auth.signOut()).called(1);
    });

    testWidgets('test_uc03_successful_sign_out_returns_shopper_to_login', (
      WidgetTester tester,
    ) async {
      when(auth.signOut()).thenAnswer((_) async {});
      await pumpBalances(tester);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pumpAndSettle();
      verify(router.go('/login')).called(1);
    });

    test(
      'test_uc03_successful_sign_out_removes_account_specific_local_state',
      () async {
        // This is a state test rather than a widget test: UC3's cleanup outcome
        // is represented by the production AppState object, not visible text.
        final shopper = MockUser();
        when(shopper.uid).thenReturn('shopper-a');
        final store = _MockStateStore({
          'balances': {
            'MILK': {'allowed': 3, 'used': 1},
          },
          'basket': [
            {'upc': '111', 'name': 'Milk', 'category': 'MILK', 'qty': 1},
          ],
          'updatedAt': Timestamp.now(),
        });
        final appState = AppState(db: store.db);
        appState.updateUser(shopper);
        await _waitForLoaded(appState);
        expect(appState.basket, isNotEmpty);

        // The production provider calls updateUser(null) after auth signs out.
        appState.updateUser(null);
        expect(appState.basket, isEmpty);
        expect(appState.balances, isEmpty);
        expect(appState.balancesLoaded, isFalse);
      },
    );

    testWidgets('test_uc03_sign_out_failure_leaves_shopper_signed_in', (
      WidgetTester tester,
    ) async {
      // The inherited implementation does not catch this Future error. The
      // framework therefore records the test as a genuine failure while the
      // navigation assertion confirms it did not falsely reach login.
      when(auth.signOut()).thenThrow(
        FirebaseAuthException(code: 'network-error', message: 'Offline'),
      );
      await pumpBalances(tester);
      await tester.tap(find.byIcon(Icons.logout));
      await tester.pump();
      expect(find.text('WIC Benefits'), findsOneWidget);
      verifyNever(router.go('/login'));
    });

    testWidgets('test_uc03_existing_signed_out_state_still_returns_to_login', (
      WidgetTester tester,
    ) async {
      final appState = AppState(db: _MockStateStore(null).db);
      appState.updateUser(null);
      // The full router hard-codes FirebaseAuth.instance. These existing seams
      // test the closest valid level without altering WolfBite production code.
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: appState,
          child: MaterialApp(home: LoginScreen(auth: auth)),
        ),
      );
      expect(find.text('Welcome back'), findsOneWidget);
      expect(find.text('Sign In'), findsOneWidget);
      expect(find.text('Scan Product'), findsNothing);
      expect(appState.basket, isEmpty);
    });
  });

  group('UC4 — Resume shopping session', () {
    late _MockStateStore store;
    late MockUser user;
    late AppState state;

    setUp(() {
      user = MockUser();
      when(user.uid).thenReturn('session-user');
      store = _MockStateStore(null);
      state = AppState(db: store.db);
    });

    // UC4 uses test() rather than testWidgets() because restoration is
    // observable directly through AppState and does not require a screen.

    test(
      'test_uc04_current_month_saved_session_restores_basket_and_balances',
      () async {
        // ARRANGE: provide compact current-month Firestore data.
        store.setData({
          'balances': {
            'MILK': {'allowed': 3, 'used': 2},
          },
          'basket': [
            {
              'upc': '001',
              'name': 'Whole Milk',
              'category': 'MILK',
              'qty': 2,
              'nutrition': {'calories': 150.0, 'protein': 8.0},
            },
          ],
          'updatedAt': Timestamp.now(),
        });
        state = AppState(db: store.db);
        // ACT: an authenticated user causes AppState to load saved data.
        state.updateUser(user);
        await _waitForLoaded(state);
        // ASSERT: check balance, basket, quantity, product, and nutrition—not
        // merely that loading avoided an exception.
        expect(state.balances['MILK']?['used'], 2);
        expect(state.basket, hasLength(1));
        expect(state.basket.single['qty'], 2);
        expect(state.basket.single['name'], 'Whole Milk');
        expect(state.basket.single['nutrition']['protein'], 8.0);
      },
    );

    test('test_uc04_missing_saved_session_starts_empty', () async {
      // A null document simulates a first-time shopper with no saved session.
      state.updateUser(user);
      await _waitForLoaded(state);
      expect(state.basket, isEmpty);
      expect(state.balances, isEmpty);
      verify(store.document.set(any, any)).called(1);
    });

    test(
      'test_uc04_partial_saved_session_uses_empty_values_for_missing_sections',
      () async {
        // The document intentionally omits basket data so the test can prove
        // that present balances survive while the missing section is empty.
        store.setData({
          'balances': {
            'milk': {'allowed': 3, 'used': 1},
          },
          'updatedAt': Timestamp.now(),
        });
        state = AppState(db: store.db);
        state.updateUser(user);
        await _waitForLoaded(state);
        expect(state.balances['MILK']?['used'], 1);
        expect(state.basket, isEmpty);
      },
    );

    test('test_uc04_missing_nutrition_uses_zero_values', () async {
      // The saved product intentionally has no nutrition map. Assertions below
      // verify the numeric defaults required by UC4 extension 3b.
      store.setData({
        'basket': [
          {'upc': '002', 'name': 'Cereal', 'category': 'CEREAL', 'qty': 1},
        ],
        'updatedAt': Timestamp.now(),
      });
      state = AppState(db: store.db);
      state.updateUser(user);
      await _waitForLoaded(state);
      final nutrition =
          state.basket.single['nutrition'] as Map<String, dynamic>;
      expect(nutrition['calories'], 0.0);
      expect(nutrition['totalFat'], 0.0);
      expect(nutrition['sodium'], 0.0);
      expect(nutrition['sugar'], 0.0);
      expect(nutrition['protein'], 0.0);
    });

    test(
      'test_uc04_previous_month_session_resets_basket_and_used_benefits',
      () async {
        // A prior year guarantees an old period even when this test runs in a
        // different calendar month, avoiding a date-dependent flaky result.
        final now = DateTime.now();
        final previousYear = DateTime(now.year - 1, now.month, 1);
        store.setData({
          'balances': {
            'MILK': {'allowed': 3, 'used': 2},
            'CEREAL': {'allowed': 2, 'used': 1},
          },
          'basket': [
            {'upc': '003', 'name': 'Old Milk', 'category': 'MILK', 'qty': 2},
          ],
          'updatedAt': Timestamp.fromDate(previousYear),
        });
        state = AppState(db: store.db);
        state.updateUser(user);
        await _waitForLoaded(state);
        expect(state.basket, isEmpty);
        expect(state.balances['MILK']?['used'], 0);
        expect(state.balances['CEREAL']?['used'], 0);
      },
    );
  });

  group('UC5 — Identify product', () {
    late MockAplService products;
    late MockAppState state;
    late MockFirebaseAuth auth;
    late MockGoRouter router;

    setUp(() {
      products = MockAplService();
      state = MockAppState();
      auth = MockFirebaseAuth();
      router = MockGoRouter();
      when(state.canAdd(any)).thenReturn(true);
      when(state.basket).thenReturn([]);
    });

    Future<void> pumpScan(WidgetTester tester) async {
      // A desktop-sized test surface selects ScanScreen's manual UPC interface
      // and avoids requiring a physical camera or barcode scanner.
      tester.view.physicalSize = const Size(1200, 800);
      tester.view.devicePixelRatio = 1;
      // addTearDown restores global view settings after every test so this
      // group cannot influence later widget tests.
      addTearDown(() {
        tester.view.resetPhysicalSize();
        tester.view.resetDevicePixelRatio();
      });
      await tester.pumpWidget(
        ChangeNotifierProvider<AppState>.value(
          value: state,
          child: MaterialApp(
            home: InheritedGoRouter(
              goRouter: router,
              child: ScanScreen(aplService: products, auth: auth),
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
    }

    testWidgets('test_uc05_matching_upc_displays_product_information', (
      WidgetTester tester,
    ) async {
      // thenAnswer returns a completed Future containing controlled product
      // data; no external product database is contacted.
      when(products.findByUpc('12345')).thenAnswer(
        (_) async => {
          'upc': '12345',
          'name': 'Test Cereal',
          'category': 'CEREAL',
          'calories': 100.0,
          'protein': 3.0,
        },
      );
      await pumpScan(tester);
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      // Verify identification separately from basket addition. Merely finding
      // a product must not change shopping state.
      verify(products.findByUpc('12345')).called(1);
      expect(find.text('Test Cereal'), findsOneWidget);
      expect(find.text('Category: CEREAL'), findsOneWidget);
      expect(find.text('UPC: 12345'), findsOneWidget);
      expect(state.basket, isEmpty);
      verifyNever(
        state.addItem(
          upc: anyNamed('upc'),
          name: anyNamed('name'),
          category: anyNamed('category'),
          nutrition: anyNamed('nutrition'),
        ),
      );
    });

    testWidgets('test_uc05_empty_manual_entry_performs_no_lookup', (
      WidgetTester tester,
    ) async {
      // Submit the untouched field and prove the early-return path avoids the
      // service entirely.
      await pumpScan(tester);
      await tester.tap(find.text('Check'));
      await tester.pump();
      verifyNever(products.findByUpc(any));
      expect(find.text('Test Cereal'), findsNothing);
      expect(state.basket, isEmpty);
    });

    testWidgets('test_uc05_unknown_upc_reports_not_found_and_clears_result', (
      WidgetTester tester,
    ) async {
      // First establish a real visible result. Without this initial lookup, a
      // test could not prove that the unknown-code path clears stale state.
      when(products.findByUpc('12345')).thenAnswer(
        (_) async => {
          'upc': '12345',
          'name': 'Previous Product',
          // Blank category avoids starting the unrelated healthier-options
          // lookup and its SnackBar, keeping this test focused on stale
          // product clearing and the not-found message.
          'category': '',
        },
      );
      when(products.findByUpc('99999')).thenAnswer((_) async => null);
      await pumpScan(tester);
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('Previous Product'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '99999');
      await tester.tap(find.text('Check'));
      // One pump processes the lookup result while its temporary SnackBar is
      // still visible; pumpAndSettle would advance until that message expires.
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 100));
      verify(products.findByUpc('99999')).called(1);
      expect(find.text('UPC 99999 not found in APL'), findsOneWidget);
      expect(find.text('Previous Product'), findsNothing);
      expect(state.basket, isEmpty);
    });

    testWidgets('test_uc05_lookup_failure_displays_error', (
      WidgetTester tester,
    ) async {
      // A thrown service exception is distinct from a successful lookup that
      // returns null (the unknown-UPC case above).
      when(
        products.findByUpc('12345'),
      ).thenThrow(Exception('Lookup unavailable'));
      await pumpScan(tester);
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Check'));
      await tester.pumpAndSettle();
      expect(find.text('Error: Exception: Lookup unavailable'), findsOneWidget);
      expect(find.text('Test Cereal'), findsNothing);
      expect(state.basket, isEmpty);
    });

    testWidgets('test_uc05_second_lookup_is_ignored_while_first_is_pending', (
      WidgetTester tester,
    ) async {
      // Keep the first lookup Future pending, press Check again, and verify the
      // screen's busy guard prevents a second call.
      final pending = Completer<Map<String, dynamic>?>();
      when(products.findByUpc('12345')).thenAnswer((_) => pending.future);
      await pumpScan(tester);
      await tester.enterText(find.byType(TextField), '12345');
      await tester.tap(find.text('Check'));
      await tester.pump();
      await tester.tap(find.text('Check'));
      await tester.pump();
      verify(products.findByUpc('12345')).called(1);
      pending.complete({
        'upc': '12345',
        'name': 'Test Product',
        'category': 'CEREAL',
      });
      await tester.pumpAndSettle();
    });
  });
}

// updateUser starts Firestore loading in the background. Waiting for the
// public flag is deterministic and avoids relying on one arbitrary delay.
Future<void> _waitForLoaded(AppState state) async {
  for (var attempt = 0; attempt < 100 && !state.balancesLoaded; attempt++) {
    await Future<void>.delayed(const Duration(milliseconds: 1));
  }
  expect(state.balancesLoaded, isTrue);
}

// A small local Mockito harness replaces fake_cloud_firestore, whose inherited
// package version is incompatible with the currently resolved Firestore SDK.
// It implements only the collection/document operations AppState actually
// uses, and it exists solely inside Abigail's new test file.
class _MockDocumentSnapshot extends Mock
    implements DocumentSnapshot<Map<String, dynamic>> {}

class _MockStateStore {
  _MockStateStore(Map<String, dynamic>? initialData) {
    // These stubs reproduce only AppState's production call chain:
    // db.collection('users').doc(uid).get()/set(). No network is involved.
    when(db.collection('users')).thenReturn(collection);
    when(collection.doc(any)).thenReturn(document);
    when(document.get()).thenAnswer((_) async => snapshot);
    when(document.set(any, any)).thenAnswer((_) async {});
    setData(initialData);
  }

  final MockFirebaseFirestore db = MockFirebaseFirestore();
  final MockCollectionReference<Map<String, dynamic>> collection =
      MockCollectionReference<Map<String, dynamic>>();
  final MockDocumentReference<Map<String, dynamic>> document =
      MockDocumentReference<Map<String, dynamic>>();
  final _MockDocumentSnapshot snapshot = _MockDocumentSnapshot();

  void setData(Map<String, dynamic>? data) {
    // Restubbing data() lets each UC4 test describe a different saved session
    // while retaining fresh mocks from the surrounding setUp call.
    when(snapshot.data()).thenReturn(data);
  }
}
