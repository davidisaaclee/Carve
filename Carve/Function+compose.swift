//
//  Function+compose.swift
//  Carve
//
//  Created by David Lee on 3/27/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation

infix operator • { associativity left }

func • <InputType, IntermediateType, OutputType>(outer: IntermediateType -> OutputType, inner: InputType -> IntermediateType) -> (InputType -> OutputType) {
	return { outer(inner($0)) }
}