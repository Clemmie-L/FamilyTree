#
# Be sure to run `pod lib lint FamilyTree.podspec' to ensure this is a
# valid spec before submitting.
#
# Any lines starting with a # are optional, but their use is encouraged
# To learn more about a Podspec see https://guides.cocoapods.org/syntax/podspec.html
#

Pod::Spec.new do |s|
  s.name             = 'FamilyTree'
  s.version          = '1.0.0'
  s.summary          = '这是一个家谱树的可视化项目，使用了 MVVM 架构模式进行开发。主要功能包括树形结构的展示、节点的自定义样式、多配偶信息展示、以及节点的交互操作（点击、长按等）'

# This description is used to generate tags and improve search results.
#   * Think: What does it do? Why did you write it? What is the focus?
#   * Try to keep it short, snappy and to the point.
#   * Write the description between the DESC delimiters below.
#   * Finally, don't worry about the indent, CocoaPods strips it!

  s.description      = <<-DESC
  这是一个基于 Swift 和 UIKit 开发的家谱树可视化项目，采用了 MVVM 架构模式。主要功能包括：

  - 树形结构展示：使用自定义的 TreeViewContainer 实现树形布局
  - 节点样式定制：通过 DemoTreeViewAdapter 实现节点的自定义样式，包括头像、姓名、性别、职业等信息的展示
  - 多配偶信息：支持展示每个节点的多个配偶信息，使用水平滚动视图展示
  - 交互功能：实现了节点的点击选中和长按操作
  - 数据模型设计：使用 TreeItemData 和 SpouseInfo 结构体管理数据
  代码采用了分层设计：

  - 数据层：TreeItemData、SpouseInfo 等模型
  - 视图层：TreeViewContainer 和自定义 UI 组件
  - 适配层：DemoTreeViewAdapter 处理数据到视图的转换
  - 布局层：TreeLayoutManager 负责节点布局
  项目使用了 SnapKit 进行布局约束，遵循了面向协议编程的设计理念，实现了良好的代码解耦和可维护性。
                       DESC

  s.homepage         = 'https://github.com/Clemmie-L/FamilyTree'
  # s.screenshots     = 'www.example.com/screenshots_1', 'www.example.com/screenshots_2'
  s.license          = { :type => 'MIT', :file => 'LICENSE' }
  s.author           = { 'Clemmie' => '379644692@qq.com' }
  s.source           = { :git => 'https://github.com/Clemmie-L/FamilyTree.git', :tag => "#{s.version}" }
  # s.social_media_url = 'https://twitter.com/<TWITTER_USERNAME>'

  s.swift_version = '5.0'
  
  s.ios.deployment_target = '15.0'

  s.source_files = 'FamilyTree/Classes/**/*'
  
  # s.resource_bundles = {
  #   'FamilyTree' => ['FamilyTree/Assets/*.png']
  # }

  # s.public_header_files = 'Pod/Classes/**/*.h'
  # s.frameworks = 'UIKit', 'MapKit'
  # s.dependency 'AFNetworking', '~> 2.3'
  s.dependency 'SnapKit'
end
