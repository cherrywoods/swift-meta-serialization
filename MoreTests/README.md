# Target: MoreTests
This test target exists to test some errors that aren't testable in the debug build configuration, because they are guarded by assertionFailures.

Because this target's build configuration is set to release, it is possible to check for these errors
