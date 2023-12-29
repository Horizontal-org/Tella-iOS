//
//  GenericEntityWidget.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GenericEntityWidget<Content: View>: View {
    var title = ""
    let content: Content
    var isRequired: Bool
    var shouldRender: Bool
    var showClear: Bool
    @Binding var showManatory: Bool
    var onClearAction: () -> Void
    
    init(title: String = "",
         isRequired: Bool = false,
         showMandatory: Binding<Bool>,
         shouldRender: Bool = true,
         showClear: Bool = false,
         onClearAction: @escaping () -> Void = {},
         @ViewBuilder content: () ->  Content)
          {
        self.title = title
        self.content = content()
        self.isRequired = isRequired
        self.shouldRender = shouldRender
        self.showClear = showClear
        self._showManatory = showMandatory
        self.onClearAction = onClearAction
    }

    var body: some View {
        if shouldRender {
            VStack() {
                UwaziEntityTitleView(title: title,
                                     isRequired: isRequired,
                                     showClear: showClear,
                                     onClearAction: onClearAction)
                if showManatory {
                    UwaziEntityMandatoryTextView()
                }
                content
            }.padding(.vertical, 14)
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
