//
//  Components.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/16/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

private func makeText(_ text: String, _ size: CGFloat) -> some View {
    Text(text)
        .font(.custom("Avenir Next Ultra Light", size: size))
        .foregroundColor(.white)
        .font(.title)
}

func bigText(_ text: String) -> some View {
    return makeText(text, 55)
}

func mediumText(_ text: String) -> some View {
    return makeText(text, 35)
}

func smallText(_ text: String) -> some View {
    return makeText(text, 25)
}

private func makeImg(_ imgName: String, _ sideLength: CGFloat) -> some View {
    Image(imgName)
        .renderingMode(.original)
        .resizable()
        .frame(width: sideLength, height: sideLength)
}

func bigImg(_ imgName: String) -> some View {
    return makeImg(imgName, 40)
}

func mediumImg(_ imgName: String) -> some View {
    return makeImg(imgName, 35)
}

func smallImg(_ imgName: String) -> some View {
    return makeImg(imgName, 25)
}

private func makeLabeledImageButton(_ isBig: Bool, _ imgName: String, _ text: String, _ onPress: @escaping () -> ()) -> some View {
    Button(action: {
       onPress()
    }) {
        HStack {
            if isBig {
                mediumImg(imgName)
                Spacer()
                mediumText(text)
            } else {
                smallImg(imgName)
                Spacer().frame(maxWidth: 10)
                smallText(text)
            }
        }
    }
        .padding(isBig ? 20 : 10)
        .border(Color.white, width: isBig ? 1 : 0)
        .cornerRadius(25)
}

func bigLabeledImageButton(_ imgName: String, _ text: String, _ onPress: @escaping () -> ()) -> some View {
    makeLabeledImageButton(true, imgName, text, onPress)
}

func smallLabeledImageButton(_ imgName: String, _ text: String, _ onPress: @escaping () -> ()) -> some View {
    makeLabeledImageButton(false, imgName, text, onPress)
}
