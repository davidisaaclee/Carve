//
//  ViewController.swift
//  Carve
//
//  Created by David Lee on 3/27/16.
//  Copyright © 2016 David Lee. All rights reserved.
//

import UIKit
import SpriteKit

class ViewController: UIViewController {

	override func viewDidLoad() {
		super.viewDidLoad()

		if let spriteView = self.view as? SKView {
			spriteView.showsDrawCount = true
			spriteView.showsNodeCount = true
			spriteView.showsFPS = true
		}
	}

	override func viewWillAppear(animated: Bool) {
		let scene = HelloScene(size: self.view.bounds.size)
		if let spriteView = self.view as? SKView {
			spriteView.presentScene(scene)
		}
	}

}

