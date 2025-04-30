//
//  UwaziEntityFetching.swift
//  Tella
//
//  Created by gus valbuena on 5/2/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import Foundation
import Combine

class UwaziEntityFetcher {
    var server: UwaziServer?
    
    var subscribers: Set<AnyCancellable> = []
    
    init(server: UwaziServer? = nil,
         subscribers: Set<AnyCancellable>) {
        self.server = server
        self.subscribers = subscribers
    }
    
    func fetchRelationshipEntities(
        template: CollectedTemplate,
        completion: @escaping (Result<[UwaziRelationshipList], APIError>) -> Void
    ) {
        let relationshipProps = template.entityRow?.properties.filter { $0.type == UwaziEntityPropertyType.dataRelationship.rawValue }

        let relatedEntityIds: [String] = relationshipProps?.map { $0.content } as! [String]
            
        guard let serverURL = server?.url, let cookie = server?.cookie else { return }

        UwaziServerRepository().getRelationshipEntities(
            serverURL: serverURL,
            cookie: cookie,
            relatedEntityIds: relatedEntityIds
        )
        .receive(on: DispatchQueue.main)
        .sink(receiveCompletion: { completionStatus in
            switch completionStatus {
                case .finished:
                    break
                case .failure(let error):
                    completion(.failure(error))
                }
            }, receiveValue: { uwaziRelationshipList in
                completion(.success(uwaziRelationshipList))
            })
        .store(in: &subscribers)
    }
    
    
}
