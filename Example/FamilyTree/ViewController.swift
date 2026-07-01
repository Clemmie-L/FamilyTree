//
//  ViewController.swift
//  FamilyTree
//
//  Created by Clemmie on 03/07/2025.
//  Copyright (c) 2025 Clemmie. All rights reserved.
//

import UIKit
import FamilyTree

// 定义家族成员数据模型
struct FamilyMember: TreeNodeIdentifiable {
    let id: String
    let name: String
    let birthYear: Int
    
    init(name: String, birthYear: Int) {
        self.id = UUID().uuidString
        self.name = name
        self.birthYear = birthYear
    }
}

// 定义家谱树适配器
class FamilyTreeAdapter: TreeViewAdapter {
    typealias T = FamilyMember
    
    let rootNode: TreeNode<FamilyMember>
    
    init(rootNode: TreeNode<FamilyMember>) {
        self.rootNode = rootNode
    }
    
    func createView(for node: TreeNode<FamilyMember>) -> UIView {
        let container = UIView()
        container.backgroundColor = .white
        container.layer.cornerRadius = 8
        container.layer.shadowColor = UIColor.black.cgColor
        container.layer.shadowOffset = CGSize(width: 0, height: 2)
        container.layer.shadowRadius = 4
        container.layer.shadowOpacity = 0.1
        
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.spacing = 4
        container.addSubview(stackView)
        stackView.snp.makeConstraints { make in
            make.edges.equalToSuperview().inset(12)
        }
        
        let nameLabel = UILabel()
        nameLabel.text = node.data.name
        nameLabel.font = .systemFont(ofSize: 16, weight: .medium)
        stackView.addArrangedSubview(nameLabel)
        
        let yearLabel = UILabel()
        yearLabel.text = "\(node.data.birthYear)"
        yearLabel.font = .systemFont(ofSize: 14)
        yearLabel.textColor = .gray
        stackView.addArrangedSubview(yearLabel)
        
        return container
    }
    
    func configureLineDrawer(_ lineDrawer: TreeLineDrawer) {
        lineDrawer.lineColor = .systemGray4
        lineDrawer.lineWidth = 2
    }
}

class ViewController: UIViewController {
    
    private var treeContainer: TreeViewContainer<FamilyTreeAdapter>!
    private let searchBar = UISearchBar()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        setupFamilyTree()
    }
    
    private func setupUI() {
        // 配置搜索栏
        searchBar.placeholder = "搜索家族成员"
        searchBar.delegate = self
        view.addSubview(searchBar)
        searchBar.snp.makeConstraints { make in
            make.top.equalTo(view.safeAreaLayoutGuide)
            make.left.right.equalToSuperview()
        }
        
        // 配置树形图容器
        treeContainer = TreeViewContainer(frame: .zero)
        treeContainer.backgroundColor = .systemBackground
        view.addSubview(treeContainer)
        treeContainer.snp.makeConstraints { make in
            make.top.equalTo(searchBar.snp.bottom)
            make.left.right.bottom.equalToSuperview()
        }
    }
    
    private func setupFamilyTree() {
        // 创建示例数据
        let grandfather = TreeNode(data: FamilyMember(name: "张大年", birthYear: 1940))
        
        let father1 = TreeNode(data: FamilyMember(name: "张明", birthYear: 1965))
        let father2 = TreeNode(data: FamilyMember(name: "张华", birthYear: 1968))
        
        let child1 = TreeNode(data: FamilyMember(name: "张小明", birthYear: 1990))
        let child2 = TreeNode(data: FamilyMember(name: "张小华", birthYear: 1992))
        let child3 = TreeNode(data: FamilyMember(name: "张小军", birthYear: 1995))
        
        // 构建家族树结构
        grandfather.addChild(father1)
        grandfather.addChild(father2)
        
        father1.addChild(child1)
        father1.addChild(child2)
        father2.addChild(child3)
        
        // 创建并设置适配器
        let adapter = FamilyTreeAdapter(rootNode: grandfather)
        treeContainer.setAdapter(adapter)
    }
}

// MARK: - UISearchBarDelegate
extension ViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let searchText = searchBar.text, !searchText.isEmpty else { return }
        treeContainer.searchNode(name: searchText)
        searchBar.resignFirstResponder()
    }
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        if searchText.isEmpty {
//            treeContainer.reloadData()w
        }
    }
}

