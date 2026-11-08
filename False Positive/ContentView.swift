//
//  ContentView.swift
//  False Positive
//
//  Created by Jonathan Bown on 6/24/20.
//  Copyright © 2020 App Factorial. All rights reserved.
//

import SwiftUI
import UIKit
import MessageUI

struct ContentView: View {
    
    //redraws the view
    @Environment(\.verticalSizeClass) var sizeClass
    
    //Variables entered by the user
    @State private var prevalance: Decimal?
    @State private var sensitivity: Decimal?
    @State private var specificity: Decimal?

        
    @State private var variableList: [varList] = [varList]()
    
    //Internal variables that output to the screen
    @State private var falsePositive: Decimal = 0.0
    @State private var falseNegative: Decimal = 0.0
    @State private var truePositive: Decimal = 0.0
    @State private var trueNegative: Decimal = 0.0
    
    @State private var numFalsePositive: Int = 0
    @State private var numFalseNegative: Int = 0
    @State private var numTruePositive: Int = 0
    @State private var numTrueNegative: Int = 0
    @State private var numSick: Int = 0
    @State private var numHealthy: Int = 0
    
    @State private var pPositive: Decimal = 0.0
    @State private var pNegative: Decimal = 0.0
    
    @State private var ppv: Decimal = 0.0
    @State private var npv: Decimal = 0.0
    @State private var fdr: Decimal = 0.0
    @State private var foRate: Decimal = 0.0

    //App state variables
    @State private var showErrorMessage: Bool = false
    @State private var showPopover: Bool = false
    @State private var showAnswers: Bool = false
    @State private var showResults: Int = 0
    @State private var showButtonToggle: Bool = true
//    @State var result: Result<MFMailComposeResult, Error>? = nil
//    @State var isShowingMailView = false
    
    init() {
        UISegmentedControl.appearance().selectedSegmentTintColor = UIColor(red: 212 / 255, green: 13 / 255, blue: 13 / 255, alpha: 1)
        UISegmentedControl.appearance().backgroundColor = #colorLiteral(red: 0.3568021352, green: 0.3568021352, blue: 0.3568021352, alpha: 1)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        UISegmentedControl.appearance().setTitleTextAttributes([.foregroundColor: UIColor.white], for: .normal)
        UISegmentedControl.appearance().alpha = 1
        
    }
    
    private var version: String = Bundle.main.infoDictionary?["CFBundleVersion"] as! String
    
    var background: Color {
        return Color(#colorLiteral(red: 0.2549019754, green: 0.2745098174, blue: 0.3019607961, alpha: 1))
    }
    
    var backgroundPop: Color {
        return Color(#colorLiteral(red: 0.501960814, green: 0.501960814, blue: 0.501960814, alpha: 1))
    }
    
    var navBackground: Color {
        return Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1))
    }
    
