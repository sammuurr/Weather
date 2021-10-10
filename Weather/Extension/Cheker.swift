//
//  Cheker.swift
//  Weather
//
//  Created by ADMIMN on 10.10.2021.
//

import Foundation

extension Int{
    func chekCorrectTime() -> Bool{
        guard self >= 0 else { return false }
        guard self <= 60 else { return false }
        
        return true
    }
}
