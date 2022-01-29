//
//  GameRoom.swift
//  rpslive
//
//  Created by Ömer Faruk KISIK on 23.01.2022.
//

import Foundation

struct GameRoom: Codable {
    var id: String? = nil
    var title: String = ""
    var host: Gamer = Gamer(id: "", username: "")
    var hostStatus: Bool = false
    var hostSelection: String = ""
    var guest: Gamer? = nil
    var guestStatus: Bool = false
    var guestSelection: String = ""
    var status: Int = 0
    var isPrivate: Bool = false
    
    func toDict() -> Dictionary<String, Any?>{
        return [
            "id": id,
            "title": title,
            "host": host.toDict(),
            "hostStatus": hostStatus,
            "hostSelection": hostSelection,
            "guest": guest?.toDict() ?? nil,
            "guestStatus": guestStatus,
            "guestSelection": guestSelection,
            "status": status,
            "isPrivate": isPrivate
        ]
    }
}
