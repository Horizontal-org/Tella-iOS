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
    @StateObject var lockViewModel: LockViewModel
    @State var isLockSucceded: Bool = false
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    
    var body: some View {
        
        ZStack {
            tabView()
            bottomView()
        }
        .containerStyle()
        .navigationBarHidden(true)
        .onReceive(lockViewModel.shouldDismiss) { shouldDismiss in
            guard shouldDismiss else { return }
            isLockSucceded = true
            self.dismiss()
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
            return isLockSucceded ? (direction == .left)
            : (direction == .right)
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
                if isLockSucceded {
                    OnboardingSuccessLoginView()
                } else {
                    LockChoiceView(lockViewModel: lockViewModel)
                }

        case .allDone:
            OnboardingLockDoneView()
        }
    }
    
    func bottomView() -> some View {
        VStack(spacing: 2) {
            Spacer()
            
            PageDots(current: viewModel.index, total: viewModel.count)
                .padding(20)
            
            BottomLockView<AnyView>(
                isValid: Binding(get: { viewModel.canGoNext }, set: { _ in }),
                nextButtonAction: .action,
                shouldHideNext: viewModel.shouldHideNext(isLockSucceeded: isLockSucceded),
                shouldHideBack: viewModel.shouldHideBack(isLockSucceeded: isLockSucceded),
                nextAction: {
                    if viewModel.canGoNext { viewModel.goNext() }
                },
                backAction: {
                    if viewModel.canGoBack {
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
    MainOnboardingView(viewModel: MainOnboardingViewModel.stub(), lockViewModel: LockViewModel.stub())
}
