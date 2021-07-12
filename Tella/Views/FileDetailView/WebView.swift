//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit

struct WebViewer: View {
    var url: String
    var body: some View {
        Webview(url: URL(string: url)!)
    }
}

struct Webview: UIViewRepresentable {
    var url: URL
    
    func makeUIView(context: UIViewRepresentableContext<Webview>) -> WKWebView {
        let webview = WKWebView()
        
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
        
        return webview
    }
    
    func updateUIView(_ webview: WKWebView, context: UIViewRepresentableContext<Webview>) {
        let request = URLRequest(url: self.url, cachePolicy: .returnCacheDataElseLoad)
        webview.load(request)
    }
}


struct WebViewerViewer_Previews: PreviewProvider {
    static var previews: some View {
        WebViewer(url: "https://google.com")
    }
}
