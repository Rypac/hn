# hn

A simple Hacker News client for iOS.

## Dependencies

### Required

- Xcode
- Carthage

### Optional

- SwiftLint
- SwiftFormat

## Building

Fetch and build all dependencies:

    carthage bootstrap

## Developing

### Dependencies

To update all dependencies:

    carthage update

To update a single dependency:

    carthage update DEPENDENCY

### Hygiene

To lint the project:

    swiftlint lint

To autocorrect lint errors:

    swiftlint autocorrect

To format source files:

    swiftformat .
