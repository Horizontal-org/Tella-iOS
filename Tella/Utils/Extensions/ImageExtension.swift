//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI


extension Image {
    func rounded() -> some View  {
      return  self.resizable()
            .scaledToFill()
            .aspectRatio(contentMode: .fit)
            .frame(width: 40)
            .clipShape(Circle())
            .overlay(Circle().stroke(Color.white, lineWidth: 3))
    }
}
