# Active-suite test results: 2026-08-31

## Result

- Scope: every test discovered under `Project3/test`
- Flutter: 3.47.2 stable
- Command: `flutter test --concurrency=1 --coverage`
- Executed: 123
- Passed: 112 (91.1%)
- Failed: 11 (8.9%)
- Process cleanup: 0 Flutter/Dart processes remained after the run

The command exited with status 1 because tests failed. This is a record of the
observed result, not a claim that the suite passes.

## Failure classification

Four failures expose application/requirement mismatches already identified by
the use-case audit:

- UC1: a profile-save exception is not handled as the test requires;
- UC3: a sign-out failure does not preserve the required signed-in state;
- UC7: a blank category does not produce the required empty result; and
- UC9: a rejected alternative does not follow the required rejection path.

Seven widget failures reported the same SDK renderer error:

`Asset 'shaders/ink_sparkle.frag' manifest could not be decoded: Runtime stages buffer failed verification.`

Those failures occurred when Material ink effects were exercised. They are
environment/SDK-renderer failures rather than failed business assertions. The
new UC17 widget harness uses `NoSplash` and passed, supporting that diagnosis.

## Safety controls

- No emulator, browser, desktop application, or device was launched.
- Tests ran with one worker to minimize concurrent engine activity.
- Flutter was invoked directly through its bundled Dart tool snapshot after
  the Windows batch wrapper stalled before launching Flutter.
- All Flutter/Dart processes were terminated immediately after completion.
