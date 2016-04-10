import Foundation
import UIKit
import VectorKit

protocol Polynomial {
	associatedtype InputType
	associatedtype OutputType
	associatedtype CoefficientType

	var coefficients: [CoefficientType] { get }
	var derivative: Self { get }

	init(coefficients: [CoefficientType])
	subscript(input: InputType) -> OutputType { get }
}

struct FloatPolynomial: Polynomial {
	let coefficients: [Float]

	var derivative: FloatPolynomial {
		let newCoefficients = self.coefficients.mapWithIndices { (coefficient: Float, index: Int) -> Float in
			return coefficient * Float(index)
		}
		return FloatPolynomial(coefficients: Array(newCoefficients.dropFirst()))
	}

	init(coefficients: [Float]) {
		self.coefficients = coefficients
	}

	subscript(input: Float) -> Float {
		return self.coefficients
			.mapWithIndices { (coefficient, index) -> Float in coefficient * pow(input, Float(index)) }
			.reduce(0) { $0 + $1 }
	}
}

struct VectorPolynomial<VectorType: Vector where VectorType.Generator.Element == CGFloat>: Polynomial {
	typealias InputType = VectorType.Generator.Element
	typealias CoefficientType = VectorType
	typealias OutputType = VectorType

	let coefficients: [VectorType]

	var derivative: VectorPolynomial<VectorType> {
		let newCoefficients: [CoefficientType] =
			self.coefficients.mapWithIndices { (coefficient, index) in coefficient * CGFloat(index) }

		return VectorPolynomial<CoefficientType>(coefficients: Array(newCoefficients.dropFirst()))
	}

	init(coefficients: [CoefficientType]) {
		self.coefficients = coefficients
	}

	subscript(input: InputType) -> OutputType {
		return self.coefficients
			.mapWithIndices { (coefficient, index) in
				let x: CGFloat = pow(input, CGFloat(index))
				return coefficient * x
			}
			.reduce(CoefficientType.additionIdentity) { $0 + $1 }
	}
}