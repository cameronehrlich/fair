//
//  Submodel.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import SwiftyJSON

typealias YearSubmodels = (year: Int, submodels: [Submodel])

struct Submodel {
    let name: String
    let niceName: String
    let year: Int
    let trim: String
    let body: String
    let modelName: String
    
    var detailText: String {
        return "\(modelName), \(trim), \(body)"
    }
}

extension Submodel {
    enum JSONFields: String {
        case
        name = "name",
        niceName = "niceName",
        year = "year",
        trim = "trim",
        body = "body",
        modelName = "modelName"
    }
}

extension Submodel {
    init(json: JSON) {
        name = json[JSONFields.name.rawValue].stringValue
        niceName = json[JSONFields.niceName.rawValue].stringValue
        year = json[JSONFields.year.rawValue].intValue
        trim = json[JSONFields.trim.rawValue].stringValue
        body = json[JSONFields.body.rawValue].stringValue
        modelName = json[JSONFields.modelName.rawValue].stringValue
    }
}

extension Submodel {
    static func submodelsByYear(fromModel model: Model) -> [YearSubmodels] {
        let uniqeSubmodels = Set(model.submodels.map { $0.year })
        let yearsSubmodels = Array(uniqeSubmodels).sorted { $0 > $1 }.map { year -> YearSubmodels in
            return (year, model.submodels.filter { submodel in
                return submodel.year == year
            })
        }
        return yearsSubmodels.sorted { $0.year > $1.year }
    }
}

extension Submodel: Hashable {
    var hashValue: Int {
        return name.hashValue
            ^ niceName.hashValue
            ^ year.hashValue
            ^ trim.hashValue
            ^ body.hashValue
            ^ modelName.hashValue
    }
    
    static func ==(lhs: Submodel, rhs: Submodel) -> Bool {
        return lhs.name == rhs.name
            && lhs.niceName == rhs.niceName
            && lhs.year == rhs.year
            && lhs.trim == rhs.trim
            && lhs.body == rhs.body
            && lhs.modelName == rhs.modelName
    }
}

