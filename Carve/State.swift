//
//  State.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit
import VectorKit

struct State {
	struct Avatar {
		var impulsePoint: CGPoint
		var impulseTimestamp: NSTimeInterval
		var impulseVelocity: CGPoint
	}
	
	struct Carve {
		var pointSequence: [CGPoint]
		var offsetToIntersection: CGPoint
	}

	enum Impulse {
		case Occurring(position: CGPoint)
		case None
	}

	var elapsed: NSTimeInterval
	var avatar: Avatar
	var carve: Carve?
	var carveBuffer: [CGPoint]?
	var impulseState: State.Impulse

	var positionFunction: VectorPolynomial<CGPoint> {
		return VectorPolynomial(coefficients: [ self.avatar.impulsePoint, self.avatar.impulseVelocity, Constants.gravity ])
	}

	func avatarPositionForTimeSinceImpulse(𝝙time: NSTimeInterval) -> CGPoint {
		return self.positionFunction[CGFloat(𝝙time)]
	}

	func avatarPositionForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let 𝝙time = timestamp - self.avatar.impulseTimestamp
		return self.avatarPositionForTimeSinceImpulse(𝝙time)
	}

	func avatarVelocityForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let 𝝙time = timestamp - self.avatar.impulseTimestamp
		return self.positionFunction.derivative[CGFloat(𝝙time)]
	}

	func avatarForceForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let mass: CGFloat = 1
		return Constants.gravity * mass
	}
}

struct Input {
	enum PointerState {
		case Down(position: CGPoint)
		case Up
	}

	let 𝝙time: NSTimeInterval
	let timestamp: NSTimeInterval?

	var pointer: PointerState
}