//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct RecentFileCell<Destination:View>: View {
    
    let recentFile: VaultFileDB
    let desination: Destination
    
    var body: some View {
        Button {
            navigateTo(destination: desination)
        } label: {
            ZStack{
                recentFile.gridImage
                    .frame(width: 75, height: 75)
            }
            
        }
        
        
    }
}
