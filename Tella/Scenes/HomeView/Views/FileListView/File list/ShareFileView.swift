//
//  ShareView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 18/3/2022.
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct ShareFileView: View {
    
    @EnvironmentObject var fileListViewModel: FileListViewModel

    var body: some View {
        ZStack {}
        .sheet(isPresented: $fileListViewModel.showingShareFileView, onDismiss: {
            fileListViewModel.clearTmpDirectory()
        }, content: {
            ActivityViewController(fileData: fileListViewModel.getDataToShare())
        })
    }
}

struct ShareView_Previews: PreviewProvider {
    static var previews: some View {
        ShareFileView()
    }
}
