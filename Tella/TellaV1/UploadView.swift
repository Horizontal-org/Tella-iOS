//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct UploadView: View {

    init() {
    }
    
    var body: some View {
        ZStack {
                    VStack(alignment:.trailing) {
                        Spacer()
                        HStack {
                            Spacer()
                            Button(action: {}) {
                                HStack {
                                    Image(systemName: "rectangle.grid.1x2.fill")
                                }
                                .padding()
                                    .background(Color.yellow)
                                    .mask(Circle())
                            }.frame(width: 60, height: 60)
                                .border(Color.red, width: 1)
                        }
                    }
                }
    }
}

struct UploadView_Previews: PreviewProvider {
    static var previews: some View {
        UploadView()
    }
}
