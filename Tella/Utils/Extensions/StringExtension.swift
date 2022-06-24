//  Tella
//
//  Copyright © 2022 INTERNEWS. All rights reserved.
//

import Foundation

extension String {
    func isInt() -> Bool {
        return Int(self) != nil
    }
    
    func doubleStringValue() -> String {
        return "\(Double(self) ?? 0)"
    }
    
    func endsWithPoint() -> Bool {
        return self.last == "."
    }
    
    func doubleStringValueEndsWithPoint() -> String {
        var formattedValue =  self
        formattedValue.removeLast()
        return "\(Double(formattedValue) ?? 0)"
    }
    
    
    func isAnOperator() -> Bool {
        let operators = ["+","–","/","x"]
        return operators.contains(where: {$0 == self})
    }
    
    func isDecimal() -> Bool {
        self.contains(".")
    }
    
    func getCalculatedResult() -> String {
        
        var value = "ERROR"
        
        var expression =  self.replacingOccurrences(of: "–", with: "-")
        expression = expression.replacingOccurrences(of: "x", with: "*")
        expression = expression.replacingOccurrences(of: "%", with: "*0.01")
        
        TryCatch.try({
            let expr = NSExpression(format: expression)
            
            if let result: Double = expr.expressionValue(with: nil, context: nil) as? Double {
                value = formatResult(result: result)
            }
        }, catch: { exception in
            value = "ERROR"
        })
        
        return value
    }
    
    func formatResult(result: Double) -> String {
       
        let maxResultNumberToShow:Double = 9999999999
        let minResultNumberToShow:Double = 0000000001

        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "00.00E+00"
        let number = NSNumber.init(value: result)
        
        if(result.truncatingRemainder(dividingBy: 1) == 0) {
            if result < maxResultNumberToShow {
                return String(format: "%.0f", result)
            } else {
                return numberFormatter.string(from: number) ?? ""
            }
        } else {
            if result < minResultNumberToShow {
                return numberFormatter.string(from: number) ?? ""
            } else {
                let fff = "%." + "\(result.decimalCount)" + "f"
                return String(format: fff, result)
            }
        }
    }
}
