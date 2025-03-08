# FamilyTree
家谱树的可视化库，使用了 MVVM 架构模式进行开发。

## 描述
  这是一个基于 Swift 开发的家谱树可视化项目，采用了 MVVM 架构模式。主要功能包括：

  - 树形结构展示：使用自定义的 TreeViewContainer 实现树形布局
  - 节点样式定制：通过 DemoTreeViewAdapter 实现节点的自定义样式，包括头像、姓名、性别、职业等信息的展示
  - 多配偶信息：支持展示每个节点的多个配偶信息，使用水平滚动视图展示
  - 交互功能：实现了节点的点击选中和长按操作
  - 数据模型设计：使用 DemoTreeItemData 和 DemoSpouseInfo 结构体管理数据
  
  代码采用了分层设计：
  - 视图层：TreeViewContainer 和自定义 UI 组件
  - 布局层：TreeLayoutManager 负责节点布局
  - 数据层：DemoTreeItemData、DemoSpouseInfo 等模型，根据需求自定义
  - 适配层：DemoTreeViewAdapter 遵循协议TreeViewAdapter，处理数据到自定义视图的转换
  
  遵循了面向协议编程的设计理念，实现了良好的代码解耦和可维护性。
