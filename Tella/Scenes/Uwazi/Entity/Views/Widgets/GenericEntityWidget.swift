//
//  GenericEntityWidget.swift
//  Tella
//
//  Created by Robert Shrestha on 9/12/23.
//  Copyright © 2023 HORIZONTAL. All rights reserved.
//

import SwiftUI

struct GenericEntityWidget<Content:View>: View {
    @ObservedObject var prompt: UwaziEntryPrompt
    private let content: Content
    private var isRequired: Bool
    private var showClearButton: Bool
    
    init(isRequired: Bool = false,
         showClearButton: Bool = false,
         prompt: UwaziEntryPrompt,
         @ViewBuilder content: () ->  Content)
    {
        self.content = content()
        self.isRequired = isRequired
        self.showClearButton = showClearButton
        self.prompt = prompt
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack {
                UwaziEntityTitleView(title: prompt.question, isRequired: isRequired)
                Spacer()
                if !prompt.isClearButtonHidden {
                    clearButton()
                }
            }
            if prompt.showMandatoryError {
                UwaziEntityMandatoryTextView()
            }
            content
        }
    }
    fileprivate func clearButton() -> Button<Image> {
        return Button {
            prompt.isClearButtonHidden = true
        } label: {
            Image(systemName: "x.circle.fill")
        }
    }
}

struct GenericEntityWidget_Previews: PreviewProvider {
    static var previews: some View {
        ContainerView {
            GenericEntityWidget(prompt: .defaultValue()) {
                Text("Hello")
            }
        }
    }
}
