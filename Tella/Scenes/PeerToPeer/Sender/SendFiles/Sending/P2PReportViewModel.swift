//
//  P2PReportViewModel.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 4/6/2025.
//  Copyright © 2025 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation

class P2PReportViewModel{

    @Published var title : String = ""
    @Published var files : [ReportVaultFile] = []

    
    init() {
        
    }
}
