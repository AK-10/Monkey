//
//  ReturnValue.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2020/01/04.
//

import Foundation

struct ReturnValue: Object {
    let value: Object

    func type() -> ObjectType {
        return .returnValue
    }

    // valueをキャストなしで取れるようにしたい
    func inspect() -> String {
        switch value {
        case let obj as Integer:
            return obj.inspect()
        case let obj as Boolean:
            return obj.inspect()
        default:
            return "ILLEGAL OBJECT"
        }
    }
}
