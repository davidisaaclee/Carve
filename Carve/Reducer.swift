//
//  Reducer.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation

extension Game {
	static func reducer(state: State, input: Input) -> State {
		let updateFromInput: State -> State = {
			self.updateCarving(
				self.updateImpulse(
					self.updateLine(
						self.updateTime(
							$0,
							𝝙time: input.𝝙time),
						pointer: input.pointer),
					pointer: input.pointer))
		}

		return updateFromInput(state)
	}
}