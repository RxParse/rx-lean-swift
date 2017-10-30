
Pod::Spec.new do |s|

  s.name         = "RxLeanCloud"
  s.version      = "0.1.0"
  s.summary      = "LeanCloud Swift sdk based on RxSwift for iOS"
  s.homepage     = "https://github.com/RxLeanCloud/rx-lean-swift"
  s.license      = { :type => "MIT", :file => "LICENSE" }
  s.author       = { "wujun4code" => "wujun19890209@gmail.com" }
  s.platform     = :ios,"10.0"
  s.source       = { :git => "https://github.com/RxLeanCloud/rx-lean-swift.git", :tag => s.version }
  s.source_files  = 'src/RxLeanCloudSwift/**/*.swift'

  s.dependency 'RxSwift',    '~> 4.0'
  s.dependency 'RxCocoa',    '~> 4.0'
  s.dependency 'RxAlamofire' 
  s.dependency 'Alamofire', '> 4.5'
  s.dependency 'Starscream', '~> 3.0.2'

end
