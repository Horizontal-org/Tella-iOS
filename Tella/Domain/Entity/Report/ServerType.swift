//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum ServerConnectionType: Int, Decodable {
    case tella = 0
    case uwazi = 1
    case odkCollect = 3
    case unknown
}

func mapServerTypeFromInt(_ serverTypeInt: Int?) -> ServerConnectionType {
    if let serverType = serverTypeInt {
        return ServerConnectionType(rawValue: serverType) ?? .unknown
    } else {
        return .unknown
    }
}
