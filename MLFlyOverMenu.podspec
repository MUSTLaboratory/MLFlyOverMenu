Pod::Spec.new do |s|
  s.name             = "MLFlyOverMenu"
  s.version          = "0.1.0"
  s.summary          = "A lightweight and convenient way of presenting a view controller inspired by UIPopoverController and SWRevealViewController. Highly customizable. Full storyboard support."
  s.description      = ""
  s.homepage         = "http://bitbucket.org/mustlab_opensource/mlflyovermenu"
  # s.screenshots     = "www.example.com/screenshots_1", "www.example.com/screenshots_2"
  s.license          = 'MIT'
  s.author           = { "MUSTLab" => "hello@mustlab.ru" }
  s.source           = { :git => "https://github.com/<GITHUB_USERNAME>/MLFlyOverMenu.git", :tag => s.version.to_s }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.platform     = :ios, '6.0'
  s.requires_arc = true

  s.source_files = 'Pod/Classes'
  s.resource_bundles = {
    'MLFlyOverMenu' => ['Pod/Assets/*.png']
  }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
end
