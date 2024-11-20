//
//  MiSignetResponseCode.swift
//  MiSignetClient
//
//  Created by MIMOS Berhad on 16/08/2018.
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//

import Foundation

public enum MiSignetResponseCode : Int {
    case ok = 1
    case invalidDataFormatError = 401
    case invalidRequestInformationError = 402
    case unauthorizedApplicationError = 403
    case permissionDeniedByUserError = 404
    case rscNotMatchError = 406
    case base64URLDecodingError = 407
    case pkiGenerationError = 408
    case csrGenerationError = 409
    case signatureGenerationError = 410
    case trustedCertificateChainNotFoundError = 411
    case invalidCertificateError = 412
    case signatureExpiredError = 413
    case invalidSignatureError = 414
    case certificateExpiredError = 415
    case invalidCertificateChainError = 416
    case invalidJWSFormatError = 417
    case sensorDataError = 418
    case jwsSignatureGenerationError = 420
    case publicKeyNotMatchError = 422
    case appNotInKeyGeneratedStateError = 424
    case appNotInRegisteredStateError = 425
    case actionDeniedByUserError = 426
    case encryptionError = 427
    case nameNotMatchError = 428
    case appAlreadyRegisteredError = 429
    case signatureVerifiedWithoutTrustedCertificateChainError = 430
}
