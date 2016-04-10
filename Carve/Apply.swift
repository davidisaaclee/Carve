//
//  Apply.swift
//  Carve
//
//  Created by David Lee on 4/10/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation

infix operator |> { associativity left precedence 130 }
func |> <I, O>(value: I, block: I -> O) -> O {
	return block(value)
}