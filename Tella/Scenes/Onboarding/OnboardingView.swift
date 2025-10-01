//
//  OnboardingView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 25/9/2025.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct OnboardingView: View {
    @StateObject private var viewModel: OnboardingViewModel
    
    init(viewModel: OnboardingViewModel) {
        _viewModel = StateObject(wrappedValue: viewModel)
    }
    
    var body: some View {
        ZStack {
            VStack(spacing: 0) {
                TabView(selection: $viewModel.index) {
                    ForEach(Array(viewModel.pages.enumerated()), id: \.element.id) { index, page in
                        page.view
                            .tag(index)
                    }
                }
                .padding(.horizontal, 24)
                .tabViewStyle(.page(indexDisplayMode: .never))
                
                PageDots(current: viewModel.index, total: viewModel.count)
                
                BottomLockView<AnyView>(
                    isValid: Binding(get: { viewModel.canGoNext }, set: { _ in }),
                    nextButtonAction: .action,
                    nextAction: { viewModel.goNext() },
                    backAction: { viewModel.goBack() }
                )
            }
        }
        .containerStyle()
    }
}

#Preview {
    OnboardingView(viewModel: OnboardingViewModel.stub())
}

// MARK: - Dots
private struct PageDots: View {
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
