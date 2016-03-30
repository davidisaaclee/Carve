//
//  Optional.swift
//  Plyn
//
//  Created by David Lee on 2/28/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation

extension Optional {
  func withDefault(value: Wrapped) -> Wrapped {
    return self ?? value
  }
}