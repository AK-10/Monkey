//
//  Parser.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/10/08.
//

import Foundation

class Parser {
    let lexer: Lexer
    var currentToken: Token? = nil
    var peekToken: Token? = nil
    
    init(_ lexer: Lexer) {
        self.lexer = lexer
        nextToken()
        nextToken()
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
    
    private func nextToken() {
        switch peekToken {
        case .some(let token):
            self.currentToken = token
        case .none:
            break
        }
        peekToken = lexer.nextToken()
    }
    
    private func parseStatement() -> Statement? {
        guard let curToken = currentToken else { return nil }
        switch curToken.type {
        case ._let:
            return parseLetStatement()
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
            // TODO: セミコロンに遭遇するまで指揮を読み飛ばしている
            while !curTokenIs(tokenType: .semicolon) {
                nextToken()
            }
            // TODO: valueに正しい値を入れる（現状nameを入れている）
            return LetStatement(token: rootToken, name: name, value: name)
        case .none:
            return nil
        }
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
}
