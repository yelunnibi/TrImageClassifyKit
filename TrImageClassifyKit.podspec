#
# Be sure to run `pod lib lint TrImageClassifyKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'TrImageClassifyKit'
  s.version          = '0.1.2'
  s.summary          = 'TrImageClassifyKit can classify images.'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
TODO: Add long description of the pod here.
                       DESC

  s.homepage         = 'https://github.com/yelunnibi/TrImageClassifyKit.git'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.version          = '0.1.1'
  s.author           = { 'dc-zy' => 'dc-zy@zy.com' }
  s.source           = { :git => 'https://github.com/yelunnibi/TrImageClassifyKit.git', :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'
  
  s.ios.deployment_target = '15.0'

  s.source_files = 'TrImageClassifyKit/Classes/**/*', 'TrImageClassifyKit/include/*.h'
  
  s.ios.vendored_library = 'TrImageClassifyKit/lib/libpaddle_api_light_bundled.a'
  
  s.static_framework = true
    
  s.ios.public_header_files = 'TrImageClassifyKit/Classes/TrImageClassifyer.h'
  s.resource_bundles = {
    'TrImageClassifyKit' => ['TrImageClassifyKit/assets/*']
  }
  
#  s.pod_target_xcconfig = {
#    'OTHER_CPLUSPLUSFLAGS' => '-mfloat-abi=hard',
#    'OTHER_CFLAGS' => '-mfloat-abi=hard'
#  }
  
#  s.pod_target_xcconfig = {
#    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'arm64',
#    'EXCLUDED_ARCHS[sdk=iphonesimulator*]' => 'x86_64',
#    'OTHER_CPLUSPLUSFLAGS' => '-mfloat-abi=hard',
#    'OTHER_CFLAGS' => '-mfloat-abi=hard'
#  }
  
  s.dependency 'OpenCV2'
end
