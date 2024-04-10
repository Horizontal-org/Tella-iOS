//
//  SearchBarView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//


import SwiftUI

struct SearchBarView: View {
    var body: some View {
        if #available(iOS 15.0, *) {
            SearchBar()
        } else {
            SearchBarNoFocus()
        }
    }
}

@available(iOS 15.0, *)
struct SearchBar: View {
    @State var value: String = ""
    @FocusState private var isInputActive:Bool
    var body: some View {
        HStack {
            Image("file.search")
            TextField("", text: $value)
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
    @State var value: String = ""
    var body: some View {
        HStack {
            Image("file.search")
            TextField("", text: $value)
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
    SearchBarView()
}
