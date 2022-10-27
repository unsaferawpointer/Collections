//
//  ArrayExtention.swift
//
//
//  Created by Anton Cherkasov on 08.08.2022.
//
import Foundation

public extension Array {

	mutating func move(indexes: IndexSet, to toIndex: Index) {
		let movingData = indexes.map { self[$0] }
		let targetIndex = toIndex - indexes.filter { $0 < toIndex }.count
		for (offset, index) in indexes.enumerated() {
			remove(at: index - offset)
		}
		insert(contentsOf: movingData, at: targetIndex)
	}

	/// - Complexity: O(n)
	mutating func modificate<V>(keyPath: WritableKeyPath<Element, V>, newValue: V) {
		for index in indices {
			self[index][keyPath: keyPath] = newValue
		}
	}


	/// Looks for the index of an element that satisfies a condition
	///
	/// - Parameters:
	///    - keyPath: KeyPath of the property
	///    - value: Value of the property
	/// - Complexity: O(n)
	func firstIndex<Value: Equatable>(keyPath: KeyPath<Element, Value>, equalsTo value: Value) -> Int? {
		return firstIndex { $0[keyPath: keyPath] == value }
	}
}

public extension RandomAccessCollection {

	/// Conviniece safe subscript
	///
	/// - Returns: If element exists return it, otherwise returns `nil`
	subscript(safeAt index: Index) -> Element? {
		get {
			return (startIndex..<endIndex) ~= index ? self[index] : nil
		}
	}

}

@available(macOS 10.15, iOS 11.0, *)
public extension Array where Element: Identifiable {

	/// - Parameters:
	///    - identifiers: Identifiers for moving
	///    - location: Relative location
	mutating func move<ID>(_ identifiers: [ID], to location: RelativeLocation<ID>) where Element.ID == ID {
		let indexes = enumerated().reduce(into: IndexSet()) { partialResult, pair in
			let id = pair.element.id
			if identifiers.contains(id) {
				partialResult.insert(pair.offset)
			}
		}
		switch location {
			case .after(let after):
				if let index = firstIndex(where: { $0.id == after }) {
					move(indexes: indexes, to: index + 1)
				}
			case .before(let before):
				if let index = firstIndex(where: { $0.id == before }) {
					move(indexes: indexes, to: index)
				}
		}
	}

	/**
	 - Parameters:
	    - newElements: new elements to insert
	    - location: Relative location
	 */
	mutating func insert<ID>(contentsOf newElements: [Element], at location: RelativeLocation<ID>) where Element.ID == ID {
		switch location {
			case .after(let id):
				if let index = firstIndex(where: { $0.id == id }) {
					insert(contentsOf: newElements, at: index + 1)
				}
			case .before(let id):
				if let index = firstIndex(where: { $0.id == id }) {
					insert(contentsOf: newElements, at: index)
				}
		}
	}

	/// Remove elements by identifiers
	/// 
	/// - Complexity: O(n)
	mutating func remove<ID>(_ identifiers: [ID]) where Element.ID == ID {
		let hashmap = Set(identifiers)
		removeAll { hashmap.contains($0.id) }
	}

	mutating func modificate<ID, Value>(
		_ identifiers: [ID],
		keyPath: WritableKeyPath<Element, Value>,
		newValue value: Value) where Element.ID == ID {
			identifiers.compactMap { id in
				firstIndex(keyPath: \.id, equalsTo: id)
			}.forEach {
				self[$0][keyPath: keyPath] = value
			}
		}

	/// - Complexity: O(1)
	func location(for index: Int?) -> RelativeLocation<Element.ID>? {
		guard let index = index else {
			return nil
		}
		precondition(count > 0, "Cant get relative location if collection is empty")
		if index > 0 {
			let id = self[index - 1].id
			return .after(id)
		}

		let id = self[index].id
		return .before(id)
	}
}
