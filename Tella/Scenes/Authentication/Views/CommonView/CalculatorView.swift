//  Tella
//
//  Copyright © 2021 INTERNEWS. All rights reserved.
//

import SwiftUI

struct CalculatorView: View {
    
    @Binding var currentOperation : String
    @Binding var resultToshow : String
    @Binding var message : String
    @Binding var isValid : Bool
    
    @State var operationArray : [String] = []
    @State var equalPressed : Bool = false
    
    var shouldValidateField : Bool = true
    var calculatorType : CalculatorType
    var action : (() -> Void)?
    
    var calculatorButtons : [[CalculatorButtonType]] = [
        [.clear, .negative, .percent, .divide],
        [.seven, .eight, .nine, .mutliply],
        [.four, .five, .six, .subtract],
        [.one, .two, .three, .add],
        [.zero, .decimal, .equal]]
    
    
    var body: some View {
        
        VStack(spacing:CalculatorData.calculatorItemSpace) {
            ForEach(calculatorButtons, id: \.self) { row in
                HStack(spacing: 13) {
                    ForEach(row, id: \.self) { item in
                        getView(item:item)
                    }
                }
            }
        }
        .padding(EdgeInsets(top: 0, leading: 13, bottom: 0, trailing: 13))
    }
    
    private func getView(item:CalculatorButtonType) -> some View {
        
        return AnyView(Button {
            calculatorType == .lockCalculator ? self.lockButtonAction(item: item) :  self.unlockButtonAction(item: item)
        } label: {
            self.getButtonView(item: item)
        }
            .buttonStyle(PinButtonStyle(enabled: true, item: item))
        ).frame(width: getButtonWidth(item: item))
    }
    
    private func getButtonView(item:CalculatorButtonType) -> some View {
        switch item.buttonType {
        case .image:
            return AnyView(Image(item.imageName)
                .frame(maxWidth: .infinity)
                .padding())
        case .text:
            return AnyView(Text(item.rawValue)
                .frame(maxWidth: .infinity)
                .padding())
        }
    }
    
    private func getButtonWidth(item: CalculatorButtonType) -> CGFloat {
        if item == .zero {
            return CalculatorData.calculatorItemDoubleWidth
        }
        return CalculatorData.calculatorItemWidth
    }

    private func unlockButtonAction(item:CalculatorButtonType) {
        
        isValid = true
        
        switch item {
            
        case .add, .subtract, .mutliply,.divide :
            
            initOperationArrayWithResult()
            
            if let lastItem = operationArray.last {
                if lastItem.isAnOperator() {
                    // Update the last opearator with the new operator
                    operationArray[operationArray.count - 1] = item.rawValue
                } else {
                    // Add the new opearator
                    operationArray.append(item.rawValue)
                }
            } else {
                // Add a zero at the begining of the operation when the opration is empty
                operationArray.append(CalculatorButtonType.zero.rawValue)
                operationArray.append(item.rawValue)
            }
            
            displayOperation()
            
        case  .equal:
            let operationArray = formatOperation()
            let operationString = operationArray.joined(separator: " ")
            self.resultToshow = operationString.getCalculatedResult()
            self.equalPressed = true
            self.login()
            
        case .clear:
            self.operationArray.removeAll()
            self.resultToshow = CalculatorButtonType.zero.rawValue
            self.currentOperation = ""
            self.equalPressed = false
            
        case .decimal:
            
            initOperationArrayWithZero()
            
            if let lastItem = operationArray.last  {
                if lastItem.isAnOperator() {
                    // Add a "0." when the operation is empty
                    operationArray.append(CalculatorButtonType.zero.rawValue + item.rawValue)
                } else {
                    // Add a "." when the last operand is not a decimal
                    if !lastItem.isDecimal() {
                        let newNumber = lastItem.appending(item.rawValue)
                        operationArray[operationArray.count - 1] = newNumber
                    }
                }
            } else {
                // Add a "0." when the operation is empty
                operationArray.append(CalculatorButtonType.zero.rawValue + item.rawValue)
            }
            
            displayOperation()
            
        case .negative:
            
            initOperationArrayWithResult()
            
            if let lastItem = operationArray.last {
                
                if lastItem.isAnOperator() {
                    // Add a "-0" when the last item is an operator
                    operationArray.append("-0")
                } else {
                    // Update the negative sign of the current operand
                    var currentOperand = operationArray[operationArray.count - 1]
                    if currentOperand.first == "-" {
                        currentOperand.removeFirst()
                    } else {
                        currentOperand.insert("-", at: currentOperand.startIndex)
                    }
                    operationArray[operationArray.count - 1] = currentOperand
                }
            } else {
                // Add a "-0" when the operation is empty
                operationArray.append("-0")
            }
            displayOperation()
            
        case .percent:
            
            initOperationArrayWithResult()
            
            if let lastItem = operationArray.last {
                
                if lastItem.isAnOperator() {
                    // Add the previous result and %
                    self.completeLastOperation()
                    operationArray.append(item.rawValue)
                } else {
                    // Add the % to the last value
                    if !lastItem.contains(CalculatorButtonType.percent.rawValue) {
                        let newNumber = lastItem.appending(item.rawValue)
                        operationArray[operationArray.count - 1] = newNumber
                    }
                }
            } else {
                // Add a "0%" when the operation is empty
                operationArray.append(CalculatorButtonType.zero.rawValue + item.rawValue)
            }
            
            displayOperation()
            
        default:
            
            resetOperationArray()
            
            if let lastItem = operationArray.last {
                
                if lastItem.isAnOperator() {
                    // Add the operand
                    operationArray.append(item.rawValue)
                } else if (lastItem == "-0") {
                    // Update the 0 with the new value
                    operationArray[operationArray.count - 1] = "-\(item.rawValue)"
                    
                } else if !lastItem.contains(CalculatorButtonType.percent.rawValue) {
                    // Add the operand if there isn't %
                    let newNumber = lastItem.appending(item.rawValue)
                    operationArray[operationArray.count - 1] = newNumber
                }
                
            } else {
                // Add the operand
                operationArray.append(item.rawValue)
            }
            
            displayOperation()
        }
    }
    
