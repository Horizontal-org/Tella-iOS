//
//  Copyright © 2021 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct SettingToggleItem: View {
    
    let title: String
    let description: String
    var linkText: String? = nil
    var link: String? = nil
    
    @Binding var toggle: Bool
    @EnvironmentObject var appModel : MainAppModel
    var isDisabled: Bool = false
    var withPadding: Bool = true
    var onChange : (() -> ())?
    
    var body: some View {
        HStack{
            VStack(alignment: .leading, spacing: 2){
                
                CustomText(title,
                           style: .body1Style,
                           alignment: .leading)
                
                CustomText(description,
                           style: .buttonDetailRegularStyle,
                           alignment: .leading)
                
                if let link,
                   let linkText {
                    Button {
                        link.url()?.open()
                    } label: {
                        CustomText(linkText,
                                   style: .buttonDetailRegularStyle,
                                   alignment: .leading,
                                   color: Styles.Colors.yellow)
                    }
                }
            }
            Spacer()
            Toggle("", isOn: $toggle)
                .onChange(of: toggle) { value in
                    appModel.saveSettings()
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
