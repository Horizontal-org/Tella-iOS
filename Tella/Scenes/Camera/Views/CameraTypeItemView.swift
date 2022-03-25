//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import SwiftUI

struct  CameraTypeItemView: View {
    
    let title: String
    let width: CGFloat
    let page: CameraType
    @Binding var selectedOption: CameraType
    
    public var body: some View {
        VStack {
            let selected: Bool = page == selectedOption
            Text(title)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 15))
                .foregroundColor(selected ? Color.white :  Color.init(red: 0.655, green: 0.685, blue: 0.702))
                .minimumScaleFactor(0.5)
                .lineLimit(1)
            Rectangle()
                .fill(selected ?  Color.white : Color.clear)
                .frame(width: width, height: 2, alignment: /*@START_MENU_TOKEN@*/.center/*@END_MENU_TOKEN@*/)
        }
    }
}
struct CameraTypeItemView_Previews: PreviewProvider {
    static var previews: some View {
        CameraTypeItemView(title: "Camera", width: 100, page: CameraType.image, selectedOption: .constant(CameraType.image))
    }
}
