@import XCTest;
@import integration_test;

// Drives the Dart integration_test suite through the native XCTest runner. This
// is what lets `xcodebuild test` run integration_test/*.dart: the macro expands
// to an XCTestCase that hosts the Runner app in-process and reports each Dart
// test as an XCTest result — no Flutter-tool VM-service (mDNS) discovery, which
// is what made `flutter test -d <sim>` hang on CI simulators.
INTEGRATION_TEST_IOS_RUNNER(RunnerTests)
