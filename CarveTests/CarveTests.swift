//
//  CarveTests.swift
//  CarveTests
//
//  Created by David Lee on 4/10/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import XCTest
import VectorKit

@testable import Carve

class CarveTests: XCTestCase {

	override func setUp() {
		super.setUp()
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDown() {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
		super.tearDown()
	}

	func testVectorPolynomial() {
		let f = VectorPolynomial(coefficients: [ CGPoint(x: 1, y: 1), CGPoint(x: 2, y: 1), CGPoint(x: 1, y: 0) ])

		XCTAssertEqual(f[1], CGPoint(x: 1, y: 0) + CGPoint(x: 2, y: 1) + CGPoint(x: 1, y: 1))
		XCTAssertEqual(f[0.5], CGPoint(x: 0.25, y: 0) + CGPoint(x: 1, y: 0.5) + CGPoint(x: 1, y: 1))

		let fʹ = f.derivative

		XCTAssertEqual(fʹ.coefficients, [CGPoint(x: 2, y: 1), CGPoint(x: 2, y: 0) ])
		XCTAssertEqual(fʹ[1], CGPoint(x: 2, y: 1) + CGPoint(x: 2, y: 0))
		XCTAssertEqual(fʹ[2], CGPoint(x: 2, y: 1) + CGPoint(x: 4, y: 0))

		let fʹʹ = fʹ.derivative
		XCTAssertEqual(fʹʹ.coefficients, [CGPoint(x: 2, y: 0) ])

		let fʹʹʹ = fʹʹ.derivative
		XCTAssertEqual(fʹʹʹ.coefficients, [])

		let fʹʹʹʹ = fʹʹʹ.derivative
		XCTAssertEqual(fʹʹʹʹ.coefficients, [])
	}

	func testPerformanceExample() {
		// This is an example of a performance test case.
		self.measureBlock {
			// Put the code you want to measure the time of here.
		}
	}

}
