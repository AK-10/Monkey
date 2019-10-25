//
//  Parser.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/08.
//

import Foundation

typealias PrefixParseFunc = () -> Expression?
typealias InfixParseFunc = (Expression) -> Expression?

enum EvalPriority: Int {
    case lowest
    case equals // ==
    case less_greater // < or >
    case sum  // +
    case product // *
    case prefix // -(value) or !(value)
    case call // myFunction(x)
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
        
        registerPrefix(tokenType: .ident, fn: parseIdentifier)
        registerPrefix(tokenType: .int, fn: parseIntegerLiteral)
    }
    
    func parseProgram() -> Program {
        var statements: [Statement] = []
        while let curToken = currentToken, curToken.type == .eof {
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
        switch curToken.type {
        case ._let:
            return parseLetStatement()
        case ._return:
            return parseReturnStatement()
        default:
            return nil
            
        }
    }
    
    private func parseLetStatement() -> LetStatement? {
        guard let rootToken = currentToken else { return nil }
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
            // TODO: valueに正しい値を入れる（現状nameを入れている）
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
        guard let expr = parseExpression(priority: .lowest) else { return nil }
        
        // セミコロンの一つ前まで進む
        while !peekTokenIs(tokenType: .semicolon) {
            nextToken()
        }
        
        return ExpressionStatement(token: rootToken, expr: expr)
    }
    
    private func parseExpression(priority: EvalPriority) -> Expression? {
        guard let curToken = currentToken, let prefix = prefixParseFuncs[curToken.type] else { return nil }
        return prefix()
    }
    
    private func parseIdentifier() -> Expression? {
        guard let curToken = currentToken else { return nil }
        return Identifier(token: curToken, value: curToken.literal)
    }
    
    private func parseIntegerLiteral() -> Expression? {
        guard let curToken = currentToken else { return nil }
        let literal = Int(curToken.literal)
        switch literal {
        case .some(let lit):
            return IntegerLiteral(token: curToken, value: lit)
        case .none:
            errors.append("could not parse \(curToken.literal) as Integer")
            return nil
        }
    }
}

// util系
extension Parser {
    private func nextToken() {
        switch peekToken {
        case .some(let token):
            self.currentToken = token
        case .none:
            break
        }
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
}
