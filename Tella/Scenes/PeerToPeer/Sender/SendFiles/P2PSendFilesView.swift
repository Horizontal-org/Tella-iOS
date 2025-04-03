//
//  P2PSendFilesView.swift
//  Tella
//
//  Created by RIMA on 25.02.25.
//  Copyright © 2025 HORIZONTAL. All rights reserved.
//

import SwiftUI
import Combine


struct P2PSendFilesView: View {
    
    @ObservedObject var viewModel: AddFilesViewModel
    
    var body: some View {
        ZStack {
            ContainerViewWithHeader {
                navigationBarView
            } content: {
                contentView
            }
            
            AddFilePhotoVideoPickerView(viewModel: viewModel)
        }
        .overlay(AddFileCameraView(viewModel: viewModel))
        .overlay(AddFileRecordView(viewModel: viewModel))
    }
    
    fileprivate var contentView: some View {
        VStack(alignment: .leading, spacing: 8) {

            RegularText(LocalizablePeerToPeer.title.localized, size: 12)
            
            RegularText("Police violence at protest") // should be dynamic
            
            Divider()
                .frame(height: 1)
                .background(Color.white.opacity(0.64))
                

            AddFileGridView(viewModel: viewModel, titleText: LocalizablePeerToPeer.selectFilesToSend.localized)
                .padding(.top, 40)
            
            Spacer()
            TellaButtonView<AnyView> (title: LocalizablePeerToPeer.sendFiles.localized.uppercased(),
                                      nextButtonAction: .action,
                                      buttonType: .yellow,
                                      isValid: .constant(true)) {
                print("saaaave files", viewModel.files)

            }.padding(.bottom, 20)

        }.padding(16)
    }

    fileprivate var navigationBarView: some View {
        NavigationHeaderView(title: LocalizablePeerToPeer.sendFiles.localized,
                             backButtonAction: { self.popToRoot() })
    }

}


