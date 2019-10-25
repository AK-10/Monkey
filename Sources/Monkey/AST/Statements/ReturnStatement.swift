//
//  ReturnStatement.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/17.
//

import Foundation

struct ReturnStatement: Statement {
    
    let token: Token
    let returnValue: Expression

    var description: String {
        return "\(tokenLiteral()) \(returnValue.description);"
    }
    
    func statementNode() {}
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
