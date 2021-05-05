//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddButtonView: View {

    var body: some View {
        VStack(alignment:.trailing) {
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    //TODO: add new media action
                }) {
                    HStack {
                        Image("home.add").frame(width: 24, height: 24)
                    }
                    .padding(EdgeInsets(top: 8, leading: 16, bottom: 8, trailing: 16))
                        .background(Color.yellow)
                        .mask(Circle())
                }.frame(width: 50, height: 50)
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 8))
    }
}
