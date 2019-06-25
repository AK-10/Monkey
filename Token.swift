//
//  Token.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/06/26.
//

import Foundation

// 元の本では以下の実装だがswiftではenumが使える
//typealias TokenType = String

enum TokenType: String {
    case illegal = "ILLEGAL"
    case eof = "EOF"
    
// 識別子 + リテラル
    case identifier = "IDENT" // add, foobar, x, y, ...
    case int = "INT" // 12421
    
//  演算子
    case assign = "="
    case plus = "+"

// デリミタ
    case comma = ","
    case semicolon = ";"
    
    case lparen = "("
    case rparen = ")"
    case lbrace = "{"
    case rbrace = "}"

// キーワード
    case function = "FUNCTION"
    case
    
}

struct Token {
    let type: TokenType
    let literal: String
}


