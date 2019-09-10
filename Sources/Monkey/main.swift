import Foundation

print("Hello, world!")

enum Token: String {
    case illegal = "ILLEGAL"
    case eof = "EOF"
    
    case ident = "IDENT" // add, foobar, x, y, ...
    case int = "INT" // 123456
    
    case assign = "="
    case plus = "+"
    
    case comma = ","
    case semicolon = ";"
    
    case lParen = "("
    case rParen = ")"
    case lBrace = "{"
    case rBrace = "}"
    
    case function = "FUNCTION"
    case _let = "LET"
}
