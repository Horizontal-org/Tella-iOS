//
//  UwaziAttachmentsActionItems.swift
//  Tella
//
//  Created by Gustavo on 02/11/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

var addFileToDraftItems : [ListActionSheetItem] { return [
        
        ListActionSheetItem(imageName: "report.camera-filled",
                            content: LocalizableReport.cameraFilled.localized,
                            type: ManageFileType.camera),
        ListActionSheetItem(imageName: "report.mic-filled",
                            content: LocalizableReport.micFilled.localized,
                            type: ManageFileType.recorder),
        ListActionSheetItem(imageName: "report.gallery",
                            content: LocalizableReport.galleryFilled.localized,
                            type: ManageFileType.tellaFile),
        ListActionSheetItem(imageName: "report.phone",
                            content: LocalizableReport.phoneFilled.localized,
                            type: ManageFileType.fromDevice)
    ]}

var addFileToPdfItems: [ListActionSheetItem] { return [
    ListActionSheetItem(imageName: "report.gallery",
                        content: LocalizableReport.galleryFilled.localized,
                        type: ManageFileType.tellaFile),
    ListActionSheetItem(imageName: "report.phone",
                        content: LocalizableReport.phoneFilled.localized,
                        type: ManageFileType.fromDevice)
]}
