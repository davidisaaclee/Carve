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

var SharedDebug = Debug(scene: nil)

class HelloScene: SKScene {
	private var contentCreated: Bool = false

	lazy var state: State =
		State(
			elapsed: 0,
			avatar: State.Avatar(impulsePoint: CGPoint(x: 0, y: self.size.height / 2), impulseTimestamp: 0, impulseVelocity: CGPoint(x: 20, y: 0)),
			carve: nil,
			carveBuffer: nil,
			impulseState: .None)
	var input: Input = Input(𝝙time: 0, timestamp: nil, pointer: Input.PointerState.Up)

	override func didMoveToView(view: SKView) {
		if !self.contentCreated {
			self.setupScene()
			self.contentCreated = true
		}
		
		SharedDebug.scene = self
	}

	override func update(currentTime: NSTimeInterval) {
		super.update(currentTime)

		guard self.contentCreated else { return }

		let scaledTime = currentTime * 1

		self.input =
			Input(
				𝝙time: self.input.timestamp.map { scaledTime - $0 } ?? 0,
				timestamp: scaledTime,
				pointer: self.input.pointer)

		self.state = Game.reducer(self.state, input: self.input)

		View.draw(self.state, scene: self)
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
}

