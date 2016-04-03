//
//  Helpers.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit

struct Helpers {
	static func calculateCarve(pointSequence: [CGPoint], avatar: Avatar, targetTime: NSTimeInterval) -> State.Carve {
		guard pointSequence.count > 2 else {
			return State.Carve(pointSequence: pointSequence, offsetToIntersection: CGPointZero)
		}

		let targetPoint = avatar.positionForTimestamp(targetTime)
		let targetTangent = avatar.velocityForTimestamp(targetTime)
		let targetSlope = targetTangent.y / targetTangent.x

		let closest = pointSequence.indices.dropFirst().dropLast().sort { (before, after) -> Bool in
			func slopeOfTangentToPointSequence(pointSequence: [CGPoint], atIndex index: Int) -> CGFloat {
				let previous = pointSequence[index.predecessor()]
				let next = pointSequence[index.successor()]

				let tangent = next - previous
				return tangent.y / tangent.x
			}

			let beforeSlope = slopeOfTangentToPointSequence(pointSequence, atIndex: before)
			let afterSlope = slopeOfTangentToPointSequence(pointSequence, atIndex: after)

			return (beforeSlope - targetSlope) < (afterSlope - targetSlope)
		}.first!

		return State.Carve(pointSequence: pointSequence, offsetToIntersection: targetPoint - pointSequence[closest])
	}


	static func pathFromPointSequence(points: [CGPoint], offset: CGPoint = CGPointZero) -> CGPath {
		let path = UIBezierPath()
		points.first
			.map { $0 + offset }
			.tap(path.moveToPoint)
		points
			.map { $0 + offset }
			.forEach { path.addLineToPoint($0) }
		return path.CGPath
	}
}