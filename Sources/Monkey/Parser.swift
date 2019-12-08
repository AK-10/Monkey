//
//  Parser.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/08.
//

import Foundation

typealias PrefixParseFunc = () -> Expression?
typealias InfixParseFunc = (Expression) -> Expression?

enum EvalPrecedence: Int, Comparable, Equatable {

    static func < (lhs: EvalPrecedence, rhs: EvalPrecedence) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }

    case lowest
    case equals // ==
    case less_greater // < or >
    case sum  // +
    case product // *
    case prefix // -(value) or !(value)
    case call // myFunction(x)

    static func infixOperatorPriority(tokenType: TokenType) -> EvalPrecedence {
        switch tokenType {
        case .eq, .notEq:
            return .equals
        case .lt, .gt:
            return .less_greater
        case .plus, .minus:
            return .sum
        case .slash, .asterisk:
            return .product
        case .lParen:
            return .call
        default:
            return .lowest
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

        // paren
        registerPrefix(tokenType: .lParen, fn: parseGroupedExpression)

        // integer
        registerPrefix(tokenType: .int, fn: parseIntegerLiteral)

        // bool
        registerPrefix(tokenType: ._true, fn: parseBoolLiteral)
        registerPrefix(tokenType: ._false, fn: parseBoolLiteral)

        // if
        registerPrefix(tokenType: ._if, fn: parseIfExpression)

        // function
        registerPrefix(tokenType: .function, fn: parseFunctionLiteral)
        
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
        
        // call function
        // add(1, 3) を `add` `(` `1, 3` `)` と見ることができる
        // `(` を中置演算子, `)`を末尾のデリミタとして扱うとinfixOperatorとして扱える
        registerInfix(tokenType: .lParen, fn: parseCallExpression)
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
        if !expectPeek(tokenType: .ident) {
            return nil
        }

        switch currentToken {
        case .some(let curToken):
            let name = Identifier(token: curToken, value: curToken.literal)

            if !expectPeek(tokenType: .assign) {
                return nil
            }

            nextToken()
            
            guard let value = parseExpression(precedence: .lowest) else { return nil }
            
            if peekTokenIs(tokenType: .semicolon) {
                nextToken()
            }

            return LetStatement(token: rootToken, name: name, value: value)
        case .none:
            return nil
        }
    }

    private func parseReturnStatement() -> ReturnStatement? {
        guard let rootToken = currentToken else { return nil }

        nextToken()

        guard let value = parseExpression(precedence: .lowest) else { return nil }
        
        return ReturnStatement(token: rootToken, returnValue: value)
    }

    private func parseExpressionStatement() -> ExpressionStatement? {
        guard let rootToken = currentToken else { return nil }
        guard let expr = parseExpression(precedence: .lowest) else { return nil }
        
        // 式のparse後次のトークンはsemicolonのはず．これを次に進めることで次のstatementをparseする．
        if peekTokenIs(tokenType: .semicolon) {
            nextToken()
        }

        return ExpressionStatement(token: rootToken, expr: expr)
    }

    private func parseExpression(precedence: EvalPrecedence) -> Expression? {
        guard let expToken = currentToken else { return nil }
        guard let prefix = prefixParseFuncs[expToken.type] else {
            // append error
            noPrefixParseFuncError(tokenType: expToken.type)
            return nil
        }
        var leftExpr = prefix()

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
        guard let identToken = currentToken else { return nil }
        return Identifier(token: identToken, value: identToken.literal)
    }

    private func parseIntegerLiteral() -> Expression? {
        guard let intToken = currentToken else { return nil }
        let literal = Int(intToken.literal)
        switch literal {
        case .some(let lit):
            return IntegerLiteral(token: intToken, value: lit)
        case .none:
            errors.append("could not parse \(intToken.literal) as Integer")
            return nil
        }
    }

    private func parseBoolLiteral() -> Expression? {
        guard let boolToken = currentToken else { return nil }
        let value = curTokenIs(tokenType: ._true)
        return BoolLiteral(token: boolToken, value: value)
    }

    private func parseGroupedExpression() -> Expression? {
        // currentTokenが`(`であるのでその次のトークンからがExpressionのため, nextTokenを実行
        nextToken()
        let exp = parseExpression(precedence: .lowest)
        return expectPeek(tokenType: .rParen) ? exp : nil
    }

    private func parsePrefixExpression() -> Expression? {
        guard let prefixOperatorToken = currentToken else { return nil }
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
        let precedence = curPrecedence()
        nextToken()

        guard let right = parseExpression(precedence: precedence) else { return nil }

        return InfixExpression(token: infixOperatorToken, op: infixOperatorToken.literal, left: left, right: right)
    }

    private func parseIfExpression() -> Expression? {
        guard let ifToken = currentToken else { return nil }
        if !expectPeek(tokenType: .lParen) { // ifの後はlParenのはずなので,そうでなければエラー(nilを返す)
            return nil
        }

        nextToken() // currentTokenは`lParen`になる

        guard let condition = parseExpression(precedence: .lowest) else { return nil } // (<condition>)をparseできなければnil
        if !expectPeek(tokenType: .rParen) {
            return nil
        }

        if !expectPeek(tokenType: .lBrace) {  // conditionの後はlBlaceのはずなので，そうでなければエラー(nilを返す)
            return nil
        }

        guard let conditionBlock = parseBlockStatement() else { return nil }

        var alternativeBlock: BlockStatement?

        if peekTokenIs(tokenType: ._else) {
            nextToken()
            if !expectPeek(tokenType: .lBrace) {
                return nil
            }
            alternativeBlock = parseBlockStatement()
        }

        return IfExpression(token: ifToken, condition: condition, consequence: conditionBlock, alternative: alternativeBlock)
     }

     // currentTokenが.lBraceの時に呼ばれる
    private func parseBlockStatement() -> BlockStatement? {
        guard let lBraceToken = currentToken else { return nil }

        var statements: [Statement] = []

        nextToken()

        while !curTokenIs(tokenType: .rBrace) && !curTokenIs(tokenType: .eof) {
            let stmt = parseStatement()
            if let stmt = stmt {
                statements.append(stmt)
            }
            nextToken()
        }

        return BlockStatement(token: lBraceToken, statements: statements)
    }
    
    private func parseFunctionLiteral() -> Expression? {
        guard let functionToken = currentToken else { return nil }
        guard expectPeek(tokenType: .lParen) else { return nil }
        
        let parameters = parseFunctionParameters()
        
        guard expectPeek(tokenType: .lBrace) else { return nil }
        
        guard let body = parseBlockStatement() else { return nil }
        
        return FunctionLiteral(token: functionToken, parameters: parameters, body: body)
    }
    
    private func parseFunctionParameters() -> [Identifier] { // currentTokenはlParenまたはidentifier
        var ids: [Identifier] = []
        if peekTokenIs(tokenType: .rParen) { // 次のトークンがrParenだったらパラメータがない
            nextToken()
            return []
        }
        
        nextToken()
        
        guard let idToken = currentToken else { return [] }
        ids.append(Identifier(token: idToken, value: idToken.literal))


        while peekTokenIs(tokenType: .comma) { // (p1, p2, ...) `,`の前がparameterなのでこの条件式
            // 二回tokenを進めるとidTokenになるはず
            nextToken()
            nextToken()
            
            guard let idToken = currentToken else { return [] }
            ids.append(Identifier(token: idToken, value: idToken.literal))
        }
        
        guard expectPeek(tokenType: .rParen) else { return [] }
        
        return ids
    }
    
    // identifierをtokenとして取得したのち，次のトークンとして`(`が得られた時に呼ばれる
    private func parseCallExpression(function: Expression) -> Expression? {
        guard let lParenToken = currentToken else { return nil }
        guard let arguments = parseCallArguments() else { return nil }
        
        return CallExpression(token: lParenToken, function: function, arguments: arguments)
    }
    
    // parseCallExpressionから呼ばれる
    private func parseCallArguments() -> [Expression]? {
        var arguments = [Expression]()
        
        if peekTokenIs(tokenType: .rParen) {
            nextToken()
            return arguments
        }
        
        nextToken()
        
        guard let exp = parseExpression(precedence: .lowest) else {
            return nil  // TODO: 別の対処をすべき
        }
        arguments.append(exp)
        
        while peekTokenIs(tokenType: .comma) {
            nextToken()
            nextToken()
            guard let expr = parseExpression(precedence: .lowest) else {
                return nil // TODO: 別の対処をすべき
            }
            arguments.append(expr)
        }
        
        guard expectPeek(tokenType: .rParen) else {
            return nil
        }
        
        return arguments
    }
}

// util系
extension Parser {
    private func nextToken() {
        self.currentToken = peekToken
        peekToken = lexer.nextToken()
    }

    private func peekError(tokenType: TokenType) {
        let msg = "expected next token to be \(tokenType.rawValue), got \(peekToken?.type.rawValue ?? "invalid type") instead"
        errors.append(msg)
    }

    private func expectPeek(tokenType: TokenType) -> Bool {
        if peekTokenIs(tokenType: tokenType) {
            nextToken()
            return true
        }
        peekError(tokenType: tokenType)
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

    private func peekPrecedence() -> EvalPrecedence {
        guard let peek = peekToken else {
//            fatalError("Parser: peekToken is nil")
            return .lowest
        }
        return EvalPrecedence.infixOperatorPriority(tokenType: peek.type)
    }

    private func curPrecedence() -> EvalPrecedence {
        guard let current = currentToken else {
//            fatalError("Parser: currentToken is nil")
            return .lowest
        }
        return EvalPrecedence.infixOperatorPriority(tokenType: current.type)
    }
}
