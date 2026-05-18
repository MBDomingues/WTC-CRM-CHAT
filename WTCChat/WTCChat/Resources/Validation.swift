import Foundation

extension String {
    
    var isValidEmail: Bool {
        let emailRegEx = "[A-Z0-9a-z._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,64}"
        let emailPred = NSPredicate(format:"SELF MATCHES %@", emailRegEx)
        return emailPred.evaluate(with: self)
    }

    var isValidCPF: Bool {
        let numbers = self.filter { $0.isNumber }.compactMap { Int(String($0)) }
        guard numbers.count == 11 else { return false }
        
        if Set(numbers).count == 1 { return false }
        
        func calculateDigit(index: Int, slice: [Int]) -> Int {
            var temp = 0
            for i in 0...index {
                temp += slice[i] * ((index + 2) - i)
            }
            let result = 11 - (temp % 11)
            return result > 9 ? 0 : result
        }
        
        let digit1 = calculateDigit(index: 8, slice: numbers)
        let digit2 = calculateDigit(index: 9, slice: numbers)
        
        return numbers[9] == digit1 && numbers[10] == digit2
    }
}
