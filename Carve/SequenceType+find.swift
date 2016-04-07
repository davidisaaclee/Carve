import Foundation

extension SequenceType {
	func find(predicate: Self.Generator.Element -> Bool) -> Self.Generator.Element? {
		var generator = self.generate()

		while let next = generator.next() {
			if predicate(next) {
				return next
			}
		}

		return nil
	}
}