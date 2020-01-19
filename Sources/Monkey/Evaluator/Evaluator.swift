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

    func eval(node: Node, env: Environment) -> Object {
        switch node {
        // statement
        case let prog as Program:
            return evalProgram(program: prog, env: env)

        case let nd as ExpressionStatement:
            return eval(node: nd.expr, env: env)

        case let block as BlockStatement:
            return evalBlockStatement(block: block, env: env)

        case let returnStmt as ReturnStatement:
            let value = eval(node: returnStmt.returnValue, env: env)
            if isError(obj: value) { return value }
            
            return ReturnValue(value: value)

        case let letStmt as LetStatement:
            let name = letStmt.name.value
            let value = eval(node: letStmt.value, env: env)
            if isError(obj: value) { return value }
          
            return env.set(name: name, value: value)

        // expression
        case let intLiteral as IntegerLiteral:
            return Integer(value: intLiteral.value)

        case let boolLiteral as BoolLiteral:
            return boolLiteral.value ? trueObject : falseObject

        case let prefixOp as PrefixExpression:
            let right = eval(node: prefixOp.right, env: env)
            if isError(obj: right) { return right }
            
            return evalPrefixOperator(op: prefixOp, right: right)

        case let infixOp as InfixExpression:
            let left = eval(node: infixOp.left, env: env)
            let right = eval(node: infixOp.right, env: env)
            if isError(obj: left) { return left }
            if isError(obj: right) { return right }
            
            return evalInfixOperator(op: infixOp, left, right)

        case let ifExpr as IfExpression:
            return evalIfExpression(ifExpr, env: env)

        case let id as Identifier:
            return evalIdentifier(id: id, env: env)
            
        case let functionLit as FunctionLiteral:
            let params = functionLit.parameters
            let body = functionLit.body
            return Function(parameters: params, body: body, env: env)

        case let callExpr as CallExpression:
            let function = eval(node: callExpr.function, env: env) // id またはfunction literalが入る
            if isError(obj: function) {
                return function
            }
            // 引数の評価
            let args = evalExpressions(exprs: callExpr.arguments, env: env)
            // 引数で評価エラーが起きた場合，以下の条件になる
            if args.count == 1 && isError(obj: args[0]) {
                return args[0]
            }
            
            return applyFunction(fn: function, args: args)

        default:
            return generateError(format: "unknown error")
        }
    }
    
    func evalProgram(program: Program, env: Environment) -> Object {
        var result: Object?
        for stmt in program.statements {
            result = eval(node: stmt, env: env)
            switch result {
            case let returnValue as ReturnValue:
                return returnValue.value
            case let err as ErrorObject:
                return err
            default:
                break
            }
        }
        return result ?? generateError(format: "statement not found")
    }
    
    func evalBlockStatement(block: BlockStatement, env: Environment) -> Object {
        var result: Object?
        for stmt in block.statements {
            result = eval(node: stmt, env: env)
            switch result {
            case let res as ReturnValue:
                return res
            case let err as ErrorObject:
                return err
            default:
                break
            }
        }
        return result ?? nullObject
    }

    func evalPrefixOperator(op: PrefixExpression, right: Object) -> Object {
        switch op.token.type {
        case .bang:
            return evalBangOperatorExpression(right: right)
        case .minus:
            return evalMinusPrefixOpratorExpression(right: right)
        default:
            return generateError(format: "unknown operator: %@%@", op.op, right.type().rawValue)
        }
        
    }

    func evalInfixOperator(op: InfixExpression, _ left: Object, _ right: Object) -> Object {
        switch (left, right) {
            
        case let (leftInteger as Integer, rightInteger as Integer):
            return evalIntegerInfixExpression(op: op, leftInteger, rightInteger)
        case let (leftBoolean as Boolean, rightBoolean as Boolean):
            return evalBooleanInfixExpression(op: op, leftBoolean, rightBoolean)
        default:
            return generateError(format: "type mismatch: %@ %@ %@", left.type().rawValue, op.op, right.type().rawValue)
        }
    }
    
    private func evalBangOperatorExpression(right: Object) -> Object {
        // 評価方針
        // boolの場合valueの反転したObjectを返す
        // それ以外はeither null or not で考え,null -> false, otherwise -> trueの反転を返す
        switch right.type() {
        case .boolean: guard let _right = right as? Boolean else { return nullObject }
            return _right.value ? falseObject : trueObject
        case .null:
            return trueObject
        default:
            return falseObject
        }
    }

    private func evalMinusPrefixOpratorExpression(right: Object) -> Object {
        switch right {
        case let _right as Integer:
            return Integer(value: -_right.value)
        default:
            return generateError(format: "type mismatch: -%@", right.type().rawValue)
        }
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
            return generateError(format: "unknown operator: %@ %@ %@", left.type().rawValue, op.op, right.type().rawValue)
        }
    }

    private func evalBooleanInfixExpression(op: InfixExpression, _ left: Boolean, _ right: Boolean) -> Object {
        switch op.token.type {
        case .eq:
            return left == right
        case .notEq:
            return left != right
        default:
            return generateError(format: "unknown operator: %@ %@ %@", left.type().rawValue, op.op, right.type().rawValue)
        }
    }

    private func evalIfExpression(_ ifExpr: IfExpression, env: Environment) -> Object {
        let condition = eval(node: ifExpr.condition, env: env)
        if isError(obj: condition) { return condition }

        if isTruthy(obj: condition) {
            return eval(node: ifExpr.consequence, env: env)
        } else {
            guard let alt = ifExpr.alternative else { return nullObject }
            return eval(node: alt, env: env)
        }
    }
    
    private func evalIdentifier(id: Identifier, env: Environment) -> Object {
        let ident = env.get(name: id.value)
        switch ident {
        case .some(let _ident):
            return _ident
        case .none:
            return generateError(format: "identifier not found: %@", id.value)
        }
    }
    
    private func evalExpressions(exprs: [Expression], env: Environment) -> [Object] {
        let evaluatedList = exprs.map { eval(node: $0, env: env) }
        let erroredObj = evaluatedList.first(where: { isError(obj: $0) })
        switch erroredObj {
        case .some(let obj):
            return [obj]
        case .none:
            return evaluatedList
        }
    }
    
    private func applyFunction(fn: Object, args: [Object]) -> Object {
        guard let fnObj = fn as? Function else { return generateError(format: "not a function: %@", fn.type().rawValue) }
        let extendedEnv = extendFunctionEnv(fn: fnObj, args: args)
        let evaluated = eval(node: fnObj.body, env: extendedEnv)

        return unwrapReturnValue(obj: evaluated)
    }
    
    private func extendFunctionEnv(fn: Function, args: [Object]) -> Environment {
        let env = Environment(outer: fn.env)
        zip(fn.parameters, args).forEach { (ident, obj) in
            _ = env.set(name: ident.value, value: obj) }
        return env
    }
    
    private func unwrapReturnValue(obj: Object) -> Object {
        guard let returnValue = obj as? ReturnValue else {
            return obj
        }
        
        return returnValue.value
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
    
    private func isError(obj: Object) -> Bool {
        return obj is ErrorObject
    }
}
