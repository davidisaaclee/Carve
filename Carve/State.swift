//
//  State.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit

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

	func avatarPositionForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let 𝝙time = timestamp - self.avatar.impulseTimestamp

		// p(t) = g * t^2 + v * t + c
		return Constants.gravity * CGFloat(𝝙time) * CGFloat(𝝙time) + self.avatar.impulseVelocity * CGFloat(𝝙time) + self.avatar.impulsePoint
	}

	func avatarVelocityForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
		let 𝝙time = timestamp - self.avatar.impulseTimestamp

		// v(t) = 2g * t + v
		return Constants.gravity * 2.0 * CGFloat(𝝙time) + self.avatar.impulseVelocity
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