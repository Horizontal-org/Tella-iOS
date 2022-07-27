//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

enum DragState {
    case inactive
    case dragging(translation: CGSize)
    
    var translation: CGSize {
        switch self {
        case .inactive:
            return .zero
        case .dragging(let translation):
            return translation
        }
    }
    
    var isDragging: Bool {
        switch self {
        case .inactive:
            return false
        case .dragging:
            return true
        }
    }
}

struct DragView<Content: View> : View {
    
    var modalHeight:CGFloat
    var shouldHideOnTap : Bool = true
    var showWithAnimation : Bool = false
    var backgroundColor: Color = Styles.Colors.backgroundTab
    
    @Binding var isShown:Bool
    
    
    @GestureState private var dragState = DragState.inactive
    @State private var value: CGFloat = 0
    @EnvironmentObject var sheetManager: SheetManager
    
    
    private func onDragEnded(drag: DragGesture.Value) {
        let dragThreshold = modalHeight * (2/3)
        if drag.predictedEndTranslation.height > dragThreshold || drag.translation.height > dragThreshold{
            isShown = false
            sheetManager.hide()
            UIApplication.shared.endEditing()
            
        }
    }
    
    var content: () -> Content
    var body: some View {
        let drag = DragGesture()
            .updating($dragState) { drag, state, transaction in
                state = .dragging(translation: drag.translation)
            }
            .onEnded(onDragEnded)
        return Group {
            GeometryReader { geometry in
                ZStack {
                    //Background
                    Spacer()
                        .edgesIgnoringSafeArea(.all)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .background(isShown ?
                                    Color.black.opacity( 0.5 * fraction_progress(lowerLimit: 0,
                                                                                 upperLimit: Double(modalHeight),
                                                                                 current: Double(dragState.translation.height),
                                                                                 inverted: true)
                                    )
                                    : nil)
                        .if (showWithAnimation) {
                            $0.animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                        }
                        .gesture(
                            TapGesture()
                                .onEnded { _ in
                                    if shouldHideOnTap {
                                        self.isShown = false
                                        UIApplication.shared.endEditing()
                                    }
                                })

                    //Foreground
                    VStack{
                        Spacer()
                        ZStack{
                            self.content()
                                .frame(width: UIScreen.main.bounds.size.width, height:modalHeight)
                                .background(backgroundColor.opacity(1.0))
                                .cornerRadius(25, corners: [.topLeft, .topRight])
                                .edgesIgnoringSafeArea(.all)
                        }
                        .offset(y: isShown ? ((self.dragState.isDragging && dragState.translation.height >= 1) ? dragState.translation.height - self.value : -self.value) : modalHeight)
                        .if (showWithAnimation) {
                            $0.animation(.interpolatingSpring(stiffness: 300.0, damping: 30.0, initialVelocity: 10.0))
                        }
                        .if (shouldHideOnTap) {
                            $0.gesture(drag)
                        }
                    }
                }}.edgesIgnoringSafeArea(.all)
                .if (showWithAnimation) {
                    $0.animation(.spring())
                }
              
                .onAppear{
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) {(noti) in
                        if isShown {
                            let keyboardFrame = noti.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect
                            self.value = keyboardFrame?.height ?? 0
                        }
                    }
                    NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) {(noti) in
                        self.value = 0
                    }
                }
            
        }
    }
}

func fraction_progress(lowerLimit: Double = 0, upperLimit:Double, current:Double, inverted:Bool = false) -> Double{
    var val:Double = 0
    if current >= upperLimit {
        val = 1
    } else if current <= lowerLimit {
        val = 0
    } else {
        val = (current - lowerLimit)/(upperLimit - lowerLimit)
    }
    
    if inverted {
        return (1 - val)
        
    } else {
        return val
    }
    
}

struct RoundedCorner: Shape {
    
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

