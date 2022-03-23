//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFileCell: View {
    let recentFile: VaultFile
    var body: some View {
        ZStack{
            recentFile.gridImage
                .frame(width: 75, height: 75)
        }
    }
}
