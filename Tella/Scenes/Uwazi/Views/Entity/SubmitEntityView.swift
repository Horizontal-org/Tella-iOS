//
//  SubmitEntityView.swift
//  Tella
//
//  Created by Gustavo on 06/11/2023.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct SubmitEntityView: View {
    @ObservedObject var entityViewModel: UwaziEntityViewModel

    var body: some View {
        ContainerView {
            VStack {
                templateData
                
                UwaziDividerWidget()
                
                Spacer()
                    .frame(height: 20)
                
                entityTitle
                
                entityContent
                
                Spacer()
                UwaziDividerWidget()
                
                bottomActionView
            }
        }
        .navigationBarTitleDisplayMode(.inline)
        .toolbar {
            ToolbarItem(placement: .principal) {
                HStack {
                    Text("Summary")
                        .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity, alignment: .leading) // Align to leading
                }
            }
        }
    }
    
    var templateData: some View {
        VStack {
            Text("Server: \(entityViewModel.template?.serverName ?? "")")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
            Text("Template: \(entityViewModel.template!.entityRow?.name ?? "")")
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }.padding()
    }
    
    var entityTitle: some View {
        VStack {
            Text(entityViewModel.getEntityTitle())
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 16))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
        .padding()
    }
    
    var entityContent: some View {
        VStack {
            entityResponseItem
            FileItems(files: $entityViewModel.pdfDocuments)
            FileItems(files: $entityViewModel.files)
        }
    }
    
    var bottomActionView: some View {
        HStack {
            Spacer()
            Button {
                entityViewModel.submitEntity()
            } label: {
                Text("SUBMIT")
                    .frame(maxWidth:.infinity)
                    .frame(height: 55)
                    .contentShape(Rectangle())
            }
            .frame(width: UIScreen.main.bounds.width / 2, alignment: .trailing)
            .cornerRadius(50)
            .buttonStyle(TellaButtonStyle(buttonStyle: YellowButtonStyle(), isValid: true))
        }.padding(.horizontal)
    }

    var entityResponseItem: some View {
        HStack {
            RoundedRectangle(cornerRadius: 5)
                .fill(Color.white.opacity(0.2))
                .frame(width: 48, height: 48, alignment: .center)
                .overlay(
                    ZStack{
                        Image("document")
                    }
                    .frame(width: 48, height: 48)
                    .cornerRadius(5)
                )
            VStack(alignment: .leading) {
                Text("Entity reponse")
                    .font(.custom(Styles.Fonts.semiBoldFontName, size: 14))
                    .foregroundColor(Color.white)
                    .lineLimit(1)
                
                Spacer()
                    .frame(height: 2)
                
                Text(entityViewModel.getEntityResponseSize())
                    .font(.custom(Styles.Fonts.regularFontName, size: 10))
                    .foregroundColor(Color.white)
            }
            .padding(.horizontal, 12)
        }
        .padding(.bottom, 17)
        .padding(.horizontal, 12)
        .frame(maxWidth: .infinity, alignment: .leading)
    }
    
}

