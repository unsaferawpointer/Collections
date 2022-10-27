//
//  RelativeLocation.swift
//  
//
//  Created by Anton Cherkasov on 01.11.2022.
//

/// Use location for moving and insertions elements in array
public enum RelativeLocation<ID: Hashable>: Hashable {
	/// Use on moving on bottom and middle of the list
	case after(_ identifier: ID)
	/// Use on moving on top and middle of the list
	case before(_ identifier: ID)
}

public extension RelativeLocation {

	var id: ID {
		switch self {
			case .after(let identifier):	return identifier
			case .before(let identifier):	return identifier
		}
	}

	func indexRelative(to index: Int) -> Int {
		switch self {
			case .after:	return index + 1
			case .before:	return index
		}
	}

	func transform<T: Hashable>(_ block: (ID) -> T) -> RelativeLocation<T> {
		switch self {
			case .after(let identifier):	return .after(block(identifier))
			case .before(let identifier):	return .before(block(identifier))
		}
	}

	func transform<T: Hashable>(_ block: (ID) -> T?) -> RelativeLocation<T>? {
		switch self {
			case .after(let identifier):
				guard let id = block(identifier) else {
					return nil
				}
				return .after(id)
			case .before(let identifier):
				guard let id = block(identifier) else {
					return nil
				}
				return .before(id)
		}
	}
}
