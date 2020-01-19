//
//  Boolena.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation

struct Boolean: Object {
    let value: Bool
    
    func type() -> ObjectType {
        return .boolean
    }
    
    func inspect() -> String {
        return value.description
    }
    
    static func ==(lhs: Self, rhs: Self) -> Self {
        return Boolean(value: lhs.value == rhs.value)
    }
    
    static func !=(lhs: Self, rhs: Self) -> Self {
        return Boolean(value: lhs.value != rhs.value)
    }
}
