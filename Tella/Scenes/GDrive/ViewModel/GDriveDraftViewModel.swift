//
//  GDriveDraftViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/13/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

class GDriveDraftViewModel: ObservableObject {
    var mainAppModel: MainAppModel
    
    @Published var title: String = ""
    @Published var description: String = ""
    
    @Published var isValidTitle : Bool = false
    @Published var isValidDescription : Bool = false
    @Published var shouldShowError : Bool = false
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
    }
}
