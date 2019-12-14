//
//  Evaluator.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation


class Evaluator {
    func eval(node: Node) -> Object? {
        switch node {
        // 式
        case is IntegerLiteral:
            guard let literal = node as? IntegerLiteral else { return nil }
            return Integer(value: literal.value)
        case is BoolLiteral:
            guard let literal = node as? BoolLiteral else { return nil }
            return Boolean(value: literal.value)
        // 文
        case is Program:
            guard let nd = node as? Program else { return nil }
            return evalStatements(stmts: nd.statements)
        case is ExpressionStatement:
            guard let nd = node as? ExpressionStatement else { return nil }
            return eval(node: nd.expr)
        default:
            return nil
        }
    }
    
    func evalStatements(stmts: [Statement]) -> Object? {
        guard let stmt = stmts.last else { return nil }
        return eval(node: stmt)
    }
}
