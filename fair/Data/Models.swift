//
//  Models.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Car {
    let name: String
    let niceName: String
    let id: Int
}

extension Car {
    enum JSONFields: String {
        case
        name = "name",
        niceName = "niceName",
        id = "id"
    }
}

extension Car {
    init(json: JSON) {
        name = json[JSONFields.name.rawValue].stringValue
        niceName = json[JSONFields.niceName.rawValue].stringValue
        id = json[JSONFields.id.rawValue].intValue
    }
}
