//
//  FormsModel.swift
//  Tella
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI

class FormViewModel: ObservableObject {
    @Published var forms = [FormModel]()
    
    init() {
        fetchForms()
    }
    
    func fetchForms(){

        forms.append(FormModel())
        forms.append(FormModel())
        forms.append(FormModel())
        forms.append(FormModel())

       // forms.append(FormModel(FormDetailsModel(title: "Test2", description: "Description2", isDraft: true, isFavorite: true)))
       // forms.append(FormModel(FormDetailsModel(title: "Test3", description: "Description3", isDraft: true, isFavorite: true)))
        //forms.append(FormModel(FormDetailsModel(title: "Test4", description: "Description4", isDraft: true, isFavorite: true)))

    }
}

class FormModel: Identifiable {
    var id = UUID()
    var form =  FormDetailsModel()
}

struct FormDetailsModel: Identifiable {
    var id = UUID()
    var title: String = "Test"
    var description: String = "Test"
    var isDraft: Bool = false
    var isFavorite: Bool = false
}
