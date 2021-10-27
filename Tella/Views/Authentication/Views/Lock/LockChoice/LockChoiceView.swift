//
//  AuthenticationView.swift
//  Tella
//
//   
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI
import CoreMIDI

struct LockChoiceView: View {
    var body: some View {
        
        NavigationContainerView {
            
            VStack(alignment: .center, spacing: 24) {
                Spacer()
                Image("lock.phone")
                    .frame(width: 60, height: 100)
                    .aspectRatio(contentMode: .fit)
                
                Text(LocalizableLock.title.localized)
                    .font(.custom(Styles.Fonts.boldFontName, size: 18))
                    .foregroundColor(.white)
                
                VStack(spacing: 15) {
                    
                    LockButtonView(lockButtonProtocol: PasswordLockButton(),
                                   destination: LockPasswordView())
                    
                    LockButtonView(lockButtonProtocol: PINLockButton(),
                                   destination: LockPinView())
                }
                Spacer()
            }
            .padding(EdgeInsets(top: 0, leading: 24, bottom: 0, trailing: 24))
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
    }
}

struct LockButtonView<Destination:View> : View {
    
    var lockButtonProtocol : LockButtonProtocol
    var destination : Destination
    
    var body: some View {
        
        HStack(spacing: 20) {
            
            Image(lockButtonProtocol.imageName)
                .frame(width: 42, height: 42)
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment:.leading, spacing: 3 ) {
                Text(lockButtonProtocol.title)
                    .font(.custom(Styles.Fonts.boldFontName, size: 16))
                    .foregroundColor(.white)
                
                Text(lockButtonProtocol.description)
                    .font(.custom(Styles.Fonts.regularFontName, size: 11))
                    .foregroundColor(.white)
            }
            Spacer()
            
        }.padding(16)
            .cornerRadius(20)
            .navigateTo(destination: destination)
        
            .cornerRadius(20)
            .buttonStyle(LockButtonStyle())
    }
}

struct LockButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.32) : Color.white.opacity(0.16))
            .overlay(
                configuration.isPressed ? RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.8), lineWidth: 3) :  RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0)
            )
    }
}

struct LockChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LockChoiceView()
    }
}
