//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileButtonView: View {

    var action: () -> ()
    
    var body: some View {
        VStack(alignment:.trailing) {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    //TODO: add new media action
                    self.action()
                }) {
                    Circle()
                        .fill(Color.yellow)
                        .frame(width: 50, height: 50, alignment: .center)
                        .overlay(Image("home.add"))
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
    }
}
