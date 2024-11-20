//
//  MiSignetResponse.swift
//  MiSignetClient
//
//  Created by MIMOS Berhad on 15/08/2018.
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//

import Foundation

public struct MiSignetResponse {
    public let type: MiSignetRequestType
    public let code: MiSignetResponseCode
    public let state: MiSignetState
    public let data: String?

    func asURLQueryItems() -> [URLQueryItem] {
        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "type", value: String(type.rawValue)),
            URLQueryItem(name: "code", value: String(code.rawValue)),
            URLQueryItem(name: "state", value: String(state.rawValue))
        ]
        
        if let data = data {
            queryItems.append(URLQueryItem(name: "data", value: data))
        }
        
        return queryItems
    }
    
    static func fromURLQueryItems(_ urlQueryItems: [URLQueryItem]) -> MiSignetResponse? {
        var type: MiSignetRequestType?
        var code: MiSignetResponseCode?
        var state: MiSignetState?
        var data: String?

        for item in urlQueryItems {
            switch item.name {
            case "type":
                if let typeInt = item.value.flatMap({ Int($0) }) {
                    type = MiSignetRequestType(rawValue: typeInt)
                }
            case "code":
                if let codeInt = item.value.flatMap({ Int($0) }) {
                    code = MiSignetResponseCode(rawValue: codeInt)
                }
            case "state":
                if let stateInt = item.value.flatMap({ Int($0) }) {
                    state = MiSignetState(rawValue: stateInt)
                }
            case "data":
                data = item.value
            default:
                break
            }
        }

        // Return the response only if all required properties are set
        guard let unwrappedType = type, let unwrappedCode = code, let unwrappedState = state else {
            return nil
        }

        return MiSignetResponse(type: unwrappedType, code: unwrappedCode, state: unwrappedState, data: data)
    }
}
