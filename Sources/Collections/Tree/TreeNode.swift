//
//  TreeNode.swift
//
//
//  Created by Anton Cherkasov on 27.10.2022.
//

import Foundation

final public class TreeNode<Element> {

	/// Value of the node
	public var value: Element

	/// Children of the node
	public var children: [TreeNode<Element>]

	///  Basic initialization
	///
	///  - Parameters:
	///    - value: Value of the node
	///    - children: Children of the node
	public init(value: Element, children: [TreeNode<Element>] = []) {
		self.value = value
		self.children = children
	}
}

public extension TreeNode {

	/// Enumerate all values in Depth-First-Traversal order.
	func enumerateValues(origin: IndexPath = .init(), _ action: (Element, IndexPath) -> Void) {
		enumerate(self, indexPath: origin, visit: action)
	}

	/// Enumerate all nodes in Depth-First-Traversal order.
	func enumerateNodes(origin: IndexPath = .init(), _ action: (TreeNode, IndexPath) -> Void) {
		enumerate(self, indexPath: origin, visit: action)
	}

	/// - Returns: Returns converted tree node
	func transform<T>(_ action: (Element) -> T) -> TreeNode<T> {
		return transform(self, action: action)
	}

	/// Filter descendants of the node
	///
	/// - Parameters:
	///    - predicate: Predicate to filter descendants
	func filter(predicate: (Element) -> Bool) {
		filter(self, predicate: predicate)
	}

	/// Returns node by index path
	///
	/// - Parameters:
	///    - indexPath: Index path of the node
	/// - Complexity: **O(k)**, where **k** - is depth of the index path.
	subscript(indexPath: IndexPath) -> TreeNode<Element>? {
		return search(in: self, indexPath: indexPath)
	}

	subscript(index: Int) -> TreeNode<Element>? {
		guard index < children.count && index >= 0 else {
			return nil
		}
		return children[index]
	}

}

@available(macOS 10.15, *)
extension TreeNode where Element: Identifiable {

	var id: Element.ID {
		return value.id
	}

	/// Enumerate all nodes in Depth-First-Traversal order.
	func enumerateNodes(origin: IndexPath = .init(),
						parent: AnyHashable? = nil,
						_ action: (TreeNode, IndexPath, AnyHashable?) -> Void) {
		enumerate(self, indexPath: origin, parent: nil, visit: action)
	}

	/// Enumerate all nodes in Depth-First-Traversal order.
	func enumerate(_ node: TreeNode,
				   indexPath: IndexPath,
				   parent: AnyHashable?,
				   visit: (TreeNode, IndexPath, AnyHashable?) -> Void) where Element: Identifiable {
		visit(node, indexPath, parent)
		for (offset, child) in node.children.enumerated() {
			let next = indexPath.appending(offset)
			enumerate(child, indexPath: next, parent: node.id, visit: visit)
		}
	}
}

// MARK: - Helpers
private extension TreeNode {

	func transform<T>(_ node: TreeNode, action: (Element) -> T) -> TreeNode<T> {
		let rootNode = TreeNode<T>(value: action(node.value))
		rootNode.children = node.children.map { transform($0, action: action) }
		return rootNode
	}

	func enumerate(_ node: TreeNode, indexPath: IndexPath, visit: (Element, IndexPath) -> Void) {
		visit(node.value, indexPath)
		for (offset, child) in node.children.enumerated() {
			let next = indexPath.appending(offset)
			enumerate(child, indexPath: next, visit: visit)
		}
	}

	func enumerate(_ node: TreeNode, indexPath: IndexPath, visit: (TreeNode, IndexPath) -> Void) {
		visit(node, indexPath)
		for (offset, child) in node.children.enumerated() {
			let next = indexPath.appending(offset)
			enumerate(child, indexPath: next, visit: visit)
		}
	}

	func search(in node: TreeNode<Element>, indexPath: IndexPath) -> TreeNode<Element> {
		guard let offset = indexPath.first else {
			return node
		}
		return search(in: node.children[offset], indexPath: indexPath.dropFirst())
	}

	func filter(_ node: TreeNode<Element>, predicate: (Element) -> Bool) {
		node.children.removeAll {
			!predicate($0.value)
		}
		for child in node.children {
			filter(child, predicate: predicate)
		}
	}

}
