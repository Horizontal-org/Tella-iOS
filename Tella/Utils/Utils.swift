//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import UIKit
import AVFoundation
import SwiftUI

struct RuntimeError: Error {
    
    let message: String
    
    init(_ message: String) {
        self.message = message
    }
    
    public var localizedDescription: String {
        return message
    }
}

extension RuntimeError: LocalizedError {
    
    public var errorMessage: String? {
        return message
    }
}

extension EdgeInsets {
    init(vertical: CGFloat, horizontal: CGFloat) {
        self.init(top: vertical, leading: horizontal, bottom: vertical, trailing: horizontal)
    }
}

extension View {
    func eraseToAnyView() -> AnyView {
        AnyView(self)
    }
}
