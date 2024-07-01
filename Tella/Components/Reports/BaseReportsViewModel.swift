//
//  BaseReportsViewModel.swift
//  Tella
//
//  Created by gus valbuena on 6/27/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

protocol ReportsViewModelProtocol: ObservableObject {
    var selectedCell: Pages { get set }
}

class BaseReportsViewModel: ObservableObject, ReportsViewModelProtocol {
    var mainAppModel: MainAppModel
    
    @Published var selectedCell: Pages = .draft
    
    init(mainAppModel: MainAppModel) {
        self.mainAppModel = mainAppModel
    }
}
