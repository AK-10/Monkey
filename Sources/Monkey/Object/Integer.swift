//
//  Integer.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation

struct Integer: Object {
    let value: Int
    
    func type() -> ObjectType {
        return .integer
    }
    
    func inspect() -> String {
        return value.description
    }
}
