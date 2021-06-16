//
//  BlankFormsView.swift
//  Tella
//
//  Created by Ahlem on 15/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct BlankFormsView: View {
    var listForms = [FormsModel(title: "Title 1", description: "Description 1", isFavorite: false), FormsModel(title: "Title 2", description: "Description 2", isFavorite: true),
                     FormsModel(title: "Title 3", description: "Description 3", isFavorite: false),
                     FormsModel(title: "Title 4", description: "Description 4", isFavorite: true)
    ]
    var body: some View {
        ZStack(alignment: .top) {
            VStack(alignment: .leading, spacing: 0){
                ScrollView{
                    ForEach(listForms) { formModel in
                        FormsCellView(formModel: formModel)
                    }
                }
            }.background(Color(Styles.Colors.backgroundMain))
            
        }
        
    }
}

struct BlankFormsView_Previews: PreviewProvider {
    static var previews: some View {
        BlankFormsView()
    }
}
