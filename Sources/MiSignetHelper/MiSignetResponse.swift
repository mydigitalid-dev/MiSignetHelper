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

        for urlQueryItem in urlQueryItems {
            switch urlQueryItem.name {
            case "type":
                if let typeInt = Int(urlQueryItem.value!) {
                    type = MiSignetRequestType(rawValue: typeInt)
                }

            case "code":
                if let codeInt = Int(urlQueryItem.value!) {
                    code = MiSignetResponseCode(rawValue: codeInt)
                }

            case "state":
                if let stateInt = Int(urlQueryItem.value!) {
                    state = MiSignetState(rawValue: stateInt)
                }

            case "data":
                data = urlQueryItem.value

            default:
                break
            }
        }

        if let type = type, let code = code, let state = state {
            return MiSignetResponse(type: type, code: code, state: state, data: data)
        }
        else {
            return nil
        }
    }
}
