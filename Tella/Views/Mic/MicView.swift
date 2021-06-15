//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct MicView: View {

    init() {
    }
    
    var body: some View {
        ZStack {
            Color.yellow
            VStack(){
                Text("Mic View")
                    .frame(maxWidth: .infinity)
            }
        }
        .edgesIgnoringSafeArea(.all)
    }
}

struct MicView_Previews: PreviewProvider {
    static var previews: some View {
        MicView()
    }
}
