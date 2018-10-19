#
#  Be sure to run `pod spec lint CovertOps.podspec' to ensure this is a
#  valid spec and to remove all comments including this before submitting the spec.
#
#  To learn more about Podspec attributes see http://docs.cocoapods.org/specification.html
#  To see working Podspecs in the CocoaPods repo see https://github.com/CocoaPods/Specs/
#

Pod::Spec.new do |s|
  s.name             = 'CovertOps'
  s.version          = '0.1.2'
  s.summary          = 'A robust application framework built upon Operation and OperationQueue.'
  s.framework        = 'CoreData'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
An open source framework using operations from Apple's Foundation framework for achieving precise timing, exclusivity, thread safety, asynchronous behavior and dependency management.
                       DESC

  s.homepage         = 'https://github.com/patricklynch/CovertOps'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'patricklynch' => 'pdlynch@gmail.com' }
  s.source           = { :git => 'https://github.com/patricklynch/CovertOps.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.ios.deployment_target = '8.0'
  s.swift_version = '4.2'

  s.source_files = 'CovertOps/Classes/**/*'
  
  # s.resource_bundles = {
  #   'CovertOps' => ['CovertOps/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
