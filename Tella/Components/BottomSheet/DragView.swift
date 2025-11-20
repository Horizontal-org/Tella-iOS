//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI


// MARK: - DragView
public struct DragView<Content: View>: View {
    // Required
    @Binding private var isPresented: Bool
    private let content: Content
    private let presentationType: PresentationType // TODO: To be updated
    
    // Appearance / behavior knobs
    private var backgroundColor: Color = Styles.Colors.backgroundTab
    private let cornerRadius: CGFloat
    private let maxHeightRatio: CGFloat
    private let tapToDismiss: Bool
    private let dismissDuration: Double
    
    // Gesture / layout state
    @GestureState private var dragState: CGFloat = 0
    @State private var dragOffset: CGFloat = 0
    @State private var contentHeight: CGFloat = 0
    
    // Tunables
    private let minDismissThreshold: CGFloat = 100
    
    // Animations
    private var presentAnimation: Animation { .spring(response: 0.30, dampingFraction: 0.85) }
    private var dismissAnimation: Animation { .easeOut(duration: dismissDuration) }
    
    // Safe bottom inset
    private var bottomInset: CGFloat {
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene {
            let window = scene.windows.first(where: { $0.isKeyWindow }) ?? scene.windows.first
            return window?.safeAreaInsets.bottom ?? 0
        }
        return 0
    }
    private var maxSheetHeight: CGFloat { UIScreen.main.bounds.height * maxHeightRatio }
    
    // MARK: Init
    public init(
        isPresented: Binding<Bool>,
        presentationType: PresentationType,
        backgroundColor: Color,
        cornerRadius: CGFloat = 20,
        maxHeightRatio: CGFloat = 0.85,
        tapToDismiss: Bool = true,
        dismissDuration: Double = 0.18,
        @ViewBuilder content: () -> Content
    ) {
        self._isPresented = isPresented
        self.backgroundColor = backgroundColor
        self.cornerRadius = cornerRadius
        self.maxHeightRatio = max(0.3, min(maxHeightRatio, 1.0))
        self.tapToDismiss = tapToDismiss
        self.dismissDuration = dismissDuration
        self.presentationType = presentationType
        self.content = content()
    }
    
    // MARK: Body
    public var body: some View {
        ZStack(alignment: .bottom) {
            
            // Backdrop
            if isPresented {
                Color.black.opacity(0.4)
                    .ignoresSafeArea()
                    .contentShape(Rectangle())
                    .onTapGesture { if tapToDismiss { dismissAnimated() } }
                    .transition(.opacity)
            }
            
            // Sheet
            if isPresented {
                VStack(spacing: 0) {
                    Spacer()
                    
                    // Content
                    content
                        .fixedSize(horizontal: false, vertical: true)
                        .background(
                            GeometryReader { g in
                                Color.clear
                                    .onAppear { contentHeight = g.size.height }
                                    .onChange(of: g.size.height) { contentHeight = $0 }
                            }
                        )
                        .padding(.horizontal, 24)
                        .padding(.vertical, 20)
                }
                .padding(.bottom, bottomInset)
                
                // 2) Paint backgrounds
                .background(backgroundColor)
                .background(backgroundColor.ignoresSafeArea(edges: .bottom))
                
                // 3) Mask after both backgrounds so the radius stays
                .compositingGroup()
                .mask(
                    RoundedCorner(radius: cornerRadius, corners: [.topLeft, .topRight])
                        .padding(.bottom, -bottomInset)
                )
                
                // 4) Effects & layout
                .shadow(color: .black.opacity(0.15), radius: 10, x: 0, y: -5)
                .frame(maxWidth: .infinity)
                .frame(
                    maxHeight: min(
                        maxSheetHeight,
                        contentHeight
                    )
                )
                .offset(y: currentOffset)
                .gesture(dragGesture)
            }
        }
        .animation(isPresented ? presentAnimation : nil, value: isPresented)
        .animation(.spring(response: 0.28, dampingFraction: 0.9), value: dragState)
    }
    
    // MARK: Helpers
    
    private var currentOffset: CGFloat {
        isPresented ? (dragOffset + dragState) : UIScreen.main.bounds.height
    }
    
    private var dragGesture: some Gesture {
        DragGesture()
            .updating($dragState) { value, state, _ in
                state = max(0, value.translation.height)
            }
            .onEnded { value in
                let drag = value.translation.height
                let predicted = value.predictedEndTranslation.height
                let shouldDismiss = drag > minDismissThreshold || predicted > 300
                if shouldDismiss {
                    dismissAnimated()
                } else {
                    withAnimation(.spring(response: 0.28, dampingFraction: 0.9)) {
                        dragOffset = 0
                    }
                }
            }
    }
    
    private func dismissAnimated() {
        withAnimation(dismissAnimation) {
            if presentationType == .present {
                self.dismiss()
            } else {
                isPresented = false
                dragOffset = 0
            }
        }
    }
}

public enum PresentationType {
    case present // Present/dismiss the bottom sheet view
    case show // show/hide the bottom sheet in ZStack from home
}
