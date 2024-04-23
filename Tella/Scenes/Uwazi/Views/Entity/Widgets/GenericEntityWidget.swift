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
    //   var showClear: Binding<Bool>
    //  var showManatory: Binding<Bool>
    var showClear: Bool
    var showManatory: Bool
    
    var onClearAction: () -> Void
    
    init(title: String = "",
         isRequired: Bool = false,
         //         showMandatory: Binding<Bool>,
         //         showClear: Binding<Bool>,
         showMandatory: Bool,
         showClear: Bool,
         shouldRender: Bool = true,
         onClearAction: @escaping () -> Void = {},
         @ViewBuilder content: () ->  Content)
    {
        self.title = title
        self.content = content()
        self.isRequired = isRequired
        self.shouldRender = shouldRender
        self.showClear = showClear
        self.showManatory = showMandatory
        self.onClearAction = onClearAction
    }
    
    var body: some View {
        if shouldRender {
            VStack() {
                UwaziEntityTitleView(title: title,
                                     isRequired: isRequired,
                                     showClear: showClear,
                                     onClearAction: onClearAction)
                content
            }.padding(.vertical, 14)
        }
    }
}

//struct GenericEntityWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        GenericEntityWidget(showMandatory: .constant(true),
//                            showClear: .constant(true)) {
//            Text("Test")
//        }.background(Styles.Colors.backgroundMain)
//    }
//}
