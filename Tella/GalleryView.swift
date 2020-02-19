//
//  GalleryView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 2/17/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct GalleryView: View {
    
    let back: Button<AnyView>
        
        var body: some View {
            
            let first = File(name: "File 1")
            let second = File(name: "File 2")
            let third = File(name: "File 3")
            let files = [first, second, third]
            
            return Group {
                
                HStack {
                    back
                    Spacer()
                    mediumText("GALLERY")
                    Spacer()
                    Button(action: {
                        print("shutdown button pressed")
                    }) {
                        mediumImg(.SHUTDOWN)
                    }
                }

                Spacer().frame(maxHeight: 50)

                HStack {
                    Button(action: {
                        print("list icon pressed")
                    }) {
                        smallImg(.LIST)
                        smallText("List view")
                    }
                    Spacer().frame(maxWidth: 40)
                    Button(action: {
                        print("grid icon pressed")
                    }) {
                        smallImg(.GRID)
                        smallText("Grid view")
                    }
                }

                Spacer()
                List(files) { file in
                    FileRow(file: file)

                }
                Spacer()
                HStack {
                    Spacer()
                    Button(action: {
                        print("plus icon pressed")
                    }) {
                        bigImg(.PLUS)
                    }
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
        Text("\(file.name)").font(.custom("Avenir Next Ultra Light", size: 20)).foregroundColor(.black)
    }
}
