//
//  UwaziEntityParser.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
class UwaziEntityParser: UwaziEntityParserProtocol {
    var entryPrompts: [UwaziEntryPrompt] = []
    var template: CollectedTemplate
    let uwaziTitleString = "title"

    init(template: CollectedTemplate) {
        self.template = template
        handleEntryPrompts()
    }
    func handleEntryPrompts() {
        handlePdfsPrompt()
        handleSupportPrompt()
        handleDividerPrompt()
        handleTitlePrompt()
        handleEntryPromptForProperties()
    }


    fileprivate func handlePdfsPrompt() {
        let pdfPrompt = UwaziEntryPrompt(id: "10242050",
                                         formIndex: "10242050",
                                         type: UwaziEntityPropertyType.dataTypeMultiPDFFiles.rawValue,
                                         question: "Primary Documents",
                                         name: "primary_documents",
                                         required: false,
                                         helpText: "Attach as many PDF files as you wish")
        entryPrompts.append(pdfPrompt)
    }
    fileprivate func handleSupportPrompt() {
        let supportPrompt = UwaziEntryPrompt(id: "10242049",
                                             formIndex: "10242049",
                                             type: UwaziEntityPropertyType.dataTypeMultiFiles.rawValue,
                                             question: "Supporting files",
                                             name: "supporting_files",
                                             required: false,
                                             helpText: "Select as many files as you wish")
        entryPrompts.append(supportPrompt)
    }
    fileprivate func handleDividerPrompt() {
        let dividerPrompt = UwaziEntryPrompt(id: "",
                                             formIndex: "",
                                             type: UwaziEntityPropertyType.dataTypeDivider.rawValue,
                                             question: "",
                                             name: "divider",
                                             required: false,
                                             helpText: "")
        entryPrompts.append(dividerPrompt)
    }

    fileprivate func handleTitlePrompt() {
        guard let titleProperty = template.entityRow?.commonProperties.first (where:{ $0.name == uwaziTitleString }) else { return }
        let titlePrompt = UwaziEntryPrompt(id: titleProperty.id ?? "",
                                           formIndex: titleProperty.id,
                                           type: titleProperty.type ?? "",
                                           question: titleProperty.translatedLabel ?? "",
                                           name: titleProperty.name ?? "",
                                           required: true,
                                           helpText: titleProperty.translatedLabel)
        self.entryPrompts.append(titlePrompt)
    }
    fileprivate func handleEntryPromptForProperties() {
        let entryPromptyProperties = template.entityRow?.properties.compactMap {
            UwaziEntryPrompt(id: $0.id ?? "",
                             formIndex: $0.id,
                             type: $0.type ?? "",
                             question: $0.translatedLabel ?? "",
                             name: $0.name ?? "",
                             required: $0.propertyRequired,
                             helpText: $0.translatedLabel,
                             selectValues: $0.values)

        } ?? []
        entryPrompts.append(contentsOf: entryPromptyProperties)
    }
}
