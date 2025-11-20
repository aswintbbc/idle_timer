Pod::Spec.new do |s|
  s.name             = 'flutter_idle_detector'
  s.version          = '0.0.1'
  s.summary          = 'A Flutter plugin that detects idle user activity.'
  s.description      = 'flutter_idle_detector provides native-level idle detection.'

  s.homepage         = 'https://github.com/aswintbbc/idle_timer'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Aswint' => 'example@example.com' }

  s.source           = { :git => 'https://github.com/aswintbbc/idle_timer.git', :tag => s.version.to_s }

  s.source_files     = 'Classes/**/*'
  s.platform         = :ios, '11.0'

  s.dependency       'Flutter'
  s.static_framework = true

  s.pod_target_xcconfig = {
    'DEFINES_MODULE' => 'YES'
  }
end
