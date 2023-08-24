//
//  UwaziConstants.swift
//  Tella
//
//  Created by Gustavo on 24/08/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation

enum UwaziConstants: String, CodingKey {
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
}
