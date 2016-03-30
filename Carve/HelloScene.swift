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
	struct Avatar: GameObject {
		var position: CGPoint
		var velocity: CGPoint
	}

	struct State {
		var avatar: Avatar
		var curve: [CGPoint]?
		var curveBuffer: [CGPoint]?
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

	lazy var state: State = State(avatar: Avatar(position: CGPoint(x: 0, y: self.size.height / 2), velocity: CGPoint(x: 10, y: 0)), curve: nil, curveBuffer: nil)
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
			avatar.position = self.state.avatar.position
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
		let updateGame: State -> State = {
			self.updateLine($0, pointer: input.pointer)
		}

		let updatePhysics: State -> State = {
			self.updatePosition(
				$0,
//				self.applyGravity(
//					$0,
//					𝝙time: input.𝝙time),
				𝝙time: input.𝝙time)
		}

		return updatePhysics(updateGame(state))
	}






	func updateLine(state: State, pointer: Input.PointerState) -> State {
		switch pointer {
		case .Up:
			if let curveBuffer = state.curveBuffer {
				return State(avatar: state.avatar, curve: curveBuffer, curveBuffer: nil)
			} else {
				return state
			}

		case let .Down(position):
			var buffer = state.curveBuffer ?? []
			buffer.append(position)

			return State(avatar: state.avatar, curve: state.curve, curveBuffer: buffer)
		}
	}


	func applyGravity(state: State, 𝝙time: NSTimeInterval) -> State {
		let accelerationFactor: Double = 9.8

		var stateʹ = state
		stateʹ.avatar.velocity = CGPoint(x: 0, y: 𝝙time * accelerationFactor) + state.avatar.velocity
		return stateʹ
	}

	func updatePosition(state: State, 𝝙time: NSTimeInterval) -> State {
		var stateʹ = state
		stateʹ.avatar.position = state.avatar.position + state.avatar.velocity * CGFloat(𝝙time)
		return stateʹ
	}


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


