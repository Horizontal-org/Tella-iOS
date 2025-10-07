//
//  ViewClassType.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/6/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import SwiftUI

struct ViewClassType {
    static let uwaziView : AnyClass = UIHostingController<ModifiedContent<UwaziView, _EnvironmentKeyWritingModifier<UwaziViewModel?>>>.self
    static let securitySettingsView : AnyClass = UIHostingController<Optional<SecuritySettingsView>>.self
    static let serversListView : AnyClass = UIHostingController<Optional<ModifiedContent<ServersListView, _EnvironmentKeyWritingModifier<Optional<ServersViewModel>>>>>.self
    static let reportMainView : AnyClass = UIHostingController<ReportMainView>.self
    static let nextcloudReportMainView : AnyClass = UIHostingController<NextcloudReportMainView>.self
    static let gdriveReportMainView : AnyClass = UIHostingController<GdriveReportMainView>.self
    static let tellaServerReportMainView : AnyClass = UIHostingController<TellaServerReportsMainView>.self
    static let dropboxReportMainView: AnyClass = UIHostingController<DropboxReportMainView>.self
    static let fileListView: AnyClass = UIHostingController<FileListView>.self
    static let serverOnboardingView: AnyClass = UIHostingController<ServerOnboardingView>.self
}

