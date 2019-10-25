//
//  ExpressionStatement.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/26.
//

import Foundation

struct ExpressionStatement: Statement {
    
    let token: Token // 式の最初のトークン
    let expr: Expression
    
    var description: String {
        return expr.description
    }
    
    func statementNode() {
    }
    
    func tokenLiteral() -> String {
        return ""
    }
    

}
