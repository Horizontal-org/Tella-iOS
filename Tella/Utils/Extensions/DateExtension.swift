//
//  Copyright © 2022 HORIZONTAL. All rights reserved.
//

import Foundation

enum DateFormat : String {
    case short = "dd MMM yyyy"
    case fileInfo = "dd-MM-yyyy HH:mm:ss Z"
    case fileName = "yyyy.MM.dd-HH.mm.ss"
    case time = "hh:mm a"
    case dataBase = "yyyy-MM-dd'T'HH:mm:ssZ"
    case submittedReport = "dd.MM.yyyy, hh:mm a"
    case autoReportNameName = "yyyy.MM.dd - HH.mm"
    case uwaziDate = "dd/MM/yyyy"

}

extension Date{
    
    func getFormattedDateString(format: String = DateFormat.short.rawValue , locale: Locale = Language.english.localeLanguage) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = format
        formatter.locale = Locale.current
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
    
    func getModifiedReportTime() -> String {
        return "Modified" + " " + getTimeAgoSinceNow()
    }
    
    func getSubmittedReportTime() -> String {
        return getTimeAgoSinceNow()
    }
    
    func getDateDouble() -> Double? {
        return self.timeIntervalSince1970
    }
    
    func getDate() -> String {
        return "\(Int(self.timeIntervalSince1970 * 1000))"
    }
    
    func getUnixTimestamp() -> Int {
        return Int(self.timeIntervalSince1970)
    }

    private func getTimeAgoSinceNow() -> String {
        
        var interval = getDateComponent(component: .year).year!
        
        if interval > 0 {
            let string = interval == 1 ?  "%i year ago" : "%i years ago"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .month).month!
        if interval > 0 {
            let string = interval == 1 ?  "%i month ago" : "%i months ago"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .day).day!
        
        if interval > 0 {
            let  string = interval == 1 ?  "%i day ago" : "%i days ago"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .hour).hour!
        
        if interval > 0 {
            let string = interval == 1 ?  "%i hour ago" : "%i hours ago"
            return String(format: string, interval)
        }
        
        interval = getDateComponent(component: .minute).minute!
        
        if interval > 0 {
            let string = interval == 1 ?  "%i minute ago" : "%i minutes ago"
            return String(format: string, interval)
        }
        
        return "a moment ago"
    }
    
    private func getDateComponent(component :  Calendar.Component) -> DateComponents {
        return Calendar.current.dateComponents([component], from: self, to: Date())
    }
    
}

