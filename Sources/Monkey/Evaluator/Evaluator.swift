//
//  Evaluator.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation


class Evaluator {
    // true, falseは新しいオブジェクトを作る必要がない
    final let trueObject = Boolean(value: true)
    final let falseObject = Boolean(value: false)
    final let nullObject = Null()
    
    func eval(node: Node) -> Object? {
        switch node {
        // 式
        case is IntegerLiteral:
            guard let literal = node as? IntegerLiteral else { return nil }
            return Integer(value: literal.value)
        case is BoolLiteral:
            guard let literal = node as? BoolLiteral else { return nil }
            return literal.value ? trueObject : falseObject
        // 文
        case let nd as Program:
            return evalStatements(stmts: nd.statements)
        case let nd as ExpressionStatement:
            return eval(node: nd.expr)
        case let prefixOp as PrefixExpression:
            guard let right = eval(node: prefixOp.right) else { return nil }
            return evalPrefixOperator(op: prefixOp, right: right)
        case let infixOp as InfixExpression:
            guard let left = eval(node: infixOp.left), let right = eval(node: infixOp.right) else { return nil }
            return evalInfixOperator(op: infixOp, left, right)
        case let prefixOp as PrefixExpression:
            guard let right = eval(node: prefixOp.right) else { return nil }
            return evalPrefixOperator(op: prefixOp, right: right)
        default:
            return nil
        }
    }
    
    func evalStatements(stmts: [Statement]) -> Object? {
        guard let stmt = stmts.last else { return nil }
        return eval(node: stmt)
    }

    func evalPrefixOperator(op: PrefixExpression, right: Object) -> Object? {
        switch op.token.type {
        case .bang:
            return evalBangOperatorExpression(right: right)
        case .minus:
            return evalMinusPrefixOpratorExpression(right: right)
        default:
            return nullObject
        }
    }

    func evalInfixOperator(op: InfixExpression, _ left: Object, _ right: Object) -> Object? {
        switch (left.type(), right.type()) {
            
        case (.integer, .integer):
            guard let leftInteger = left as? Integer, let rightInteger = right as? Integer else { return nullObject }
            return evalIntegerInfixExpression(op: op, leftInteger, rightInteger)
        case (.boolean, .boolean):
            guard let leftBoolean = left as? Boolean, let rightBoolean = right as? Boolean else { return nullObject }
            return evalBooleanInfixExpression(op: op, leftBoolean, rightBoolean)
        default:
            return nullObject
        }
    }

    private func evalBangOperatorExpression(right: Object) -> Object {
        // 評価方針
        // boolの場合valueの反転したObjectを返す
        // それ以外はeither null or not で考え,null -> false, otherwise -> trueの反転を返す
        switch right.type() {
        case .boolean:
            guard let _right = right as? Boolean else { return nullObject }
            return _right.value ? falseObject : trueObject
        case .null:
            return trueObject
        default:
            return falseObject
        }
    }

    private func evalMinusPrefixOpratorExpression(right: Object) -> Object {
        guard right.type() == .integer else { return nullObject }
        guard let integer = right as? Integer else { return nullObject }
        return Integer(value: -integer.value)
    }

    private func evalIntegerInfixExpression(op: InfixExpression, _ left: Integer, _ right: Integer) -> Object {
        switch op.token.type {
        case .plus:
            return left + right
        case .minus:
            return left - right
        case .asterisk:
            return left * right
        case .slash:
            return left / right
        case .eq:
            return left == right
        case .notEq:
            return left != right
        case .gt:
            return left > right
        case .lt:
            return left < right
        default:
            return nullObject
        }
    }

    private func evalBooleanInfixExpression(op: InfixExpression, _ left: Boolean, _ right: Boolean) -> Object {
        switch op.token.type {
        case .eq:
            return left == right
        case .notEq:
            return left != right
        default:
            return nullObject
        }
    }
}
