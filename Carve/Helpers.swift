//
//  Helpers.swift
//  Carve
//
//  Created by David Lee on 4/3/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit
import VectorKit

struct Helpers {
	static func calculateCarve(pointSequence: [CGPoint], state: State, targetTime: NSTimeInterval) -> State.Carve {
		guard pointSequence.count > 2 else {
			return State.Carve(pointSequence: pointSequence, offsetToIntersection: CGPointZero)
		}

		// TODO: need state here
		let targetPoint = state.avatarPositionForTimestamp(targetTime)
		let targetTangent = state.avatarVelocityForTimestamp(targetTime)
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

			return abs(beforeSlope - targetSlope) < abs(afterSlope - targetSlope)
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

	/*
		[a, b, c]			-> [(a, b), (b, c)]
		[a, b, c, d]		-> [(a, b), (b, c), (c, d)]
		[a]						-> []
		[]						-> []
	*/
	static func segments<T: SequenceType>(sequence: T) -> [(T.Generator.Element, T.Generator.Element)] {
		var generator = sequence.generate()

		guard var previous = generator.next() else {
			return []
		}

		var accumulator: [(T.Generator.Element, T.Generator.Element)] = []
		while let next = generator.next() {
			accumulator.append((previous, next))
			previous = next
		}

		return accumulator
	}


	static func line(from from1: CGPoint, to to1: CGPoint, intersectsWithLineFrom from2: CGPoint, to2: CGPoint) -> CGPoint? {
		// stolen from: http://stackoverflow.com/questions/13999249/uibezierpath-intersect/14301701#14301701
		func intersectionBetweenSegments(p0: CGPoint, _ p1: CGPoint, _ p2: CGPoint, _ p3: CGPoint) -> CGPoint? {
			var denominator = (p3.y - p2.y) * (p1.x - p0.x) - (p3.x - p2.x) * (p1.y - p0.y)
			var ua = (p3.x - p2.x) * (p0.y - p2.y) - (p3.y - p2.y) * (p0.x - p2.x)
			var ub = (p1.x - p0.x) * (p0.y - p2.y) - (p1.y - p0.y) * (p0.x - p2.x)
			if (denominator < 0) {
				ua = -ua; ub = -ub; denominator = -denominator
			}

			if ua >= 0.0 && ua <= denominator && ub >= 0.0 && ub <= denominator && denominator != 0 {
				return CGPoint(x: p0.x + ua / denominator * (p1.x - p0.x), y: p0.y + ua / denominator * (p1.y - p0.y))
			}

			return nil
		}

		return intersectionBetweenSegments(from1, to1, from2, to2)
	}

}