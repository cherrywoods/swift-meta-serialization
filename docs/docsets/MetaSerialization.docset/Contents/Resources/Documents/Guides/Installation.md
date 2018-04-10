# Installing MetaSerialization
## [CocoaPods](https://www.cocoapods.org)
Add the following line to your Podfile:
```ruby
pod 'MetaSerialization', '~> 2.0'
```
You can run `pod init` from your command line in the base folder of your project to create a default Podfile. Add the above line after the `target 'YourTarget' do` line.
Run `pod install` to install MetaSerialization and your other dependencies.

You can find more information about CocoaPods at www.cocoapods.org.
## [Carthage](https://github.com/Carthage/Carthage)
Add this line to your Cartfile:
```ogdl
github "cherrywoods/swift-meta-serialization" ~> 2.0
```
If you don't have a Cartfile, create a new one in the base folder of your project and insert only the line above.
Run `carthage update` from your command line. Now you need to add MetaSerialization and your other dependencies to your project. To do this, follow the guide at https://github.com/Carthage/Carthage#adding-frameworks-to-an-application.

You can find more information about Carthage at https://github.com/Carthage/Carthage.
## [Swift Package Manager](https://swift.org/getting-started/#using-the-package-manager)
Add this line to your dependencies in your Package.swift file:
```swift
.Package(url: "https://github.com/cherrywoods/swift-meta-serialization.git", majorVersion: 2)
```
You can create a new Package.swift file by running `swift package init` from command line in the base folder of your project. `swift build` will download MetaSerialization and your further dependencies.

Find out more about the Swift Package Manager at https://swift.org/getting-started/#using-the-package-manager
## [Git Submodules](https://git-scm.com/book/en/v2/Git-Tools-Submodules)
You can also use git submodules to use MetaSerialization in your project.
You can find a good guide about that in the [documentation of the Quick project](https://github.com/Quick/Quick/blob/master/Documentation/en-us/InstallingQuick.md#git-submodules).
