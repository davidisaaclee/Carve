//
//  HelloScene.swift
//  Carve
//
//  Created by David Lee on 3/27/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import Foundation
import SpriteKit

struct Game {}

class HelloScene: SKScene {
	private var contentCreated: Bool = false

	lazy var state: State =
		State(
			elapsed: 0,
			avatar: Avatar(impulsePoint: CGPoint(x: 0, y: self.size.height / 2), impulseTimestamp: 0, impulseVelocity: CGPoint(x: 20, y: 0)),
			carve: nil,
			carveBuffer: nil,
			impulseState: .None)
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

		let scaledTime = currentTime * 0.5

		self.input =
			Input(
				𝝙time: self.input.timestamp.map { scaledTime - $0 } ?? 0,
				timestamp: scaledTime,
				pointer: self.input.pointer)

		self.state = Game.reducer(self.state, input: self.input)

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
		func drawAvatar(state: State) {
			if let avatar = self.childNodeWithName("avatar") {
				avatar.position = self.state.avatar.positionForTimestamp(self.state.elapsed)
			}
		}

		func drawCarve(state: State) {
			self.view?.layer.sublayers?.filter { $0.name == "carve" }.forEach { $0.removeFromSuperlayer() }

			if let carve = state.carve {
				let carveLayer = CAShapeLayer()
				carveLayer.name = "carve"
				carveLayer.strokeColor = UIColor.grayColor().CGColor
				carveLayer.lineWidth = 5
				carveLayer.fillColor = nil

				let viewPath = carve.pointSequence
					.map { $0 + carve.offsetToIntersection }
					.map(self.convertPointToView)

				let path = Helpers.pathFromPointSequence(viewPath)
				carveLayer.path = path
				self.view?.layer.addSublayer(carveLayer)
			}
		}

		drawAvatar(state)
		drawCarve(state)


		func debugPointSequence(pointSequence: [CGPoint], name: String, color: UIColor = UIColor.whiteColor()) {
			self.view?.layer.sublayers?.filter { $0.name == name }.forEach { $0.removeFromSuperlayer() }
			let lineLayer = CAShapeLayer()
			lineLayer.name = name
			lineLayer.strokeColor = color.CGColor
			lineLayer.fillColor = nil

			let path = Helpers.pathFromPointSequence(pointSequence)

			lineLayer.path = path
			self.view?.layer.addSublayer(lineLayer)
		}

		let trajectory: [CGPoint] =
			(0..<10)
				.map { state.avatar.positionForTimestamp(Double($0) + state.elapsed) }
				.map(self.convertPointToView)


		let positionAtLookahead = state.avatar.positionForTimestamp(state.elapsed + Constants.lookaheadTime)
		let velocityAtLookahead = state.avatar.velocityForTimestamp(state.elapsed + Constants.lookaheadTime)

		let tangentAtLookahead: [CGPoint] =
			(-5..<5)
				.map { (n: Int) -> CGPoint in positionAtLookahead + velocityAtLookahead * (CGFloat(n) * 10.0) }
				.map(self.convertPointToView)

		let intersectorAtLookahead: [CGPoint] =
			(-5..<5)
				.map { (n: Int) -> CGPoint in velocityAtLookahead * CGFloat(n) * 10.0 }
				.map { (v: CGPoint) -> CGPoint in CGPoint(x: -v.y, y: v.x) }
				.map { (v: CGPoint) -> CGPoint in v + positionAtLookahead }
				.map(self.convertPointToView)

		debugPointSequence(trajectory, name: "trajectory")
		debugPointSequence(tangentAtLookahead, name: "tangent at lookahead")
		debugPointSequence(intersectorAtLookahead, name: "intersector at lookahead")
		state.carveBuffer
			.map { $0.map(self.convertPointToView) }
			.tap { debugPointSequence($0, name: "carve buffer") }
	}


	//



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

	private func debugPath(path: UIBezierPath, name: String) {
		self.view?.layer.sublayers?.filter { $0.name == name }.forEach { $0.removeFromSuperlayer() }

		let debugLayer = CAShapeLayer()
		debugLayer.name = name
		debugLayer.strokeColor = UIColor.greenColor().CGColor
		debugLayer.lineWidth = 5
		debugLayer.fillColor = nil

		debugLayer.path = path.CGPath

		self.view?.layer.addSublayer(debugLayer)
	}

	private func debugPoint(point: CGPoint, name: String) {
		let size = CGPoint(x: 10, y: 10)
		let path = UIBezierPath(ovalInRect: CGRect(origin: point - size * 0.5, size: CGSize(width: size.x, height: size.y)))

		self.debugPath(path, name: name)
	}

	private func debugVector(vector: CGPoint, startingPoint: CGPoint, name: String) {
		let path = UIBezierPath()
		path.moveToPoint(startingPoint)
		path.addLineToPoint(startingPoint + vector)
		self.debugPath(path, name: name)
	}
}

