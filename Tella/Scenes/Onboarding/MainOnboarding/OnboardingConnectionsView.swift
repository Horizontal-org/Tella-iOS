//
//  OnboardingConnectionsView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 14/1/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct OnboardingConnectionsView: View {
    
    let content: any ImageTitleMessageContent
    
    private var gridLayout: [GridItem] {
        [
            GridItem(.flexible()),
            GridItem(.flexible()),
            GridItem(.flexible())
        ]
    }
    
    struct Connection {
        let icon: ImageResource
        let title: String
    }
    
    static var connections: [Connection] {
        [
            .init(icon: .onboardDropbox,
                  title: LocalizableLock.onboardingConnectionsDropbox.localized),
            .init(icon: .onboardGoogledrive,
                  title: LocalizableLock.onboardingConnectionsGDrive.localized),
            .init(icon: .onboardNextcloud,
                  title: LocalizableLock.onboardingConnectionsNextcloud.localized),
            .init(icon: .onboardUwazi,
                  title: LocalizableLock.onboardingConnectionsUwazi.localized),
            .init(icon: .onboardTella,
                  title: LocalizableLock.onboardingConnectionsTellaWeb.localized)
        ]
    }
    
    var body: some View {
        VStack(spacing: .medium) {
            ImageTitleMessageView(content: content)
            connectionsView
        }
        .padding(.horizontal, .medium)
    }
    
    private var connectionsView: some View {
        VStack(spacing: .medium) {
            LazyVGrid(columns: gridLayout, alignment: .center, spacing: .normal) {
                ForEach(Array(Self.connections.prefix(3)), id: \.title) { connection in
                    connectionItem(connection: connection)
                }
            }
            
            HStack {
                Spacer()
                
                if let firstItem = Self.connections[safe: 3] {
                    connectionItem(connection: firstItem)
                }
                Spacer()
                
                if let secondItem = Self.connections[safe: 4] {
                    connectionItem(connection: secondItem)
                }
                
                Spacer()
            }
        }
    }
    
    private func connectionItem(connection: Connection) -> some View {
        VStack {
            Image(connection.icon)
                .frame(width: .mediumIconSize, height: .mediumIconSize)
            Text(connection.title)
                .font(.custom(Styles.Fonts.regularFontName, size: 12))
                .foregroundColor(.white)
        }
    }
}

#Preview {
    OnboardingConnectionsView(content: RecordContent())
}
