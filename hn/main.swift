import UIKit

UIApplicationMain(
  CommandLine.argc,
  CommandLine.unsafeArgv,
  nil,
  NSClassFromString("XCTestCase") == nil ? NSStringFromClass(AppDelegate.self) : nil
)
