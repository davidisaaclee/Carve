/*
Extensions to commonly-used vector types in Apple's core libraries.
*/

import Foundation
import CoreGraphics

// 
extension CGFloat: ExponentiableArithmeticType {
	public static var zero: CGFloat = 0
	public func toThePowerOf(exponent: CGFloat) -> CGFloat {
		return pow(self, exponent)
	}
}

extension Int: ArithmeticType {
	public static let zero: Int = 0
}

extension CGPoint: Vector {
	public typealias Index = Int

	public var startIndex: Int { return 0 }
	public var endIndex: Int { return 2 }

	public init<T where T: CollectionType, T.Generator.Element == CGFloat>(collection: T) {
		var g = collection.generate()
		guard let x = g.next(), let y = g.next() else {
			fatalError()
		}
		self.init(x: x, y: y)
	}

	public subscript(index: Int) -> CGFloat {
		switch index {
		case 0:
			return x
		case 1:
			return y
		default:
			fatalError()
		}
	}
}


extension CGSize: Vector {
	public typealias Index = Int

	public var startIndex: Int { return 0 }
	public var endIndex: Int { return 2 }

	public init<T where T: CollectionType, T.Generator.Element == CGFloat>(collection: T) {
		var g = collection.generate()
		guard let width = g.next(), let height = g.next() else {
			fatalError()
		}
		self.init(width: width, height: height)
	}

	public subscript(index: Int) -> CGFloat {
		switch index {
		case 0:
			return width
		case 1:
			return height
		default:
			fatalError()
		}
	}
}
