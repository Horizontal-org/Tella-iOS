//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct AddFileYellowButton: View {

    var action: () -> ()
    var body: some View {
        VStack(alignment:.trailing) {
            Spacer()
            HStack(spacing: 0) {
                Spacer()
                Button(action: {
                    self.action()
                }) {
                    Image("home.add")
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
    }
}
