# M4 Issue 3: checkout-help frontend

The frontend now supports **basket item → Get checkout help → explanation and
next step → Close → unchanged basket**. All four prepared scenarios are
available in a clearly labeled, read-only sample basket. Ordinary saved basket
items have the same help action and receive fallback when verified evidence
is unavailable.

## Demonstrate the four prepared scenarios

1. Start WolfBite from `Project3` with `flutter run`, sign in, and open **My Basket**.
2. Select the flask icon in the basket app bar. Its tooltip/accessibility label
   is **Try sample checkout help**. This is available even with an empty basket.
3. The **Sample basket** contains four synthetic item cards. It does not insert
   records into your saved basket or replace benefit balances.
4. On the chosen card, select **Get checkout help**. Scroll if necessary.
5. Confirm the dialog identifies that item, describes a possible cause or
   uncertainty, gives an explanation and next step, and explicitly says
   **This is guidance, not an official checkout decision.**
6. Select **Close**. You return to the same sample basket with the same names,
   quantities, and payment categories. Repeat for the other cards.
7. Use the app-bar back action to return to **My Basket**. Your saved items and
   benefit balances remain unchanged.

| Sample basket item | Scenario | Expected help |
| --- | --- | --- |
| Mock cereal - 24 oz | M0-M4-01 | Possible package-size mismatch; compare the label with current benefit information and look for an otherwise eligible 18 oz package. |
| Mock cereal - no available benefit units | M0-M4-02 | Possible cereal balance shortfall; review the balance and quantity intended for coverage. Its payment category is PAID, but its original benefit category is CEREAL. |
| Mock cereal - outdated benefit information | M0-M4-03 | Information may be outdated; verify current information or ask the cashier before retrying. |
| Mock cereal - incomplete information | M0-M4-F01 | Unable to determine the cause; ask the cashier to check the item and consult current benefit information. |

The sample basket uses the **same button, selected-line evidence lookup,
service call, and dialog** as the saved basket. It is not a list of prerecorded
answers. Samples are immutable, and the sample screen has no shopper AppState
or persistence dependency. This intentionally demonstrates the prepared mock
cases without treating sample rules as real benefits.

To demonstrate missing evidence on an ordinary item, open **Get checkout help**
on an item in **My Basket**. The view displays the fallback and selected item;
**Close** returns to the unchanged basket. Ambiguous or conflicting evidence
also uses fallback, covered by tests through the real repository and dialog.

## Frontend structure and teammate integration

Most M4 work is in separate files:

| File | Responsibility |
| --- | --- |
| [checkout_help_button.dart](../../Project3/lib/widgets/checkout_help_button.dart) | Reusable labeled action; selected-item tooltip; prevents duplicate dialogs from rapid taps. |
| [checkout_help_dialog.dart](../../Project3/lib/widgets/checkout_help_dialog.dart) | Selected-item details, evidence loading, fallback/error states, uncertainty notice, scrollable content, and Close. |
| [checkout_help_samples_screen.dart](../../Project3/lib/screens/checkout_help_samples_screen.dart) | Read-only sample basket and four item cards. |
| [checkout_help_repository.dart](../../Project3/lib/services/checkout_help_repository.dart) | Loads prepared evidence and maps an explicitly linked line to its exact scenario. `toBasketLine()` creates an immutable sample card record. |
| [checkout_help_service.dart](../../Project3/lib/services/checkout_help_service.dart) | Issue 2 decision logic; unchanged by this Issue 3 follow-up. |

The shared [basket_screen.dart](../../Project3/lib/screens/basket_screen.dart)
keeps its existing item layout, quantity controls, nutrition section, and
checkout footer. Its M4 integration consists of imports, an optional repository,
the sample-navigation app-bar action, and a `CheckoutHelpButton` inside each
item card. The follow-up replaces the previous inline button code with this
component, so future M4 dialog changes do not require editing the basket screen.

If a teammate rearranges the basket cards, preserve this widget with the
**original selected map object** and the existing AppState:

```dart
CheckoutHelpButton(
  state: appState,
  line: widget.item,
  repository: widget.checkoutHelpRepository,
)
```

Keep each item card's `ObjectKey(item)`, so a removed/reordered line does not
transfer its button state to a different item. The saved-basket button requires
AppState so it can observe changes. Use `.sample` only with the separate,
immutable sample lines; it has no live state to observe.

No new application route, global theme, dependency, or shared state model was
introduced for this follow-up. Standard Material Card, ListTile, TextButton,
Tooltip, and AlertDialog components inherit the existing theme. The earlier M4
work already registered the asset in `pubspec.yaml` and retained original
categories in `app_state.dart`; those edits remain in the working tree but were
not changed again here. Existing nutrition, scanning, signup, and logout logic
was not refactored.

## Evidence and unchanged-state behavior

The repository requires explicit `synthetic` source linkage and matching
scenario ID, UPC/item ID, quantity, payment category, and original benefit
category. Matching an ordinary UPC to a sample is insufficient. The service
receives input evidence only, never the fixture's expected answer.

Opening help does not reload/save state, reset usage, invoke checkout, apply a
suggested action, or change quantity. If the basket or benefit data changes
while the dialog is open or loading, its old diagnosis is replaced with
uncertainty and a request to reopen help. Close, back, and outside-tap dismissal
are supported. Failed evidence loading also leaves a closable fallback.

The dialog is scrollable and retains its Close button on a small screen. Tests
cover 320×568 pixels and text scaled to 200%. No physical-device or screen-reader
session was performed; native Material semantics and item-specific tooltips
are used, but manual accessibility testing remains useful.

## Local validation

The final [Flutter log](test_results/issue3_2026-09-27/full_suite_final.txt)
records the complete suite. The M4 selection contains 139 passing tests,
including 20 widget/state tests and 3 repository tests. All 50 existing M0
baseline tests pass within that run. Overall, 278 tests pass and the same four
pre-existing alternatives/signup/logout tests fail; see the
[earlier review](checkout_help_test_review.md) for those unrelated failures.
[Analysis](test_results/issue3_2026-09-27/analysis.txt) reports no issues in the
M4 frontend/repository files and their changed tests.

New or strengthened checks exercise all four sample cards through their own
help button, correct selected item, exact messages, explicit unofficial-decision
notice, unchanged sample cards and real saved state, immutable sample mapping,
ambiguous/conflicting evidence, and rapid repeated taps.

The first full run's additional large-text test failed because the test looked
for a lazily built item before scrolling. A follow-up reached the item but tapped
before the changed scroll position was rendered. The helper now scrolls to the
item and pumps a frame before tapping; no expected results were weakened.
The [final large-text check](test_results/issue3_2026-09-27/large_text_verified.txt)
and final full run pass that test. Earlier outputs are retained in the same folder.

From `Project3`, with dependencies installed:

```bash
flutter test --no-pub --concurrency=1 --timeout 30s --reporter expanded \
  --file-reporter expanded:../Project2_Work/M4/test_results/issue3_2026-09-27/full_suite_final.txt

dart analyze lib/widgets/checkout_help_button.dart \
  lib/widgets/checkout_help_dialog.dart lib/screens/checkout_help_samples_screen.dart \
  lib/services/checkout_help_repository.dart \
  test/screens/checkout_help_screen_test.dart test/services/checkout_help_repository_test.dart
```

Use fresh filenames for later results. These are local working-tree results;
CI verification and a verified real benefit/product evidence provider remain
separate work. No commit or push was performed.
