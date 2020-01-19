//
//  CallExpression.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/17.
//

import Foundation

struct CallExpression: Expression {
    let token: Token // `(` token
    let function: Expression // identifer or function literal
    let arguments: [Expression]
    
    var description: String {
        let args = ["("] + arguments.map { $0.description } + [")"]
        return ([function.description] + args).reduce("") { $0 + $1 + "\n" }
    }
    
    func expressionNode() {
        
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
