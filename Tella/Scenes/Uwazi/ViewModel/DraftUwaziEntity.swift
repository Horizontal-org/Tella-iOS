//
//  DraftUwaziEntity.swift
//  Tella
//
//  Created by Gustavo on 04/09/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import Foundation
import SwiftUI

class DraftUwaziEntity: ObservableObject {
    var mainAppModel: MainAppModel
    
    @Published var template: CollectedTemplate
    @Published var text: String = ""
    
    // Fields validation
    @Published var shouldShowError : Bool = false
    @Published var isValidText : Bool = false
    
    @Published var propertyValues : [String:Any] = [ : ]
    
    func initializePropertyTextValues() {
        // Iterate through the template's properties and set initial values in propertyTextValues
        for property in template.entityRow?.properties ?? [] {
            if let label = property.label {
                propertyValues[label] = ""
            }
        }
        
        for commonProperty in template.entityRow?.commonProperties ?? [] {
            if let label = commonProperty.label {
                propertyValues[label] = ""
            }
        }
    }
    
    func bindingForLabel(_ label: String) -> Binding<String> {
            // Use a computed property to return a binding to the value in propertyValues
            Binding<String>(
                get: { self.propertyValues[label, default: ""] as! String },
                set: { self.propertyValues[label] = $0 }
            )
        }
    init(mainAppModel: MainAppModel, template: CollectedTemplate) {
        self.mainAppModel = mainAppModel
        self.template = template
        
        self.initializePropertyTextValues()
        
        dump(template.entityRow?.properties)
        dump(propertyValues)
        
        
    }

}
