//
//  Environment.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2020/01/13.
//

import Foundation

final class Environment {
    var store: [String:Object] = [:]
    var outer: Environment? = nil

    init() {
        self.store = [:]
    }

    init(outer: Environment) {
        self.outer = outer
    }

    func get(name: String) -> Object? {
        store[name] ?? outer?.get(name: name)
    }

    func set(name: String, value: Object) -> Object {
        store[name] = value
        return value
    }
}
