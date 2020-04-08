//
//  Components.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/16/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

//TODO tweak this boundary
let mainPadding: CGFloat = UIScreen.main.bounds.width > 400 ? 20 : 10

private func makeText(_ text: String, _ size: CGFloat, _ header: Bool) -> AnyView {
    if header {
        return AnyView(Text(text)
            .font(.custom("Avenir Light Oblique", size: size))
            .foregroundColor(.white)
            .font(.title)
            .tracking(3))
    }
        return AnyView(Text(text)
            .font(.custom("Avenir Light", size: size))
            .foregroundColor(.white)
            .font(.title))

}

func bigText(_ text: String, _ header: Bool) -> AnyView {
    return makeText(text, 55, header)
}

func mediumText(_ text: String) -> AnyView {
    return makeText(text, 35, false)
}

func smallText(_ text: String) -> AnyView {
    return makeText(text, 25, false)
}

private func makeImg(_ imgName: ImageEnum, _ sideLength: CGFloat) -> AnyView {
    AnyView(Image(imgName.rawValue)
        .renderingMode(.original)
        .resizable()
        .frame(width: sideLength, height: sideLength))
}

func bigImg(_ img: ImageEnum) -> AnyView {
    return makeImg(img, 40)
}

func mediumImg(_ img: ImageEnum) -> AnyView {
    return makeImg(img, 35)
}

func smallImg(_ img: ImageEnum) -> AnyView {
    return makeImg(img, 25)
}

private func makeLabeledImageButton(_ isBig: Bool, _ img: ImageEnum, _ text: String, _ onPress: @escaping () -> ()) -> AnyView {
    AnyView(Button(action: {
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
        .cornerRadius(15)
    )
}

func bigLabeledImageButton(_ img: ImageEnum, _ text: String, _ onPress: @escaping () -> ()) -> AnyView {
    makeLabeledImageButton(true, img, text, onPress)
}

func smallLabeledImageButton(_ img: ImageEnum, _ text: String, _ onPress: @escaping () -> ()) -> AnyView {
    makeLabeledImageButton(false, img, text, onPress)
}

func backButton(_ onPress: @escaping () -> ()) -> Button<AnyView> {
    Button(action: onPress) {
        mediumText("<")
    }
}

func doneButton(_ onPress: @escaping () -> ()) -> Button<AnyView> {
    Button(action: onPress) {
        return makeText("Close", 18, false)
    }
}

func header(_ back: Button<AnyView>, _ title: String) -> AnyView {
    AnyView(HStack {
        back
        Spacer()
        mediumText(title)
        Spacer()
        Button(action: {
            print("shutdown button pressed")
        }) {
            mediumImg(.SHUTDOWN)
        }
    })
}

func previewHeader(_ back: Button<AnyView>, _ title: String) -> AnyView {
    AnyView(HStack {
        Spacer()
        mediumText(title)
        Spacer()
        back
        //but i want to make this an x button
    })
}
