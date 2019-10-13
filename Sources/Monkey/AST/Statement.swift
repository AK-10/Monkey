//
//  Statement.swfit.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/09.
//

import Foundation

struct Identifier {
    let token: Token
}

struct LetStatement: Statement {
    let token: Token
    let name: Identifier
    let value: Expression

    func tokenLiteral() -> String {
        return token.literal
    }

    
    func statementNode() {}
}
