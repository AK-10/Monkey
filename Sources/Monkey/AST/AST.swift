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

// 式
protocol Expression: Node {
    func expressionNode()
}

struct Program {
    let statements: [Statement]

    func TokenLiteral() -> String {
        switch statements.first {
        case .some(let statement):
            return statement.tokenLiteral()
        case .none:
            return ""
        }
    }
}

