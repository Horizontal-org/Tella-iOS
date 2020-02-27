//
//  GalleryView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import UIKit



enum ActivePicker {
   case image, document
}

struct GalleryView: View {

    @State var image: Image? = nil
    @State private var showPicker = false
    @State private var activePicker: ActivePicker = .image

    let back: Button<AnyView>
    let files = [File(name: "File 1"), File(name: "File 2"), File(name: "File 3")]

    @State var doc: NSObject? = nil
    @State var showingSheet: Bool = false

    var body: some View {

        let first = File(name: "File 1")
        let second = File(name: "File 2")
        let third = File(name: "File 3")
        let files = [first, second, third]

        return Group {
            header(back, "GALLERY")
            Spacer().frame(maxHeight: 50)
            HStack {
                smallLabeledImageButton(.LIST, "List view") {
                    print("list icon pressed")
                }
                Spacer().frame(maxWidth: 40)
                smallLabeledImageButton(.GRID, "Grid view") {
                    print("grid icon pressed")
                }
            }
            Spacer()
            List(TellaFileManager.getEncryptedFileNames().map({ (value: String) -> File in File(name: value) })) { file in
                smallText(file.name)
            }
            Spacer()
            HStack {
                Spacer()
                Button(action: {
                    self.showingSheet = true
                }) {
                    bigImg(.PLUS)
                }
                .actionSheet(isPresented: $showingSheet) {
                    //creates the popup on plus button, giving options of where to import from
                    ActionSheet(title: Text("Import from..."), message: nil, buttons: [
                        .default(Text("Files")) {
                            self.showPicker.toggle()
                            self.activePicker = ActivePicker.document
                        },
                        .default(Text("Photos")) {
                            self.showPicker.toggle()
                            self.activePicker = ActivePicker.image
                        },
                        //.default(Text("Voice Memos")) { },
                        .cancel()
                    ])
                }
                    //presenting the specified picker on top of the current view
                .sheet(isPresented: $showPicker) {
                    if self.activePicker == ActivePicker.image {
                        ImagePickerView(isShown: self.$showPicker, image: self.$image)
                    } else if self.activePicker == ActivePicker.document {
                        DocPickerView(isShown: self.$showPicker, doc: self.$doc)
                    }
                }
            }
        }
        }

    }



//code to fix constraints bug found from: https://stackoverflow.com/questions/55653187/swift-default-alertviewcontroller-breaking-constraints
extension UIAlertController {
    override open func viewDidLoad() {
        super.viewDidLoad()
        pruneNegativeWidthConstraints()
    }

    func pruneNegativeWidthConstraints() {
        for subView in self.view.subviews {
            for constraint in subView.constraints where constraint.debugDescription.contains("width == - 16") {
                subView.removeConstraint(constraint)
            }
        }
    }
}

struct File: Identifiable {
    var id = UUID()
    var name: String
}

struct FileRow: View {
    var file: File
    var body: some View {
        smallText(file.name)
    }
}
