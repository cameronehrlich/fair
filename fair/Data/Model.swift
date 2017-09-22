//
//  Model.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Model {
    let name: String
    let niceName: String
    let submodels: [Submodel]
}

extension Model {
    enum JSONFields: String {
        case
        name = "name",
        niceName = "niceName",
        years = "years",
        styles = "styles"
    }
}

extension Model {
    init(json: JSON) {
        name = json[JSONFields.name.rawValue].stringValue
        niceName = json[JSONFields.niceName.rawValue].stringValue
        let years = json[JSONFields.years.rawValue].arrayValue
        
        var tmpSubmodels: [Submodel] = []
        let _ = years.map { yearDict in
            let _ = yearDict[JSONFields.styles.rawValue].arrayValue.map { styleDict in
                let year = yearDict["year"].intValue
                let submodel = styleDict["submodel"].dictionaryValue
                tmpSubmodels.append(
                    Submodel(
                        name: styleDict["name"].stringValue,
                        niceName: submodel["niceName"]?.stringValue ?? "",
                        year: year,
                        trim: styleDict["trim"].stringValue,
                        body: submodel["body"]?.stringValue ?? "",
                        modelName: submodel["modelName"]?.stringValue ?? "")
                )
            }
        }
        submodels = tmpSubmodels
    }
}

extension Model {
    static func list(from json: JSON) -> [Model] {
        guard let models = json.dictionaryValue["models"] else { return [] }
        return models.arrayValue.map { Model(json: $0) }.sorted{ $0.niceName < $1.niceName }
    }
}
