//
//  ViewClassType.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/6/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

struct ViewClassType {
    static let uwaziView : AnyClass = UIHostingController<ModifiedContent<UwaziView, _EnvironmentKeyWritingModifier<UwaziViewModel?>>>.self
    static let securitySettingsView : AnyClass = UIHostingController<Optional<ModifiedContent<SecuritySettingsView, _EnvironmentKeyWritingModifier<Optional<SettingsViewModel>>>>>.self
    static let serversListView : AnyClass = UIHostingController<Optional<ModifiedContent<ServersListView, _EnvironmentKeyWritingModifier<Optional<ServersViewModel>>>>>.self
}

