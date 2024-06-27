//
//  NextcloudServerViewModel.swift
//  Tella
//
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

class NextcloudServerViewModel: ServerViewModel {
    
    private var nextcloudRepository: NextCloudRepository

    init(nextcloudRepository: NextCloudRepository = NextCloudRepository()) {
        self.nextcloudRepository = nextcloudRepository
    }
    
    override func checkURL() {
//        self.isLoading = true
        nextcloudRepository.checkServer(serverUrl: serverURL)
    }
}
