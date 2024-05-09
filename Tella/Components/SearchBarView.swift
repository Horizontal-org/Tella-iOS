//
//  SearchBarView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//


import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var body: some View {
        VStack {
            ZStack {
                PlaceholderText(searchText: $searchText)
                if #available(iOS 15.0, *) {
                    FocusedSearchBar(searchText: $searchText)
                } else {
                    UnfocusedSearchBar(searchText: $searchText)
                }
            }
        }.padding(.top, 8)
    }
}

struct PlaceholderText: View {
    @Binding var searchText: String
    var body: some View {
        Text(LocalizableUwazi.uwaziRelationshipSearchTitle.localized)
            .font(.custom(Styles.Fonts.regularFontName, size: 14))
            .offset(x: searchText.isEmpty ? 42 : 0, y: searchText.isEmpty ? 0 : -40)
            .frame(maxWidth: .infinity,alignment: .leading)
            .contentShape(Rectangle())
            .foregroundColor(searchText.isEmpty ? .white : .white.opacity(0.8))
            .padding(.horizontal, 18)
    }
}

@available(iOS 15.0, *)
struct FocusedSearchBar: View {
    @Binding var searchText: String
    @FocusState private var isInputActive:Bool
    var body: some View {
        HStack {
            Image("file.search")
            TextField("", text: $searchText)
                .keyboardType(.default)
                .textFieldStyle(TextfieldStyle(shouldShowError: false))
                .frame(height: 22)
                .focused($isInputActive)
            CancelButton(searchText: $searchText)
        }
        .padding()
        .overlay(
          RoundedRectangle(cornerRadius: 6)
            .stroke(isInputActive ? Styles.Colors.yellow : .white.opacity(0.64), lineWidth: 1)
        )
        .padding()
    }
}

struct UnfocusedSearchBar: View {
    @Binding var searchText: String
    var body: some View {
        HStack {
            Image("file.search")
            TextField("", text: $searchText)
                .keyboardType(.default)
                .textFieldStyle(TextfieldStyle(shouldShowError: false))
                .frame( height: 22)
            CancelButton(searchText: $searchText)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.white.opacity(0.64), lineWidth: 1)
        )
        .padding()
    }
}

struct CancelButton: View {
    @Binding var searchText: String
    var body: some View {
        if !searchText.isEmpty {
            Button(action: { searchText = "" }) {
                Image("uwazi.cancel")
            }
        }
    }
}
#Preview {
    SearchBarView(searchText: .constant(""))
}
