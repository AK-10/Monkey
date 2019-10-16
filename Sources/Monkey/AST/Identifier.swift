//
//  Identifier.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/17.
//

import Foundation

struct Identifier: Expression {
    let token: Token
    let value: String
    
    func expressionNode() {}
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
