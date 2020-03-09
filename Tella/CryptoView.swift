//
//  CryptoView.swift
//  Tella
//
//  Created by Oliphant, Samuel on 3/9/20.
//  Copyright © 2020 Anessa Petteruti. All rights reserved.
//

import SwiftUI

struct CryptoView: View {
    
    let back: Button<AnyView>
    
    var body: some View {
        return Group {
            header(back, "CRYPTO")
            VStack {
                Spacer().frame(maxHeight: 30)
                Button(action: {
                    print(CryptoManager.publicKeyExists())
                }) {
                    smallText("pub key exists")
                }
                Spacer().frame(maxHeight: 15)
                Button(action: {
                    print(CryptoManager.privateKeyExists())
                }) {
                    smallText("priv key exists")
                }
                Spacer().frame(maxHeight: 15)
                Button(action: {
                    TellaFileManager.deletePublicKey()
                }) {
                    smallText("delete pub key")
                }
                Spacer().frame(maxHeight: 15)
                Button(action: {
                    CryptoManager.deletePrivateKey()
                }) {
                    smallText("delete priv key")
                }
                Spacer().frame(maxHeight: 15)
                Button(action: {
                    CryptoManager.initKeys()
                }) {
                    smallText("init keys")
                }
            }
            Spacer()
        }
    }
}
