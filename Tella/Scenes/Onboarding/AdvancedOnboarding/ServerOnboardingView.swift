//
//  ServerOnboardingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 3/10/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import Combine

struct ServerOnboardingView: View {
    @StateObject var viewModel: ServerOnboardingViewModel
    @StateObject var serversViewModel: ServersViewModel
    
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        ZStack {
            tabView()
            bottomView()
        }
        .containerStyle()
        .navigationBarHidden(true)
    }
    
    private func tabView() -> some View {
        TabView(selection: $viewModel.index) {
            ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                Group {
                    switch page {
                    case .main:
                        if viewModel.isConnectionSucceded {
                            ServerConnectedSuccessView()
                        } else {
                            MainServerOnboardingView(serversViewModel: serversViewModel)
                        }
                        
                    case .customizationDone:
                        AdvancedCustomizationCompleteView()
                    }
                }
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(
            .interactiveSpring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.2),
            value: viewModel.index
        )
    }
    
    private func bottomView() -> some View {
        VStack(spacing: 0) {
            Spacer()
            
            if viewModel.shouldShowDots {
                PageDots(current: viewModel.index, total: viewModel.count)
            }
            
            BottomLockView<AnyView>(
                isValid: Binding(get: { viewModel.canGoNext }, set: { _ in }),
                nextButtonAction: .action,
                shouldHideNext: viewModel.shouldHideNext,
                shouldHideBack: true,
                nextAction: { viewModel.goNext() }
            )
        }
    }
}
