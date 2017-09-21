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
    let trim: String
    let submodels: [Submodel]
}

extension Model {
    enum JSONFields: String {
        case
        name = "name",
        niceName = "niceName",
        trim = "trim",
        years = "years",
        styles = "styles"
    }
}

extension Model {
    init(json: JSON) {
        name = json[JSONFields.name.rawValue].stringValue
        niceName = json[JSONFields.niceName.rawValue].stringValue
        trim = json[JSONFields.trim.rawValue].stringValue
        let years = json[JSONFields.years.rawValue].arrayValue
        
        var tmpSubmodels: [Submodel] = []
        for yearDict in years {
            let styles = yearDict[JSONFields.styles.rawValue].arrayValue
            let year = yearDict["year"].intValue
            for styleDict in styles {
                let subName = styleDict["name"].stringValue
                let subTrim = styleDict["trim"].stringValue
                let submodel = styleDict["submodel"].dictionaryValue
                let subBody = submodel["body"]?.stringValue ?? ""
                let subNiceName = submodel["niceName"]?.stringValue ?? ""
                let subModelName = submodel["modelName"]?.stringValue ?? ""
                let newSubmodel = Submodel(name: subName, niceName: subNiceName, year: year, trim: subTrim, body: subBody, modelName: subModelName)
                tmpSubmodels.append(newSubmodel)
            }
        }
        submodels = tmpSubmodels
    }
}
