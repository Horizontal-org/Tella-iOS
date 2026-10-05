//
//  CameraGalleryButton.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct CameraGalleryButton: View {
    
    let file: VaultFileDB?
    var rotation = CameraControlRotation()
    let action: () -> Void
    
    @State private var displayedThumbnail: GalleryThumbnail?
    @State private var incomingThumbnail: GalleryThumbnail?
    @State private var incomingScale: CGFloat = Self.startScale
    @State private var thumbnailTransitionID = UUID()
    /// The last-file reload on open should not play the insert animation.
    @State private var canAnimateInserts = false
    
    private static let startScale: CGFloat = 0.2
    
    var body: some View {
        Button(action: action) {
            ZStack {
                thumbnailImage(displayedThumbnail)
                
                thumbnailImage(incomingThumbnail)
                    .compositingGroup()
                    .scaleEffect(incomingScale)
            }
            .frame(width: .mediumIconSize, height: .mediumIconSize)
            .overlay(Circle().strokeBorder(Color.white, lineWidth: 2))
        }
        .rotate(rotation)
        .opacity(file == nil ? 0 : 1)
        .animation(nil, value: file == nil)
        .disabled(file == nil)
        .accessibilityLabel(LocalizableCamera.appBar.localized)
        .onAppear {
            resetThumbnail(to: file?.thumbnail)
            DispatchQueue.main.async {
                canAnimateInserts = true
            }
        }
        .onChange(of: file?.thumbnail) { newThumbnail in
            guard canAnimateInserts else {
                resetThumbnail(to: newThumbnail)
                return
            }
            presentLatestThumbnail(newThumbnail)
        }
    }
    
    @ViewBuilder
    private func thumbnailImage(_ thumbnail: GalleryThumbnail?) -> some View {
        if let thumbnail {
            Image(uiImage: thumbnail.image)
                .resizable()
                .scaledToFill()
                .frame(width: .mediumIconSize, height: .mediumIconSize)
                .clipShape(Circle())
        }
    }
    
    private func presentLatestThumbnail(_ latestThumbnail: Data?) {
        // The incoming layer remains on top after its animation finishes.
        let visibleThumbnail = incomingThumbnail ?? displayedThumbnail
        guard latestThumbnail != visibleThumbnail?.data else { return }
        guard let thumbnail = GalleryThumbnail(data: latestThumbnail) else {
            resetThumbnail(to: nil)
            return
        }

        let transitionID = UUID()
        thumbnailTransitionID = transitionID
        
        withoutAnimation {
            if let incomingThumbnail = incomingThumbnail {
                displayedThumbnail = incomingThumbnail
            }
            incomingScale = Self.startScale
            incomingThumbnail = thumbnail
        }
        
        DispatchQueue.main.async {
            guard thumbnailTransitionID == transitionID else { return }
            withAnimation(.timingCurve(0, 0, 0.58, 1, duration: CameraStyle.Animations.galleryTransition)) {
                incomingScale = 1
            }
        }
    }

    private func resetThumbnail(to data: Data?) {
        thumbnailTransitionID = UUID()
        let thumbnail = GalleryThumbnail(data: data)
        withoutAnimation {
            displayedThumbnail = thumbnail
            incomingThumbnail = nil
            incomingScale = Self.startScale
        }
    }
}

/// Decode only when the thumbnail changes, rather than during every view update.
private struct GalleryThumbnail {
    let data: Data
    let image: UIImage

    init?(data: Data?) {
        guard let data, let image = UIImage(data: data) else { return nil }
        self.data = data
        self.image = image
    }
}

struct CameraGalleryButton_Previews: PreviewProvider {
    static var previews: some View {
        CameraGalleryButton(file: .stub()) {}
            .padding()
            .background(Styles.Colors.grey2)
    }
}
