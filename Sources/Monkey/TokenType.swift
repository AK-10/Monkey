//
//  Token.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/09/10.
//

import Foundation

enum TokenType: String {
    case illegal = "ILLEGAL"
    case eof = "EOF"
    
    case ident = "IDENT" // add, foobar, x, y, ...
    case int = "INT" // 123456
    
    case assign = "="
    case plus = "+"
    case minus = "-"
    case bang = "!"
    case asterisk = "*"
    case slash = "/"
    
    case lt = "<"
    case gt = ">"
    
    case comma = ","
    case semicolon = ";"
    
    case lParen = "("
    case rParen = ")"
    case lBrace = "{"
    case rBrace = "}"
    
    case function = "FUNCTION"
    case _let = "LET"
    
    case _true = "TRUE"
    case _false = "FALSE"
    case _if = "IF"
    case _else = "ELSE"
    case _return = "RETURN"
    
    case eq = "=="
    case notEq = "!="
}
