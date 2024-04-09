//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct CardFrameView<Content:View>: View {
    
    var content : () -> Content
    var padding: EdgeInsets
    
    init(padding: EdgeInsets, @ViewBuilder content : @escaping () -> Content) {
        self.content = content
        self.padding = padding
    }
    
    var body: some View {
        VStack(spacing: 0) {
            self.content()
        }.background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(padding)
    }
}

#Preview {
    CardFrameView(padding: EdgeInsets(top: 6, leading: 17, bottom: 6, trailing: 17), content: {
            Text("Test")
    })
}

