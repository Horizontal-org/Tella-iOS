//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import Combine

class OOXMLContentTypeParser : NSObject {
    
    var contentTypes : [String?] = []

    func getContentType(from data:Data) -> [String?] {
        let parser = XMLParser(data: data)
        parser.delegate = self
        parser.parse()
        return contentTypes
    }
}

extension OOXMLContentTypeParser: XMLParserDelegate {
    func parser(_ parser: XMLParser, didStartElement elementName: String, namespaceURI: String?, qualifiedName qName: String?, attributes attributeDict: [String : String] = [:]) {
        let contentType = attributeDict["ContentType"]
        contentTypes.append(contentType)
    }
    
}
