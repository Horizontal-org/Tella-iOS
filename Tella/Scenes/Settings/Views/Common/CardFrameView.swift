//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CardFrameView<Content:View>: View {
    
    var content : () -> Content
    
    init(@ViewBuilder content : @escaping () -> Content) {
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            self.content()
        }.background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 17, bottom: 6, trailing: 17))
    }
}

#Preview {
    CardFrameView(content: {
        Text("Test")
    })
    
}


