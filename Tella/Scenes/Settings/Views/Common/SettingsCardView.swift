//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingsCardView<T:View> : View {
    
    var cardViewArray : [T]
    
    var body : some View {
        
        VStack(spacing: 0) {
            
            ForEach(0..<cardViewArray.count, id:\.self) { index in
                
                cardViewArray[index].eraseToAnyView()
                
                if index < cardViewArray.count - 1 {
                    DividerView()
                }
            }
        }.background(Color.white.opacity(0.08))
            .cornerRadius(15)
            .padding(EdgeInsets(top: 6, leading: 17, bottom: 6, trailing: 17))
    }
}

struct DividerView : View {
    var body: some View {
        Divider()
            .frame(height: 1)
            .background(Color.white.opacity(0.2))
    }
}

struct SettingsCardView_Previews: PreviewProvider {
    static var previews: some View {
        SettingsCardView(cardViewArray: [Text("Hello")])
    }
}
