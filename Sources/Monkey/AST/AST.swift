//
//  AST.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/08.
//

import Foundation

protocol Node {
    func tokenLiteral() -> String
}

protocol Statement: Node {
    func statementNode()
}

protocol Expression: Node {
    func expressionNode()
}

struct Program {
    var statements: [Statement]

    func TokenLiteral() -> String {
        switch statements.first {
        case .some(let statement):
            return statement.tokenLiteral()
        case .none:
            return ""
        }
    }
}

