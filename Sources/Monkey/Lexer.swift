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
                token = Token(.illegal, TokenType.illegal.rawValue)
            }
        case .none:
            token = Token(.eof, "")
        }
        readChar()
        return token
    }
    
    func readIdentifier() {
        switch ch {
        case .some:
            readChar()
        case .none:
            fatalError("readIdentifier: unexpected value")
        }
    }
    
    func isLetter(char: Character) -> Bool {
        return Character("a") <= char && char <= Character("z") || Character("A") <= char && char <= Character("Z") || char == Character("_")
    }
}

extension String {
    subscript (i: Int) -> Character? {
        return i < self.count ? self[index(startIndex, offsetBy: i)] : nil
    }
    subscript (bounds: CountableRange<Int>) -> Substring? {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return end <= self.endIndex ? self[start ..< end] : nil
    }
    subscript (bounds: CountableClosedRange<Int>) -> Substring? {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return end <= self.endIndex ? self[start ... end] : nil
    }
    subscript (bounds: CountablePartialRangeFrom<Int>) -> Substring? {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(endIndex, offsetBy: -1)
        return end <= self.endIndex ? self[start ... end] : nil
    }
    subscript (bounds: PartialRangeThrough<Int>) -> Substring? {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return end <= self.endIndex ? self[startIndex ... end] : nil
    }
    subscript (bounds: PartialRangeUpTo<Int>) -> Substring? {
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return end <= self.endIndex ? self[startIndex ..< end] : nil
    }
}
