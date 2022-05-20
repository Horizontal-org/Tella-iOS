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

    @Binding var isPresented : Bool
    @EnvironmentObject var lockViewModel : LockViewModel
    @Environment(\.presentationMode) var presentationMode: Binding<PresentationMode>
    @EnvironmentObject private var appViewState: AppViewState

    var body: some View {
        
        NavigationContainerView {
            VStack {
                if lockViewModel.unlockType == .update {
                    LockChoiceHeaderView(isPresented: $isPresented)
                }

                VStack(alignment: .center, spacing: 24) {
                    Spacer()
                    Image("lock.phone")
                        .frame(width: 60, height: 100)
                        .aspectRatio(contentMode: .fit)
                    
                    Text(Localizable.Lock.lockSelectSubhead)
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
        }
        .navigationBarTitle("")
        .navigationBarHidden(true)
        .onReceive(appViewState.$shouldHidePresentedView) { value in
            if(value) {
                self.presentationMode.wrappedValue.dismiss()
            }
        }
    }
}

struct LockChoiceHeaderView : View {
    
    @Binding var isPresented : Bool
    
    var body: some View {
        
        HStack {
            Button {
                isPresented = false
            } label: {
                Image("close")
            }.padding(EdgeInsets(top: 0, leading: 16, bottom: 0, trailing: 12))
            
            Text(Localizable.Lock.lockSelectTitle)
                .font(.custom(Styles.Fonts.semiBoldFontName, size: 18))
                .foregroundColor(Color.white)
            Spacer()
        }.padding(.top, 15)
        
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
                    .font(.custom(Styles.Fonts.regularFontName, size: 13.5))
                    .foregroundColor(.white)
            }
            Spacer()
        } .padding(16)
            .background( Color.white.opacity(0.16))
            .cornerRadius(20)
            .buttonStyle(LockButtonStyle())
            .navigateTo(destination: destination)
    }
}

struct LockButtonStyle : ButtonStyle {
    
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .background(configuration.isPressed ? Color.white.opacity(0.32) : Color.white.opacity(0.16))
            .cornerRadius(20)
            .overlay(
                configuration.isPressed ? RoundedRectangle(cornerRadius: 20).stroke(Color.white.opacity(0.8), lineWidth: 3) :  RoundedRectangle(cornerRadius: 20).stroke(Color.clear, lineWidth: 0)
            )
    }
}

struct LockChoiceView_Previews: PreviewProvider {
    static var previews: some View {
        LockChoiceView(isPresented: .constant(true))
    }
}
