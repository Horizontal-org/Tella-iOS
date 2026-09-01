//
//  MainOnboardingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI
import Combine

struct MainOnboardingView: View {
    @ObservedObject var viewModel: MainOnboardingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 0) {
            tabView()

            bottomView()
                .frame(height: .bottomViewHeight)
                .opacity(viewModel.isOnWelcome ? 0 : 1)
                .allowsHitTesting(!viewModel.isOnWelcome)
                .accessibilityHidden(viewModel.isOnWelcome)
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
                return viewModel.handleSwipe(for: page, direction: direction)
            },
            content: { idx in
                let page = viewModel.pages[idx]
                view(for: page)
            }
        )
    }
    
    @ViewBuilder
    func view(for page: OnboardingItem) -> some View {
        switch page {
        case .welcome:
            TransitionView(transitionViewData: WelcomeViewData()) {
                viewModel.goNext()
            }

        case .record(let content):
            OnboardingInfoView(content: content, info: LocalizableLock.onboardingRecordInfo.localized)
            
        case .files(let content):
            OnboardingInfoView(content: content, info: LocalizableLock.onboardingFilesInfo.localized)
            
        case .connections(let content):
            OnboardingConnectionsView(content: content)
            
        case .nearbySharing(let content):
            ImageTitleMessageView(content: content)
                .padding(.horizontal, .medium)

        case .lockChoice:
            LockChoiceView(lockViewModel: viewModel.lockViewModel)

            
        case .allDone:
            OnboardingLockDoneView(appViewState: viewModel.lockViewModel.appViewState)
        }
    }
    
    func bottomView() -> some View {
        VStack(spacing: 2) {
            Spacer()
            
            PageDots(current: viewModel.dotIndex, total: viewModel.dotCount)
                .padding(.smallMedium)
            
            NavigationBottomView<AnyView>(
                shouldActivateNext: Binding(get: { viewModel.canTapNext() }, set: { _ in }),
                nextButtonAction: .action,
                shouldHideNext: viewModel.shouldHideNext(),
                shouldHideBack: viewModel.shouldHideBack(),
                nextAction: {
                    guard viewModel.canTapNext() else { return }
                    viewModel.goNext()
                },
                backAction: {
                    if viewModel.canTapBack() {
                        viewModel.goBack()
                    } else {
                        presentationMode.wrappedValue.dismiss()
                    }
                }
            )
        }
    }
}

#Preview {
    MainOnboardingView(viewModel: MainOnboardingViewModel.stub())
}
