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
        ZStack {
            tabView()
            bottomView()
        }
        .containerStyle()
        .navigationBarHidden(true)
        .onReceive(viewModel.lockViewModel.shouldDismiss
            .filter { $0 }
        ) { _ in
            dismiss()
        }
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
    
    func handleSwipe(for page: OnboardingItem, direction: SwipeDirection) -> Bool {
        switch page {
        case .camera:
            return direction == .left
        case .recorder, .files, .connections, .nearbySharing:
            return true
        case .lock:
            return viewModel.isLockSucceeded ? (direction == .left) : (direction == .right)
        case .allDone:
            return direction == .right
        }
    }
    
    @ViewBuilder
    func view(for page: OnboardingItem) -> some View {
        switch page {
        case .camera(let content),
                .recorder(let content),
                .files(let content),
                .connections(let content),
                .nearbySharing(let content):
            OnboardingPageView(content: content)
            
        case .lock:
            if viewModel.isLockSucceeded {
                OnboardingSuccessLoginView()
            } else {
                LockChoiceView(lockViewModel: viewModel.lockViewModel)
            }
            
        case .allDone:
            OnboardingLockDoneView(appViewState: viewModel.lockViewModel.appViewState)
        }
    }
    
    func bottomView() -> some View {
        VStack(spacing: 2) {
            Spacer()
            
            PageDots(current: viewModel.index, total: viewModel.count)
                .padding(20)
            
            BottomLockView<AnyView>(
                isValid: Binding(get: { viewModel.canTapNext() }, set: { _ in }),
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

#Preview {
    MainOnboardingView(viewModel: MainOnboardingViewModel.stub())
}
