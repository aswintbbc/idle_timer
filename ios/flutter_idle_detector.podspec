Pod::Spec.new do |s|
  s.name             = 'flutter_idle_detector'
  s.version          = '0.0.1'
  s.summary          = 'Idle detector plugin'
  s.license          = { :type => 'MIT' }
  s.author           = { 'Author' => 'email@example.com' }
  s.source           = { :path => '.' }
  s.source_files     = 'Classes/**/*'
  s.dependency       'Flutter'
  s.platform         = :ios, '11.0'
end
