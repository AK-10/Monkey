//
//  AST.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/08.
//

import Foundation

protocol Node: CustomStringConvertible {
    func tokenLiteral() -> String
}

// 式
protocol Expression: Node {
    func expressionNode()
}

struct Program: Node {
    let statements: [Statement]
    var description: String {
        return statements.reduce("") { $0 + $1.description + "\n" }
    }
    
    func tokenLiteral() -> String {
        switch statements.first {
        case .some(let statement):
            return statement.tokenLiteral()
        case .none:
            return ""
        }
    }
}

