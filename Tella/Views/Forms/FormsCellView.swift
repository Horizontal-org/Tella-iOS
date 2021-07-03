//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct FormsCellView: View {
    
    let formModel : FormModel
    @State var toggle : Bool
    
    init(formModel : FormModel) {
        //create State with initial value here
        self.formModel = formModel
        self._toggle = State(initialValue: self.formModel.details.isFavorite)
    }
    
    var body: some View {
        HStack(alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/){
            Button(action: {
                formModel.details.isFavorite.toggle()
                self.toggle.toggle()
                debugLog("\(formModel.details.isFavorite)")
            }, label: {
                Image(systemName: self.toggle ? "star.fill" : "star")
                    .foregroundColor(self.toggle ? .yellow : .white)
            })
            .padding()
            VStack(alignment : .leading,spacing: 0){
                Text(formModel.details.title)
                    .font(Font.custom("open-sans.regular", size: 14))
                    .fontWeight(/*@START_MENU_TOKEN@*/.bold/*@END_MENU_TOKEN@*/)
                    .foregroundColor(Color.white)
                Text(formModel.details.description)
                    .font(Font.custom("open-sans.regular", size: 12))
                    .fontWeight(.regular)
                    .foregroundColor(Color.white)
                    .padding(.top, 4)
            }.padding(.vertical)
            Spacer()
            Button(action: {
                debugLog("More clicked")
            }, label: {
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
            })
            
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
