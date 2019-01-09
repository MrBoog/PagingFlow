Pod::Spec.new do |s|

  s.name         = "PagingFlow"
  s.version      = "0.0.2"
  s.summary      = "A Page View base on UIPageViewController."
  s.description  = <<-DESC
                   Easily setup and manage a list of UIViewController by using UIPageViewController.
                   DESC

  s.homepage     = "https://github.com/MrBoog/PagingFlow"
  s.license      = "MIT"
  s.author             = { "HuanLiu" => "iosboog@163.com" }

  s.platform     = :ios
  s.platform     = :ios, "9.0"
  s.source       = { :git => "https://github.com/MrBoog/PagingFlow.git", :tag => "#{s.version}" }

  s.source_files  = "PagingFlow", "PagingFlow/**/*.{h,swift}"
  s.swift_version = "4.2"
  s.requires_arc = true

end
