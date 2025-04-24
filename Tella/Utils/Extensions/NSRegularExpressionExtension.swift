//
//  NSRegularExpressionExtension.swift
//  Tella
//
//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

extension NSRegularExpression {
    func notMatchedIn(value:String) -> Bool {
        return (self.firstMatch(in: value, options: [], range: NSRange(location: 0, length: value.count)) == nil)
    }
}
