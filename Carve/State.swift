//
//  State.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit

struct Avatar {
	var impulsePoint: CGPoint
	var impulseTimestamp: NSTimeInterval
	var impulseVelocity: CGPoint

	func positionForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let 𝝙time = timestamp - self.impulseTimestamp
		let gravity = CGPoint(x: 0, y: -9.8)

		// p(t) = g * t^2 + v * t + c
		return gravity * CGFloat(𝝙time) * CGFloat(𝝙time) + self.impulseVelocity * CGFloat(𝝙time) + self.impulsePoint
	}

	func velocityForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let 𝝙time = timestamp - self.impulseTimestamp
		let gravity = CGPoint(x: 0, y: -9.8)

		// v(t) = 2g * t + v
		return gravity * 2.0 * CGFloat(𝝙time) + self.impulseVelocity
	}
}

struct State {
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