//
//  Overview.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/20/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias OtherInfoPair = (label: String, fulltext: String)

struct Overview {
    let title: String
    let introduction: String
    let edmundsSays: String
    let safety: String
    let driving: String
    let body: String
    let whatsNew : String
    let interior: String
    let powertrain: String
    
    var otherInfoArray: [OtherInfoPair] {
        var tmpInfoArray: [OtherInfoPair] = []
        tmpInfoArray.append( OtherInfoPair(label: "Introduction", fulltext: introduction) )
        tmpInfoArray.append( OtherInfoPair(label: "Edmunds Says", fulltext: edmundsSays) )
        tmpInfoArray.append( OtherInfoPair(label: "Safety", fulltext: safety) )
        tmpInfoArray.append( OtherInfoPair(label: "Driving", fulltext: driving) )
        tmpInfoArray.append( OtherInfoPair(label: "Body", fulltext: body) )
        tmpInfoArray.append( OtherInfoPair(label: "What's New", fulltext: whatsNew) )
        tmpInfoArray.append( OtherInfoPair(label: "Interior", fulltext: introduction) )
        tmpInfoArray.append( OtherInfoPair(label: "Powertrain", fulltext: powertrain) )
        return tmpInfoArray
    }
}

extension Overview {
    enum JSONFields: String {
        case
        title = "title",
        introduction = "introduction",
        edmundsSays = "edmundsSays",
        safety = "safety",
        driving = "driving",
        body = "body",
        whatsNew = "whatsNew",
        interior = "interior",
        powertrain = "powertrain"
    }
}

extension Overview {
    init(json: JSON) {
        title = json[JSONFields.title.rawValue].stringValue
        introduction = json[JSONFields.introduction.rawValue].stringValue
        edmundsSays = json[JSONFields.edmundsSays.rawValue].stringValue
        safety = json[JSONFields.safety.rawValue].stringValue
        driving = json[JSONFields.driving.rawValue].stringValue
        body = json[JSONFields.body.rawValue].stringValue
        whatsNew = json[JSONFields.whatsNew.rawValue].stringValue
        interior = json[JSONFields.interior.rawValue].stringValue
        powertrain = json[JSONFields.powertrain.rawValue].stringValue
    }
}
