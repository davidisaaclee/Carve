//
//  Vector.swift
//  pfreddit2
//
//  Created by David Lee on 1/13/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import CoreGraphics

public protocol Vector: CollectionType {
	associatedtype Generator = IndexingGenerator<Self>
	associatedtype LengthType

	init<T where T: CollectionType, T.Generator.Element == Self.Generator.Element>(collection: T)

	var magnitude: LengthType { get }
	var squaredMagnitude: LengthType { get }
	var unit: Self { get }
	var negate: Self { get }

	// Named aliases for + and * operators, for ease of protocol adoption.
	func sum(operand: Self) -> Self
	func scale(scalar: Self.Generator.Element) -> Self

	func + (randl: Self, randr: Self) -> Self
	func * (vector: Self, scalar: Self.Generator.Element) -> Self
	func - (randl: Self, randr: Self) -> Self
	prefix func - (rand: Self) -> Self
}

public extension Vector {
	public func generate() -> IndexingGenerator<Self> {
		return IndexingGenerator(self)
	}
}

public func + <V: Vector> (randl: V, randr: V) -> V {
	return randl.sum(randr)
}

public func * <V: Vector> (vector: V, scalar: V.Generator.Element) -> V {
	return vector.scale(scalar)
}

public func - <V: Vector>(randl: V, randr: V) -> V {
	return randl + randr.negate
}

public prefix func - <V: Vector>(rand: V) -> V {
	return rand.negate
}


public extension Vector where Generator.Element: ArithmeticType {
	public func sum(operand: Self) -> Self {
		return self.dynamicType.init(collection: Array(zip(self, operand).map { $0 + $1 }))
	}

	public func scale(scalar: Self.Generator.Element) -> Self {
		return self.dynamicType.init(collection: self.map { $0 * scalar })
	}

	public var squaredMagnitude: Self.Generator.Element {
		return self.reduce(Self.Generator.Element.zero) { $0 + $1 * $1 }
	}
}

public extension Vector where Generator.Element: ExponentiableArithmeticType, LengthType == Self.Generator.Element {
	public var magnitude: LengthType {
		return self.squaredMagnitude.toThePowerOf(0.5)
	}

	public var unit: Self {
		return self * magnitude.toThePowerOf(-1.0)
	}

	public var negate: Self {
		return self * -1.0
	}
}