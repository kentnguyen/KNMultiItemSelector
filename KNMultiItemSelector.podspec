Pod::Spec.new do |s|
  s.name     = 'KNMultiItemSelector'
  s.license  = 'MIT'
  s.summary  = 'KNMultiItemSelector is a versatile drop in multiple items selector for iOS projects.'
  s.homepage = 'https://github.com/kentnguyen/KNMultiItemSelector'
  s.author   = { 'Kent Nguyen' => 'nguyen.dmz@gmail.com' }
  s.platform = :ios
  s.version  = '1.0.1'
  s.source   = { :git => 'https://github.com/kentnguyen/KNMultiItemSelector.git', :tag => '1.0' }

  s.source_files = 'KNMultiItemSelector/KNMultiItemSelector.{h,m}', 'KNMultiItemSelector/KNSelectorItem.{h,m}'
  s.resources = "KNMultiItemSelector/Images/*.png"

  
  s.requires_arc = true
  s.dependency 'SDWebImage'
  s.frameworks = 'CoreGraphics', 'ImageIO'
end
