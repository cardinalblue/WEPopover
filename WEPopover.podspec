Pod::Spec.new do |s|
  s.name     = 'WEPopover'
<<<<<<< HEAD
  s.version  = '0.1.1-cb'
=======
  s.version  = '0.1.2-cb'
>>>>>>> CB
  s.license  = 'MIT'
  s.summary  = 'Generic popover implementation for iOS with same API as the UIPopoverController.'
  s.description  =  'Generic popover implementation for iOS with same API as the UIPopoverController for the iPad, but configurable with custom background and available for iPhone as well.'
  s.homepage = 'https://github.com/werner77/WEPopover'
  s.author   = { 'Werner Altewischer' => 'http://www.werner-it.com/' }
  s.source   = { :git => 'https://github.com/cardinalblue/WEPopover.git', :tag => s.version.to_s }
  s.platform = :ios
  s.ios.deployment_target = '7.0'
  s.frameworks   = 'Foundation','UIKit'
  s.requires_arc = false
  s.source_files = 'Classes/Popover/**/*.{c,m,h}'  
  s.resources = 'Resources/Popover/**/*.*'
end
