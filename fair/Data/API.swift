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

typealias DefaultRequestCompletion = (JSON) -> Void
typealias RequestErrorCompletion = (RequestError) -> Void

enum Endpoint {
    case search(makeModel: String)
}

extension Endpoint {
    var rawValue: CallInfo {
        get {
            switch self {
            case .search(let makeModel):
                let splitString = makeModel.components(separatedBy: " ")
                switch splitString.count {
                case 1: return CallInfo(.get, path: splitString[0], params: nil)
                case 2: return CallInfo(.get, path: "\(splitString[0])/\(splitString[1])", params: nil)
                default:
                    print("Error in \(#function)") // TODO : Proper error handling
                    return CallInfo(.get, path: makeModel, params: nil)
                }
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
    
    init(_ method: HTTPMethod, path: String, params: [String : Any]?) {
        self.method = method
        self.path = path
        var newParams: [String: Any] = params ?? [:]
        newParams["api_key"] = API.Key // Add API key
        self.params = newParams
    }
    
    init(_ method: HTTPMethod, path: String) {
        self.init(method, path: path, params: nil)
    }
}

struct API {
    static let BaseURL = "https://api.edmunds.com/api/vehicle/v2/"
    static let Key = "ke2d4cv925rhhzgmkvmt755u"
    
    static func baseURL(_ path: String) -> String {
        return API.BaseURL + path
    }
    
    @discardableResult
    static func request(_ endpoint: Endpoint, completion: @escaping DefaultRequestCompletion, failure: @escaping RequestErrorCompletion) -> DataRequest {
        let url = baseURL(endpoint.rawValue.path)
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
                // TODO : Handle other errors
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
