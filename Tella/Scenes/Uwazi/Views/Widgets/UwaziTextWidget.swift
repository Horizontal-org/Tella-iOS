//
//  UwaziTextWidget.swift
//  Tella
//
//  Created by Robert Shrestha on 9/11/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziTextWidget: View {
    @State var isValidText = false
    @State var mandatoryError = false
    @EnvironmentObject var prompt: UwaziEntryPrompt
    @State var value: UwaziValue

    var body: some View {
        VStack(alignment: .leading) {
                if mandatoryError {
                    UwaziEntityMandatoryTextView()
                }
                TextfieldView(
                    fieldContent: $value.stringValue,
                    isValid: $isValidText,
                    shouldShowError: .constant(false),
                    fieldType: .text
                )
            }
        .onChange(of: prompt.showMandatoryError) { mandatoryError = $0 }
    }
}
struct UwaziTextWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            UwaziTextWidget(value:UwaziValue.defaultValue())
        }
    }
}
