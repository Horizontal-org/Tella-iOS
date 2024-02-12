//
//  UwaziTextWidget.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziTextWidget: View {
    @State var isValidText = false
    @State var value: UwaziValue
    var body: some View {
        VStack(alignment: .leading) {
            TextField("", text: $value.stringValue)
            .keyboardType(.default)
            .textFieldStyle(TextfieldStyle(shouldShowError: false))
            .frame( height: 22)
            
            Divider()
            .frame(height: 1)
            .background(Color.white)
            .opacity(0.64)
        }
    }
}
struct UwaziTextWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            UwaziTextWidget(value:UwaziValue.defaultValue())
        }
    }
}
