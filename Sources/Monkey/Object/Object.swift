//
//  Object.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation

enum ObjectType: String {
    case integer = "INTEGER"
    case boolean = "BOOLEAN"
}

protocol Object {
    func type() -> ObjectType
    func inspect() -> String
}
