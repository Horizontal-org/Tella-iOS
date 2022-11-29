//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3

struct D {
    /* DATABASE */
    static let databaseName = "tella_vault.db"
    
    /* DEFAULT TYPES FOR DATABASE */
    static let integer = " INTEGER "
    static let text = " TEXT ";
    static let blob = " BLOB ";
    
    
    /* DATABASE TABLES */
    
    static let tServer = "t_server"
    static let tReport = "t_report"
    static let tReportInstanceVaultFile = "t_report_instance_vault_file";

    /* DATABASE COLUMNS */
    
    static let cId = "c_id"
    static let cName = "c_name"
    static let cURL = "c_url"
    static let cUsername = "c_username"
    static let cPassword = "c_password"
    
    static let cAccessToken = "c_access_token"
    static let cActivatedMetadata = "c_activated_metadata"
    static let cBackgroundUpload = "c_background_upload"
    
    
    static let cTitle = "c_title"
    static let cDescription = "c_description"
    static let cDate = "c_date"
    static let cStatus = "c_Status"
    static let cServerId = "c_server_id"
    
    static let cReportId = "c_report_id"

    
    static let  cReportInstanceId = "c_report_instance_id";
    static let  cVaultFileId = "c_vault_file_id";
    //    static let  C_REPORT_SERVER_ID = "c_report_server_id";
    //    static let  C_REPORT_API_ID = "c_report_api_id";
}


