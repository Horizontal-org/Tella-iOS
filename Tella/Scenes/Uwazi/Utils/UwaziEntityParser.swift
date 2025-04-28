//
//  UwaziEntityParser.swift
//  Tella
//
//  Created by Gustavo on 29/09/2023.
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
class UwaziEntityParser: UwaziEntityParserProtocol {
    var entryPrompts: [any UwaziEntryPrompt] = []
    var template: CollectedTemplate
    let uwaziTitleString = "title"
    var entityInstance: UwaziEntityInstance?
    let appModel : MainAppModel
    
    init(template: CollectedTemplate,
         appModel : MainAppModel,
         entityInstance: UwaziEntityInstance? = nil) {
        self.template = template
        self.entityInstance = entityInstance
        self.appModel = appModel
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
        let pdfPrompt = UwaziFilesEntryPrompt(id: "10242050",
                                              type: UwaziEntityPropertyType.dataTypeMultiPDFFiles.rawValue,
                                              question: LocalizableUwazi.uwaziMultiFileWidgetPrimaryDocuments.localized,
                                              required: false,
                                              helpText: LocalizableUwazi.uwaziMultiFileWidgetAttachManyPDFFiles.localized,
                                              name: UwaziEntityPropertyType.dataTypeMultiPDFFiles.rawValue)
        entryPrompts.append(pdfPrompt)
    }
    fileprivate func handleSupportPrompt() {
        let supportPrompt = UwaziFilesEntryPrompt(id: "10242049",
                                                  type: UwaziEntityPropertyType.dataTypeMultiFiles.rawValue,
                                                  question: LocalizableUwazi.uwaziMultiFileWidgetSupportingFiles.localized,
                                                  required: false,
                                                  helpText: LocalizableUwazi.uwaziMultiFileWidgetSelectManyFiles.localized,
                                                  name: UwaziEntityPropertyType.dataTypeMultiFiles.rawValue)
        entryPrompts.append(supportPrompt)
    }
    fileprivate func handleDividerPrompt() {
        let dividerPrompt = UwaziDividerEntryPrompt (id: "",
                                                     type: UwaziEntityPropertyType.dataTypeDivider.rawValue,
                                                     question: "",
                                                     required: false,
                                                     helpText: "",
                                                     name: "")
        entryPrompts.append(dividerPrompt)
    }
    
    fileprivate func handleTitlePrompt() {
        guard let titleProperty = template.entityRow?.commonProperties.first (where:{ $0.name == uwaziTitleString }) else { return }
        let titlePrompt = UwaziTextEntryPrompt(id: titleProperty.id ?? "",
                                               type: titleProperty.type ?? "",
                                               question: titleProperty.translatedLabel ?? "",
                                               required: true,
                                               helpText: titleProperty.translatedLabel,
                                               name:titleProperty.name)
        self.entryPrompts.append(titlePrompt)
    }
    fileprivate func handleEntryPromptForProperties() {
        
        
        
        template.entityRow?.properties.forEach {
            
            var prompt : any UwaziEntryPrompt
            
            switch UwaziEntityPropertyType(rawValue: $0.type ?? "") {
                
            case .dataTypeText:
                
                prompt = UwaziTextEntryPrompt(id: $0.id ?? "",
                                              type: $0.type ?? "",
                                              question: $0.translatedLabel ?? "",
                                              required: $0.propertyRequired,
                                              helpText: $0.translatedLabel,
                                              selectValues:[] ,
                                              name: $0.name)
                
            case .dataTypeSelect:
              
                let selectValues = $0.values?.compactMap({SelectValues(id: $0.id ?? "", label: $0.translatedLabel ?? "")})

                prompt = UwaziSelectEntryPrompt(id: $0.id ?? "",
                                                type: $0.type ?? "",
                                                question: $0.translatedLabel ?? "",
                                                required: $0.propertyRequired,
                                                helpText: $0.translatedLabel,
                                                selectValues: selectValues,
                                                name: $0.name)
            case .dataRelationship:
                
                let content = $0.content ?? ""
                
                var relationshipValues : [EntityRelationshipItem] = []
                if content.isEmpty {
                    relationshipValues = self.template.relationships?.flatMap({$0.values}) ?? []
                } else {
                    relationshipValues = self.template.relationships?.first(where:{ $0.id == content})?.values ?? []
                }
                
                let selectValues = relationshipValues.compactMap({SelectValues(id: $0.id, label: $0.label)})

                prompt = UwaziRelationshipEntryPrompt(id: $0.id ?? "",
                                                      type: $0.type ?? "",
                                                      question: $0.translatedLabel ?? "",
                                                      content: $0.content ?? "",
                                                      required: $0.propertyRequired,
                                                      helpText: $0.translatedLabel,
                                                      selectValues: selectValues ,
                                                      name: $0.name)
                
            default:
                prompt = UwaziTextEntryPrompt(id: $0.id ?? "",
                                              type: $0.type ?? "",
                                              question: $0.translatedLabel ?? "",
                                              content: $0.content ?? "",
                                              required: $0.propertyRequired,
                                              helpText: $0.translatedLabel,
                                              selectValues: [],
                                              name: $0.name)
            }
            
            entryPrompts.append(prompt)
        }
    }
    
