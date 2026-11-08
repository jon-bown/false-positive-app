//
//  NeuButton.swift
//  False Positive
//
//  Created by Jonathan Bown on 7/26/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI

struct NeuButton: View {
    
    @State private var isPressed: Bool = false
    
    private var buttonText: String = ""
    private var systemName: String = ""
    private var onTap: () -> Void
    private var showText: Bool = false
    
    init(buttonText: String = "", systemName: String = "", onTap: @escaping () -> Void){
        if systemName == "" {
            self.buttonText = buttonText
            self.showText = true
        }
        else{
            self.systemName = systemName
            self.showText = false
        }
        
        
        self.onTap = onTap
    }
    
    var gray: Color {
        return Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
    }
    
    var white: Color {
        return Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1))
    }
    
    var black: Color {
        return Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    
    var body: some View {
        VStack{
            ZStack{
                Button(action: {
                    
                    self.isPressed.toggle()
                    
                    //add haptic feedback
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.25){
                        self.isPressed = false
                        self.onTap()
                    }
                    
                    
                    
                }){
                    if showText {
                        Text(self.buttonText).foregroundColor(Color.black).padding()
                    } else {
                        Image(systemName: self.systemName).font(.system(size: 30)).imageScale(.large)
                            .aspectRatio(contentMode: .fit).frame(width: 25, height: 25).padding()
                    }
                         
                    
                   
                    }.background(RoundedRectangle(cornerRadius: 10).fill(Color.orange)).buttonStyle(PlainButtonStyle()).frame(width: 60, height: 60)
            }.clipShape(RoundedRectangle(cornerRadius: 10).inset(by: 1)).shadow(color: self.isPressed ? gray:black, radius: self.isPressed ? 10:8, x: 8, y: 8).shadow(color: self.isPressed ? black:gray, radius: self.isPressed ? 10:8, x: -8, y: -8).scaleEffect(self.isPressed ? 0.95:1.0).animation(.spring())

        }

    }
}



extension LinearGradient {
    init(_ colors: Color...){
        self.init(gradient: Gradient(colors: colors), startPoint: .topLeading, endPoint: .bottomTrailing)
    }
}

extension Color {
    static let offWhite = Color(red: 225 / 255, green: 225 / 255, blue: 235 / 255)
    
    static let darkStart = Color(red: 50 / 255, green: 60 / 255, blue: 65 / 255)
    static let darkEnd = Color(red: 25 / 255, green: 25 / 255, blue: 30 / 255)
    
    static let lightStart = Color(red: 60 / 255, green: 160 / 255, blue: 240 / 255)
    static let lightEnd = Color(red: 30 / 255, green: 80 / 255, blue: 120 / 255)
    
    static let redStart = Color(red: 224 / 255, green: 81 / 255, blue: 81 / 255)
    static let redEnd = Color(red: 212 / 255, green: 13 / 255, blue: 13 / 255)
}


struct SimpleButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                Group {
                    if configuration.isPressed {
                        Circle()
                            .fill(Color.offWhite)
                            .overlay(
                                Circle()
                                    .stroke(Color.gray, lineWidth: 4)
                                    .blur(radius: 4)
                                    .offset(x: 2, y: 2)
                                    .mask(Circle().fill(LinearGradient(Color.black, Color.clear)))
                        )
                            .overlay(
                                Circle()
                                    .stroke(Color.white, lineWidth: 8)
                                    .blur(radius: 4)
                                    .offset(x: -2, y: -2)
                                    .mask(Circle().fill(LinearGradient(Color.clear, Color.black)))
                        )
                    } else {
                        Circle()
                            .fill(Color.offWhite)
                            .shadow(color: Color.black.opacity(0.2), radius: 10, x: 10, y: 10)
                            .shadow(color: Color.white.opacity(0.7), radius: 10, x: -5, y: -5)
                    }
                }
        )
    }
}

struct DarkBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.darkEnd, Color.darkStart))
                    .overlay(shape.stroke(LinearGradient(Color.darkStart, Color.darkEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(Color.darkEnd, lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: -10, y: -10)
                    .shadow(color: Color.darkEnd, radius: 10, x: 10, y: 10)
            }
        }
    }
}

struct ColorfulBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.redEnd, Color.redStart))
                    .overlay(shape.stroke(LinearGradient(Color.redStart, Color.redEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
                    .frame(width: 75, height: 75)
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(LinearGradient(Color.redStart, Color.redEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 8, x: -5, y: -5)
                    .shadow(color: Color.darkEnd, radius: 8, x: 5, y: 5).frame(width: 75, height: 75)
            }
        }
    }
}

struct ColorfulRectBackground<S: Shape>: View {
    var isHighlighted: Bool
    var shape: S
    
    var body: some View {
        ZStack {
            if isHighlighted {
                shape
                    .fill(LinearGradient(Color.redEnd, Color.redStart))
                    .overlay(shape.stroke(LinearGradient(Color.redStart, Color.redEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 10, x: 5, y: 5)
                    .shadow(color: Color.darkEnd, radius: 10, x: -5, y: -5)
                    .frame(width: 125, height: 40)
            } else {
                shape
                    .fill(LinearGradient(Color.darkStart, Color.darkEnd))
                    .overlay(shape.stroke(LinearGradient(Color.redStart, Color.redEnd), lineWidth: 4))
                    .shadow(color: Color.darkStart, radius: 8, x: -5, y: -5)
                    .shadow(color: Color.darkEnd, radius: 8, x: 5, y: 5).frame(width: 125, height: 40)
            }
        }
    }
}

struct DarkButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                DarkBackground(isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 20))
        )
            .animation(nil)
    }
}

struct DarkToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(30)
                .contentShape(Circle())
        }
        .background(
            DarkBackground(isHighlighted: configuration.isOn, shape: Circle())
        )
    }
}

struct ColorfulButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                ColorfulBackground(isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 20))
        )
            .animation(nil)
    }
}

struct ColorfulRectButtonStyle: ButtonStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        configuration.label
            .padding(30)
            .contentShape(Circle())
            .background(
                ColorfulRectBackground(isHighlighted: configuration.isPressed, shape: RoundedRectangle(cornerRadius: 20))
        )
            .animation(nil)
    }
}

struct ColorfulToggleStyle: ToggleStyle {
    func makeBody(configuration: Self.Configuration) -> some View {
        Button(action: {
            configuration.isOn.toggle()
        }) {
            configuration.label
                .padding(30)
                .contentShape(Circle())
        }
        .background(
            ColorfulBackground(isHighlighted: configuration.isOn, shape: Circle())
        )
    }
}

struct NeuButton_Previews: PreviewProvider {
    static var previews: some View {
        VStack{
            NeuButton(buttonText: "Calculate"){
                
            }
            
            NeuButton(systemName: "equal"){
                
            }
        }
       
    }
}
