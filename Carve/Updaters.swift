//
//  Updaters.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit
import VectorKit

extension Game {
	static func updateTime(state: State, 𝝙time: NSTimeInterval) -> State {
		var stateʹ = state
		stateʹ.elapsed = state.elapsed + 𝝙time
		return stateʹ
	}

	static func updateLine(state: State, pointer: Input.PointerState) -> State {
		switch pointer {
		case .Up:
			if let carveBuffer = state.carveBuffer {
				var stateʹ = state
				stateʹ.carve = Helpers.calculateCarve(carveBuffer, state: state, targetTime: state.elapsed + Constants.lookaheadTime)
				stateʹ.carveBuffer = nil
				return stateʹ
			} else {
				return state
			}

		case let .Down(position):
			var buffer = state.carveBuffer ?? []
			buffer.append(position)

			var stateʹ = state
			stateʹ.carveBuffer = buffer
			return stateʹ
		}
	}

	static func updateImpulse(state: State, pointer: Input.PointerState) -> State {
		var stateʹ = state

		switch pointer {
		case .Up:
			switch state.impulseState {
			case .Occurring:
				stateʹ.impulseState = .None
				stateʹ.avatar.impulsePoint = state.avatarPositionForTimestamp(state.elapsed)
				stateʹ.avatar.impulseTimestamp = state.elapsed
				stateʹ.avatar.impulseVelocity = CGPoint(x: state.avatarVelocityForTimestamp(state.elapsed).x, y: 30)

			case .None:
				break
			}
		case let .Down(position):
			let distanceToAvatarCenter = (position - state.avatarPositionForTimestamp(state.elapsed)).magnitude
			let impulseRadius: CGFloat = 50
			if distanceToAvatarCenter < impulseRadius {
				stateʹ.impulseState = .Occurring(position: position)
			} else {
				stateʹ.impulseState = .None
			}
		}

		return stateʹ
	}

	static func updateCarving(state: State) -> State {
		var stateʹ = state

		if let carve = state.carve {
			let 𝝙time = state.elapsed - state.avatar.impulseTimestamp
			let lookbehind = 0.1 // TODO: Store this in state?

			let prevPosition = state.avatarPositionForTimeSinceImpulse(𝝙time - lookbehind)
			let nextPosition = state.avatarPositionForTimeSinceImpulse(𝝙time)
			let segments = Helpers.segments(carve.pointSequence.map { $0 + carve.offsetToIntersection })

			if let intersectedSegment = segments.find({ Helpers.line(from: prevPosition, to: nextPosition, intersectsWithLineFrom: $0.0, to2: $0.1) != nil }) {
				let intersectionPoint = Helpers.line(from: prevPosition, to: nextPosition, intersectsWithLineFrom: intersectedSegment.0, to2: intersectedSegment.1)!
				let currentForce = state.avatarForceForTimestamp(state.elapsed)

				let segmentDirection = intersectedSegment.1 - intersectedSegment.0
//				let segmentSlope = segmentDirection.y / segmentDirection.x
//				let segmentAngle = atan(segmentSlope)
//				let parallelForce = segmentDirection.unit * currentForce.magnitude * sin(segmentAngle)

				let parallelForce = segmentDirection.unit * currentForce.magnitude

				stateʹ.avatar.impulsePoint = intersectionPoint
				stateʹ.avatar.impulseVelocity = parallelForce // not really
				stateʹ.avatar.impulseTimestamp = stateʹ.elapsed // also not really (calculate time at intersection?)
			}
		}

		return stateʹ
	}

}