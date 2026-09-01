//
//  AttributedString+Extension.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 5/2/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

extension AttributedString {
    mutating func link(
        text: String,
        url: URL?) {
            guard let range = self.range(of: text) else { return }
            
            if let url {
                self[range].link = url
            }
            self[range].foregroundColor = Styles.Colors.yellow
            self[range].underlineStyle = .single
        }
}

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: lhs)
        result.append(rhs)
        return result
    }
}