    func updateRelationships(relationships: [UwaziRelationshipList]?) {
        guard let entryPrompts = entryPrompts.filter({$0.type == .dataRelationship}) as? [UwaziRelationshipEntryPrompt] else {
            return
        }
        
        entryPrompts.forEach { prompt in
            let values: [EntityRelationshipItem]
            
            if(prompt.content == "") {
                values = relationships?.flatMap({$0.values}) ?? []
            } else {
                values = relationships?.first (where: {$0.id == prompt.content } )?.values ?? []
            }
            
            prompt.selectValues = values.compactMap({SelectValues(id: $0.id, label: $0.label)})
        }
    }
    
    func saveAnswersToEntityInstance(status:EntityStatus) {
        
        var metadata: [String: Any] = [:]
        var uwaziEntityInstanceFile : [UwaziEntityInstanceFile] = []
        let entityInstance = self.entityInstance == nil ? UwaziEntityInstance() : self.entityInstance
        
        for entryPrompt in entryPrompts {
            
            guard let propertyName = entryPrompt.name else { break }
            
            switch entryPrompt.type {
                
            case .dataTypeText where propertyName == UwaziEntityMetadataKeys.title:
                guard let entryPrompt = entryPrompt as? UwaziTextEntryPrompt else { continue }
                entityInstance?.title = entryPrompt.value
                
            case .dataTypeText, .dataTypeNumeric, .dataTypeMarkdown, .dataTypeDate:
                guard let entryPrompt = entryPrompt as? UwaziTextEntryPrompt else { continue }
                guard !entryPrompt.isEmpty else { continue }
                let value = entryPrompt.value
                
                if entryPrompt.type == .dataTypeDate , let intValue = Int(value) {
                    metadata[propertyName] = [UwaziValue(value: intValue)].arraydDictionnary
                } else {
                    metadata[propertyName] = [UwaziValue(value: value)].arraydDictionnary
                }
                
            case .dataTypeSelect, .dataTypeMultiSelect:
                guard let entryPrompt = entryPrompt as? UwaziSelectEntryPrompt else { continue }
                guard !entryPrompt.isEmpty else { continue }
                metadata[propertyName] = entryPrompt.value.compactMap({UwaziValue(value: $0)}).arraydDictionnary
                
            case .dataTypeMultiFiles:
                guard let entryPrompt = entryPrompt as? UwaziFilesEntryPrompt else { continue }
                let attachments = entryPrompt.value
                let attachedVaultFiles = attachments.compactMap({UwaziEntityInstanceFile(vaultFileInstanceId: $0.id , entityInstanceId:self.entityInstance?.id )})
                uwaziEntityInstanceFile.append(contentsOf: attachedVaultFiles)
                entityInstance?.attachments = attachments
            case .dataTypeMultiPDFFiles:
                guard let entryPrompt = entryPrompt as? UwaziFilesEntryPrompt else { continue }
                let attachments = entryPrompt.value
                let attachedVaultFiles = attachments.compactMap({UwaziEntityInstanceFile(vaultFileInstanceId: $0.id , entityInstanceId:self.entityInstance?.id )})
                uwaziEntityInstanceFile.append(contentsOf: attachedVaultFiles)
                entityInstance?.documents = attachments
            case .dataRelationship:
                guard let entryPrompt = entryPrompt as? UwaziRelationshipEntryPrompt else { continue }
                guard !entryPrompt.isEmpty else { continue }
                metadata[propertyName] = entryPrompt.value.compactMap({ UwaziValue(value: $0)}).arraydDictionnary
            default:
                break
            }
        }
        
        entityInstance?.status = status
        entityInstance?.templateId = template.id
        entityInstance?.metadata = metadata
        entityInstance?.updatedDate = Date()
        entityInstance?.server = appModel.tellaData?.getUwaziServer(serverId: template.serverId)
        entityInstance?.collectedTemplate = appModel.tellaData?.getUwaziTemplateById(id: template.id)
        entityInstance?.files = uwaziEntityInstanceFile
        self.entityInstance = entityInstance
    }
    
