//
//  OuisyncRepositoryView.swift
//  Tella
//
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct OuisyncRepositoryView: View {
    @ObservedObject var viewModel: OuisyncViewModel
    
    var body: some View {
        ContainerViewWithHeader {
            NavigationHeaderView(
                title: viewModel.selectedRepository?.displayName ?? LocalizableOuisync.appBar.localized,
                rightButtonType: .reload,
                rightButtonAction: {
                    Task { await viewModel.refreshEntries() }
                }
            )
        } content: {
            contentView
        }
    }
    
    private var contentView: some View {
        Group {
            if viewModel.entries.isEmpty {
                EmptyFileView(message: LocalizableOuisync.emptyFolder.localized)
            } else {
                entriesList
            }
        }
    }
    
    private var entriesList: some View {
        ScrollView {
            LazyVStack(spacing: 1) {
                ForEach(viewModel.entries) { entry in
                    entryRow(entry)
                }
            }
        }
    }
    
    private func entryRow(_ entry: OuisyncEntry) -> some View {
        Button {
            showSaveConfirmation(for: entry)
        } label: {
            HStack(alignment: .center, spacing: 0) {
                RoundedRectangle(cornerRadius: 5)
                    .fill(Color.white.opacity(0.2))
                    .frame(width: 35, height: 35, alignment: .center)
                    .overlay(entryIcon(for: entry))
                Text(entry.name)
                    .style(.subheading1Style)
                    .foregroundColor(.white)
                    .lineLimit(1)
                    .padding(.leading, 18)
                Spacer()
                if !entry.isDirectory {
                    Image(.filesMore)
                        .padding(13)
                        .accessibilityHidden(true)
                }
            }
            .padding(.horizontal, 16)
            .frame(height: 60)
        }
        .buttonStyle(FileListItemButtonStyle(backgroundColor: Styles.Colors.backgroundMain.opacity(0.001)))
        .disabled(entry.isDirectory)
    }
    
    private func showSaveConfirmation(for entry: OuisyncEntry) {
        let content = ConfirmBottomSheet(
            titleText: entry.name,
            msgText: LocalizableOuisync.saveFileMessage.localized,
            cancelText: LocalizableCommon.commonCancel.localized,
            actionText: LocalizableOuisync.saveFile.localized,
            shouldHideSheet: false,
            didConfirmAction: {
                self.dismiss {
                    Task { await viewModel.saveFileToVault(entry) }
                }
            },
            didCancelAction: {
                self.dismiss()
            }
        )
        showBottomSheetView(content: content)
    }

    @ViewBuilder
    private func entryIcon(for entry: OuisyncEntry) -> some View {
        if entry.isDirectory {
            Image(.filetypeSmallFolder)
                .frame(width: 35, height: 35)
                .cornerRadius(5)
        } else {
            Image(.document)
                .renderingMode(.original)
                .resizable()
                .scaledToFit()
                .frame(width: 22, height: 22)
        }
    }
}
