//
//  UwaziDateWidget.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziDateWidget: View {
    @State private var selectedDate = Date()
    @State private var dateText = ""
    var defaultDateString = "Select date"
    @ObservedObject var prompt: UwaziEntryPrompt
    var effect: CGAffineTransform = CGAffineTransform(scaleX: 3, y: 2.1)
    init(prompt: UwaziEntryPrompt) {
        self.prompt = prompt
        dateText = "Select date"
    }

    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            ZStack(alignment: .topLeading) {
                viewWithBackground()
                UwaziDatePickerView(selectedDate: $selectedDate)
                    .transformEffect(effect)
            }
            .onReceive(prompt.$isClearButtonHidden, perform: {
                if $0 {
                    dateText = defaultDateString
                    prompt.value.stringValue = ""
                }
            })
            Spacer()
        }
    }

    fileprivate func viewWithBackground() -> some View{
        ZStack {
            Color.white.opacity(0.16)
                .cornerRadius(15)
            HStack(alignment: .top) {
                mainView()
            }
        }
    }

    fileprivate func mainView() -> some View {
        return HStack {
            Image("date")
            Text(dateText)
                .font(.custom(Styles.Fonts.regularFontName, size: 14))
                .kerning(0.5)
                .onChange(of: selectedDate) { newValue in
                    dateText = newValue.getFormattedDateString(format: "d/MM/yyyy")
                    prompt.value.stringValue = dateText
                    prompt.isClearButtonHidden = false
                }
                .foregroundColor(.white)
            Spacer()
        }.padding(15)
    }
}

struct UwaziDateWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            UwaziDateWidget(prompt: .defaultValue())
        }
    }
}
