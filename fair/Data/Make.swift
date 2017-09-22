//
//  Models.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Make {
    let name: String
    let niceName: String
}

extension Make {
    enum JSONFields: String {
        case
        name = "name",
        niceName = "niceName"
    }
}

extension Make {
    init(json: JSON) {
        name = json[JSONFields.name.rawValue].stringValue
        niceName = json[JSONFields.niceName.rawValue].stringValue
    }
}

extension Make {
    static func list(from json: JSON) -> [Make] {
        guard let makes = json.dictionaryValue["makes"] else { return [] }
        return makes.arrayValue.map { Make(json: $0) }.sorted{ $0.niceName < $1.niceName }.sorted {$0.niceName < $1.niceName }
    }
}
