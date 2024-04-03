//
//  SearchBarView.swift
//  Tella
//
//  Created by gus valbuena on 3/25/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI


struct SearchBarView: View {
    @Binding var searchText: String
    var body: some View {
        if #available(iOS 15.0, *) {
            SearchBar(searchText: $searchText)
        } else {
            SearchBarNoFocus(searchText: $searchText)
        }
    }
}

@available(iOS 15.0, *)
struct SearchBar: View {
    @Binding var searchText: String
    @FocusState private var isInputActive:Bool
    var body: some View {
        HStack {
            Image("file.search")
            TextField("", text: $searchText)
            .keyboardType(.default)
            .textFieldStyle(TextfieldStyle(shouldShowError: false))
            .frame( height: 22)
            .focused($isInputActive)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(isInputActive ? Styles.Colors.yellow : .white.opacity(0.64), lineWidth: 1)
        )
        .padding()
    }
}

struct SearchBarNoFocus: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            Image("file.search")
            TextField("", text: $searchText)
            .keyboardType(.default)
            .textFieldStyle(TextfieldStyle(shouldShowError: false))
            .frame( height: 22)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.white.opacity(0.64), lineWidth: 1)
        )
        .padding()
    }
}

#Preview {
    SearchBarView(searchText: .constant(""))
}
