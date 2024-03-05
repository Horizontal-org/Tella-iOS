//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TopSheetView<Content:View>: View {
    
    //MARK: - Properties
    private var kMinHeight: CGFloat {
        return childSize.height > 130 ? 320.0 + safeArea.top : 200 + safeArea.top
    }
    
    private let kmaxDrag: CGFloat =  UIScreen.main.bounds.height - 50
    private let kMinVelocity: CGFloat = -300
    
    @State private var offset: CGFloat = 0.0
    @State private var currentDrag: CGFloat = 0.0
    @State private var currentHeight: CGFloat = 320.0 + safeArea.top
    
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @State var childSize: CGSize = .zero
    
    var content :  Content
    
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .top) {
                backgroundView(geometry: geometry)
                contentView
                    .gesture(dragGesture)
            }
        }  .edgesIgnoringSafeArea(.all)
    }
    
    private func backgroundView(geometry:GeometryProxy) -> some View {
        Group {
            Spacer()
                .edgesIgnoringSafeArea(.all)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(
                    Color.black.opacity(0.6 * fractionProgress(lowerLimit: 0,
                                                                upperLimit: kmaxDrag,
                                                                current: self.currentHeight + currentDrag,
                                                                inverted: true)
                    )
                )
        }
    }
    
    private var contentView : some View {
        VStack(alignment: .center) {
            Spacer()
                .frame(height: safeArea.top)
            self.content
                .background(
                    GeometryReader { proxy in
                        Color.clear
                            .onAppear {
                                self.childSize = proxy.size
                                currentHeight = childSize.height > 130 ? 320.0 + safeArea.top : 200 + safeArea.top
                            }
                    }
                )
            Spacer()
            
            Image("encryption.up")
                .padding(EdgeInsets(top: 32, leading: 0, bottom: 16, trailing: 0))
            
        } .frame(height:self.currentHeight + currentDrag)
            .frame(maxWidth: .infinity)
            .background(Styles.Colors.backgroundTab.cornerRadius(30))
            .clipped()
            .offset(y: offset)
            .if(offset == -kMinHeight, transform: { view in
                view.animation(.interpolatingSpring(stiffness: 1000, damping: 100, initialVelocity: 50))
            })
        
        
    }
    private var dragGesture: some Gesture {
        
        DragGesture()
        
            .onChanged { value in
                onChangedDragGesture(dragValue: value)
            }
            .onEnded({ value in
                onEndedDragGesture(dragValue: value)
            })
    }
    private func onChangedDragGesture(dragValue:DragGesture.Value) {
        let drag = (dragValue.location.y - dragValue.startLocation.y)
        
        if (drag < 0 && self.currentHeight == kMinHeight) {
            self.offset = drag
        } else {
            self.currentDrag = drag
        }
    }
    
    private func onEndedDragGesture(dragValue:DragGesture.Value ) {
        
        let velocity = (dragValue.velocity)
        let drag = (dragValue.location.y - dragValue.startLocation.y)
        
        let newHeight = self.currentHeight + (dragValue.location.y - dragValue.startLocation.y)
        
        if (drag < 0 && newHeight < self.kMinHeight && velocity.height < kMinVelocity) {
            offset = -kMinHeight
            self.presentationMode.wrappedValue.dismiss()
        }
        
        if (drag < 0 && newHeight < self.kMinHeight && velocity.height > kMinVelocity) {
            self.offset = 0
        }
        
        if (drag < 0 && newHeight > self.kMinHeight) {
            self.currentHeight = kMinHeight
        }
        
        if drag > 0 {
            self.currentHeight = kmaxDrag
        }
        
        self.currentDrag = .zero
    }

    private func fractionProgress(lowerLimit: Double = 0, 
                                  upperLimit:Double,
                                  current:Double,
                                  inverted:Bool = false) -> Double {
        
        let clampedCurrent = min(max(current, lowerLimit), upperLimit)
        let fraction = (clampedCurrent - lowerLimit) / (upperLimit - lowerLimit)
        return inverted ? fraction : 1 - fraction
    }

}

#Preview {
    TopSheetView(content: BackgroundActivitiesView(mainAppModel: MainAppModel.stub()))
        .background(Styles.Colors.backgroundMain)
}
