Pod::Spec.new do |s|
  s.name         = "YBPagerView"
  s.version      = "0.0.4"
  s.summary      = "根据JXPagingView优化而来，主要适配了无障碍，优化了部分api"
  s.description  = "根据JXPagingView优化而来，适配了无障碍，优化了部分api"
  s.homepage     = "https://github.com/lyb5834/YBPagerView.git"
  s.license      = "MIT"
  s.author       = { "lyb" => "lyb5834@126.com" }
  s.source       = { :git => "https://gitee.com/lyb5834/YBPagerView.git", :tag => s.version.to_s }
  s.source_files  = "YBPagerView/YBPagerView/*.{h,m}"
  s.requires_arc = true
  s.dependency 'Masonry'
  s.platform     = :ios, '6.0'
end
