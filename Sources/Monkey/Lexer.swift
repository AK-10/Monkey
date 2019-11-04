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
    
    init(_ _input: String) {
        input = _input
        position = 0
        readPosition = position + 1
        ch = input[position]
    }
    
    func readChar() {
        print(ch)
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
            // 一文字トークン
            case TokenType.assign.rawValue:
                switch peekChar() {
                case .some(let nextChar):
                    if nextChar == Character("=") {
                        token = Token(.eq, String([char, nextChar]))
                    } else {
                        token = Token(.assign, literal)
                    }
                case .none:
                    fatalError("unexpected character")
                }
                readChar()
            case TokenType.semicolon.rawValue:
                token = Token(.semicolon, literal)
                readChar()
            case TokenType.lParen.rawValue:
                token = Token(.lParen, literal)
                readChar()
            case TokenType.rParen.rawValue:
                token = Token(.rParen, literal)
                readChar()
            case TokenType.comma.rawValue:
                token = Token(.comma, literal)
                readChar()
            case TokenType.lBrace.rawValue:
                token = Token(.lBrace, literal)
                readChar()
            case TokenType.rBrace.rawValue:
                token = Token(.rBrace, literal)
                readChar()
            case TokenType.plus.rawValue:
                token = Token(.plus, literal)
                readChar()
            case TokenType.minus.rawValue:
                token = Token(.minus, literal)
                readChar()
            case TokenType.bang.rawValue:
                switch peekChar() {
                case .some(let nextChar):
                    if nextChar == Character("=") {
                        token = Token(.notEq, String([char, nextChar]))
                    } else {
                        token = Token(.bang, literal)
                    }
                case .none:
                    fatalError("unexpected character")
                }
                readChar()
            case TokenType.asterisk.rawValue:
                token = Token(.asterisk, literal)
                readChar()
            case TokenType.slash.rawValue:
                token = Token(.slash, literal)
                readChar()
            case TokenType.lt.rawValue:
                token = Token(.lt, literal)
                readChar()
            case TokenType.gt.rawValue:
                token = Token(.gt, literal)
                readChar()
            default:
                if isLetter(char: char) {
                    switch readIdentifier() {
                    case .some(let ident):
                        // キーワードトークン
                        let type = Token.lookupIdent(ident: ident)
                        token = Token(type, ident)
                    case .none:
                        fatalError("unexpected character")
                    }
                } else if isDigit(char: char) {
                    switch readNumber() {
                    case .some(let number):
                        let type = TokenType.int
                        token = Token(type, number)
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
        return token
    }
    
    private func isLetter(char: Character) -> Bool {
        return Character("a") <= char && char <= Character("z") || Character("A") <= char && char <= Character("Z") || char == Character("_")
    }
    
    private func readIdentifier() -> String? {
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
    
    private func skipWhiteSpace() {
        while ch == Character(" ") || ch == Character("\n") || ch == Character("\t")  || ch == Character("\r") {
            readChar()
        }
    }
    
    private func isDigit(char: Character) -> Bool {
        return Character("0") <= char && char <= Character("9")
    }
    
    private func readNumber() -> String? {
        let startPosition = position
        while let char = ch {
            if isDigit(char: char) {
                readChar()
            } else {
                break
            }
        }
        let range = startPosition ..< position
        
        return input.read(range)?.description
    }
    
    // 覗き見するだけ
    private func peekChar() -> Character? {
        return input[readPosition]
    }
}
