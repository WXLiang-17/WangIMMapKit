#
# Be sure to run `pod lib lint WangIMMapKit.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'WangIMMapKit'
  s.version          = '0.0.1'
  s.summary          = '在IM中使用高德地图，进行位置共享和分享位置,使用NO-IDFA避免上架问题'
  s.description      = <<-DESC
                       提供在IM应用中集成高德地图的功能，支持实时位置共享与位置消息发送，使用无IDFA版本SDK规避App Store审核问题。
                       DESC
  s.homepage         = 'https://github.com/Wang/WangIMMapKit'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Wang' => '1162558647@qq.com' }
  s.source           = { :git => 'https://github.com/Wang/WangIMMapKit.git', :tag => s.version.to_s }
  s.ios.deployment_target = '13.0'
  s.swift_version    = '5.0'  # 强制主工程启用动态框架模式

  # 源码文件声明
  s.source_files = 'WangIMMapKit/Classes/**/*'

  # ✅ 资源文件声明（修正点）
  s.resource_bundles = {
    'WangIMMapKit' => [
      # 'WangIMMapKit/Assets/**/*.xcassets',  # 包含 .xcassets
      'WangIMMapKit/Assets/*.xcassets',  # 包含 .xcassets
      'WangIMMapKit/Assets/**/*.png',       # 图片资源
      'WangIMMapKit/Assets/**/*.json',       # JSON文件
    ]
  }

  # 📚 依赖声明（关键修正）
  s.dependency 'Kingfisher'                   # 动态框架（默认）
  s.dependency 'SnapKit'                      # 动态框架（默认）
  s.dependency 'AMap3DMap-NO-IDFA'            # 高德3D地图SDK（需主工程静态链接）
  s.dependency 'AMapSearch-NO-IDFA'           # 高德搜索SDK
  s.dependency 'AMapLocation-NO-IDFA'         # 高德定位SDK
  
  # 关键修改：声明静态依赖传播
  s.static_framework = true  # 声明整个 Pod 为静态库
  s.user_target_xcconfig = {
    'OTHER_LDFLAGS' => '$(inherited) -framework "MAMapKit" -framework "AMapSearchKit" -framework "AMapLocationKit"',
    'LIBRARY_SEARCH_PATHS' => '"$(PODS_ROOT)/AMap3DMap-NO-IDFA" "$(PODS_ROOT)/AMapSearch-NO-IDFA" "$(PODS_ROOT)/AMapLocation-NO-IDFA"'
  }
  
end
