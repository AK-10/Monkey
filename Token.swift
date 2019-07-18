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
    case _illegal = "ILLEGAL"
    case _eof = "EOF"
    
// 識別子 + リテラル
    case _identifier = "IDENT" // add, foobar, x, y, ...
    case _int = "INT" // 12421
    
//  演算子
    case _assign = "="
    case _plus = "+"

// デリミタ
    case _comma = ","
    case _semicolon = ";"
    
    case _lparen = "("
    case _rparen = ")"
    case _lbrace = "{"
    case _rbrace = "}"

// キーワード
    case _function = "FUNCTION"
    case _let = "let"
    
}

struct Token {
    let type: TokenType
    let literal: String
}


