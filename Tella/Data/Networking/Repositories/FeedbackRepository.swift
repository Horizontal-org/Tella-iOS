//
//  Copyright © 2023 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

struct FeedbackRepository: WebRepository {
    
    func submitFeedback(feedback: Feedback, mainAppModel: MainAppModel) -> AnyPublisher<FeedbackAPI,APIError>? {
        
        if !mainAppModel.networkMonitor.isConnected {
            FeedbackService.shared.addFeedbackOperation(mainAppModel: mainAppModel, feedbackToSend: feedback)
        }
        
        let apiResponse : APIResponse<FeedbackDTO> = getAPIResponse(endpoint: FeedbackRepository.API.submitFeedback(feedback.text))
        return apiResponse
            .compactMap{$0.response.toDomain() as? FeedbackAPI}
            .eraseToAnyPublisher()
    }
}

extension FeedbackRepository {
    enum API {
        case submitFeedback((String?))
    }
}

extension FeedbackRepository.API: APIRequest {
    
    
    var keyValues: [Key : Value?]? {
        
        switch self {
        case .submitFeedback((let text)):
            return [
                FeedbackParameterKey.platform: Platform.ios.rawValue,
                FeedbackParameterKey.text: text]
        }
    }
    
    var baseURL: String {
        switch self {
        case .submitFeedback:
            return FeedbackConstants.baseURL
        }
    }
    
    var path: String? {
        switch self {
        case .submitFeedback:
            return FeedbackConstants.opinionsPath
        }
    }
    
    var httpMethod: HTTPMethod {
        switch self {
        case .submitFeedback:
            return HTTPMethod.post
        }
    }
    
    var headers: [String : String]? {
        switch self {
        case .submitFeedback:
            return [HTTPHeaderField.tellaPlatform.rawValue:FeedbackConstants.tellaPlatform]
        }
    }
}


enum Platform : String {
    case ios = "IOS"
}
