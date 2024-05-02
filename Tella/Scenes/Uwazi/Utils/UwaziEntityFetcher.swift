//
//  UwaziEntityFetching.swift
//  Tella
//
//  Created by gus valbuena on 5/2/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
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
    
    func fetchRelationshipEntities(template: CollectedTemplate,completion: @escaping ([UwaziRelationshipList]) -> Void) {
        let relationshipProps = template.entityRow?.properties.filter { $0.type == UwaziEntityPropertyType.dataRelationship.rawValue }
                let templatesEntities = relationshipProps?.map { $0.content }
                
                guard let serverURL = server?.url, let cookie = server?.cookie else {
                    return
                }

                UwaziServerRepository().getRelationshipEntities(
                    serverURL: serverURL,
                    cookie: cookie,
                    templatesIds: templatesEntities ?? []
                )
                .receive(on: DispatchQueue.main)
                .sink(receiveCompletion: { completionStatus in
                    switch completionStatus {
                    case .finished:
                        break
                    case .failure(let error):
                        Toast.displayToast(message: error.localizedDescription)
                    }
                }, receiveValue: { uwaziRelationshipList in
                    completion(uwaziRelationshipList)
                })
                .store(in: &subscribers)
    }
    
    
}
