//
//  CameraModeSelectorView.swift
//  Tella
//
//  Created by Dhekra Rouatbi on 10/9/2026.
//  Copyright © 2026 HORIZONTAL.
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//

import SwiftUI

struct CameraModeSelectorView: View {
    
    let selectedType: CameraType
    let onSelect: (CameraType) -> Void
    
    private static let modes: [CameraType] = [.video, .image]
    
    @Namespace private var selectionNamespace
    
    var body: some View {
        HStack(spacing: 0) {
            ForEach(Self.modes, id: \.self) { mode in
                Button {
                    onSelect(mode)
                } label: {
                    label(for: mode)
                }
            }
        }.frame(height: 52.adjusted)
            .animation(.easeInOut(duration: CameraStyle.Animations.modeChange), value: selectedType)
    }
    
    private func label(for mode: CameraType) -> some View {
        let isSelected = mode == selectedType
        
        return CustomText(mode.title.uppercased(),
                          style: .body2Style,
                          alignment: .center,
                          color: isSelected ? Styles.Colors.backgroundGrey1 : Styles.Colors.grey1)
        .lineLimit(1)
        .padding(.horizontal, .small)
        .frame(minWidth: .mediumButtonWidth,
               minHeight: .mediumButtonHeight)
        .background(selectionPill(isSelected: isSelected))
    }
    
    @ViewBuilder
    private func selectionPill(isSelected: Bool) -> some View {
        if isSelected {
            Capsule()
                .fill(Styles.Colors.yellowWhite)
                .matchedGeometryEffect(id: "selectedMode", in: selectionNamespace)
        }
    }
}

struct CameraModeSelectorView_Previews: PreviewProvider {
    static var previews: some View {
        VStack(spacing: 20) {
            CameraModeSelectorView(selectedType: .image) { _ in }
            CameraModeSelectorView(selectedType: .video) { _ in }
        }
        .padding()
        .background(Styles.Colors.backgroundGrey1)
    }
}
