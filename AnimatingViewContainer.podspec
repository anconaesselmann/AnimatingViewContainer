Pod::Spec.new do |s|
  s.name             = 'AnimatingViewContainer'
  s.version          = '0.1.2'
  s.summary          = 'A view container with transition animation'
  s.swift_version = '5.0'
  s.description      = <<-DESC
A view container with transition animation.
                       DESC
  s.homepage         = 'https://github.com/anconaesselmann/AnimatingViewContainer'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'anconaesselmann' => 'axel@anconaesselmann.com' }
  s.source           = { :git => 'https://github.com/anconaesselmann/AnimatingViewContainer.git', :tag => s.version.to_s }
  s.ios.deployment_target = '8.0'
  s.source_files = 'AnimatingViewContainer/Classes/**/*'
  s.ios.deployment_target = '10.0'

  s.ios.dependency 'constrain'
end
