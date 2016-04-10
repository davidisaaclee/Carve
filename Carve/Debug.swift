import Foundation
import SpriteKit
import VectorKit

struct Debug {
	var scene: SKScene?

	func debugPath(path: UIBezierPath, name: String) {
		self.scene?.view?.layer.sublayers?.filter { $0.name == name }.forEach { $0.removeFromSuperlayer() }

		let debugLayer = CAShapeLayer()
		debugLayer.name = name
		debugLayer.strokeColor = UIColor.purpleColor().CGColor
		debugLayer.lineWidth = 5
		debugLayer.fillColor = nil

		debugLayer.path = path.CGPath

		self.scene?.view?.layer.addSublayer(debugLayer)
	}

	func debugPoint(point: CGPoint, name: String, convert: Bool = false) {
		let point = convert ? self.scene!.convertPointToView(point) : point

		let size = CGPoint(x: 10, y: 10)
		let path = UIBezierPath(ovalInRect: CGRect(origin: point - size * 0.5, size: CGSize(width: size.x, height: size.y)))

		self.debugPath(path, name: name)
	}

	func debugVector(vector: CGPoint, startingPoint: CGPoint, name: String, convert: Bool = false) {
//		let scaleFactor = self.sceneToViewScaleFactor()
//		let vector = convert ? CGPoint(x: vector.x * scaleFactor.x, y: vector.y * scaleFactor.y) : vector
		let startingPoint = convert ? self.scene!.convertPointToView(startingPoint) : startingPoint

		let path = UIBezierPath()
		path.moveToPoint(startingPoint)
		path.addLineToPoint(startingPoint + vector)

		self.debugPath(path, name: name)
	}

	private func sceneToViewScaleFactor() -> CGPoint {
		let viewSize = self.scene!.view!.bounds.size
		let sceneSize = self.scene!.size

		return CGPoint(x: viewSize.width / sceneSize.width, y: viewSize.height / sceneSize.height)
	}
}
