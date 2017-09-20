//
//  Article.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/20/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import SwiftyJSON

struct Article {
    let authors: [String]
    let title: String
    let description: String
    let body: String
    let link: URL?
}

extension Article {
    enum JSONFields: String {
        case
        authors = "authors",
        title = "title",
        description = "description",
        body = "body",
        link = "link",
        href = "href"
    }
}

extension Article {
    init(json: JSON) {
        authors = json[JSONFields.authors.rawValue].arrayValue.flatMap { (authorDict) -> String? in
            return authorDict.dictionaryValue["name"]?.stringValue
        }
        title = json[JSONFields.title.rawValue].stringValue
        description = json[JSONFields.description.rawValue].stringValue
        body = json[JSONFields.body.rawValue].stringValue
        link = json[JSONFields.link.rawValue].dictionaryValue[JSONFields.href.rawValue]?.url
    }
}
