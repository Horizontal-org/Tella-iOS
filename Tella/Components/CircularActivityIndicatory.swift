//  Tella
//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CircularActivityIndicatory: View {
    @State private var isCircleRotating = false
    var isTransparent: Bool = false
    
    let rotationAnimation = Animation.linear(duration: 1).repeatForever(autoreverses: false)
    let trimAnimationStart = Animation.linear(duration: 1).delay(0.5).repeatForever(autoreverses: true)
    let trimAnimationEnd = Animation.linear(duration: 1).delay(1).repeatForever(autoreverses: true)
    
    var body: some View {
        ZStack {
            Color.white.opacity(isTransparent ? 0 : 0.04)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .fill(Color.init(red: 0.96, green: 0.96, blue: 0.96))
                    .frame(width: 25, height: 25)
                
                Circle()
                    .trim(from: 1/9, to: 2/5)
                    .stroke(Styles.Colors.yellow, lineWidth: 4)
                    .rotationEffect(.degrees(isCircleRotating ? 360 : 0))
                    .frame(width: 25, height: 25)
                    .onAppear {
                        self.isCircleRotating = true
                    }
            }
        }
        .animation(rotationAnimation, value: isCircleRotating)
    }
}

struct CircularActivityIndicatory_Previews: PreviewProvider {
    static var previews: some View {
        CircularActivityIndicatory()
    }
}
