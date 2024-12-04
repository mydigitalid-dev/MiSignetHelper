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
        let typeItem = URLQueryItem(name: "type", value: String(type.rawValue))
        let codeItem = URLQueryItem(name: "code", value: String(code.rawValue))
        let stateItem = URLQueryItem(name: "state", value: String(state.rawValue))
        if let data = data {
            let dataItem = URLQueryItem(name: "data", value: data)
            return [typeItem, codeItem, stateItem, dataItem]
        } else {
            return [typeItem, codeItem, stateItem]
        }
    }

    static func fromURLQueryItems(_ urlQueryItems: [URLQueryItem]) -> MiSignetResponse? {
        var type: MiSignetRequestType?
        var code: MiSignetResponseCode?
        var state: MiSignetState?
        var data: String?
        for urlQueryItem in urlQueryItems {
            if urlQueryItem.name == "type" {
                if let typeInt = Int(urlQueryItem.value!) {
                    type = MiSignetRequestType(rawValue: typeInt)
                }
            } else if urlQueryItem.name == "code" {
                if let codeInt = Int(urlQueryItem.value!) {
                    code = MiSignetResponseCode(rawValue: codeInt)
                }
            } else if urlQueryItem.name == "state" {
                if let stateInt = Int(urlQueryItem.value!) {
                    state = MiSignetState(rawValue: stateInt)
                }
            } else if urlQueryItem.name == "data" {
                data = urlQueryItem.value
            }
        }
        if let type = type, let code = code, let state = state {
            return MiSignetResponse(type: type, code: code, state: state, data: data)
        } else {
            return nil
        }
    }
}
