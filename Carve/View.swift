import Foundation
import SpriteKit

struct View {
	static func draw(state: State, scene: SKScene) {
		func drawAvatar(state: State) {
			if let avatar = scene.childNodeWithName("avatar") {
				avatar.position = state.avatarPositionForTimestamp(state.elapsed)
			}
		}

		func drawCarve(state: State) {
			scene.view?.layer.sublayers?.filter { $0.name == "carve" }.forEach { $0.removeFromSuperlayer() }

			if let carve = state.carve {
				let carveLayer = CAShapeLayer()
				carveLayer.name = "carve"
				carveLayer.strokeColor = UIColor.grayColor().CGColor
				carveLayer.lineWidth = 5
				carveLayer.fillColor = nil

				let viewPath = carve.pointSequence
					.map { $0 + carve.offsetToIntersection }
					.map(scene.convertPointToView)

				let path = Helpers.pathFromPointSequence(viewPath)
				carveLayer.path = path
				scene.view?.layer.addSublayer(carveLayer)
			}
		}

		drawAvatar(state)
		drawCarve(state)


		func debugPointSequence(pointSequence: [CGPoint], name: String, color: UIColor = UIColor.whiteColor()) {
			scene.view?.layer.sublayers?.filter { $0.name == name }.forEach { $0.removeFromSuperlayer() }
			let lineLayer = CAShapeLayer()
			lineLayer.name = name
			lineLayer.strokeColor = color.CGColor
			lineLayer.fillColor = nil

			let path = Helpers.pathFromPointSequence(pointSequence)

			lineLayer.path = path
			scene.view?.layer.addSublayer(lineLayer)
		}

		let trajectory: [CGPoint] =
			(0..<10)
				.map { state.avatarPositionForTimestamp(Double($0) + state.elapsed) }
				.map(scene.convertPointToView)


		let positionAtLookahead = state.avatarPositionForTimestamp(state.elapsed + Constants.lookaheadTime)
		let velocityAtLookahead = state.avatarVelocityForTimestamp(state.elapsed + Constants.lookaheadTime)

		let tangentAtLookahead: [CGPoint] =
			(-5..<5)
				.map { (n: Int) -> CGPoint in positionAtLookahead + velocityAtLookahead * (CGFloat(n) * 10.0) }
				.map(scene.convertPointToView)

		let intersectorAtLookahead: [CGPoint] =
			(-5..<5)
				.map { (n: Int) -> CGPoint in velocityAtLookahead * CGFloat(n) * 10.0 }
				.map { (v: CGPoint) -> CGPoint in CGPoint(x: -v.y, y: v.x) }
				.map { (v: CGPoint) -> CGPoint in v + positionAtLookahead }
				.map(scene.convertPointToView)

		debugPointSequence(trajectory, name: "trajectory")
//		debugPointSequence(tangentAtLookahead, name: "tangent at lookahead")
//		debugPointSequence(intersectorAtLookahead, name: "intersector at lookahead")
		state.carveBuffer
			.map { $0.map(scene.convertPointToView) }
			.tap { debugPointSequence($0, name: "carve buffer") }


		let v = state.avatarVelocityForTimestamp(state.elapsed)
		SharedDebug.debugVector(CGPoint(x: v.x, y: -v.y),
		                        startingPoint: state.avatarPositionForTimestamp(state.elapsed),
		                        name: "avatar velocity",
		                        convert: true)
	}
}