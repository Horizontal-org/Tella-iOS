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
    
    private var isSwipeAllowed: Bool {
        viewModel.pages[viewModel.index] != .lock &&  viewModel.pages[viewModel.index] != .allDone
    }

    var body: some View {
        ContainerView {
            
            ZStack {
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
                .highPriorityGesture(DragGesture())

                VStack(spacing: 2) {
                    Spacer()
                    PageDots(current: viewModel.index, total: viewModel.count)
                        .padding(20)
                    
                    BottomLockView<AnyView>(
                        isValid: Binding(get: { viewModel.canGoNext }, set: { _ in }),
                        nextButtonAction: .action,
                        shouldHideNext: (viewModel.pages[viewModel.index] == .lock && !isLockSucceded) || (viewModel.pages[viewModel.index] == .allDone),
                        shouldHideBack: (viewModel.pages[viewModel.index] == .lock && isLockSucceded) || (viewModel.pages[viewModel.index] == .allDone) ,
                        nextAction: {
                            if viewModel.canGoNext {
                                viewModel.goNext()
                            }
                        },
                        backAction: {
                            if viewModel.canGoBack {
                                viewModel.goBack()
                            } else {
                                self.presentationMode.wrappedValue.dismiss()
                            }
                        }
                    )
                }
            }
        }
        .containerStyle()
        .navigationBarHidden(true)
        .onReceive(lockViewModel.shouldDismiss) { shouldDismiss in
            if shouldDismiss {
                self.dismiss {
                    isLockSucceded = true
                }
            }
        }
        
    }
    
}

//#Preview {
//    OnboardingView(viewModel: OnboardingViewModel.stub())
//}

// MARK: - Dots
struct PageDots: View {
    let current: Int
    let total: Int
    
    var body: some View {
        HStack(spacing: 10) {
            ForEach(0..<total, id: \.self) { index in
                Circle()
                    .fill(current == index ? Styles.Colors.yellow
                          : Styles.Colors.gray.opacity(0.6))
                    .frame(width: 10, height: 10)
            }
        }
    }
}




