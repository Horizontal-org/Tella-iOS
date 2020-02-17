//
//  Components.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/16/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

private func makeText(_ text: String, _ size: CGFloat) -> AnyView {
    AnyView(Text(text)
        .font(.custom("Avenir Next Ultra Light", size: size))
        .foregroundColor(.white)
        .font(.title))
}

func bigText(_ text: String) -> AnyView {
    return makeText(text, 55)
}

func mediumText(_ text: String) -> AnyView {
    return makeText(text, 35)
}

func smallText(_ text: String) -> AnyView {
    return makeText(text, 25)
}

private func makeImg(_ imgName: ImageEnum, _ sideLength: CGFloat) -> some View {
    Image(imgName.rawValue)
        .renderingMode(.original)
        .resizable()
        .frame(width: sideLength, height: sideLength)
}

func bigImg(_ img: ImageEnum) -> some View {
    return makeImg(img, 40)
}

func mediumImg(_ img: ImageEnum) -> some View {
    return makeImg(img, 35)
}

func smallImg(_ img: ImageEnum) -> some View {
    return makeImg(img, 30)
}

private func makeLabeledImageButton(_ isBig: Bool, _ img: ImageEnum, _ text: String, _ onPress: @escaping () -> ()) -> some View {
    Button(action: {
       onPress()
    }) {
        HStack {
            if isBig {
                mediumImg(img)
                Spacer().frame(maxWidth: 20)
                mediumText(text)
            } else {
                smallImg(img)
                Spacer().frame(maxWidth: 10)
                smallText(text)
            }
        }
    }
        .padding(isBig ? 20 : 10)
        .border(Color.white, width: isBig ? 1 : 0)
        .cornerRadius(25)
}

func bigLabeledImageButton(_ img: ImageEnum, _ text: String, _ onPress: @escaping () -> ()) -> some View {
    makeLabeledImageButton(true, img, text, onPress)
}

func smallLabeledImageButton(_ img: ImageEnum, _ text: String, _ onPress: @escaping () -> ()) -> some View {
    makeLabeledImageButton(false, img, text, onPress)
}

func backButton(_ onPress: @escaping () -> ()) -> Button<AnyView> {
    Button(action: onPress) {
        bigText("<")
    }
}
