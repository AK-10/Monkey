//
//  Parser.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/08.
//

import Foundation

typealias PrefixParseFunc = () -> Expression?
typealias InfixParseFunc = (Expression) -> Expression?

enum EvalPriority: Int, Comparable, Equatable {
    
    static func < (lhs: EvalPriority, rhs: EvalPriority) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    case lowest
    case equals // ==
    case less_greater // < or >
    case sum  // +
    case product // *
    case prefix // -(value) or !(value)
    case call // myFunction(x)
    
    static func infixOeratorPriority(tokenType: TokenType) -> EvalPriority {
        switch tokenType {
        case .eq, .notEq:
            return .equals
        case .lt, .gt:
            return .less_greater
        case .plus, .minus:
            return .sum
        case .slash, .asterisk:
            return .product
        default:
            fatalError("\(tokenType) is not infix operator")
        }
    }
}

struct DummyExpression: Expression {
    var description: String {
        return "dummy expr"
    }
    
    func expressionNode() {}
    
    func tokenLiteral() -> String {
        return "dummy"
    }
}

class Parser {
    let lexer: Lexer
    private var currentToken: Token? = nil
    private var peekToken: Token? = nil
    
    var errors: [String] = []
    
    var prefixParseFuncs: [TokenType : PrefixParseFunc] = [:]
    var infixParseFuncs: [TokenType : InfixParseFunc] = [:]
    
    init(_ lexer: Lexer) {
        self.lexer = lexer
        nextToken()
        nextToken()
        
        // identifier
        registerPrefix(tokenType: .ident, fn: parseIdentifier)

        // integer
        registerPrefix(tokenType: .int, fn: parseIntegerLiteral)

        // prefix operator
        registerPrefix(tokenType: .minus, fn: parsePrefixExpression)
        registerPrefix(tokenType: .bang, fn: parsePrefixExpression)
        
        // infix operator
        registerInfix(tokenType: .plus, fn: parseInfixExpression)
        registerInfix(tokenType: .minus, fn: parseInfixExpression)
        registerInfix(tokenType: .slash, fn: parseInfixExpression)
        registerInfix(tokenType: .asterisk, fn: parseInfixExpression)
        registerInfix(tokenType: .eq, fn: parseInfixExpression)
        registerInfix(tokenType: .notEq, fn: parseInfixExpression)
        registerInfix(tokenType: .lt, fn: parseInfixExpression)
        registerInfix(tokenType: .gt, fn: parseInfixExpression)
    }
    
    func parseProgram() -> Program {
        var statements: [Statement] = []
        while currentToken != nil {
            let stmt = parseStatement()
            if let stmt = stmt {
                statements.append(stmt)
            }
            nextToken()
        }
        return Program(statements: statements)
    }
}

// parse処理 (semantic code)
extension Parser {
    private func parseStatement() -> Statement? {
        guard let curToken = currentToken else { return nil }
        print("invoke: parseStatement")
        switch curToken.type {
        case ._let:
            return parseLetStatement()
        case ._return:
            return parseReturnStatement()
        default:
            return parseExpressionStatement()
        }
    }
    
    private func parseLetStatement() -> LetStatement? {
        // rootToken: これはletのはず
        guard let rootToken = currentToken else { return nil }
        print("invoke: parseLetStatement")
        if !expectPeek(tokenType: .ident) {
            return nil
        }

        switch currentToken {
        case .some(let curToken):
            let name = Identifier(token: curToken, value: curToken.literal)
            if !expectPeek(tokenType: .assign) {
                return nil
            }
            // TODO: セミコロンに遭遇するまで式を読み飛ばしている
            while !curTokenIs(tokenType: .semicolon) {
                nextToken()
            }
            // TODO: valueに正しい値を入れる（現状dummyを入れている）
            return LetStatement(token: rootToken, name: name, value: DummyExpression())
        case .none:
            return nil
        }
    }
    
    private func parseReturnStatement() -> ReturnStatement? {
        guard let rootToken = currentToken else { return nil }
        
        nextToken()
        
        // TODO: セミコロンに遭遇するまで式を読み飛ばしている
        while !curTokenIs(tokenType: .semicolon) {
            nextToken()
        }
        
        return ReturnStatement(token: rootToken, returnValue: DummyExpression())
    }
    
    private func parseExpressionStatement() -> ExpressionStatement? {
        guard let rootToken = currentToken else { return nil }
        guard let expr = parseExpression(precedence: .lowest) else { return nil }
        print("invoke: parseExpressionStatement")
        // セミコロンの一つ前まで進む
        while !peekTokenIs(tokenType: .semicolon) {
            nextToken()
        }
        
        return ExpressionStatement(token: rootToken, expr: expr)
    }
    
