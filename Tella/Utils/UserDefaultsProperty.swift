//
//  UserDefaults.swift
//  Tella
//
//  Created by Rance Tsai on 8/12/20.
//  Copyright © 2020 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

@propertyWrapper
struct UserDefaultsProperty<T> {
    let key: String

    var wrappedValue: T? {
        get { UserDefaults.standard.object(forKey: key) as? T }
        set { UserDefaults.standard.set(newValue, forKey: key) }
    }
}

@propertyWrapper
struct RawValueUserDefaultsProperty<T: RawRepresentable> {
    let key: String
    let defaultValue: T

    init(_ key: String, defaultValue: T) {
        self.key = key
        self.defaultValue = defaultValue
    }

    var wrappedValue: T {
        get {
            guard let rawValue = UserDefaults.standard.object(forKey: key) as? T.RawValue, let value = T(rawValue: rawValue) else {
                 return defaultValue
            }
            return value
        }
        set {
            UserDefaults.standard.set(newValue.rawValue, forKey: key)
        }
    }
}
