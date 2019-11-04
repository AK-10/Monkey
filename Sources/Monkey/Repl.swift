//
//  Repl.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/09/19.
//

import Foundation

struct Repl {
    public func start() {
        while true {
            print("Monkey >> ", terminator: "")
            if let input = readLine() {
                if input == "bye" { exit(0) }
                let lexer = Lexer(input)
                let parser = Parser(lexer)
                let program = parser.parseProgram()
            }
        }
    }
}
