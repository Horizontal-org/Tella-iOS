//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct TextDate: View {
    
    let date: Date
    var dateFormatter: DateFormatter {
        let dateformatter = DateFormatter()
        dateformatter.dateFormat = "DD MMM YYYY"
        return dateformatter
    }
    
    var body: some View {
        Text("\(dateFormatter.string(from: date))")
    }
}


