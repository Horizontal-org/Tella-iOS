//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation
import SQLite3

struct D {
    /* DATABASE */
    // MARK: - DATABASE
    static let databaseName = "tella_vault.db"
    
    /* DATABASE VERSIO */
    // MARK: - DATABASE VERSION
    static let databaseVersion = 2

    /* DEFAULT TYPES FOR DATABASE */
    // MARK: - DEFAULT TYPES FOR DATABASE
    static let integer = " INTEGER "
    static let text = " TEXT ";
    static let blob = " BLOB ";
    static let float = " FLOAT ";

    
    /* DATABASE TABLES */
    // MARK: - DATABASE TABLES
    static let tServer = "t_server"
    static let tReport = "t_report"
    static let tUwaziServerLanguage = "t_uwazi_server_language"
    static let tReportInstanceVaultFile = "t_report_instance_vault_file";
    static let tUwaziTemplate = "t_uwazi_template"

    /* DATABASE COLUMNS */
    // MARK: - DATABASE COLUMNS
    static let cId = "c_id"
    static let cName = "c_name"
    static let cServerURL = "c_server_url"
    static let cURL = "c_url"

    static let cUsername = "c_username"
    static let cPassword = "c_password"
    
    static let cAccessToken = "c_access_token"
    static let cActivatedMetadata = "c_activated_metadata"
    static let cBackgroundUpload = "c_background_upload"
    
    static let cAutoUpload = "c_auto_upload"
    static let cAutoDelete = "c_auto_delete"

    static let cApiProjectId = "c_api_project_id"
    static let cSlug = "c_slug"

    static let cTitle = "c_title"
    static let cDescription = "c_description"
    static let cDate = "c_date"
    static let cStatus = "c_status"
    static let cServerId = "c_server_id"
    static let cServerType = "c_server_type"
    
    static let cReportId = "c_report_id"
    static let cApiReportId = "c_api_report_id"
    static let cCurrentUpload = "c_current_upload"

    static let cReportInstanceId = "c_report_instance_id";
    static let cVaultFileInstanceId = "c_vault_file_instance_id";
    static let cBytesSent = "c_bytes_Sent"
    static let cCreatedDate = "c_created_date"
    static let cUpdatedDate = "c_upated_date"
    // MARK: Uwazi Locale
    static let cLocale = "c_locale"
    static let cLocaleId = "c_locale_id"

    static let cTemplateId = "c_template_id"
    static let cTemplateEntity = "c_template_entity"
    static let cTemplateDownloaded = "c_template_downloaded"
    static let cTemplateUpdated = "c_template_updated"
    static let cTemplateFavorited = "c_template_favorited"
    static let cServerName = "c_server_name"

}


