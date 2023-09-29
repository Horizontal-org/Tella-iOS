//
//  UwaziDividerWidget.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziDividerWidget: View {
    var body: some View {
        Color.white.opacity(0.2)
            .frame(height: 1)
    }
}

struct UwaziDividerWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            UwaziDividerWidget()
        }
    }
}
