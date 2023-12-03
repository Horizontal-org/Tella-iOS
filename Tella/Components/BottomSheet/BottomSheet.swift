//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct BottomSheet<Content:View>: View {
    var height: CGFloat
    
    var content: () -> Content
    
    var body: some View {
        GeometryReader { geometry in
            ZStack(alignment: .bottom) {
                backgroundView(geometry: geometry)
                contentView
            }
        }  .edgesIgnoringSafeArea(.all)
    }
    
    private func backgroundView(geometry:GeometryProxy) -> some View {
        Group {
            Spacer()
                .edgesIgnoringSafeArea(.all)
                .frame(width: geometry.size.width, height: geometry.size.height)
                .background(Color.black).opacity(0.6)
            
        }
    }
    
    private var contentView : some View {
        VStack(alignment: .center) {
            Spacer()
            self.content()
                .frame(height: height)
                .frame(maxWidth: .infinity)
                .background(Styles.Colors.backgroundTab.cornerRadius(30))
        }
    }
}

#Preview {
    BottomSheet(height: 200.0) {
        return Text("Text")
    }
}
