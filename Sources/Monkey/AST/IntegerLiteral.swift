//
//  IntegerLiteral.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/26.
//

import Foundation

struct IntegerLiteral: Expression {
    let token: Token
    let value: Int
    
    var description: String {
        return "Int: \(token.literal)"
    }
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
