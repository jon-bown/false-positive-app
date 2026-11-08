//
//  NavigationModifier.swift
//  False Positive
//
//  Created by Jonathan Bown on 7/27/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import Foundation
import SwiftUI


struct NavigationBarModifier: ViewModifier {
    
    var backgroundColor: Color?
    
    init( backgroundColor: Color?) {
        self.backgroundColor = backgroundColor
        let coloredAppearance = UINavigationBarAppearance()
        coloredAppearance.configureWithTransparentBackground()
        coloredAppearance.backgroundColor = .clear
        coloredAppearance.titleTextAttributes = [.foregroundColor: UIColor.white]
        coloredAppearance.largeTitleTextAttributes = [.foregroundColor: UIColor.white]
        
        UINavigationBar.appearance().standardAppearance = coloredAppearance
        UINavigationBar.appearance().compactAppearance = coloredAppearance
        UINavigationBar.appearance().scrollEdgeAppearance = coloredAppearance
        UINavigationBar.appearance().tintColor = .white
        
    }
    
    func body(content: Content) -> some View {
        ZStack{
            content
            VStack {
                GeometryReader { geometry in
                    (self.backgroundColor ?? Color(.clear))
                        .frame(height: geometry.safeAreaInsets.top)
                        .edgesIgnoringSafeArea(.top)
                    Spacer()
                }
            }
        }
    }
}


extension View {
    
    func navigationBarColor(_ backgroundColor: Color?) -> some View {
        self.modifier(NavigationBarModifier(backgroundColor: backgroundColor))
    }
    
}
