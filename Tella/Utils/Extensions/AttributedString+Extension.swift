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

@available(iOS 15, *)
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

extension NSMutableAttributedString {
    func link(
        text: String,
        url: URL?) {
            let range = (string as NSString).range(of: text)
            guard range.location != NSNotFound else { return }
            
            if let url {
                addAttribute(.link, value: url, range: range)
            }
            addAttribute(.foregroundColor, value: Styles.Colors.yellow, range: range)
            addAttribute(.underlineStyle, value: NSUnderlineStyle.single.rawValue, range: range)
        }
}

extension NSAttributedString {
    static func + (lhs: NSAttributedString, rhs: NSAttributedString) -> NSAttributedString {
        let result = NSMutableAttributedString(attributedString: lhs)
        result.append(rhs)
        return result
    }
}


