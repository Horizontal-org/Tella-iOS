//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CircularActivityIndicatory: View {
    
    @State private var isCircleRotating = true
    @State private var animateStart = false
    @State private var animateEnd = true
    
    var body: some View {
        ZStack {
            
            Color.white.opacity(0.04)
                .edgesIgnoringSafeArea(.all)
            
            ZStack {
                Circle()
                    .stroke(lineWidth: 4)
                    .fill(Color.init(red: 0.96, green: 0.96, blue: 0.96))
                    .frame(width: 25, height: 25)
                
                Circle()
                    .trim(from: animateStart ? 1/3 : 1/9, to: animateEnd ? 2/5 : 1)
                    .stroke(lineWidth: 4)
                    .rotationEffect(.degrees(isCircleRotating ? -360 : 0))
                    .frame(width: 25, height: 25)
                
                    .foregroundColor(Styles.Colors.yellow)
                    .onAppear() {
                        withAnimation(Animation
                            .linear(duration: 1)
                            .repeatForever(autoreverses: false)) {
                                self.isCircleRotating.toggle()
                            }
                        withAnimation(Animation
                            .linear(duration: 1)
                            .delay(0.5)
                            .repeatForever(autoreverses: true)) {
                                self.animateStart.toggle()
                            }
                        withAnimation(Animation
                            .linear(duration: 1)
                            .delay(1)
                            .repeatForever(autoreverses: true)) {
                                self.animateEnd.toggle()
                            }
                    }
            }
        }
    }
}

struct CircularActivityIndicatory_Previews: PreviewProvider {
    static var previews: some View {
        CircularActivityIndicatory()
    }
}
