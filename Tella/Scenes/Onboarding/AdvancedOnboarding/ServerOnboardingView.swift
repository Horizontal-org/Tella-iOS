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
    var appViewState: AppViewState

    @StateObject var viewModel: ServerOnboardingViewModel
    @StateObject var serversViewModel: ServersViewModel

    var body: some View {
        ZStack {
            tabView()
            bottomView()
        }
        .containerStyle()
        .navigationBarHidden(true)
    }
    
    func tabView() -> some View {
        ControlledPager(
            pageCount: viewModel.count,
            index: $viewModel.index,
            canSwipe: { idx, direction in
                let page = viewModel.pages[idx]
                return handleSwipe(for: page, direction: direction)
            },
            content: { idx in
                let page = viewModel.pages[idx]
                view(for: page)
            }
        )
    }
    
    func handleSwipe(for page: ServerOnboardingItem, direction: SwipeDirection) -> Bool {
        switch page {
        case .main:
            return viewModel.isConnectionSucceded ? (direction == .left)
            : false
        case .customizationDone:
            return false
        }
    }
    
    @ViewBuilder
    func view(for page: ServerOnboardingItem) -> some View {
        switch page {
        case .main:
            if viewModel.isConnectionSucceded {
                ServerConnectedSuccessView()
            } else {
                MainServerOnboardingView(appViewState: appViewState, serversViewModel: serversViewModel)
            }
            
        case .customizationDone:
            AdvancedCustomizationCompleteView(appViewState: appViewState)
        }
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