    func putAnswers() {
        
        let metadata = self.entityInstance?.metadata

        let vaultFilesID = self.entityInstance?.files.compactMap{$0.vaultFileInstanceId} ?? []
        let vaultFiles = appModel.vaultFilesManager?.getVaultFiles(ids: vaultFilesID) ?? []
        
        self.entityInstance?.documents = Set(vaultFiles.filter({$0.mimeType?.isPDF ?? false}))
        self.entityInstance?.attachments = Set(vaultFiles.filter({!($0.mimeType?.isPDF ?? true)}))
        
        for entryPrompt in entryPrompts {
            let propertyName = entryPrompt.name
            let value = metadata?[propertyName ?? ""]
            switch  entryPrompt.type {
                
            case .dataTypeText where propertyName == UwaziEntityMetadataKeys.title:
                guard let entryPrompt = entryPrompt as? UwaziTextEntryPrompt else { continue }
                entryPrompt.value = self.entityInstance?.title ?? ""
                
            case .dataTypeText, .dataTypeNumeric, .dataTypeMarkdown, .dataTypeDate:
                guard let entryPrompt = entryPrompt as? UwaziTextEntryPrompt else { continue }
                let valueDict = value as? [[String:Any]]
                guard let decoded = try? valueDict?.first?.decode(UwaziValue<String>.self) else { continue }
                entryPrompt.value = decoded.value
                
            case .dataTypeSelect, .dataTypeMultiSelect:
                let uwaziString = value as? [[String:Any]]
                guard let entryPrompt = entryPrompt as? UwaziSelectEntryPrompt else { continue }
                guard let decoded =  uwaziString?.compactMap({ try? $0.decode(UwaziValue<String>.self)})  else { continue }
                entryPrompt.value = decoded.compactMap({$0.value})
                
            case .dataTypeMultiFiles:
                guard let entryPrompt = entryPrompt as? UwaziFilesEntryPrompt else { continue }
                entryPrompt.value = Set(self.entityInstance?.attachments ?? [])
                
            case .dataTypeMultiPDFFiles:
                guard let entryPrompt = entryPrompt as? UwaziFilesEntryPrompt else { continue }
                entryPrompt.value = Set(self.entityInstance?.documents ?? [])
            case .dataRelationship:
                guard let entryPrompt = entryPrompt as? UwaziRelationshipEntryPrompt else { continue }
                let uwaziString = value as? [[String:Any]]
                guard let decoded = uwaziString?.compactMap({ try? $0.decode(UwaziValue<String>.self)}) else { continue }

                entryPrompt.value = decoded.compactMap({$0.value})
            default:
                break
            }
            
            entryPrompt.displayClearButton()
        }
    }
    
}
