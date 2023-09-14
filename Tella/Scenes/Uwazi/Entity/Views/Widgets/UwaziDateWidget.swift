//
//  UwaziDateWidget.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziDateWidget: View {
    @State private var isDatePickerVisible = false
    @State private var selectedDate = Date()
    @State private var dateText = "Select date"
    var value: UwaziValue
    var onSuccess: ((String) -> Void)?
    var effect: CGAffineTransform = CGAffineTransform(scaleX: 3, y: 2.1)
    init( value: inout UwaziValue, onSuccess: @escaping (String) -> Void) {
        self.value = value
        self.onSuccess = onSuccess
    }
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            ZStack(alignment: .topLeading) {
                UwaziEntityButtonView(action: {
                    isDatePickerVisible.toggle()
                }, content: {
                    mainView()
                })
                UwaziDatePickerView(selectedDate: $selectedDate)
                    .transformEffect(effect)
            }
            Spacer()
        }
    }
    fileprivate func mainView() -> some View {
        return HStack {
            Image("date")
            Text(dateText)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .kerning(0.5)
                .foregroundColor(.white.opacity(0.8))
                .onChange(of: selectedDate) { newValue in
                    dateText = formattedDate(newValue)
                    value.stringValue = dateText
                    if onSuccess != nil {
                        onSuccess?(dateText)
                    }
                }
            Spacer()
        }.padding(15)
    }
    func formattedDate(_ date: Date) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "d/M/yyyy"
        return dateFormatter.string(from: date)
    }
}

//struct UwaziDateWidget: View {
//    @State private var isDatePickerVisible = false
//    @State private var selectedDate = Date()
//    @State private var dateText = "Select date"
//    var body: some View {
//        UwaziEntityButtonView(action: {
//            isDatePickerVisible.toggle()
//        }, content: {
//            VStack {
//                HStack(alignment: .center) {
//                    Image("date")
//                    Text(dateText)
//                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
//                        .kerning(0.5)
//                        .foregroundColor(.white.opacity(0.8))
//                    Spacer()
//                }.padding(15)
//                if isDatePickerVisible {
//                    UwaziDatePickerView(selectedDate: $selectedDate)
//                        .datePickerStyle(.wheel)
//                        .offset(x: 40,y: 6)
//                        .transformEffect(.init(scaleX: 0.8, y: 0.8))
//                }
//            }
//
//        })
//        .onChange(of: selectedDate) { newValue in
//           dateText = formattedDate(newValue)
//        }
//    }
//    func formattedDate(_ date: Date) -> String {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "d/M/yyyy"
//        return dateFormatter.string(from: date)
//    }
//}

//struct UwaziDateWidget_Previews: PreviewProvider {
//    static var previews: some View {
//        ContainerView {
//            UwaziDateWidget(value: .defaultValue())
//        }
//    }
//}
