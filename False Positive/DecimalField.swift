//
//  DecimalField.swift
//
//  Created by Edwin Watkeys on 9/20/19.
//  Copyright © 2019 Edwin Watkeys.
//
//  Permission is hereby granted, free of charge, to any person
//  obtaining a copy of this software and associated documentation
//  files (the "Software"), to deal in the Software without
// restriction, including without limitation the rights to use,
// copy, modify, merge, publish, distribute, sublicense, and/or sell
// copies of the Software, and to permit persons to whom the Software
// is furnished to do so, subject to the following conditions:
//
// The above copyright notice and this permission notice shall be
// included in all copies or substantial portions of the Software.
//
// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND,
// EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF
// MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND
// NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT
// HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY,
// WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER
// DEALINGS IN THE SOFTWARE.
//
import SwiftUI
import Combine

struct DecimalField : View {
    let label: LocalizedStringKey
    @Binding var value: Decimal?
    let formatter: NumberFormatter
    let backgroundColor: Color
    let onEditingChanged: (Bool) -> Void
    let onCommit: () -> Void
    
    // The text shown by the wrapped TextField. This is also the "source of
    // truth" for the `value`.
    @State private var textValue: String = ""
    
    // When the view loads, `textValue` is not synced with `value`.
    // This flag ensures we don't try to get a `value` out of `textValue`
    // before the view is fully initialized.
    @State private var hasInitialTextValue = false
    
    init(
        _ label: LocalizedStringKey,
        value: Binding<Decimal?>,
        formatter: NumberFormatter,
        onEditingChanged: @escaping (Bool) -> Void = { _ in },
        onCommit: @escaping () -> Void = {},
        backgroundColor: Color
    ) {
        self.label = label
        _value = value
        self.formatter = formatter
        self.onEditingChanged = onEditingChanged
        self.onCommit = onCommit
        self.backgroundColor = backgroundColor
    }
    
    var body: some View {
        TextField(label, text: $textValue, onEditingChanged: { isInFocus in
            // When the field is in focus we replace the field's contents
            // with a plain unformatted number. When not in focus, the field
            // is treated as a label and shows the formatted value.
            if isInFocus {
                self.textValue = self.value?.description ?? ""
            } else {
                let f = self.formatter
                let newValue = f.number(from: self.textValue)?.decimalValue
                self.textValue = f.string(for: newValue) ?? ""
            }
            self.onEditingChanged(isInFocus)
        }, onCommit: {
            self.onCommit()
        }).padding(.horizontal, 10).padding(.vertical, 5)
            .onReceive(Just(textValue)) {
                guard self.hasInitialTextValue else {
                    // We don't have a usable `textValue` yet -- bail out.
                    return
                }
                // This is the only place we update `value`.
                self.value = self.formatter.number(from: $0)?.decimalValue
        }
            .onAppear(){ // Otherwise textfield is empty when view appears
                self.hasInitialTextValue = true
                // Any `textValue` from this point on is considered valid and
                // should be synced with `value`.
                if let value = self.value {
                    // Synchronize `textValue` with `value`; can't be done earlier
                    self.textValue = self.formatter.string(from: NSDecimalNumber(decimal: value)) ?? ""
                }
            }
        .keyboardType(.decimalPad).font(.largeTitle).background(
                
//                RoundedRectangle(cornerRadius: 16, style: .continuous)
//                    .foregroundColor(backgroundColor)
//                    .blur(radius: 4)
//                    .offset(x: -8, y: -8)
//
                RoundedRectangle(cornerRadius: 10).foregroundColor(backgroundColor)
                    
        ).overlay(
            RoundedRectangle(cornerRadius: 10)
                .stroke(backgroundColor, lineWidth: 3)
                .shadow(color: Color.black, radius: 3, x: 5, y: 5)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
            )
                .shadow(color: Color(#colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)), radius: 2, x: -2, y: -2)
                .clipShape(
                    RoundedRectangle(cornerRadius: 10)
            )
        ).foregroundColor(Color.white)

            .frame(width: 100, height: nil)
    }
}



struct DecimalField_Previews: PreviewProvider {
    static var previews: some View {
        TipCalculator()
    }
    
    struct TipCalculator: View {
        @State var amount: Decimal? = 50
        @State var tipRate: Decimal?
        
        var tipValue: Decimal {
            guard let amount = self.amount, let tipRate = self.tipRate else {
                return 0
            }
            return amount * tipRate / 100
        }
        
        var totalValue: Decimal {
            guard let amount = self.amount else {
                return tipValue
            }
            return amount + tipValue
        }
        
        static var currencyFormatter: NumberFormatter {
            let nf = NumberFormatter()
            nf.numberStyle = .currency
            nf.isLenient = true
            return nf
        }
        
        static var percentFormatter: NumberFormatter {
            let nf = NumberFormatter()
            nf.numberStyle = .percent
            // preserve input as-is, otherwise 10 becomes 0.1, which makes
            // sense but is less intuitive for input
            nf.multiplier = 1
            nf.isLenient = true
            return nf
        }
        
        var body: some View {
            Form {
                Section {
                    DecimalField("Amount", value: $amount, formatter: Self.currencyFormatter, backgroundColor: Color.gray)
                    DecimalField("Tip Rate", value: $tipRate, formatter: Self.percentFormatter, backgroundColor: Color.black)
                }
                Section {
                    HStack {
                        Text("Tip Amount")
                        Spacer()
                        Text(Self.currencyFormatter.string(for: tipValue)!)
                    }
                    HStack {
                        Text("Total")
                        Spacer()
                        Text(Self.currencyFormatter.string(for: totalValue)!)
                    }
                }
            }
        }
    }
}
