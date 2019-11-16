//
//  StringExtension.swift
//  Monkey
//
//  Created by Atsushi KONISHI on 2019/09/15.
//

import Foundation

extension String {
    
    subscript (i: Int) -> Character? {
        return i < self.count ? self[index(startIndex, offsetBy: i)] : nil
    }
    
    func read(_ bounds: CountableRange<Int>) -> Substring? {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return end <= self.endIndex ? self[start ..< end] : nil
    }
    func read(_ bounds: CountableClosedRange<Int>) -> Substring? {
        let start = index(startIndex, offsetBy: bounds.lowerBound)
        let end = index(startIndex, offsetBy: bounds.upperBound)
        return end <= self.endIndex ? self[start ... end] : nil
    }
}
