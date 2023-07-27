//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum ServerType: String {
    case unknown = "UNKNOWN"
    case odkCollect = "ODK_COLLECT"
    case tellaUpload = "TELLA_UPLOAD"
    case uwazi = "UWAZI"
}
enum ServerConnectionType: Int {
    case tella = 0
    case uwazi = 1
}
