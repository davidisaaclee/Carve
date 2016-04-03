import Foundation
import UIKit

struct Polynomial {
	init(coefficients: [CGFloat]) {
		self.coefficients = coefficients
	}

	var coefficients: [CGFloat]

	var derivative: Polynomial {
		let newCoefficients = self.coefficients.mapWithIndices { (coefficient: CGFloat, index: Int) -> CGFloat in
			return coefficient * CGFloat(index)
		}
		return Polynomial(coefficients: Array(newCoefficients.dropFirst()))
	}
}