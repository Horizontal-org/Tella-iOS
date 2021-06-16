//
//  FormsCellView.swift
//  Tella
//
//  Created by Ahlem on 15/06/2021.
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FormsCellView: View {
    var formModel : FormsModel
    
    var body: some View {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
            FavoriteButton(isSet: formModel.$isFavorite)
                .padding()
            VStack(alignment : .leading,spacing: 0){
                Text(formModel.title)
                    .font(Font.custom("open-sans.regular", size: 14))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.white)
                Text(formModel.description)
                    .font(Font.custom("open-sans.regular", size: 12))
                    .fontWeight(.regular)
                    .foregroundColor(Color.white)
                    .padding(.top, 4)
            }.padding(.vertical)
            Spacer()
            VStack(spacing: 0){
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .padding(.top, 2)
                RoundedRectangle(cornerRadius: 25)
                    .fill(Color.white)
                    .frame(width: 4, height: 4)
                    .padding(.top, 2)
            }
            .padding(.trailing, 20)
        }
        .background(Color(Styles.Colors.backgroundFileButton)
                        .clipShape(RoundedRectangle(cornerRadius:15)))
        .padding(.horizontal, 16)
        
        
    }
}

extension UIView {
    func roundCorners(corners: UIRectCorner, radius: CGFloat) {
        let path = UIBezierPath(roundedRect: bounds, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        let mask = CAShapeLayer()
        mask.path = path.cgPath
        layer.mask = mask
    }
}

struct FormsCellView_Previews: PreviewProvider {
    static var previews: some View {
        FormsCellView(formModel: FormsModel(title: "Test", description: "This is a description", isFavorite: true))
    }
}
