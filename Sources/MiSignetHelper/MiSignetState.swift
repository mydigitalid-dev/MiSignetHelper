//
//  MiSignetState.swift
//  MiSignetClient
//
//  Created by MIMOS Berhad on 05/08/2018.
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//
import Foundation

public enum MiSignetState : Int {
    case unregistered = 0
    case keypairGenerated = 1
    case registered = 2
}
