//
//  MiSignetRequestType.swift
//  MiSignetClient
//
//  Created by MIMOS Berhad on 07/08/2018.
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//

import Foundation

public enum MiSignetRequestType: Int {
    case authorizeRegistration = 0
    case executeRegistration = 1
    case authorizeStoreCertificate = 2
    case executeStoreCertificate = 3
    case authorizeSubmitCertificate = 4
    case executeSubmitCertificate = 5
    case authorizeFileSigning = 6
    case executeFileSigning = 7
    case authorizeHashSigning = 8
    case executeHashSigning = 9
    case viewCertificate = 101
    case getState = 102
    case getEngineVersion = 103
}
