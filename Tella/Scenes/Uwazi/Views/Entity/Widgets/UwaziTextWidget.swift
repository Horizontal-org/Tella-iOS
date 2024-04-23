//
//  UwaziTextWidget.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziTextWidget: View {
    
    @ObservedObject var prompt: UwaziTextEntryPrompt
    @EnvironmentObject var uwaziEntityViewModel : UwaziEntityViewModel
    var body: some View {
        VStack(alignment: .leading) {
            TextField("", text: $prompt.value.value)
            .keyboardType(.default)
            .textFieldStyle(TextfieldStyle(shouldShowError: false))
            .frame( height: 22)
            .onChange(of: prompt.value.value, perform: { value in
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
