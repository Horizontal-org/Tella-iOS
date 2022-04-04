//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct SettingItem: View {
    
    let name: String
    let image: Image
    
    var body: some View {
        HStack{
            image
                .frame(width: 25, height: 25)
                .foregroundColor(Color.white)
            Text(name)
                .font(.callout)
                .foregroundColor(Color.white)
        }
        .frame(height: 56)
        .listRowBackground(Styles.Colors.backgroundTab)
        .cornerRadius(25)
    }
}

struct SettingToggleItem: View {
    
    let title: String
    let description: String
    @Binding var toggle: Bool
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(title)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white).padding(.bottom, -5)
                
                Text(description)
                    .foregroundColor(Color.white)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
            }
            Toggle( "", isOn: $toggle)
                .labelsHidden()
        }
        .padding()
    }
}
