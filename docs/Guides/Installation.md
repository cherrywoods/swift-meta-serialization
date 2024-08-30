# Installing MetaSerialization

## [Swift Package Manager](https://swift.org/getting-started/#using-the-package-manager)
Add this line to your dependencies in your Package.swift file:
```swift
.package(url: "https://github.com/cherrywoods/swift-meta-serialization.git", from: "2.3.0"),
```
You can create a new Package.swift file by running `swift package init` from command line in the base folder of your project. 
Once you have created this file and added MetaSerialization as a dependency, running `swift build` will download MetaSerialization and your further dependencies.

Find out more about the Swift Package Manager at https://www.swift.org/getting-started/cli-swiftpm/

## [Carthage](https://github.com/Carthage/Carthage)
Add this line to your Cartfile:
```ogdl
github "cherrywoods/swift-meta-serialization" ~> 2.3
```
If you don't have a Cartfile, create a new one in the base folder of your project and insert only the line above.
Run `carthage update` from your command line. Now you need to add MetaSerialization and your other dependencies to your project. To do this, follow the guide at https://github.com/Carthage/Carthage#adding-frameworks-to-an-application.

You can find more information about Carthage at https://github.com/Carthage/Carthage.

## [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
You can also use git submodules to use MetaSerialization in your project.
You can find a good guide about that in the [documentation of the Quick project](https://github.com/Quick/Quick/blob/master/Documentation/en-us/InstallingQuick.md#git-submodules).

## [CocoaPods](https://www.cocoapods.org)
MetaSerialization 2.1 is available on CocoaPods. Newer releases (>=2.3) are not available via CocoaPods currently.
To install MetaSerialization 2.1 via CocoaPods, add the following line to your Podfile:
```ruby
pod 'MetaSerialization', '~> 2.0'
```
You can run `pod init` from your command line in the base folder of your project to create a default Podfile. Add the above line after the `target 'YourTarget' do` line.
Run `pod install` to install MetaSerialization and your other dependencies.

You can find more information about CocoaPods at www.cocoapods.org.
