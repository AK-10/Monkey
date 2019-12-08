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
                if parser.errors.count > 0 {
                    print("error detected:")
                    printParserErrors(errors: parser.errors)
                    continue
                }
                print("parse succeeded:")
                print(program.description)
            }
        }
    }
    
    private func printParserErrors(errors: [String]) {
        for err in errors {
            print("message: \(err)")
        }
    }
}
