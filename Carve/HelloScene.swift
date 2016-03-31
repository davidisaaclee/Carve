//
//  HelloScene.swift
//  Carve
//
//  Created by David Lee on 3/27/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit

class HelloScene: SKScene {
	struct Avatar {
		var impulsePoint: CGPoint
		var impulseTimestamp: NSTimeInterval
		var impulseVelocity: CGPoint

		func positionForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
			let 𝝙time = timestamp - self.impulseTimestamp
			let gravity = CGPoint(x: 0, y: -9.8)

			// p(t) = g * t^2 + v * t + c
			return gravity * CGFloat(𝝙time) * CGFloat(𝝙time) + self.impulseVelocity * CGFloat(𝝙time) + self.impulsePoint
		}

		func velocityForTimestamp(timestamp: NSTimeInterval) -> CGPoint {
			let 𝝙time = timestamp - self.impulseTimestamp
			let gravity = CGPoint(x: 0, y: -9.8)

			// v(t) = 2g * t + v
			return gravity * 2.0 * CGFloat(𝝙time) + self.impulseVelocity
		}
	}

	struct State {
		var elapsed: NSTimeInterval
		var avatar: Avatar
		var curve: [CGPoint]?
		var curveBuffer: [CGPoint]?
		var isImpulseHappening: Bool
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

	private var contentCreated: Bool = false

	lazy var state: State =
		State(
			elapsed: 0,
			avatar: Avatar(impulsePoint: CGPoint(x: 0, y: self.size.height / 2), impulseTimestamp: 0, impulseVelocity: CGPoint(x: 10, y: 0)),
			curve: nil,
			curveBuffer: nil,
			isImpulseHappening: false)
	var input: Input = Input(𝝙time: 0, timestamp: nil, pointer: Input.PointerState.Up)

	override func didMoveToView(view: SKView) {
		if !self.contentCreated {
			self.setupScene()
			self.contentCreated = true
		}
	}

	override func update(currentTime: NSTimeInterval) {
		super.update(currentTime)

		guard self.contentCreated else { return }

		self.input = Input(𝝙time: self.input.timestamp.map { currentTime - $0 } ?? 0, timestamp: currentTime, pointer: self.input.pointer)
		self.state = self.reducer(self.state, input: self.input)

		self.draw(self.state)
	}

	private var currentTouch: UITouch?
	override func touchesBegan(touches: Set<UITouch>, withEvent event: UIEvent?) {
		guard self.currentTouch == nil else { return }

		guard let currentTouch = touches.first else { return }

		self.currentTouch = currentTouch

		let touchLocation = currentTouch.locationInNode(self)
		self.input.pointer = .Down(position: touchLocation)
	}

	override func touchesMoved(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.currentTouch.tap { currentTouch in
			let touchLocation = currentTouch.locationInNode(self)
			self.input.pointer = .Down(position: touchLocation)
		}
	}

	override func touchesEnded(touches: Set<UITouch>, withEvent event: UIEvent?) {
		self.currentTouch.tap { currentTouch in
			if touches.contains(currentTouch) {
				self.currentTouch = nil
				self.input.pointer = .Up
			}
		}
	}

	override func touchesCancelled(touches: Set<UITouch>?, withEvent event: UIEvent?) {
		self.currentTouch.tap { currentTouch in
			self.currentTouch = nil
			self.input.pointer = .Up
		}
	}



	func draw(state: State) {
		if let avatar = self.childNodeWithName("avatar") {
			avatar.position = self.state.avatar.positionForTimestamp(self.state.elapsed)
		}

		self.view?.layer.sublayers?.filter { $0.name == "line" }.forEach { $0.removeFromSuperlayer() }

		if let curve = state.curve {
			let lineLayer = CAShapeLayer()
			lineLayer.name = "line"
			lineLayer.strokeColor = UIColor.grayColor().CGColor
			lineLayer.fillColor = nil

			let path = self.pathFromPointSequence(curve.map { CGPoint(x: $0.x, y: self.size.height - $0.y) })

			lineLayer.path = path
			self.view?.layer.addSublayer(lineLayer)
		}
	}


	//

	func reducer(state: State, input: Input) -> State {
		let updateFromInput: State -> State = {
			self.updateImpulse(
				self.updateLine(
					self.updateTime(
						$0,
						𝝙time: input.𝝙time),
					pointer: input.pointer),
				pointer: input.pointer)
		}

		return updateFromInput(state)
	}





	func updateTime(state: State, 𝝙time: NSTimeInterval) -> State {
		var stateʹ = state
		stateʹ.elapsed = state.elapsed + 𝝙time
		return stateʹ
	}

	func updateLine(state: State, pointer: Input.PointerState) -> State {
		switch pointer {
		case .Up:
			if let curveBuffer = state.curveBuffer {
				var stateʹ = state
				stateʹ.curve = curveBuffer
				stateʹ.curveBuffer = nil
				return stateʹ
			} else {
				return state
			}

		case let .Down(position):
			var buffer = state.curveBuffer ?? []
			buffer.append(position)

			var stateʹ = state
			stateʹ.curveBuffer = buffer
			return stateʹ
		}
	}

	func updateImpulse(state: State, pointer: Input.PointerState) -> State {
		var stateʹ = state

		switch pointer {
		case .Up:
			if state.isImpulseHappening {
				stateʹ.isImpulseHappening = false
				stateʹ.avatar.impulsePoint = state.avatar.positionForTimestamp(state.elapsed)
				stateʹ.avatar.impulseTimestamp = state.elapsed
				stateʹ.avatar.impulseVelocity = state.avatar.velocityForTimestamp(state.elapsed) + CGPoint(x: 5, y: 10)
			}

		case .Down:
			stateʹ.isImpulseHappening = true
		}

		return stateʹ
	}


//	func applyGravity(state: State, 𝝙time: NSTimeInterval) -> State {
//		let accelerationFactor: Double = 9.8
//
//		var stateʹ = state
//		stateʹ.avatar.velocity = CGPoint(x: 0, y: 𝝙time * accelerationFactor) + state.avatar.velocity
//		return stateʹ
//	}
//
//	func updatePosition(state: State, 𝝙time: NSTimeInterval) -> State {
//		var stateʹ = state
//		stateʹ.avatar.position = state.avatar.position + state.avatar.velocity * CGFloat(𝝙time)
//		return stateʹ
//	}


	//

	func setupScene() {
		self.backgroundColor = SKColor.blueColor()
		self.scaleMode = .AspectFit

		self.addChild(self.makeRectNode())
	}

	func makeRectNode() -> SKNode {
		let node = SKSpriteNode(color: SKColor.greenColor(), size: CGSize(width: 100, height: 100))
		node.position = CGPoint(x: self.frame.midX, y: self.frame.midY)
		node.name = "avatar"
		return node
	}

	func pathFromPointSequence(points: [CGPoint]) -> CGPath {
		let path = UIBezierPath()
		points.first.tap(path.moveToPoint)
		points.forEach { path.addLineToPoint($0) }
		return path.CGPath
	}
}

protocol GameObject {
	var position: CGPoint { get }
	var velocity: CGPoint { get }
}


