# Test Assertion Guarded Features
The tests in this directory test features that are normaly guarded by assertions.
These tests exist to test the fallback the baviour that MetaSerialization provides when assertions are disabled (for example, in release mode).
If the tests are run in debug mode (standard for testing), all tests in this directory are skipped.
To run the tests, execute
```bash
swift test -c release
```
