//
//  GDriveData.swift
//  Tella
//
//  Created by gus valbuena on 6/28/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import Foundation

extension TellaData {
    func addGDriveReport(report : GDriveReport) -> Result<Int, Error> {
        let id =  database.addGDriveReport(report: report)
        
        return id
    }
    
    func getDraftGDriveReport() -> [GDriveReport] {
        self.database.getDraftGDriveReports()
    }
    
    func getDriveReport(id: Int) -> GDriveReport? {
        self.database.getGDriveReport(id: id)
    }
}
