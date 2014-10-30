Pod::Spec.new do |s|
  s.name             = "MLFlyOverMenu"
  s.version          = "0.1.2"
  s.summary          = "A lightweight and convenient way of presenting a view controller inspired by UIPopoverController and SWRevealViewController."
  s.description      = "A lightweight and convenient way of presenting a view controller inspired by UIPopoverController and SWRevealViewController. Highly customizable. Full initialization and customization from a storyboard."
  s.homepage         = "https://github.com/MUSTLaboratory/MLFlyOverMenu"
  s.screenshots     = "https://camo.githubusercontent.com/8afab5f2c8c3c2788ba56d146b2c207706476203/68747470733a2f2f6269746275636b65742e6f72672f7265706f2f6f726e6535412f696d616765732f333631383437373336302d6d6c666c796f7665725f64656d6f2e676966"
  s.license          = 'MIT'
  s.author           = { "MUSTLab Developer" => "hello@mustlab.ru" }
  s.source           = { :git => "https://github.com/MUSTLaboratory/MLFlyOverMenu.git", :tag => '0.1.2' }

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'MLFlyOverMenu' => ['Pod/Assets/*.png']
  }

  s.public_header_files = 'Pod/Classes/**/*.h'
  s.frameworks = 'UIKit'
end
