//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct OfflineFeedbackToast: View {
  
    var body: some View {
       
        VStack {
            
            Spacer()
            
            VStack {
                
                Text(LocalizableSettings.offlineToast.localized)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(.black)
                Spacer()
                    .frame(height: 20)
                HStack {
                    Spacer()
                    Button  {
                        self.dismiss()
                    } label: {
                        Text("OK")
                            .font(.custom(Styles.Fonts.boldFontName, size: 14))
                            .foregroundColor(Styles.Colors.yellow)
                    }
                    
                }
            } .padding()
                .background(Color.white)
                .cornerRadius(4)
                .padding()
            
            Spacer()
                .frame(height: 40)

        }.background(Color.black.opacity(0.53))
            .ignoresSafeArea()    }
}

struct OfflineFeedbackToast_Previews: PreviewProvider {
    static var previews: some View {
        OfflineFeedbackToast()
    }
}
