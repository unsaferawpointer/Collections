//
//  TreeSnapshot.swift
//
//
//  Created by Anton Cherkasov on 29.10.2022.
//

import Foundation
import os.log

struct Node {

	let id: AnyHashable
	let indexPath: IndexPath
	let children: [AnyHashable]

	init(id: AnyHashable,
		 indexPath: IndexPath,
		 children: [AnyHashable]) {
		self.id = id
		self.indexPath = indexPath
		self.children = children
	}
}

/// Snapshot of the tree data
@available(macOS 10.15, *)
public struct TreeSnapshot<Element: Identifiable> {

	/// All identifiers
	public var identifiers: Set<AnyHashable> = []

	public var rootIdentifiers: [AnyHashable] = []
	private var cache: [IndexPath: AnyHashable] = [:]

	private var nodes: [AnyHashable: Node] = [:]
	private var elements: [AnyHashable: Element] = [:]

	/// Initialization
	///
	/// - Parameters:
	///    - items: Root items
	public init(_ items: [TreeNode<Element>]) {
		reload(items)
	}

	/// Initialization of the empty snapshot
	public init() { }

}

// MARK: - Subscripts
@available(macOS 10.15, *)
public extension TreeSnapshot {

	/// Returns root element
	///
	/// - Parameters:
	///    - index: Index of the root element
	/// - Returns: If element does not exist returns `nil`
	/// - Complexity: O(1)
	subscript(index: Int) -> Element? {
		return self[IndexPath(index: index)]
	}

	/// Returns element by index path
	///
	/// - Parameters:
	///    - indexPath: Index path of the item
	/// - Complexity: O(1)
	/// - Note: First value of the index path is index of root item
	subscript(indexPath: IndexPath) -> Element? {
		guard let identifier = cache[indexPath] else {
			return nil
		}
		return elements[identifier]
	}

	/// Returns element by index path
	///
	/// - Parameters:
	///    - identifier: Identifier of the element
	/// - Complexity: O(1)
	subscript(identifier: AnyHashable) -> Element? {
		return elements[identifier]
	}
}

@available(macOS 10.15, *)
public extension TreeSnapshot {

	/// If snapshot is empty returns `true`, otherwise returns `false`
	var isEmpty: Bool {
		return nodes.isEmpty
	}

	/// - Complexity: O(1)
	func childrenCount(for parent: AnyHashable?) -> Int {
		guard let identifier = parent else {
			return rootIdentifiers.count
		}
		guard let node = nodes[identifier] else {
			return 0
		}
		return node.children.count
	}

	/// - Complexity: O(1)
	func childIdentifier(in parent: AnyHashable?, at index: Int) -> AnyHashable? {
		guard let identifier = parent else {
			return rootIdentifiers[index]
		}
		return nodes[identifier]?.children[index]
	}

	/// - Complexity: O(1)
	func childrenIdentifiers(_ identifier: AnyHashable?) -> [AnyHashable] {
		guard let parent = identifier else {
			return rootIdentifiers
		}
		return nodes[parent]?.children ?? []
	}

	/// - Parameters:
	///    - indexPath: IndexPath of the element
	/// - Returns: If element does not exist returns `nil`
	/// - Complexity: O(1)
	func identifier(atIndexPath indexPath: IndexPath) -> AnyHashable? {
		return cache[indexPath]
	}

	/// - Parameters:
	///    - identifier: Identifier of the element
	/// - Returns: If element does not exist returns `nil`
	/// - Complexity: O(1)
	func indexPath(forIdentifier identifier: AnyHashable) -> IndexPath? {
		return nodes[identifier]?.indexPath
	}

	/// Returns relative location
	///
	/// - Parameters:
	///    - parent: Parent of the element
	///    - index: Index if the element in children array
	/// - Complexity: O(1)
	func relativeLocation(in parent: AnyHashable?, at index: Int) -> RelativeLocation<AnyHashable> {
		let children = childrenIdentifiers(parent)
		precondition(children.count > 0, "Cant get relative location when collection is empty")
		if index > 0 {
			let id = children[index - 1]
			return .after(id)
		}

		let id = children[index]
		return .before(id)
	}

	/// - Complexity: O(1)
	func index(identifier: (some Hashable)) -> TreeIndex? {
		guard let indexPath = indexPath(forIdentifier: identifier) else {
			return nil
		}
		return .init(id: identifier, indexPath: indexPath)
	}

	/// Update element in snapshot
	/// - Parameters:
	///    - element: Updating element
	/// - Complexity: O(1)
	mutating func forceUpdate(_ element: Element) {
		elements[element.id] = element
	}

}

// MARK: - Helpers
@available(macOS 10.15, *)
extension TreeSnapshot {

	mutating func reload(_ newItems: [TreeNode<Element>]) {
		for (offset, item) in newItems.enumerated() {
			let origin = IndexPath(index: offset)
			rootIdentifiers.append(item.id)
			item.enumerateNodes(origin: origin) { treeNode, indexPath in
				store(treeNode, origin: indexPath)
			}
		}
	}

	mutating func store(_ treeNode: TreeNode<Element>, origin indexPath: IndexPath) {
		let children = treeNode.children.map(\.id)
		let node = Node(id: treeNode.id, indexPath: indexPath, children: children)
		nodes[treeNode.id] = node
		elements[treeNode.id] = treeNode.value
		cache[indexPath] = treeNode.id
	}

}
