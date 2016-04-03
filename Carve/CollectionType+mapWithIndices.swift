import Foundation

extension CollectionType {
	func mapWithIndices<T>(transform: (Self.Generator.Element, Self.Index) -> T) -> [T] {
		return self.indices
			.map { (self[$0], $0) }
			.map(transform)
	}
}