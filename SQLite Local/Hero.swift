//
//  Hero.swift
//  SQLite Local
//
//  Created by Marco Antonio Gutierrez López on 3/10/18.
//  Copyright © 2018 Marco Antonio Gutierrez López. All rights reserved.
//

import Foundation

class Hero {
    
    var id: Int
    var name: String?
    var powerRanking: Int
    init(id: Int, name: String?, powerRanking: Int){
        self.id = id
        self.name = name
        self.powerRanking = powerRanking
    }
}
