//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum ServerType: String {
    case unknown = "UNKNOWN"
    case odkCollect = "ODK_COLLECT"
    case tella = "TELLA_UPLOAD"
    case uwazi = "UWAZI"
}
enum ServerConnectionType: Int {
    case tella = 0
    case uwazi = 1
    case odkCollect = 3
}

func mapServerTypeFromInt(_ serverTypeInt: Int?) -> ServerType {
    switch serverTypeInt {
    case ServerConnectionType.tella.rawValue:
        return .tella
    case ServerConnectionType.uwazi.rawValue:
        return .uwazi
    case ServerConnectionType.odkCollect.rawValue:
        return .odkCollect
    default:
        return .unknown
    }
}
