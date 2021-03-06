//
//  TokenType.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/09/10.
//

import Foundation

struct Token {
    let type: TokenType
    let literal: String
    
    init(_ _type: TokenType, _ _literal: String) {
        type = _type
        literal = _literal
    }
    
    static func lookupIdent(ident: String) -> TokenType {
        let keywords = ["fn": TokenType.function,
                        "let": TokenType._let,
                        "true": TokenType._true,
                        "false": TokenType._false,
                        "if": TokenType._if,
                        "else": TokenType._else,
                        "return": TokenType._return
                        ]
        guard let type = keywords[ident] else {
            return TokenType.ident
        }
        return type
    }
}
