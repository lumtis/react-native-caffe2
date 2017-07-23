
Pod::Spec.new do |s|
  s.name         = "RNReactNativeCaffe2"
  s.version      = "1.0.0"
  s.summary      = "RNReactNativeCaffe2"
  s.description  = <<-DESC
                  RNReactNativeCaffe2
                   DESC
  s.homepage     = ""
  s.license      = "MIT"
  # s.license      = { :type => "MIT", :file => "FILE_LICENSE" }
  s.author             = { "author" => "author@domain.cn" }
  s.platform     = :ios, "7.0"
  s.source       = { :git => "https://github.com/author/RNReactNativeCaffe2.git", :tag => "master" }
  s.source_files  = "RNReactNativeCaffe2/**/*.{h,m}"
  s.requires_arc = true


  s.dependency "React"
  #s.dependency "others"

end

  