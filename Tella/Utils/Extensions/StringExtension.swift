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
        
        var value = ""
        
        var expression =  self.replacingOccurrences(of: "–", with: "-")
        expression = expression.replacingOccurrences(of: "x", with: "*")
        expression = expression.replacingOccurrences(of: "%", with: "*0.01")
        
        do {
            try TryCatch.try({
                let expr = NSExpression(format: expression)
                let result: Double = expr.expressionValue(with: nil, context: nil) as! Double
                value = formatResult(result: result)
                print(value)
            })
        } catch {
            return "ERROR"
        }
        
        return value
    }
    
    func formatResult(result: Double) -> String {
        
        let numberFormatter = NumberFormatter()
        numberFormatter.positiveFormat = "00.00e+00"
        let number = NSNumber.init(value: result)
        
        
        if(result.truncatingRemainder(dividingBy: 1) == 0) {
            
            if result < 9999999999 {
                return String(format: "%.0f", result)
                
            } else {
                return numberFormatter.string(from: number) ?? ""
            }
            
        } else {
            return String(format: "%.5f", result)
        }
    }
    
    
}
