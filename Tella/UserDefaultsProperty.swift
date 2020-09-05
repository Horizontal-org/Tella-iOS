//
//  UserDefaults.swift
//  Tella
//
//  Created by Rance Tsai on 8/12/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
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
