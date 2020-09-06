//
//  Components.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/16/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This class is used to factor out the core UI elements. The functions are used over all of the files so that information (text, images, buttons) is presented uniformly and cleanly throughout the app.
 */

import SwiftUI

//TODO tweak this boundary
let mainPadding: CGFloat = UIScreen.main.bounds.width > 400 ? 20 : 10

//  Text related functions
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

func verySmallText(_ text: String) -> AnyView {
    return makeText(text, 15, false)
}

//  Image related functions
private func makeImg(_ imgName: ImageEnum, _ sideLength: CGFloat) -> AnyView {
    AnyView(Image(imgName.rawValue)
        .renderingMode(.original)
        .resizable()
        .frame(width: sideLength, height: sideLength))
}

func largeImg(_ img: ImageEnum) -> AnyView {
    return makeImg(img, 60)
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

//  Button related functions
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
    .cornerRadius(25))
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

struct ShutdowButton : View {
    @Binding var isPresented: Bool

    var body : some View {
        Button(action: {
            self.isPresented = true
        }, label: {
            mediumImg(.SHUTDOWN)
        })
            .alert(isPresented: $isPresented) {
                Alert(
                    title: Text("Delete all files?"),
                    message: Text("This cannot be undone."),
                    primaryButton: .default(
                        Text("Delete"),
                        action: {
                            TellaFileManager.clearAllFiles()
                        }
                    ),
                    secondaryButton: .cancel())
            }
    }
}


func doneButton(_ onPress: @escaping () -> ()) -> Button<AnyView> {
    Button(action: onPress) {
        return makeText("Close", 18, false)
    }
}

//  Navigational elements
func header(
    _ back: Button<AnyView>,
    _ title: String? = nil,
    shutdownWarningPresented: Binding<Bool>? = nil) -> some View {

    HStack {
        back
        Spacer()
        title.map { title in
            Group {
                mediumText(title)
                Spacer()
            }
        }
        shutdownWarningPresented.map { ShutdowButton(isPresented: $0) }
    }
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

struct RoundedButton: View {
    let text: String
    let onClick: () -> Void

    var body: some View {
        Button(action: onClick) {
            smallText(text)
                .padding(EdgeInsets(vertical: 10, horizontal: 20))
                .frame(maxWidth: .infinity)
                .overlay(
                    RoundedRectangle(cornerRadius: 30)
                        .stroke(Color.white, lineWidth: 0.5)
                )
        }
    }
}
