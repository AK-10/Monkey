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
        // statement
        case let prog as Program:
            return evalProgram(program: prog)
        case let nd as ExpressionStatement:
            return eval(node: nd.expr)
        case let block as BlockStatement:
            return evalBlockStatement(block: block)
        case let returnStmt as ReturnStatement:
            guard let value = eval(node: returnStmt.returnValue) else { return nil }
            return ReturnValue(value: value)
        // expression
        case let intLiteral as IntegerLiteral:
            return Integer(value: intLiteral.value)
        case let boolLiteral as BoolLiteral:
            return boolLiteral.value ? trueObject : falseObject
        case let prefixOp as PrefixExpression:
            guard let right = eval(node: prefixOp.right) else { return nil }
            return evalPrefixOperator(op: prefixOp, right: right)
        case let infixOp as InfixExpression:
            guard let left = eval(node: infixOp.left), let right = eval(node: infixOp.right) else { return nil }
            return evalInfixOperator(op: infixOp, left, right)
        case let ifExpr as IfExpression:
            return evalIfExpression(ifExpr)
        default:
            return nil
        }
    }
    
    func evalProgram(program: Program) -> Object? {
        for stmt in program.statements {
            if let result = eval(node: stmt) as? ReturnValue {
                return result.value
            }
        }
        return nil
    }
    
    func evalBlockStatement(block: BlockStatement) -> Object? {
        var result: Object?
        for stmt in block.statements {
            result = eval(node: stmt)
            if let res = result, res.type() == .returnValue {
                return res
            }
        }
        
        return result
    }

    func evalPrefixOperator(op: PrefixExpression, right: Object) -> Object? {
        switch op.token.type {
        case .bang:
            return evalBangOperatorExpression(right: right)
        case .minus:
            return evalMinusPrefixOpratorExpression(right: right)
        default:
            return generateError(format: "unknown operator: %@%@", op.description, right.type().rawValue)
        }
        
    }

    func evalInfixOperator(op: InfixExpression, _ left: Object, _ right: Object) -> Object? {
        switch (left, right) {
            
        case let (leftInteger as Integer, rightInteger as Integer):
            return evalIntegerInfixExpression(op: op, leftInteger, rightInteger)
        case let (leftBoolean as Boolean, rightBoolean as Boolean):
            return evalBooleanInfixExpression(op: op, leftBoolean, rightBoolean)
        default:
            switch op.token.type {
            case .plus, .minus, .asterisk, .slash, .lt, .gt, .eq, .notEq:
                return generateError(format: "type mismatch: %@ %@ %@", left.type().rawValue, op.op, right.type().rawValue)
            default:
                return generateError(format: "unknown operator: %@ %@ %@", left.type().rawValue, op.op, right.type().rawValue)
            }
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
            // unavailable binary operator
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
            // unavailable binary operator
            return nullObject
        }
    }

    private func evalIfExpression(_ ifExpr: IfExpression) -> Object {
        guard let condition = eval(node: ifExpr.condition) else { return nullObject }

        if isTruthy(obj: condition) {
            return eval(node: ifExpr.consequence) ?? nullObject
        } else {
            guard let alt = ifExpr.alternative else { return nullObject }
            return eval(node: alt) ?? nullObject
        }
    }

    private func isTruthy(obj: Object) -> Bool {
        switch obj {
        case let boolObj as Boolean:
            return boolObj.value
        case is Null:
            return false
        default:
            return true
        }
    }

    private func generateError(format: String, _ args: CVarArg...) -> ErrorObject {
//        let descriptions = args.map { elem in elem.description }
//        let errorMessage = String(format: format, descriptions)
        // どうなるかわからない
        let msg = String(format: format, args)
        return ErrorObject(message: msg)

    }
}
