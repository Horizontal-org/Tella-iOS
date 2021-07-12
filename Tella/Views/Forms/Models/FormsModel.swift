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
    
    func fetchForms() {
        forms.append(FormModel.stub())
        forms.append(FormModel.stub())
        forms.append(FormModel.stub())
        forms.append(FormModel.stub())
    }
}

class FormModel: Identifiable {
    var id: UUID = UUID()
    var details: FormDetailsModel
    
    init(details: FormDetailsModel) {
        self.details = details
    }
}

struct FormDetailsModel: Identifiable {
    var id = UUID()
    var title: String
    var description: String
    var isDraft: Bool
    var isFavorite: Bool
}

extension FormModel {
    
    static func stub() -> FormModel {
        let form = FormModel(details: FormDetailsModel.stub())
        return form
    }
}

extension FormDetailsModel {
    
    static func stub() -> FormDetailsModel {
        let details = FormDetailsModel(id: UUID(), title: "Form title", description: "Form Desctiption", isDraft: false, isFavorite: false)
        return details
    }
}
