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
        TabView(selection: $viewModel.index) {
            ForEach(Array(viewModel.pages.enumerated()), id: \.offset) { index, page in
                Group {
                    switch page {
                    case let .intro(content):
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
                .tag(index)
            }
        }
        .tabViewStyle(.page(indexDisplayMode: .never))
        .animation(.interactiveSpring(response: 0.35, dampingFraction: 0.9, blendDuration: 0.2),
                   value: viewModel.index)
        
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
