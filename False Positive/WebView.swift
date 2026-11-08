//
//  WebView.swift
//  False Positive
//
//  Created by Jonathan Bown on 7/15/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import Foundation
import SwiftUI
import WebKit


struct WebView: UIViewRepresentable{
    
    var file: String
    
    func updateUIView(_ uiView: WKWebView, context: UIViewRepresentableContext<WebView>) {
        
    }
    
    func makeUIView(context: Context) ->  WKWebView {
        let configuration = WKWebViewConfiguration()
        let wkWebView = WKWebView(frame: .zero, configuration: configuration)
        wkWebView.autoresizingMask = [.flexibleWidth, .flexibleHeight]
        
        let myProjectBundle:Bundle = Bundle.main
        
        let filePath:String = myProjectBundle.path(forResource: self.file, ofType: "html")!
        
        let myURL = URL(fileURLWithPath: filePath);

        
        wkWebView.scrollView.contentInset = .zero
        wkWebView.scrollView.contentInsetAdjustmentBehavior = .never
        
        
        wkWebView.loadFileURL(myURL, allowingReadAccessTo: myURL)
        return wkWebView
    }
}
