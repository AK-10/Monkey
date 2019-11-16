//
//  ArrayExtension.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/11/15.
//

import Foundation

infix operator ++ : AdditionPrecedence

extension Array {
    static func ++(lhs: Array, rhs: Array) -> Array {
        // lhsに直接appendするとlhsが変わってしまうのでダメ?
        // 引数に渡すタイミングでコピーされるでは? <- そもそもargumentはmutableだったのでコピーが必要
        // また，引数はコピーが渡される(直接いじりたいのであればinoutをつけるが元の値も変わるのでダメ)

        // Arrayは値型なのでlhsのコピーがresultに代入される
        var result = lhs
        result.append(contentsOf: rhs)
        return result
    }
}
