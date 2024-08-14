//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

enum APIError: Swift.Error {
    case invalidURL
    case httpCode(HTTPCode)
    case unexpectedResponse
    case noInternetConnection
    case badServer
    case noToken
    case errorOccured
}

extension APIError: LocalizedError {

    var errorDescription: String? {
        switch self {
        case .invalidURL:
            return "Invalid URL"
        case let .httpCode(code):
            return customErrorMessage(errorCode: code)
        case .unexpectedResponse:
            return "Unexpected response from the server"
        case .noInternetConnection:
            return LocalizableSettings.settServerNoInternetConnection.localized
        case .badServer:
            return LocalizableSettings.settServerServerURLIncorrect.localized
        case .noToken:
            return LocalizableSettings.settServerNoTokenPresent.localized
        case .errorOccured :
            return LocalizableCommon.commonError.localized
        }
    }
    private func customErrorMessage(errorCode : Int) -> String {
        let httpErrorCode = HTTPErrorCodes(rawValue: errorCode)
        switch httpErrorCode{
        case .unauthorized:
            return "Invalid username or password"
        case .forbidden:
            return "Account locked due to too many unsuccessful attempts."
        case .notFound:
            return LocalizableSettings.settServerServerURLIncorrect.localized
        case .nextcloudFolderExists:
            return "Folder already exist"
        case .ncUnauthorized, .ncUnauthorizedError:
            return "The username or password is incorrect"
        case .ncNoInternetError:
            return "No Internet connection. Try again when you are connected to the Internet."
        default:
            return "Unexpected response from the server"
        }
    }
}
