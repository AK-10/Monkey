//
//  ErrorObject.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2020/01/11.
//

import Foundation

struct ErrorObject: Object {
    let message: String

    func type() -> ObjectType {
        return .error
    }

    func inspect() -> String {
        return "ERROR: \(message)"
    }
}
