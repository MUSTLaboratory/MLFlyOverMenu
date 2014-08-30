Pod::Spec.new do |s|
  s.name             = "MLFlyOverMenu"
  s.version          = "0.1.0"
  s.summary          = "A lightweight and convenient way of presenting a view controller inspired by UIPopoverController and SWRevealViewController."
  s.description      = "A lightweight and convenient way of presenting a view controller inspired by UIPopoverController and SWRevealViewController. Highly customizable. Full initialization and customization from a storyboard."
  s.homepage         = "http://mustlab.ru"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "MUSTLab Developer" => "hello@mustlab.ru" }
  s.source           = { :git => "https://bitbucket.org/mustlab_opensource/mlflyovermenu.git", :tag => '0.1.0' }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'MLFlyOverMenu' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
