//
//  API.swift
//  fair
//
//  Created by Cameron Ehrlich on 9/19/17.
//  Copyright © 2017 fair. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON

typealias SuccessCompletion = (JSON) -> Void
typealias ErrorCompletion   = (RequestError) -> Void

enum BaseURLType: String {
    case vehicle    = "https://api.edmunds.com/api/vehicle/v2/"
    case media      = "https://api.edmunds.com/api/media/v2/" // TODO : Endpoint not working?
    case editorial  = "https://api.edmunds.com/api/editorial/v2/"
}

struct API {
    
    static let Key = "ke2d4cv925rhhzgmkvmt755u"
    
    @discardableResult
    static func request(_ endpoint: Endpoint, completion: @escaping SuccessCompletion, failure: @escaping ErrorCompletion) -> DataRequest {
        let url: String = endpoint.rawValue.endpointType.rawValue + endpoint.rawValue.path
        let method = endpoint.rawValue.method
        let params = endpoint.rawValue.params
        let encoding: ParameterEncoding = (method == .get) ? URLEncoding() : JSONEncoding()
        let dataRequest = Alamofire.request(url, method: method, parameters: params, encoding:  encoding, headers: nil)
        
        return dataRequest.response { response in
            do {
                let responseJSON = try validatedJSON(forResponse: response)
                completion(responseJSON)
            }
            catch RequestError.invalidJSON(let invalidJSON, let jsonError) {
                failure(RequestError.invalidJSON(json: invalidJSON, jsonError: jsonError))
            }
            catch RequestError.noData {
                failure(RequestError.noData)
            }
            catch RequestError.unauthorized {
                failure(RequestError.unauthorized)
            }
            catch {
                failure(RequestError.otherError(error: error))
            }
        }
    }
    
    private static func validatedJSON(forResponse response: DefaultDataResponse) throws -> JSON {
        guard response.response?.statusCode != 401 else {
            throw RequestError.unauthorized
        }
        guard response.error == nil else {
            throw RequestError.otherError(error: response.error!)
        }
        guard let data = response.data else {
            throw RequestError.noData
        }
        let json = try JSON(data: data)
        guard json.error == nil else {
            throw RequestError.invalidJSON(json: json, jsonError: json.error!)
        }
        return json
    }
}

enum Endpoint {
    case fetchMakes()
    case fetchMake(make: String)
    case fetchModel(model: String, make: String)
    case fetchImages(make: String, model: String, year: String?) // TODO : Edmunds media API not working?
    case fetchOverview(make: String, model: String, year: String?)
    case fetchArticles(tag: String)
}

extension Endpoint {
    var rawValue: CallInfo {
        get {
            switch self {
            case .fetchMakes():
                return CallInfo(.get, path: "makes", params : ["state" : "new", "view" : "basic"])
            case .fetchMake(let make):
                return CallInfo(.get, path: "\(make)/models")
            case .fetchModel(let model, let make):
                return CallInfo(.get, path: "\(make)/\(model)")
            case .fetchImages(let make, let model, let year):
                return CallInfo(.get, path: "\(make)/\(model)/\(year ?? "")", params: nil, endpointType: .media)
            case .fetchOverview(let make, let model, let year):
                return CallInfo(.get, path: "\(make)/\(model)/\(year ?? "")", params: nil, endpointType: .editorial)
            case .fetchArticles(let tag):
                return CallInfo(.get, path: "articles", params: ["tag" : tag], endpointType: .editorial)
            }
        }
    }
}

enum RequestError: Error {
    case unauthorized
    case noData
    case invalidJSON(json: JSON, jsonError: Error)
    case otherError(error: Error)
}

struct CallInfo {
    let method: HTTPMethod
    let path: String
    let params: [String : Any]?
    var endpointType: BaseURLType = .vehicle
    
    init(_ method: HTTPMethod, path: String) {
        self.init(method, path: path, params: nil)
    }
    
    init(_ method: HTTPMethod, path: String, params: [String : Any]?) {
        self.init(method, path: path, params: params, endpointType: .vehicle)
    }
    
    init(_ method: HTTPMethod, path: String, params: [String : Any]?, endpointType: BaseURLType) {
        self.method = method
        self.path = path
        var newParams: [String: Any] = params ?? [:]
        newParams["api_key"] = API.Key // Add API key
        self.params = newParams
        self.endpointType = endpointType
    }
}
