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
    @State private var dateString: String = "Selected date"
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            ZStack(alignment: .topLeading) {
                DateLabel()
                DatePicker("select date",
                           selection: $selectedDate,
                           displayedComponents: [.date]
                ).datePickerStyle(.compact)
                    .labelsHidden()
                    .accentColor(Styles.Colors.lightBlue)
                    .colorInvert()
                    .colorMultiply(Color.clear)
                    .onChange(of: selectedDate) { newDate in
                        updatePromptWithDate(newDate)
                    }
                
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
    }
    
    fileprivate func DateLabel() -> some View{
        ZStack {
            HStack(alignment: .top) {
                HStack {
                    Image("uwazi.date")
                    Text(dateString)
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                }
            }
        }.padding()
    }
    
    private func updatePromptWithDate(_ date: Date) {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd-MM-yyyy"
        dateString = dateFormatter.string(from: date)
        let unixTimestamp = Int(date.timeIntervalSince1970)
        prompt.value.stringValue = String(unixTimestamp)
    }

}

struct UwaziDatePicker_Previews: PreviewProvider {
    static var previews: some View {
        UwaziDatePicker()
    }
}
