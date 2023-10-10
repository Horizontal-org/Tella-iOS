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
                TextfieldView(
                    fieldContent: $value.stringValue,
                    isValid: $isValidText,
                    shouldShowError: .constant(false),
                    fieldType: .text
                )
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