//
//  GDriveListView.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GDriveListView: View {
    @Binding var reportArray : [GDriveReport]
    var message: String
    var body: some View {
        ZStack {
            if $reportArray.wrappedValue.count > 0 {
                ScrollView {
                    VStack(alignment: .center, spacing: 0) {
                        ForEach($reportArray, id: \.self) { report in
                            GDriveCardView(report: report)
                        }
                    }
                }
            } else {
                ConnectionEmptyView(message: message, type: .gDrive)
            }
        }
    }
}
