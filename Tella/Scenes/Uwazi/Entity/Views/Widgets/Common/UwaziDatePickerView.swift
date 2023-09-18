//
//  UwaziDatePickerView.swift
//  Tella
//
//  Created by Robert Shrestha on 9/13/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct UwaziDatePickerView: View {
    @Binding var selectedDate: Date
    var body: some View {
        DatePicker("",
                   selection: $selectedDate,
                   displayedComponents: [.date])
        .datePickerStyle(.compact)
        .accentColor(Styles.Colors.lightBlue)
        .changeTextColor(.clear)
        .labelsHidden()
        .clipped()
    }
}

struct UwaziDatePickerView_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            UwaziDatePickerView(selectedDate: .constant(Date()))
        }
    }
}
