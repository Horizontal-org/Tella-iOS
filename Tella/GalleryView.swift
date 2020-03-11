//
//  GalleryView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI
import UIKit

struct GalleryView: View {
    
    @State var currentView = GalleryViewEnum.MAIN
    @State var displayList = true
    @State var fileList = TellaFileManager.getEncryptedFileNames()
    @State var showingAlert = false
    
    
    func galleryBack() {
        self.currentView = GalleryViewEnum.MAIN;
        self.fileList = TellaFileManager.getEncryptedFileNames()
    }

    var galleryBackButton: Button<AnyView> {
        return backButton { self.galleryBack() }
    }
    
    let back: Button<AnyView>
    
    func getListGridView() -> AnyView {
        if displayList {
            return AnyView(List(fileList.map({ (value: String) -> File in File(name: value) })) { file in
                Group {
                    Button(action: {
                        print("preview")
                        self.currentView = .PREVIEW(filepath: TellaFileManager.fileNameToPath(name: file.name))
                        //self.showingPreview.toggle()
                        
                    }) {
                        smallText(file.name)
                    }
                    Spacer()
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        smallText("x")
                    }.buttonStyle(BorderlessButtonStyle())
                        .alert(isPresented: self.$showingAlert) {
                            Alert(title: Text("Are you sure you want to delete this?"), message: Text("There is no undo"), primaryButton: .destructive(Text("Delete"), action: {
                                    print("delete")
                                    TellaFileManager.deleteEncryptedFile(name: file.name)
                                    self.fileList = TellaFileManager.getEncryptedFileNames()
                            }), secondaryButton: .cancel())
                    }
                }
            })
        } else {
            return smallText("Grid View Not Implemented")
        }
    }

    func getMainView() -> AnyView {
        return AnyView(Group {
            header(back, "GALLERY")
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
                Button(action: {
                    self.currentView = .PICKERPICKER
                }) {
                    bigImg(.PLUS)
                }
            }
            .actionSheet(isPresented: Binding(
                get: {self.currentView == .PICKERPICKER},
                set: {
                    _ = $0
                    if self.currentView == .PICKERPICKER {
                        self.currentView = .MAIN
                    }
                })) {
                //creates the popup on plus button, giving options of where to import from
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
                //presenting the specified picker on top of the current view
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
    
    func getViewContents(_ currentView: GalleryViewEnum) -> AnyView {
        switch currentView {
        case .PREVIEW(let filepath):
            return AnyView(PreviewView(back: galleryBackButton, filepath: filepath))
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
