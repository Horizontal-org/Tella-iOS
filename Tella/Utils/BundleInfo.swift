//
//  BundleInfo.swift
//  Tella
//
//  Created by Daniil Subbotin on 29.09.2020.
//  Copyright © 2020 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

public protocol BundleInfo {

    var versionNumber: String { get }

    var buildNumber: String { get }

    var name: String { get }
}

extension BundleInfo {

    public var version: String {
        "\(versionNumber)"
    }

    public var versionWithBuildNumber: String {
        "\(versionNumber) (\(buildNumber))"
    }
}

extension Bundle: BundleInfo {

    public var versionNumber: String {
        string(for: "CFBundleShortVersionString")
    }

    public var buildNumber: String {
        string(for: kCFBundleVersionKey as String)
    }

    public var name: String {
        string(for: kCFBundleNameKey as String)
    }

    private func string(for key: String) -> String {
        object(forInfoDictionaryKey: key) as? String ?? ""
    }
}
