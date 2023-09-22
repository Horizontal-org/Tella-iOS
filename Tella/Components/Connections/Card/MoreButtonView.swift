//
//  MoreButtonView.swift
//  Tella
//
//  Created by Gustavo on 02/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct MoreButtonView: View {
    var imageName : String
    var action : () -> Void
    var body: some View {
        Button {
            action()
        } label: {
            Image(imageName)
                .padding()
        }
    }
}

struct MoreButtonView_Previews: PreviewProvider {
    static var previews: some View {
        MoreButtonView(imageName: "", action: {})
    }
}
