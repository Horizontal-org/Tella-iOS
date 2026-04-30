//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
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
                    Image("file.add")
                }
            }
        }.padding(EdgeInsets(top: 0, leading: 0, bottom: 16, trailing: 16))
    }
}
