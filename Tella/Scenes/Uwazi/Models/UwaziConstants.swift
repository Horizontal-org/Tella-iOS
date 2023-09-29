//
//  UwaziConstants.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum UwaziEntityPropertyType: String, CodingKey {
    case dataTypeText = "text"
    case dataTypeNumeric = "numeric"
    case dataTypeSelect = "select"
    case dataTypeMultiSelect = "multiselect"
    case dataTypeDate = "date"
    case dataTypeDateRange = "daterange"
    case dataTypeMultiDate = "multidate"
    case dataTypeMultiDateRange = "multidaterange"
    case dataTypeMarkdown = "markdown"
    case dataTypeLink = "link"
    case dataTypeImage = "image"
    case dataTypePreview = "preview"
    case dataTypeMedia = "media"
    case dataTypeGeolocation = "geolocation"
    case dataTypeMultiFiles = "multifiles"
    case dataTypeMultiPDFFiles = "multipdffiles"
    case dataTypeGeneratedID = "generatedid"
    case dataTypeDivider = "divider"
}
