//
//  UwaziDatePicker.swift
//  Tella
//
//  Created by Gustavo on 04/01/2024.
//  Copyright © 2024 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziDatePicker: View {
    @State private var selectedDate = Date()
    @EnvironmentObject var prompt: UwaziEntryPrompt
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            ZStack(alignment: .topLeading) {
                viewWithBackground()
                DatePicker("select date",
                           selection: $selectedDate,
                           displayedComponents: [.date]
                ).datePickerStyle(.compact)
                    .labelsHidden()
                    .accentColor(Styles.Colors.lightBlue)
                    .onChange(of: selectedDate) { newDate in
                        updatePromptWithDate(newDate)
                    }
                
            }
        }
    }
    
    fileprivate func viewWithBackground() -> some View{
        ZStack {
            Color
                .white.opacity(0.16)
                .cornerRadius(15)
            HStack(alignment: .top) {
                HStack {
                    Image("uwazi.date")
                    Text("Select Date")
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                }
            }
        }
    }
    
    private func updatePromptWithDate(_ date: Date) {
//        let dateFormatter = DateFormatter()
//        dateFormatter.dateFormat = "d/MM/yyyy"
//        prompt.value.stringValue = dateFormatter.string(from: date)
        let unixTimestamp = Int(date.timeIntervalSince1970)
        prompt.value.stringValue = String(unixTimestamp)
        dump(prompt.value)
    }

}

struct UwaziDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        UwaziDatePicker()
    }
}
