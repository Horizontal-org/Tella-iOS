//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum DateFormat : String {
    case short = "dd MMM yyyy"
    case fileInfo = "dd-MM-yyyy HH:mm:ss Z"
    case fileName = "yyyy.MM.dd-HH.mm"
    case time = "hh:mm a"
    case dataBase = "yyyy-MM-dd'T'HH:mm:ssZ"
}

extension Date{
    
    func getFormattedDateString(format: String = DateFormat.short.rawValue , locale: Locale = Language.english.localeLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = locale
        return formatter.string(from: self)
    }
    
    func fileCreationDate() -> String {
        
        let calendar = Calendar.current
        
        if calendar.isDateInToday(self) {
            return getFormattedDateString(format: DateFormat.time.rawValue)
        } else   {
            return  getFormattedDateString()
        }
    }
    
    //    23 minutes ago
    //    2 hours ago
    //    1 day ago
    //    2 days ago
    //
    //    Modified 2 days ago
    //    Modified 1 week ago
    //    Modified 2 weeks ago
    //    Modified 1 month ago
    
    
    
    
    func getDraftReportTime() -> String {
        return "Modified" + " " + getTimeAgoSinceNow()
    }
    
    func getSubmittedReportTime() -> String {
        return getTimeAgoSinceNow()
    }
    
    
    func getDateString() -> String? {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = DateFormat.dataBase.rawValue
        return dateFormatter.string(from: self)
    }
    
    private func getTimeAgoSinceNow() -> String {
        
        var interval = getDateComponent(component: .year).year!
        
        if interval > 0 {
            let string = interval == 1 ?  "%i year" : "%i years"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .month).month!
        if interval > 0 {
            let string = interval == 1 ?  "%i month" : "%i months"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .day).day!
        
        if interval > 0 {
            let  string = interval == 1 ?  "%i day" : "%i days"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .hour).hour!
        
        if interval > 0 {
            let string = interval == 1 ?  "%i hour" : "%i hours"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .minute).minute!
        
        if interval > 0 {
            let string = interval == 1 ?  "%i minute" : "%i minutes"
            return String(format: string, interval)
        }
        
        return "a moment ago"
    }
    
    private func getDateComponent(component :  Calendar.Component) -> DateComponents {
        return Calendar.current.dateComponents([component], from: self, to: Date())
    }
    
}

