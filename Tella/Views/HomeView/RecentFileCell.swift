//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

protocol RecentFileProtocol {
    var thumbnailImage: UIImage {get}
}

struct mockRecentFile: RecentFileProtocol {
    var thumbnailImage: UIImage {
        return UIImage(named: "test_image") ?? UIImage()
    }
}

struct RecentFileCell: View {

    let recentFile: RecentFileProtocol
    var body: some View {
        Image(uiImage: recentFile.thumbnailImage)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 70, height: 70)
    }
}

struct RecentFileCell_Previews: PreviewProvider {
    static var previews: some View {
        RecentFileCell(recentFile: mockRecentFile())
    }
}
