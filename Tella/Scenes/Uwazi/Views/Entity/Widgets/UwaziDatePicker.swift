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
    @State private var dateString: String
    @EnvironmentObject var prompt: UwaziTextEntryPrompt
    @EnvironmentObject var entityViewModel: UwaziEntityViewModel
//    @ObservedObject var value: UwaziValue
        
    init() {
//        self.value = value
        _dateString = State(initialValue: LocalizableUwazi.uwaziEntitySelectDateTitle.localized)
    }
    
    var body: some View {
        HStack(alignment: .lastTextBaseline) {
            ZStack(alignment: .topLeading) {
                DateLabel()
                TransparentDatePicker(selection: $selectedDate) {
                    updatePromptWithDate($0)
                }
                
            }
        }.frame(maxWidth: .infinity, alignment: .leading)
            .background(Color.white.opacity(0.08))
            .cornerRadius(12)
    }
    
    private func TransparentDatePicker(selection: Binding<Date>, onChange: @escaping (Date) -> Void) -> some View {
        DatePicker("", selection: selection, displayedComponents: [.date])
            .datePickerStyle(.compact)
            .labelsHidden()
            .accentColor(Styles.Colors.lightBlue)
            .colorInvert()
            .colorMultiply(Color.clear)
            .onChange(of: selection.wrappedValue, perform: onChange)
    }

    fileprivate func DateLabel() -> some View{
        ZStack {
            HStack(alignment: .top) {
                HStack {
                    Image("uwazi.date")
                    Text(parseDateFromPrompt(prompt.value))
                        .font(.custom(Styles.Fonts.regularFontName, size: 14))
                        .foregroundColor(.white)
                        .padding(.horizontal, 8)
                }
            }
        }.padding()
    }
    
    private func updatePromptWithDate(_ date: Date) {
        let unixTimestamp = date.getUnixTimestamp()
        prompt.value = String(unixTimestamp)
//        entityViewModel.toggleShowClear(forId: prompt.id ?? "", value: true)
    }
    
    private func parseDateFromPrompt(_ date: String) -> String {
        guard !date.isEmpty, let unixTimeStamp = Double(date) else {
            return dateString
        }
        
        return unixTimeStamp.getDate()?.getFormattedDateString(format: DateFormat.uwaziDate.rawValue) ?? ""
    }
}

//struct UwaziDatePicker_Previews: PreviewProvider {
//    static var previews: some View {
//        UwaziDatePicker(value: UwaziValue(type: UwaziEntityPropertyType.dataTypeText,
//                                          stringValue: "",
//                                          selectedValue: []))
//    }
//}
