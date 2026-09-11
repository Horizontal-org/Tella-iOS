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
    
    @State private var displayedThumbnail: Data?
    @State private var incomingThumbnail: Data?
    @State private var incomingScale: CGFloat = Self.startScale
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
            displayedThumbnail = file?.thumbnail
            DispatchQueue.main.async {
                canAnimateInserts = true
            }
        }
        .onChange(of: capture) { newCapture in
            guard canAnimateInserts else {
                displayedThumbnail = newCapture.thumbnail
                return
            }
            presentLatestThumbnail(newCapture.thumbnail)
        }
    }
    
    private var capture: GalleryCapture {
        GalleryCapture(id: file?.id, thumbnail: file?.thumbnail)
    }
    
    private func thumbnailImage(_ data: Data?) -> some View {
        Image(uiImage: data.flatMap { UIImage(data: $0) } ?? UIImage())
            .resizable()
            .scaledToFill()
            .frame(width: .mediumIconSize, height: .mediumIconSize)
            .clipShape(Circle())
            .opacity(data == nil ? 0 : 1)
    }
    
    private func presentLatestThumbnail(_ latestThumbnail: Data?) {
        guard let latestThumbnail = latestThumbnail,
              latestThumbnail != displayedThumbnail,
              latestThumbnail != incomingThumbnail else { return }
        
        withoutAnimation {
            if let incomingThumbnail = incomingThumbnail {
                displayedThumbnail = incomingThumbnail
            }
            incomingScale = Self.startScale
            incomingThumbnail = latestThumbnail
        }
        
        DispatchQueue.main.async {
            withAnimation(.timingCurve(0, 0, 0.58, 1, duration: CameraStyle.Animations.galleryTransition)) {
                incomingScale = 1
            }
        }
    }
}

private struct GalleryCapture: Equatable {
    let id: String?
    let thumbnail: Data?
    
    static func == (lhs: Self, rhs: Self) -> Bool {
        lhs.id == rhs.id
    }
}

struct CameraGalleryButton_Previews: PreviewProvider {
    static var previews: some View {
        CameraGalleryButton(file: .stub()) {}
            .padding()
            .background(Styles.Colors.grey2)
    }
}
