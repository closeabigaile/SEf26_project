// Runs the shopper journeys and M2 scan-to-swap tests on a real device or
// desktop build (real rendering, real timers) instead of the test VM.
// Data stays in a fake Firestore, so this never touches live Firebase.
//
//   flutter test integration_test/journeys_device_test.dart -d windows
import 'package:integration_test/integration_test.dart';

import '../test/e2e/m2_scan_to_swap_test.dart' as m2_scan_to_swap;
import '../test/e2e/shopping_journeys_e2e_test.dart' as journeys;

void main() {
  IntegrationTestWidgetsFlutterBinding.ensureInitialized();
  journeys.main();
  m2_scan_to_swap.main();
}
