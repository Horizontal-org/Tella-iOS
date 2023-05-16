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

    func getBaseURL() -> String? {
        let url = NSURL(string: self)
        return "https://" + (url?.host ?? "")
    }

    func getFileSizeWithoutUnit() -> String {
        let array =  self.getStringComponents(separator: " ")
        guard !array.isEmpty else {return ""}
        return array[0]
    }
    
    func getStringComponents(separator: String) -> [String] {
        return self.components(separatedBy: separator)
    }
}
