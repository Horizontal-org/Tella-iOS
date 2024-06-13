//
//  GDriveListView.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GDriveListView: View {
    var message: String
    var body: some View {
        ConnectionEmptyView(message: message, type: .gDrive)
    }
}

#Preview {
    GDriveListView(message: "You have no drafts")
}
