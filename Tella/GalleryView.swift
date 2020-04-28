//
//  GalleryView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//



/*
 This class is for the Gallery view of the app. It contains two main view options: grid view and list view. This determines how the files will be presented to the user in terms of the interface.
 Key Functionality:
    Users can import photos and videos from their camera roll into Tella. Users can also import pdfs, docs, audio files, etc from the Files app on the device. It does not currently support importing items stored on iCloud.
    Users can preview items by clicking anywhere on the name of the file for list view. Previewing should support any file type.
    Users can delete files by clicking the x on the right hand side of each item. Users will be prompted before deletion in order to prevent accidental deletions.
 */

import Foundation
import SwiftUI
import UIKit

struct GalleryView: View {
    @State private var shutdownWarningDisplayed = false
    @State var currentView = GalleryViewEnum.MAIN
    @State var displayList = true
    @State var fileList = TellaFileManager.getEncryptedFileNames()
    
//  Setting up a special back button that allows user to navigate back to the gallery when importing or previewing files
    func galleryBack() {
        self.currentView = GalleryViewEnum.MAIN;
        self.fileList = TellaFileManager.getEncryptedFileNames()
    }

    var galleryBackButton: Button<AnyView> {
        return backButton { self.galleryBack() }
    }
    
    let back: Button<AnyView>
    let privKey: SecKey
    
// Setting up the List view for the files
    func getListGridView() -> AnyView {
        if displayList {
            return AnyView(List(fileList.map({ (value: String) -> File in File(name: value) })) { file in
                Group {
                    //  Functionality for previewing files
                    Button(action: {
                        //  updates the current view to Preview enum
                        //  the getViewcontents method responds to updates on the variable currentView
                        self.currentView = .PREVIEW(filepath: TellaFileManager.fileNameToPath(name: file.name))
                    }) {
                        smallText(file.name)
                    }.buttonStyle(BorderlessButtonStyle())
                    Spacer()
                    //  Functionality for deleting files
                    Button(action: {
                        TellaFileManager.deleteEncryptedFile(name: file.name)
                        self.fileList = TellaFileManager.getEncryptedFileNames()
                    }) {
                        smallText("x")
                    }.buttonStyle(BorderlessButtonStyle())
                }
            })
        } else {
            return smallText("Grid View Not Implemented")
        }
    }
    
//  Sets up the main view. Has a toggle for displaying list or grid view. Has a plus button in the bottom right corner for importing files.
    func getMainView() -> AnyView {
        return AnyView(Group {
            header(back, "GALLERY", shutdownWarningPresented: $shutdownWarningDisplayed)
            Spacer().frame(maxHeight: 50)
            HStack {
                if displayList {
                    smallLabeledImageButton(.GRID, "Grid view") {
                        self.displayList = false
                    }
                } else {
                    smallLabeledImageButton(.LIST, "List view") {
                        self.displayList = true
                    }
                }
            }
            Spacer()
            getListGridView()
            Spacer()
            HStack {
                Spacer()
                //  When the user clicks this button it will tell the action sheet to be presented.
                Button(action: {
                    self.currentView = .PICKERPICKER
                }) {
                    bigImg(.PLUS)
                }
            }
                //  Using an action sheet to present multiple options for importing
            .actionSheet(isPresented: Binding(
                get: {self.currentView == .PICKERPICKER},
                set: {
                    _ = $0
                    if self.currentView == .PICKERPICKER {
                        self.currentView = .MAIN
                    }
                })) {
                //  User can import from files or photos. Depending on what they pick a new view will be set for the current view and one of the importers from the importers file will be presented
                ActionSheet(title: Text("Import from..."), message: nil, buttons: [
                    .default(Text("Files")) {
                        self.currentView = .DOCPICKER
                    },
                    .default(Text("Photos")) {
                        self.currentView = .IMAGEPICKER
                    },
                    .cancel()
                ])
            }
                //  Presenting the specified picker on top of the current view
            .sheet(isPresented: Binding(
                get: {self.currentView == .IMAGEPICKER || self.currentView == .DOCPICKER},
            set: {
                _ = $0
                if self.currentView == .IMAGEPICKER || self.currentView == .DOCPICKER {
                    self.currentView = .MAIN
                }
            })) {
                if self.currentView == .IMAGEPICKER {
                    ImagePickerView(back: self.galleryBack)
                } else if self.currentView == .DOCPICKER {
                    DocPickerView(back: self.galleryBack)
                }
            }
        })
    }
    
    //  Presents either the main view or the preview view based on the currentView enum
    func getViewContents(_ currentView: GalleryViewEnum) -> AnyView {
        switch currentView {
        case .PREVIEW(let filepath):
            return AnyView(PreviewView(back: galleryBackButton, filepath: filepath, privKey: privKey))
        default:
            return getMainView()
        }
    }
    
    var body: some View {
        getViewContents(currentView)
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
