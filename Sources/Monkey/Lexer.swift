//
//  Lexer.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/09/10.
//

import Foundation

class Lexer {
    let input: String
    var position: Int // 入力における現在の位置
    var readPosition: Int // これから読み込む位置（現在の次の位置）
    var ch: Character? // 現在検査中の文字
    
    init(_input: String) {
        input = _input
        position = 0
        readPosition = position + 1
        ch = input[position]
    }
    
    func readChar() {
        ch = input[readPosition]
        position = readPosition
        readPosition += 1
    }
    
    func nextToken() -> Optional<Token> {
        var token: Optional<Token> = nil
        
        // 空行は特に意味を持たないのでスキップ
        skipWhiteSpace()
        
        switch ch {
        case .some(let char):
            let literal = String(char)
            switch literal {
            case TokenType.assign.rawValue:
                token = Token(.assign, literal)
            case TokenType.semicolon.rawValue:
                token = Token(.semicolon, literal)
            case TokenType.lParen.rawValue:
                token = Token(.lParen, literal)
            case TokenType.rParen.rawValue:
                token = Token(.rParen, literal)
            case TokenType.comma.rawValue:
                token = Token(.comma, literal)
            case TokenType.plus.rawValue:
                token = Token(.plus, literal)
            case TokenType.lBrace.rawValue:
                token = Token(.lBrace, literal)
            case TokenType.rBrace.rawValue:
                token = Token(.rBrace, literal)
            default:
                if isLetter(char: char) {
                    switch readIdentifier() {
                    case .some(let ident):
                        let type = Token.lookupIdent(ident: ident)
                        token = Token(type, ident)
                    case .none:
                        fatalError("unexpected character")
                    }
                } else {
                    token = Token(.illegal, TokenType.illegal.rawValue)
                }
            }
        case .none:
            token = nil
        }
        readChar()
        return token
    }
    
    func readIdentifier() -> String? {
        let startPosition = position
        while let char = ch {
            if isLetter(char: char) {
                readChar()
            } else {
                break
            }
        }
        let range = startPosition ..< position
        
        return input.read(range)?.description
    }
    
    func isLetter(char: Character) -> Bool {
        return Character("a") <= char && char <= Character("z") || Character("A") <= char && char <= Character("Z") || char == Character("_")
    }
    
    func skipWhiteSpace() {
        while ch == Character(" ") || ch == Character("\n") || ch == Character("\t")  || ch == Character("\r") {
            readChar()
        }
    }
}
