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
                Group {
                    Spacer().frame(maxHeight: 30)
                    Button(action: {
                        print(TellaFileManager.keyFileExists(.META_PUBLIC))
                    }) {
                        smallText("meta pub key exists")
                    }
                    Spacer().frame(maxHeight: 15)
                    Button(action: {
                        print(CryptoManager.metaPrivateKeyExists())
                    }) {
                        smallText("meta priv key exists")
                    }
                    Spacer().frame(maxHeight: 15)
                    Button(action: {
                        CryptoManager.deleteMetaKeypair()
                    }) {
                        smallText("delete meta keypair")
                    }
                }
                Group {
                    Spacer().frame(maxHeight: 15)
                    Button(action: {
                        print(TellaFileManager.keyFileExists(.PUBLIC))
                    }) {
                        smallText("pub key exists")
                    }
                    Spacer().frame(maxHeight: 15)
                    Button(action: {
                        print(TellaFileManager.keyFileExists(.PRIVATE))
                    }) {
                        smallText("priv key exists")
                    }
                    Spacer().frame(maxHeight: 15)
                    Button(action: {
                        CryptoManager.deleteKeypair()
                    }) {
                        smallText("delete keypair")
                    }
                    Spacer().frame(maxHeight: 15)
                    Button(action: {
                        CryptoManager.initKeys(.PASSWORD)
                    }) {
                        smallText("init keys w/ password")
                    }
                }
            }
            Spacer()
        }
    }
}
