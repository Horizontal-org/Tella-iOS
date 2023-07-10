//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct TrailingButtonToolbar: ToolbarContent {
    
    var title : String = ""
    var completion : (() -> ())?
    
    var body: some ToolbarContent {
       
        ToolbarItem(placement: .navigationBarTrailing) {
           
            Button {
                completion?()
            } label: {
                Text(title)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(Color.white)
                .frame(width: 260,height:25,alignment:.trailing)

            }

            
        }
    }
 }

struct TrailingButtonToolbar_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            
        } .toolbar {
            TrailingButtonToolbar(title: "Test")
        }
    }
}
