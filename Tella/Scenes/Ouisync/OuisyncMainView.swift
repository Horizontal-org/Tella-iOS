//
//  OuisyncMainView.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct OuisyncMainView: View {
    
    @StateObject private var viewModel: OuisyncViewModel
    
    init(client: any OuisyncServing, mainAppModel: MainAppModel) {
        _viewModel = StateObject(wrappedValue: OuisyncViewModel(client: client, mainAppModel: mainAppModel))
    }
    
    var body: some View {
        ContainerViewWithHeader {
            NavigationHeaderView(title: LocalizableOuisync.appBar.localized,
                                 rightButtonType: .reload,
                                 rightButtonAction: { Task { await viewModel.start() } })
        } content: {
            contentView
        }
        .task {
            await viewModel.start()
        }
    }
    
    private var contentView: some View {
        ZStack(alignment: .top) {
            if viewModel.repositories.isEmpty {
                EmptyFileView(message: LocalizableOuisync.emptyRepositories.localized)
            } else {
                repositoryList
            }
            
            AddFileYellowButton {
                showBottomSheetView(content: OuisyncImportRepositoryView(viewModel: viewModel))
            }
        }
    }
    
    private var repositoryList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.repositories) { repository in
                    repositoryRow(repository)
                }
                Spacer().frame(height: 70)
            }
        }
    }
    
    private func repositoryRow(_ repository: OuisyncRepositoryInfo) -> some View {
        Button {
            Task {
                if await viewModel.openRepository(repository) {
                    navigateTo(destination: OuisyncRepositoryView(viewModel: viewModel))
                }
            }
        } label: {
            HStack(alignment: .center, spacing: 0) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 35, height: 35, alignment: .center)
                    .overlay(
                        Image(.filetypeSmallFolder)
                            .frame(width: 35, height: 35)
                            .cornerRadius(5)
                    )
                Text(repository.displayName)
                    .style(.subheading1Style)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 18)
                Spacer()
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
        }
        .buttonStyle(FileListItemButtonStyle(backgroundColor: Styles.Colors.backgroundMain.opacity(0.001)))
    }
}

struct OuisyncImportRepositoryView: View {
    @ObservedObject var viewModel: OuisyncViewModel

    var body: some View {
        TextFieldBottomSheetView(
            titleText: LocalizableOuisync.importRepository.localized,
            validateButtonText: LocalizableOuisync.importRepository.localized,
            cancelButtonText: LocalizableCommon.commonCancel.localized,
            placeholder: LocalizableOuisync.shareToken.localized,
            fieldContent: $viewModel.shareToken,
            shouldHideSheet: false,
            shouldClearFieldOnConfirm: false,
            didConfirmAction: {
                Task {
                    if await viewModel.importRepository() {
                        self.dismiss()
                    }
                }
            },
            didCancelAction: {
                self.dismiss()
            }
        )
    }
}
