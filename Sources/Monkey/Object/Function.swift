//
//  Function.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2020/01/19.
//

import Foundation

struct Function: Object {
    let parameters: [Identifier]
    let body: BlockStatement
    let env: Environment
    
    func type() -> ObjectType {
        return .function
    }
    
    func inspect() -> String {
        let paramsStr = parameters.map { $0.description }.joined(separator: ", ")
        let out = ["fn", "(", paramsStr, ")", "{", body.description, "}"]
        return out.joined(separator: "\n")
    }
}
