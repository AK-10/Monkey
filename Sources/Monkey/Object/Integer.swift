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

    static func +(lhs: Self, rhs: Self) -> Self {
        return Integer(value: lhs.value + rhs.value)
    }

    static func -(lhs: Self, rhs: Self) -> Self {
        return Integer(value: lhs.value - rhs.value)
    }

    static func *(lhs: Self, rhs: Self) -> Self {
        return Integer(value: lhs.value * rhs.value)
    }

    static func /(lhs: Self, rhs: Self) -> Self {
        return Integer(value: lhs.value / rhs.value)
    }

    static func ==(lhs: Self, rhs: Self) -> Boolean {
        return Boolean(value: lhs.value == rhs.value)
    }

    static func !=(lhs: Self, rhs: Self) -> Boolean {
        return Boolean(value: lhs.value != rhs.value)
    }

    static func >(lhs: Self, rhs: Self) -> Boolean {
        return Boolean(value: lhs.value > rhs.value)
    }

    static func <(lhs: Self, rhs: Self) -> Boolean {
        return Boolean(value: lhs.value < rhs.value)
    }
    
    static func <=(lhs: Self, rhs: Self) -> Boolean {
        return Boolean(value: lhs.value <= rhs.value)
    }
}
