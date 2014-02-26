Pod::Spec.new do |s|
  s.name         = 'TMAERecorder'
  s.version      = '0.1.0'
  s.homepage     = 'https://github.com/tuenti/TMAERecorder'
  s.summary      = 'AVAudioRecorder replacement which allows audio recording with real time sound filtering. Implemented using The Amazing Audio Engine.'
  s.authors      = { 'Tuenti Technologies S.L.' => 'https://twitter.com/TuentiEng' }
  s.source       = { :git => 'https://github.com/tuenti/TMAERecorder.git', :tag => s.version.to_s }
  	s.dependency 'TheAmazingAudioEngine', '~> 1.2'
  s.source_files = 'Classes/**/*.{h,m}'
  s.license      = { :type => 'Apache License, Version 2.0', :file => 'LICENSE' }
  s.requires_arc = true
end
