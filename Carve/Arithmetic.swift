//
//  Arithmetic.swift
//  Pods
//
//  Created by David Lee on 2/13/16.
//
//

import Foundation

public protocol ArithmeticType {
	static var zero: Self { get }
	func + (randl: Self, randr: Self) -> Self
	func * (randl: Self, randr: Self) -> Self
}

public protocol ExponentiableArithmeticType: ArithmeticType, FloatLiteralConvertible {
	func toThePowerOf(exponent: Self) -> Self
}