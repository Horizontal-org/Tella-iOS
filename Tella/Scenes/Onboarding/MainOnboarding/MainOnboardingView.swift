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
    @StateObject var viewModel: MainOnboardingViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        VStack(spacing: 0) {
            tabView()
            bottomView()
                .frame(height: .bottomViewHeight)
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
        case .record(let content):
            OnboardingInfoView(content: content, info: LocalizableLock.onboardingRecordInfo.localized)
            
        case .files(let content):
            OnboardingInfoView(content: content, info: LocalizableLock.onboardingFilesInfo.localized)
            
        case .connections(let content):
            OnboardingConnectionsView(content: content)
            
        case .nearbySharing(let content):
            ImageTitleMessageView(content: content)
            
        case .allDone:
            OnboardingLockDoneView(appViewState: viewModel.lockViewModel.appViewState)
        }
    }
    
    func bottomView() -> some View {
        VStack(spacing: 2) {
            Spacer()
            
            PageDots(current: viewModel.index, total: viewModel.count)
                .padding(.smallMedium)
            
            NavigationBottomView<AnyView>(
                shouldActivateNext: Binding(get: { viewModel.canTapNext() }, set: { _ in }),
                nextButtonAction: .action,
                shouldHideNext: viewModel.shouldHideNext(),
                shouldHideBack: viewModel.shouldHideBack(),
                nextAction: {
                    guard viewModel.canTapNext() else { return }
                    
                    let page = viewModel.pages[viewModel.index]
                    
                    switch page {
                    case .nearbySharing:
                        self.present(style: .fullScreen, transitionStyle: .crossDissolve) {
                            LockChoiceOnboardingView(lockViewModel: viewModel.lockViewModel)
                        }
                    default:
                        viewModel.goNext()
                    }
                    
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
