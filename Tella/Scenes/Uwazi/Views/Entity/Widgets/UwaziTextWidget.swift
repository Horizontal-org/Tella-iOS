//
//  UwaziTextWidget.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziTextWidget: View {
    
    @ObservedObject var prompt: UwaziTextEntryPrompt
    var uwaziEntityViewModel : UwaziEntityViewModel
    var body: some View {
        VStack(alignment: .leading) {
            TextField("", text: $prompt.value)
                .textFieldStyle(TextfieldStyle(shouldShowError: false, keyboardType: prompt.type == .dataTypeNumeric ? .numberPad : .default))
                .frame( height: 22)
                .onChange(of: prompt.value, perform: { value in
                    prompt.showClear = !value.isEmpty
                    uwaziEntityViewModel.publishUpdates()
                })
            
            Divider()
                .frame(height: 1)
                .background(Color.white)
                .opacity(0.64)
        }
    }
}

//struct UwaziTextWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        ContainerView {
//            UwaziTextWidget()
//        }
//    }
//}
