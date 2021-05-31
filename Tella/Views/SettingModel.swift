//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation

struct Setting: Hashable {
    let imageName: String
    let title: String
}

struct SettingItems {
    
    static let options = [
        Setting(imageName: "gear",
              title: "General"),
        
        Setting(imageName: "person.crop.circle.badge.exclam",
              title: "Security"),
        
        Setting(imageName: "hand.raised.fill",
              title: "Documentation"),
              
        Setting(imageName: "key.fill",
              title: "About & Help"),
    ]
}