    private func parseExpression(precedence: EvalPriority) -> Expression? {
        guard let curToken = currentToken else { return nil }
        guard let prefix = prefixParseFuncs[curToken.type] else {
            // append error
            noPrefixParseFuncError(tokenType: curToken.type)
            return nil
        }
        print("invoke: parseExpression")
        var leftExpr = prefix()

        // debug
        if !peekTokenIs(tokenType: .semicolon) {
            print("peekToken: \(peekToken)")
            print("precedence: \(precedence), peekPrecedence: \(peekPrecedence())")
            print("precedence < peekPrecedence: \(precedence < peekPrecedence())")
        }

        while !peekTokenIs(tokenType: .semicolon) && precedence < peekPrecedence() {
            guard let peek = peekToken, let infix = infixParseFuncs[peek.type], let left = leftExpr else {
                return leftExpr
            }
            
            nextToken()
            leftExpr = infix(left)
        }
        
        return leftExpr
    }
    
    private func parseIdentifier() -> Expression? {
        guard let curToken = currentToken else { return nil }
        print("invoke: parseIdentifier")
        return Identifier(token: curToken, value: curToken.literal)
    }
    
    private func parseIntegerLiteral() -> Expression? {
        guard let curToken = currentToken else { return nil }
        let literal = Int(curToken.literal)
        print("invoke: parseIntegerLiteral")
        switch literal {
        case .some(let lit):
            return IntegerLiteral(token: curToken, value: lit)
        case .none:
            errors.append("could not parse \(curToken.literal) as Integer")
            return nil
        }
    }
    
    private func parsePrefixExpression() -> Expression? {
        guard let prefixOperatorToken = currentToken else { return nil }
        print("invoke: parsePrefixExpression")
        nextToken()
        
        guard let right = parseExpression(precedence: .prefix) else {
            let msg = "\(prefixOperatorToken.literal) operand is nil"
            errors.append(msg)
            return nil
        }
        return PrefixExpression(token: prefixOperatorToken, op: prefixOperatorToken.literal, right: right)
    }
    
    private func parseInfixExpression(left: Expression) -> Expression? {
        guard let infixOperatorToken = currentToken else { return nil }
        print("invoke: parseInfixExpression")
        let precedence = curPrecedence()
        nextToken()
        
        guard let right = parseExpression(precedence: precedence) else { return nil }
        
        return InfixExpression(token: infixOperatorToken, op: infixOperatorToken.literal, left: left, right: right)
        
    }
}

// util系
extension Parser {
    private func nextToken() {
        self.currentToken = peekToken
        peekToken = lexer.nextToken()
    }
    
    private func peekError(tokenType: TokenType) {
        let msg = "expected next token to be \(tokenType.rawValue), got \(peekToken?.type.rawValue ?? "") instead"
        errors.append(msg)
    }
    
    private func expectPeek(tokenType: TokenType) -> Bool {
        if peekTokenIs(tokenType: tokenType) {
            nextToken()
            return true
        }
        return false
    }
    
    private func curTokenIs(tokenType: TokenType) -> Bool {
        guard let curToken = currentToken else { return false }
        return curToken.type == tokenType
    }
    
    private func peekTokenIs(tokenType: TokenType) -> Bool {
        guard let peekToken = peekToken else { return false }
        return peekToken.type == tokenType
    }
    
    // semantic codeを追加するための関数(prefix)
    private func registerPrefix(tokenType: TokenType, fn: @escaping PrefixParseFunc) {
        prefixParseFuncs[tokenType] = fn
    }

    // semantic codeを追加するための関数(infix)
    private func registerInfix(tokenType: TokenType, fn: @escaping InfixParseFunc) {
        infixParseFuncs[tokenType] = fn
    }
    
    private func noPrefixParseFuncError(tokenType: TokenType) {
        let msg = "no prefix parse function for \(tokenType.rawValue) found"
        errors.append(msg)
    }
    
    private func peekPrecedence() -> EvalPriority {
        guard let peek = peekToken else {
//            fatalError("Parser: peekToken is nil")
            return .lowest
        }
        return EvalPriority.infixOeratorPriority(tokenType: peek.type)
    }
    
    private func curPrecedence() -> EvalPriority {
        guard let current = currentToken else {
//            fatalError("Parser: currentToken is nil")
            return .lowest
        }
        return EvalPriority.infixOeratorPriority(tokenType: current.type)
    }
}
