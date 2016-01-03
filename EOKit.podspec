# vim: set ft=ruby
Pod::Spec.new do |s|

  # ―――  Spec Metadata  ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.name         = "EOKit"
  s.version      = "0.0.2"
  s.summary      = "EOKit is an Exact Online client library for iOS and OSX."
  s.description  = <<-DESC
  EOKit is an Exact Online client library for iOS and OSX. Other platform will
  follow.
  DESC
  s.homepage     = "https://github.com/Lingewoud/EOKit"

  # ―――  Spec License  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.license      = { :type => "MIT", :file => "LICENSE" }

  # ――― Author Metadata  ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.author             = { "Pim Snel" => "pim@lingewoud.nl" }

  # ――― Platform Specifics ――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.ios.deployment_target = "8.0"
  s.osx.deployment_target = "10.9"
  # s.watchos.deployment_target = "2.0"
  # s.tvos.deployment_target = "9.0"

  # ――― Source Location ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.source       = { :git => "https://github.com/Lingewoud/EOKit.git", :tag => "0.0.2" }

  # ――― Source Code ―――――――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  #s.source_files  = "Classes", "Classes/**/*.{h,m}"
  s.source_files  = "Classes", "Classes/EOKitShared/*.{h,m}"

  s.subspec 'OSX' do |ss|
    ss.osx.deployment_target = '10.9'
    ss.source_files = 'Classes/EOKitOSX/*.{h,m}'
  end

  s.subspec 'IOS' do |ss|
    ss.ios.deployment_target = '8.0'
    ss.source_files = 'Classes/EOKitIOS/*.{h,m}'
  end

  # ――― Project Settings ――――――――――――――――――――――――――――――――――――――――――――――――――――――――― #
  s.requires_arc = true
  s.dependency 'AFNetworking', '~> 2.2'
  s.dependency 'AFOAuth2Manager', '~> 2.2'
end
