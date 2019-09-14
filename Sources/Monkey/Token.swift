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
        let keywords = [TokenType.function.rawValue: TokenType.function,
                        TokenType._let.rawValue: TokenType._let]
        guard let type = keywords[ident] else {
            return TokenType.ident
        }
        return type
    }
}
