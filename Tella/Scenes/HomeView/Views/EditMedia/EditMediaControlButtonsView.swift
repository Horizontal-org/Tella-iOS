//
//  EditMediaControlButtonsView.swift
//  Tella
//
//  Created by RIMA on 21.11.24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct EditMediaControlButtonsView: View {
    
    @ObservedObject var viewModel: EditMediaViewModel

    var body: some View {
        HStack(spacing: 64) {
            Button(action: { viewModel.undo() }) {
                Image("cancel.edit.file")
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
            Button(action: { viewModel.handlePlayButton() }) {
                Image(viewModel.playButtonImageName)
                    .resizable()
                    .frame(width: 50, height: 50)
                    .foregroundColor(.gray)
            }
        }
    }
}