    var gray: Color {
        return Color(#colorLiteral(red: 0.6000000238, green: 0.6000000238, blue: 0.6000000238, alpha: 1))
    }
    
    var white: Color {
        return Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)).opacity(0.2)
    }
    
    var black: Color {
        return Color(#colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)).opacity(1)
    }
    
    var red: Color {
        return Color(red: 212 / 255, green: 13 / 255, blue: 13 / 255)
    }
    
    //Font variable
    var font: String{
        return "AppleSDGothicNeo-Regular"
    }
    
    var fontSize: CGFloat{
        return CGFloat(20)
    }
    
    var resultFontSize: CGFloat{
        return CGFloat(15)
    }
    

    var percentFormatter: NumberFormatter {
        let nf = NumberFormatter()
        nf.numberStyle = .percent
        
        nf.maximumFractionDigits = 2
        nf.maximumIntegerDigits = 2
        nf.minimum = 0
        nf.maximum = 100
        nf.multiplier = 1
        nf.isLenient = true
        return nf
    }
    
    var body: some View {
        NavigationView{
            VStack{

             VStack{
                        HStack(alignment: .center){
                            VStack{
                                Text("Prevalence  =").font(.custom(self.font, size: self.fontSize)).padding(.vertical, 20)
                               Text("Sensitivity  =").font(.custom(self.font, size: self.fontSize)).padding(.vertical, 20)
                               Text("Specificity  =").font(.custom(self.font, size: self.fontSize)).padding(.vertical, 20)
                            }
                            VStack{
                                DecimalField("0.0", value: self.$prevalance, formatter: self.percentFormatter, backgroundColor: gray)
                                DecimalField("0.0", value: self.$sensitivity, formatter: self.percentFormatter, backgroundColor: gray)
                                DecimalField("0.0", value: self.$specificity, formatter: self.percentFormatter, backgroundColor: gray)
                            }
                            
                    
                            
                        }
                }.padding()
            

                HStack{
                    
                 
                    Button(action:{
                        self.hideKeyboard()
                        self.calculateProbabilities()
                        
                    }){
                        Image(systemName: "equal").font(.system(size: 30)).imageScale(.large)
                            .aspectRatio(contentMode: .fit).frame(width: 25, height: 25).padding()
                    }.buttonStyle(ColorfulButtonStyle()).alert(isPresented: self.$showErrorMessage) {
                        self.simpleFailure()
                        self.clearAll()
                        return Alert(title: Text("Error"), message: Text("Please enter numbers between 0 and 100 in each of the required fields"), dismissButton: .default(Text("OK")))
                                           }
                    


                }.padding(.vertical, 25)
                
                
                
                HStack(alignment: .center){
                    Button(action:{
                        self.showButtonToggle = true
                        self.showResults = 0
                        
                    }){
                        Text("Probabilities").lineLimit(1).foregroundColor(.white).padding(.horizontal, 50)
                    }.background(
                        ColorfulRectBackground(isHighlighted: self.showButtonToggle, shape: RoundedRectangle(cornerRadius: 10))
                    ).frame(width: 200)
      
                    Button(action:{
                        self.showButtonToggle = false
                        self.showResults = 1
                        
                    }){
                        Text("Actuals").lineLimit(1).foregroundColor(.white).padding(.horizontal, 50)
                    }.background(
                        ColorfulRectBackground(isHighlighted: !self.showButtonToggle, shape: RoundedRectangle(cornerRadius: 10))
                    ).frame(width: 200)
                    
                }.padding(.vertical, 10)

                
                Spacer()
            
                if self.showResults == 0{
                   
                    
                    HStack{
                        VStack(alignment: .trailing){
                            Text("P(+): \(self.decimalToText(self.pPositive))").font(.custom(self.font, size: self.fontSize)).padding(.top, 20).padding(.bottom, 20)
                            Text("P(-): \(self.decimalToText(self.pNegative))").font(.custom(self.font, size: self.fontSize)).padding(.bottom, 20)
                        }.padding(.horizontal, 5)
                        VStack(alignment: .trailing){
                            Text("PPV: \(self.decimalToText(self.ppv))").font(.custom(self.font, size: self.fontSize)).padding(.top, 20).padding(.bottom, 20)
                            Text("NPV: \(self.decimalToText(self.npv))").font(.custom(self.font, size: self.fontSize)).padding(.bottom, 20)
                        }.padding(.horizontal, 5)
                        VStack(alignment: .trailing){
                            Text("FDR: \(self.decimalToText(self.fdr))").font(.custom(self.font, size: self.fontSize)).padding(.top, 20).padding(.bottom, 20)
                            Text("FOR: \(self.decimalToText(self.foRate))").font(.custom(self.font, size: self.fontSize)).padding(.bottom, 20)
                        }.padding(.horizontal, 5)
                        
                    }.overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 4).padding(.horizontal).frame(width: 400, height: 125)
                    )
                    
                }else{
                    
                    HStack{
                        
                        VStack(alignment: .trailing){
                            Text("")
                            Text("Actual |").font(.custom(self.font, size: self.resultFontSize))
                            Text("Positive |").font(.custom(self.font, size: self.resultFontSize))
                            Text("Negative |").font(.custom(self.font, size: self.resultFontSize))
                        }.padding(.bottom, 20).padding(.top, 20).padding(.leading, 3)
                        VStack(alignment: .trailing){
                            Text("Sick |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numSick) |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\( self.numTruePositive) |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numFalseNegative) |").font(.custom(self.font, size: self.resultFontSize))
                            
                        }.padding(8).padding(.bottom, 20).padding(.top, 20)
                        VStack(alignment: .trailing) {
                            Text("Healthy |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numHealthy) |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numFalsePositive) |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numTrueNegative) |").font(.custom(self.font, size: self.resultFontSize))
                            
                            
                        }.padding(8).padding(.bottom, 20).padding(.top, 20)
                        VStack(alignment: .trailing){
                            Text("Total |").font(.custom(self.font, size: self.resultFontSize))
                            Text("100,000 |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numTruePositive + self.numFalsePositive) |").font(.custom(self.font, size: self.resultFontSize))
                            Text("\(self.numFalseNegative+self.numTrueNegative) |").font(.custom(self.font, size: self.resultFontSize))
                        }.padding(.bottom, 20).padding(.top, 20).padding(.trailing, 3)
                        
                        
                    }.overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.blue, lineWidth: 4).padding(.horizontal).frame(width: 400, height: 125)
                    )
                        //.shadow(color: black, radius: 10, x:10, y:10)
                    
                    
                }
                
                Spacer()
                
            
                
                } .navigationBarColor(navBackground).navigationBarTitle("False Positive", displayMode: .inline)       .navigationBarItems(leading: Button(action:{self.showPopover = true}) {
                Image(systemName: "info.circle").font(.system(size: 25))
            }.popover(
                isPresented: self.$showPopover,
                arrowEdge: .top
            ) {
                
                VStack(alignment: .leading){
                    Button(action: {self.showPopover = false}){
                        Image(systemName: "xmark.circle").resizable().frame(width: 30, height: 30).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                        
                    }.padding()
                    WebView(file: "index").frame(minWidth: 200, idealWidth: .infinity, maxWidth: .infinity, minHeight: 400)
                }
                }.edgesIgnoringSafeArea(.all), trailing:
                Button(action:{self.showAnswers = true}) {
                    Image(systemName: "questionmark").font(.system(size: 23))
                }.popover(
                    isPresented: self.$showAnswers,
                    arrowEdge: .top
                ) {

                    VStack(alignment: .leading){
                        Button(action: {self.showAnswers = false}){
                            Image(systemName: "xmark.circle").resizable().frame(width: 30, height: 30).foregroundColor(Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)))
                            
                        }.padding()
           
                        Text("How To Use The Calculator").font(.title).frame(maxWidth: .infinity, alignment: .center).padding()
                    
                        VStack{
                        Text("Enter the known or estimated prevalence of a disease/condition being tested for. Then enter values for the sensitivity and specificity to see how the probabilities change.").font(.custom(self.font, size: 15)).frame(maxWidth: .infinity, alignment: .leading).padding()
                   
                        Text("The 'Probabilities' section shows the statistics described on the info page. Touch the info button to learn more about these quantities and how to interpret them. The 'Actuals' section uses the statistics to calculate the results on a population of 100,000 people tested.").lineLimit(11).font(.custom(self.font, size: 15)).frame(maxWidth: .infinity, alignment: .leading).padding()
                        }
                        
                        Text("© App Factorial LLC").font(.custom(self.font, size: 15)).frame(maxWidth: .infinity, alignment: .center).padding()
                        
                        Spacer()
                        
                        
                       }.frame(minWidth: 200, idealWidth: .infinity, maxWidth: .infinity, minHeight: 400)
                    
                    
            }).frame(maxWidth: .infinity, maxHeight: .infinity).background(background).edgesIgnoringSafeArea(.bottom)
        }.navigationViewStyle(StackNavigationViewStyle())
        
        
    }
    
    private func decimalToText(_ decimal: Decimal)->String{
        return self.percentFormatter.string(from: NSDecimalNumber(decimal: decimal*100 )) ?? ""
    }
    
    //Alert the user with a haptic feedback when the calculator ran successfully
    func simpleSuccess() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.success)
    }
    //Alert the user with a haptic feedback when the calculator failed
    func simpleFailure() {
        let generator = UINotificationFeedbackGenerator()
        generator.notificationOccurred(.error)
    }
    
    
    private func clearAll(){
        self.falseNegative = 0.0
        self.falsePositive = 0.0
        self.trueNegative = 0.0
        self.truePositive = 0.0
        
        self.ppv = 0.0
        self.npv = 0.0
        self.fdr = 0.0
        self.foRate = 0.0
        
        self.numFalseNegative = 0
        self.numTrueNegative = 0
        self.numTruePositive = 0
        self.numFalsePositive = 0
        
        
        self.prevalance = nil
        
    }
    
    
    //Calculates all statistics used in the app
    private func calculateProbabilities() {
        
        //remove variables from variable list
        self.variableList.removeAll()
        var notDisease: Decimal = 0.0
        
        if var prev = self.prevalance{
            prev = prev/100
            notDisease = 1-prev
            if var sens = self.sensitivity{
                sens = sens/100
                
                if var spec = self.specificity{
                    if spec == 0.0 || sens == 0.0 || prev == 0.0 {
                        showErrorMessage.toggle()
                    }
                    spec = spec/100
                    self.truePositive = sens
                    self.trueNegative = spec
                    self.falsePositive = 1-spec
                    self.falseNegative = 1-sens

                    
                    //Probability of positive
                    self.pPositive = (self.falsePositive)*notDisease+sens*prev
                    self.variableList.append(varList(id: "% +", value: self.pPositive*100))
                    
                    //Probability of negative
                    self.pNegative = (self.falseNegative)*prev+spec*notDisease
                    self.variableList.append(varList(id: "% -", value: self.pNegative*100))
                    //PPV
                    self.ppv = (sens*prev)/self.pPositive
                    self.variableList.append(varList(id: "PPV", value: self.ppv*100))
                    //NPV
                    self.npv = (spec*notDisease)/self.pNegative
                    self.variableList.append(varList(id: "NPV", value: self.npv*100))
                    
                    //FDR
                    self.fdr = 1-self.ppv
                    self.variableList.append(varList(id: "FDR", value: self.fdr*100))
                    
                    //FOR
                    self.foRate = 1-self.npv
                    self.variableList.append(varList(id: "FOR", value: self.foRate*100))
                    
                    
                    
                    //Number in experiement
                    self.numSick = Int(Double(truncating: NSDecimalNumber(decimal: prev))*100_000.0)
                    self.numHealthy = Int(Double(truncating: NSDecimalNumber(decimal: notDisease))*100_000.0)
                    self.numTruePositive = Int(Double(self.numSick)*Double(truncating: NSDecimalNumber(decimal: self.truePositive)))
                    self.numFalsePositive = Int(Double(self.numHealthy)*Double(truncating: NSDecimalNumber(decimal: self.falsePositive)))
                    self.numTrueNegative = Int(Double(self.numHealthy)*Double(truncating: NSDecimalNumber(decimal: self.trueNegative)))
                    self.numFalseNegative = Int(Double(self.numSick)*Double(truncating: NSDecimalNumber(decimal: self.falseNegative)))
                    
                    
                    self.simpleSuccess()
                    
                    
                }else {
                    showErrorMessage.toggle()
                    return
                }
                
                
            }
            else {
                //error
                showErrorMessage.toggle()
                return
            }
        }else {
            //error
            showErrorMessage.toggle()
            return
        }
    }
}



struct varList: Identifiable {
    var id: String
    var value: Decimal?
}

#if canImport(UIKit)
extension View {
    func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
#endif

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
    }
}
