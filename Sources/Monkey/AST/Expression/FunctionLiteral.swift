//
//  FunctionLiteral.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/17.
//

import Foundation

struct FunctionLiteral: Expression {
    let token: Token
    let parameters: [Identifier]
    let body: BlockStatement

    var description: String {
        let params = parameters.map { $0.description }
        return ([token.literal] + params).reduce("") { $0 + $1 + "\n" }
    }
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }

}
