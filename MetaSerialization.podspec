#
#  Be sure to run `pod spec lint MetaSerialization.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#

Pod::Spec.new do |s|

  s.name         = "MetaSerialization"
  s.version      = "2.0"
  s.summary      = "A framework to simplify the creation of new serialisation-frameworks for the swift standard library serialization environment"

  s.homepage     = "https://github.com/cherrywoods/swift-meta-serialization"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #
  #  Licensing your code is important. See http://choosealicense.com for more info.
  #  CocoaPods will detect a license file if there is a named LICENSE*
  #  Popular ones are 'MIT', 'BSD' and 'Apache License, Version 2.0'.
  #
  s.license      = { :type => "Unlicense", :file => "LICENSE" }
  
  s.author    = "cherrywoods"
   
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  s.watchos.deployment_target = "2.0"
  s.tvos.deployment_target = "9.0"
  s.source       = { :git => "https://github.com/cherrywoods/swift-meta-serialization.git", :tag => 'v2.0' }

  s.source_files  = "Sources/**/*.swift"

end
