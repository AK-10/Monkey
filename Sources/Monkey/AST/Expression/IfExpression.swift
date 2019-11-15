//
//  IfExpression.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/15.
//

import Foundation

struct IfExpression: Expression {
    let token: Token
    let condition: Expression
    let consequence: BlockStatement
    let alternative: BlockStatement? // elseは任意
    
    var description: String {
        let descriptions = [
            "if:",
            "  condition: \(condition.description)",
            "  consequence: \(consequence.description)",
        ]
        guard let alt = alternative else { return descriptions.reduce("") { $0 + $1 + "\n" } }
        let alternatives = [
            "else:",
            "  alternative: \(alt.description)"
        ]
        
        return (descriptions + alternatives).reduce("") { $0 + $1 + "\n" }
    }
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
    
}
