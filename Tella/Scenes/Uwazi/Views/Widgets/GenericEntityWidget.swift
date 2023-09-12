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

    init(title: String = "", @ViewBuilder content: () ->  Content) {
        self.title = title
        self.content = content()
    }
    var body: some View {
        VStack {
            UwaziEntityTitleView(title: title)
            content
        }
    }
}

struct GenericEntityWidget_Previews: PreviewProvider {
    static var previews: some View {
        GenericEntityWidget {
            Text("")
        }
    }
}
