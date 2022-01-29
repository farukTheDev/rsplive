//
//  Gamer.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 23.01.2022.
//

import Foundation

struct Gamer: Codable {
    var id: String? = ""
    var username: String? = ""
    
    init(id: String, username: String) {
        self.id = id
        self.username = username
    }
    
    init?(dict: Dictionary<String, String>?) {
        if dict == nil {
            id = nil
            username = nil
        } else {
            id = dict!["id"]! as String
            username = dict!["username"]! as String
        }
    }
    
    func toDict() -> Dictionary<String?, String?> {
        return [
            "id": id,
            "username": username
        ]
    }
    
}
