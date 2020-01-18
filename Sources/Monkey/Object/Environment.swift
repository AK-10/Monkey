//
//  Environment.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2020/01/13.
//

import Foundation

final class Environment {
    var store: [String:Object] = [:]

    func get(name: String) -> Object? {
        return store[name]
    }

    func set(name: String, value: Object) -> Object {
        store[name] = value
        return value
    }
}
