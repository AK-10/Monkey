//
//  InfixExpression.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/04.
//

import Foundation

struct InfixExpression: Expression {
    let token: Token
    let op: String
    let left: Expression
    let right: Expression

    var description: String {
        return "infix: (\(left.description) \(op) \(right.description))"
    }

    func expressionNode() {
    }

    func tokenLiteral() -> String {
        return token.literal
    }
}
