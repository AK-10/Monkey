//
//  Null.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation

struct Null: Object {
    func type() -> ObjectType {
        return .null
    }
    
    func inspect() -> String {
        return "null"
    }
}
