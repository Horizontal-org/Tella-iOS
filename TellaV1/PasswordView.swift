//
//  PasswordView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 4/22/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

/*
 This struct represents the view for users to setup a lock for the app. It is shown once on initial app setup.
 */
import SwiftUI

struct PasswordView: View {
    @EnvironmentObject private var appViewState: AppViewState
    
    var body: some View {
        ZStack(alignment: .top) {
            Styles.Colors.backgroundMain.edgesIgnoringSafeArea(.all)
            VStack {
                Spacer()
                smallText("Choose lock type:")
                Spacer().frame(height: 30)
                VStack {
                    ForEach(Array(zip(PasswordTypeEnum.allCases.indices, PasswordTypeEnum.allCases)), id: \.0) { index, type in
                        Group {
                            if index > 0 {
                                Spacer().frame(height: 10)
                            }
                            RoundedButton(text: type.buttonText) {
                                do {
                                    try CryptoManager.shared.initKeys(type)
                                    self.appViewState.resetToMain()
                                } catch {}
                            }
                        }
                    }
                }
                .fixedSize()
                Spacer()
            }
        }
    }
}

struct PasswordView_Previews: PreviewProvider {
    
    static var previews: some View {
        PasswordView().environmentObject(AppViewState())
    }
}

