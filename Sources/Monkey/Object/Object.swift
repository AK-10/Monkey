//
//  Object.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/12/14.
//

import Foundation

enum ObjectType {
}

protocol Object {
    func type()
    func inspect()
}
