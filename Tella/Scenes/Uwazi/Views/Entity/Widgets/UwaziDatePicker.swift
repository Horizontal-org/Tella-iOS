//
//  UwaziDatePicker.swift
//  Tella
//
//  Created by Gustavo on 04/01/2024.
//  Copyright © 2024 HORIZONTAL. 
//  Licensed under MIT (https://github.com/Horizontal-org/Tella-iOS/blob/develop/LICENSE)
//


import SwiftUI

struct UwaziDatePicker: View {
    @State private var selectedDate: Date
    @State private var dateString: String
    @ObservedObject var prompt: UwaziTextEntryPrompt
    var entityViewModel: UwaziEntityViewModel
        
    init(prompt: UwaziTextEntryPrompt, entityViewModel: UwaziEntityViewModel) {
        self.prompt = prompt
        _dateString = State(initialValue: LocalizableUwazi.uwaziEntitySelectDateTitle.localized)
        _selectedDate = State(initialValue: Date())
        self.entityViewModel = entityViewModel
    }
    
    var body: some View {
        UwaziActionRow(icon: .uwaziDate,
                       title: parseDateFromPrompt(prompt.value))
            .overlay {
                TransparentDatePicker(selection: $selectedDate) {
                    updatePromptWithDate($0)
                }
            }
            .onAppear {
                selectedDate = Date()
            }
    }
    
    private func TransparentDatePicker(selection: Binding<Date>, onChange: @escaping (Date) -> Void) -> some View {
        DatePicker("", selection: selection, displayedComponents: [.date])
            .datePickerStyle(.compact)
            .labelsHidden()
            .accentColor(Styles.Colors.lightBlue)
            .colorInvert()
            .colorMultiply(Color.clear)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .contentShape(Rectangle())
            .onChange(of: selection.wrappedValue, perform: onChange)
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
