//
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//


import Foundation
import Combine

class EncryptionOperation:Operation, WebRepository {
    
    public var mainAppModel :MainAppModel!
    
    private var cancellable: AnyCancellable?
    private var subscribers = Set<AnyCancellable>()
    
    init(mainAppModel :MainAppModel) {
        super.init()
        self.mainAppModel = mainAppModel
    }
    
    override func main() {
        super.main()
    }
    
    public func addVaultFile(filePath: URL, parentId: String?, mainAppModel: MainAppModel) -> CurrentValueSubject<ImportVaultFileInBackgroundResult,Never> {
        
        let backgroundActivityModel = BackgroundActivityModel(type: .file)
        
        
        let subject = CurrentValueSubject<ImportVaultFileInBackgroundResult, Never>(.fileAdded(backgroundActivityModel))
        
        Task {
            
            do {
                if let fileDetail = try await self.mainAppModel.vaultFilesManager?.getFileDetails(filePath: filePath) {
                    backgroundActivityModel.updateWith(vaultFile:fileDetail.file)
                    subject.send(.fileUpdated(backgroundActivityModel))
                    
                    self.mainAppModel.vaultFilesManager?.addVaultFile(fileDetail: fileDetail, filePath: filePath, parentId: parentId)
                        .sink(receiveValue: { importVaultFileResult in
                            backgroundActivityModel.status = importVaultFileResult
                            subject.send(.fileUpdated(backgroundActivityModel))
                        }).store(in: &subscribers)
                }
                
            } catch {
            }
        }
        return subject
    }
}


