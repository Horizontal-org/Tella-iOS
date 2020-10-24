//
//  AppViewState.swift
//  Tella
//
//  Created by Rance Tsai on 9/7/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

final class AppViewState: ObservableObject {
    @Published private var viewStack = [MainViewEnum]()

    var currentView: MainViewEnum {
        return viewStack.last ?? .AUTH
    }

    func navigateBack() {
        viewStack.removeLast()
    }

    func navigate(to view: MainViewEnum) {
        viewStack.append(view)
    }

    func resetToAuth() {
        viewStack = [.AUTH]
    }

    func resetToMain() {
        viewStack = [.MAIN]
    }
}
