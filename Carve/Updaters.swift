//
//  Updaters.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit

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
}