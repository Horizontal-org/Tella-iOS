//
//  NSRegularExpressionExtension.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. All rights reserved.
//

import Foundation

extension NSRegularExpression {
    func notMatchedIn(value:String) -> Bool {
        return (self.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil)
    }
}
