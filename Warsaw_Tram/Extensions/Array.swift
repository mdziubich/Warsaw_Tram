//
//  Array.swift
//  Warsaw_Tram
//
//  Created by Małgorzata Dziubich on 05/07/16.
//  Copyright © 2016 Małgorzata Dziubich. All rights reserved.
//

extension Array {
    
    /*
     Costructs an array removing the duplicate values in self
     - returns: Array of unique values
     */
    func unique() -> [Int] {
        var result = [Int]()
        
        for item in self {
            if !result.contains(item as! Int) {
                result.append(item as! Int)
            }
        }
        return result
    }
}
