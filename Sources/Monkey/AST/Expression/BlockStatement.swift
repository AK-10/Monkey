//
//  BlockStatement.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/15.
//

import Foundation

struct BlockStatement: Expression {

    let token: Token
    let statements: [Statement]
    
    var description: String {
        let values = ["{"] ++ statements.map{ $0.description } ++ ["}"]
        return values.reduce("") { $0 + $1 + "\n" }
    }
    
    func expressionNode() {
    }
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
