//
//  ExpressionStatement.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/26.
//

import Foundation

struct ExpressionStatement: Statement {
    var description: String {
        return ""
    }
    
    let token: Token // 式の最初のトークン
    let expr: Expression
    
    func statementNode() {
    }
    
    func tokenLiteral() -> String {
        return ""
    }
    

}
