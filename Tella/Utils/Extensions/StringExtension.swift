//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension String {
    func getDate() -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dataBase.rawValue
        dateFormatter.locale = Locale(identifier: "en")
        return dateFormatter.date(from: self) // replace Date String
    }
}
