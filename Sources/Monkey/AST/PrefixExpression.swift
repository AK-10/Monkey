//
//  PrefixExpression.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/26.
//

import Foundation

struct PrefixExpression: Expression {
    let token: Token // !, -など
    let op: String
    let right: Expression

    var description: String {
        return "prefix operator: (\(op)\(right.description))"
    }
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
