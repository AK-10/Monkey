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
    
    func statementNode() {}
    
    func tokenLiteral() -> String {
        return token.literal
    }
}
