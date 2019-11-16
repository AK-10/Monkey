//
//  BoolLiteral.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/13.
//

import Foundation

struct BoolLiteral: Expression {
    let token: Token
    let value: Bool
    
    var description: String {
        return "Bool: \(token.literal)"
    }

    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
