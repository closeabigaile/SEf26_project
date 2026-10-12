import 'package:flutter_test/flutter_test.dart';
import 'package:wolfbite/services/checkout_help_repository.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  const repository = CheckoutHelpRepository();

  test(
    'registered asset provides all examples with immutable evidence',
    () async {
      final examples = await repository.loadExamples();
      expect(examples.map((entry) => entry.id), [
        'M0-M4-01',
        'M0-M4-02',
        'M0-M4-03',
        'M0-M4-F01',
      ]);
      expect(
        () => examples.first.item['package_size']['value'] = 99,
        throwsUnsupportedError,
      );
      expect(examples.first.item.containsKey('expected_help'), isFalse);
    },
  );

  test(
    'sample basket lines are immutable and map back to their own evidence',
    () async {
      for (final example in await repository.loadExamples()) {
        final line = example.toBasketLine();
        expect(line['name'], example.item['name']);
        expect((await repository.forBasketItem(line))?.id, example.id);
        expect(() => line['qty'] = 99, throwsUnsupportedError);
      }
    },
  );

  test(
    'explicit sample linkage requires the exact line identity and evidence quantity',
    () async {
      final sample = (await repository.loadExamples()).first;
      final line = <String, dynamic>{
        'upc': sample.item['id'],
        'qty': sample.item['quantity'],
        'category': sample.item['basket_category'],
        'original_benefit_category': sample.item['original_benefit_category'],
        'checkout_help_source': 'synthetic',
        'checkout_help_scenario_id': sample.id,
      };
      expect((await repository.forBasketItem(line))?.id, sample.id);
      // A single mismatch must prevent borrowing a prepared answer for a
      // different product, paid line, quantity, or unrelated shopper record.
      for (final entry in {
        'upc': 'another-item',
        'qty': 2,
        'category': 'PAID',
        'original_benefit_category': 'MILK',
        'checkout_help_source': 'real',
        'checkout_help_scenario_id': 'missing',
      }.entries) {
        expect(
          await repository.forBasketItem({...line, entry.key: entry.value}),
          isNull,
          reason: entry.key,
        );
      }
    },
  );
}
