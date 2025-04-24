//
//  Copyright © 2021 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct RecentFileCell<Destination:View>: View {
    
    let recentFile: VaultFileDB
    let desination: Destination
    @EnvironmentObject var appModel: MainAppModel
    
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
