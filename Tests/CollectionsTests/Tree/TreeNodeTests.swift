//
//  TreeNodeTests.swift
//  
//
//  Created by Anton Cherkasov on 28.10.2022.
//

import XCTest
@testable import Collections

final class TreeNodeTests: XCTestCase {

	var sut: TreeNode<String>!

	override func setUpWithError() throws {
		sut = makeNode()
	}

	override func tearDownWithError() throws {
		sut = nil
	}

}

extension TreeNodeTests {

	func testSubscriptIndexPath() throws {

		// Act
		let indexPath = IndexPath(arrayLiteral: 0, 1)
		let result = sut[indexPath]

		// Assert
		XCTAssertEqual(result?.value, "01")
	}

	func testSubscriptIndex() throws {

		// Act
		let result = sut[1]

		// Assert
		XCTAssertEqual(result?.value, "1")
	}

	func testSubscriptIndexWhenNoChildren() throws {
		// Arrange
		sut = TreeNode<String>(value: "")

		// Act
		let result = sut[0]

		// Assert
		XCTAssertNil(result)
	}

	func testEnumerateValues() throws {
		// Arrange
		var stack: [IndexPath] = []

		// Act
		sut.enumerateValues(origin: .init(index: 2)) { value, indexPath in
			stack.append(indexPath)
		}

		// Assert
		XCTAssertEqual(stack, [.init(index: 2),
							   .init(arrayLiteral: 2, 0),
							   .init(arrayLiteral: 2, 0, 0),
							   .init(arrayLiteral: 2, 0, 1),
							   .init(arrayLiteral: 2, 1)])
	}

	func testEnumerateNodes() throws {
		// Arrange
		var indexPathsStack: [IndexPath] = []
		var valuesStack: [String] = []

		// Act
		sut.enumerateNodes(origin: .init(index: 2)) { node, indexPath in
			indexPathsStack.append(indexPath)
			valuesStack.append(node.value)
		}

		// Assert
		XCTAssertEqual(indexPathsStack, [.init(index: 2),
							   .init(arrayLiteral: 2, 0),
							   .init(arrayLiteral: 2, 0, 0),
							   .init(arrayLiteral: 2, 0, 1),
							   .init(arrayLiteral: 2, 1)])
		XCTAssertEqual(valuesStack, ["", "0", "00", "01", "1"])
	}

	func testTransform() throws {
		// Arrange
		var stack: [String] = []

		// Act
		let result = sut.transform { value in
			print("value = \(value)")
			return "_\(value)"
		}

		// Assert
		result.enumerateValues { value, indexPath in
			stack.append(value)
		}
		XCTAssertEqual(stack, ["_", "_0", "_00", "_01", "_1"])
	}

	func testFilter() throws {
		// Arrange
		var stack: [String] = []

		// Act
		sut.filter {
			$0.hasPrefix("0")
		}

		// Assert
		sut.enumerateValues { value, indexPath in
			stack.append(value)
		}
		XCTAssertEqual(stack, ["", "0", "00", "01"])
	}
}

// MARK: - Helpers
private extension TreeNodeTests {

	/*
	 Node:
	 - *
		- 0
			- 00
			- 01
		- 1
	 */

	func makeNode() -> TreeNode<String> {

		let child00 = TreeNode<String>(value: "00")
		let child01 = TreeNode<String>(value: "01")

		let child0 = TreeNode<String>(value: "0", children: [child00, child01])
		let child1 = TreeNode<String>(value: "1")

		let root = TreeNode<String>(value: "", children: [child0, child1])
		return root
	}
}