    private func lockButtonAction(item:CalculatorButtonType) {
        
        switch item {
            
        case .equal:
            self.login()

        case .clear:
            self.resultToshow = CalculatorButtonType.zero.rawValue
            
        default:
            
            if self.resultToshow == CalculatorButtonType.zero.rawValue  {
                self.resultToshow = ""
            }
            resultToshow =  resultToshow.appending(item.rawValue)
        }
    }
    
    private func formatOperation() -> [String] {
        
        self.completeLastOperation()
        
        var operationArray : [String] = operationArray.compactMap { value in
            if value.isInt() {
                return value.doubleStringValue()
            }
            
            if value.endsWithPoint() {
                return value.doubleStringValueEndsWithPoint()
            }
            return value
        }
        
        self.getPreviousPercentResult(operationArray: &operationArray)
        
        return operationArray
    }
    
    private func displayOperation() {
        currentOperation = operationArray.joined(separator: " ")
    }
    
    private func completeLastOperation() {
        if let lastElement = self.operationArray.last, lastElement.isAnOperator() {
            
            if lastElement == CalculatorButtonType.mutliply.rawValue  {
                // Add the same previous operand
                self.operationArray.append( self.operationArray[self.operationArray.count - 2])
            } else {
                // Add the result of the previous operation
                let previousOperation = self.operationArray.prefix(self.operationArray.count - 1)
                var array = Array(previousOperation)
                getPreviousPercentResult(operationArray: &array)
                let operationString = array.joined(separator: " ")
                let result = operationString.getCalculatedResult()
                self.operationArray.append( result)
            }
        }
        displayOperation()
    }
    
    private func getPreviousPercentResult(operationArray: inout [String]) {
        for (index, item) in operationArray.enumerated() {
            if item.contains("%") {
                if  operationArray.count > 1 && index > 0 {
                    let previousOperation =  operationArray[index-1]
                    if previousOperation == "+" || previousOperation == "–"  {
                        let operationString = operationArray.prefix(index - 1).joined(separator: " ")
                        let result = operationString.getCalculatedResult()
                        let value = "\(result)*" + item
                        operationArray[index] = value
                    }
                }
            }
        }
    }

    private func initOperationArrayWithResult() {
        if self.equalPressed == true {
            self.equalPressed = false
            operationArray.removeAll()
            operationArray.append(resultToshow)
            self.resultToshow = CalculatorButtonType.zero.rawValue
        }
    }
    
    private func initOperationArrayWithZero() {
        resetOperationArray()
        
        if self.equalPressed == true {
            operationArray.append(CalculatorButtonType.zero.rawValue)
        }
    }
    
    private func resetOperationArray() {
        if self.equalPressed == true {
            self.equalPressed = false
            operationArray.removeAll()
            self.resultToshow = CalculatorButtonType.zero.rawValue
        }
    }
    
    private func login() {
        self.validateField()
        
        if self.isValid {
            action?()
        }
    }
    
    private func validateField() {
        self.isValid = resultToshow.passwordValidator() && resultToshow.passwordLengthValidator()
        
        if shouldValidateField {
            if !resultToshow.passwordLengthValidator() {
                message = Localizable.Lock.errorPinLengthBannerExpl
                
            } else if !resultToshow.passwordValidator() {
                message = Localizable.Lock.errorPinDigitsBannerExpl
            }
        }
    }
}

struct PinButtonStyle : ButtonStyle {
    
    var enabled : Bool
    var item : CalculatorButtonType
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .font(item.buttonViewData.font)
            .foregroundColor(item.buttonViewData.fontColor)
            .background(configuration.isPressed ? item.buttonViewData.backgroundColor.opacity(0.4) : item.buttonViewData.backgroundColor)
            .cornerRadius(15)
    }
}

struct PinView_Previews: PreviewProvider {
    static var previews: some View {
        CalculatorView(currentOperation: .constant(""),
                       resultToshow: .constant(""),
                       message: .constant("Error"),
                       isValid: .constant(false),
                       calculatorType: .lockCalculator)
    }
}
