//
//  SearchBarView.swift
//  Tella
//
//  Created by gus valbuena on 4/10/24.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//



import SwiftUI

struct SearchBarView: View {
    @Binding var searchText: String
    var placeholderText: String
    var body: some View {
        VStack {
            ZStack {
                SearchBarPlaceholderText(searchText: $searchText, placeholderText: placeholderText)
                if #available(iOS 15.0, *) {
                    FocusedSearchBar(searchText: $searchText)
                } else {
                    UnfocusedSearchBar(searchText: $searchText)
                }
            }
        }.padding(.top, 8)
    }
}

struct SearchBarPlaceholderText: View {
    @Binding var searchText: String
    var placeholderText: String
    var body: some View {
        Text(placeholderText)
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
            SearchBarCancelButton(searchText: $searchText)
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
            SearchBarCancelButton(searchText: $searchText)
        }
        .padding()
        .overlay(
            RoundedRectangle(cornerRadius: 6)
                .stroke(.white.opacity(0.64), lineWidth: 1)
        )
        .padding()
    }
}

struct SearchBarCancelButton: View {
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
    SearchBarView(searchText: .constant(""), placeholderText: "placeholder")
}
