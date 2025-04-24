//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CircularLoader: View {
    
    @State var spinCircle : Bool = false
    
    var body: some View {
        ZStack {
            
            Circle()
                .stroke(lineWidth: 4.0)
                .opacity(0.8)
                .foregroundColor(Color.white)
            
            Circle()
                .trim(from: 0.5, to: 1)
                .stroke(Styles.Colors.yellow, lineWidth:4)
                .frame(width:20,height: 20)
                .rotationEffect(.degrees(spinCircle ? 0 : -360), anchor: .center)
                .animation(Animation.linear(duration: 1).repeatForever(autoreverses: false))
            
            
        }.frame(width:20,height: 20)
            .onAppear {
                self.spinCircle = true
            }
    }
}

struct CircularLoader_Previews: PreviewProvider {
    static var previews: some View {
        CircularLoader()
    }
}
