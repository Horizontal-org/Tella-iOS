//
//  GenericEntityWidget.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GenericEntityWidget<Content: View>: View {
    var title = ""
    let content: Content
    var isRequired: Bool
    @Binding var showManatory: Bool

    init(title: String = "",
         isRequired: Bool = false,
         showMandatory: Binding<Bool>,
         @ViewBuilder content: () ->  Content)
          {
        self.title = title
        self.content = content()
        self.isRequired = isRequired
        self._showManatory = showMandatory
    }
    var body: some View {
        VStack {
            UwaziEntityTitleView(title: title, isRequired: isRequired)
            if showManatory {
                UwaziEntityMandatoryTextView()
            }
            content
        }
    }
}

struct GenericEntityWidget_Previews: PreviewProvider {
    static var previews: some View {
        GenericEntityWidget(showMandatory: .constant(false)) {
            Text("")
        }
    }
}
