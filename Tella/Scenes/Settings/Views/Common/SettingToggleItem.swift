//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingToggleItem: View {
    
    let title: String
    let description: String
    @Binding var toggle: Bool
    var isDisabled: Bool = false
    var withPadding: Bool = true
    var onChange : (() -> ())?
    
    var body: some View {
        HStack{
            VStack(alignment: .leading){
                Text(title)
                    .font(.custom(Styles.Fonts.regularFontName, size: 14))
                    .foregroundColor(Color.white).padding(.bottom, -5)
                
                Text(description)
                    .foregroundColor(Color.white)
                    .font(.custom(Styles.Fonts.regularFontName, size: 12))
                    .fixedSize(horizontal: false, vertical: true)
            }
            Spacer()
            Toggle("", isOn: $toggle)
                .onChange(of: toggle) { value in
                    onChange?()
                }
                .labelsHidden()
                .disabled(isDisabled)
        }
        .if(withPadding, transform: { view in
            view.padding()
        })
    }
}
