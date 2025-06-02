//  Tella
//
//  Copyright © 2022 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension Sequence {
    func limit(_ max: Int) -> [Element] {
        return self.enumerated()
            .filter { $0.offset < max }
            .map { $0.element }
    }
    func asyncMap<T>( _ transform: (Element) async throws -> T) async rethrows -> [T] {
        var values = [T]()

        for element in self {
            try await values.append(transform(element))
        }

        return values
    }
}
