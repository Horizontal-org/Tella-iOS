//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI


protocol RecentFileProtocol {
    var image: UIImage {get}
}

struct mockRecentFile: RecentFileProtocol {
    
    var image: UIImage {
        return UIImage(named: "test_image") ?? UIImage()
    }
    
}

struct RecentFileCell: View {

    let recentFile: RecentFileProtocol
    
    init(file: RecentFileProtocol) {
        self.recentFile = file
    }
    
    var body: some View {
        Image(uiImage: recentFile.image)
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 70, height: 70)
    }
}

struct RecentFileCell_Previews: PreviewProvider {
    static var previews: some View {
        RecentFileCell(file: mockRecentFile())
    }
}
