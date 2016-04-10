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
		return self.updateTime(state, 𝝙time: input.𝝙time)
			|> { self.updateLine($0, pointer: input.pointer) }
			|> { self.updateImpulse($0, pointer: input.pointer) }
			|> { self.updateCarving($0) }
	}
}