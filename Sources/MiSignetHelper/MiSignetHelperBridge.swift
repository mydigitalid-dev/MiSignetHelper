//
//  MiSignetHelperBridge.swift
//  SignetHelperTest
//
//  Created by MIMOS Berhad on 05/09/2018.
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//

import Foundation
import UIKit

@objc(MiSignetResponse)
final class ObjC_MiSignetResponse: NSObject {
    private var miSignetResponse: MiSignetResponse?
    
    init(response: MiSignetResponse) {
        self.miSignetResponse = response
    }
    
    var type: Int {
        return self.miSignetResponse!.type.rawValue
    }
    
    var code: Int {
        return self.miSignetResponse!.code.rawValue
    }
    
    var state: Int {
        return self.miSignetResponse!.state.rawValue
    }
    
    var data: String? {
        return self.miSignetResponse!.data
    }
}

@objc(MiSignetHelper)
final class ObjC_MiSignetHelper: NSObject {
    // Check if Mi-Signet is installed
    @MainActor
    static func isMiSignetInstalled() -> Bool {
        return MiSignetHelper.isMiSignetInstalled()
    }
    
    // Send an authorization request for registration
    
    static func sendAuthorizeRegistrationRequest(fullName: String, icNumber: String, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendAuthorizeRegistrationRequest(fullName: fullName, icNumber: icNumber, errorHandler: errorHandler)
    }
    
    // Send an execution request for registration
    static func sendExecuteRegistrationRequest(data: String, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendExecuteRegistrationRequest(data: data, errorHandler: errorHandler)
    }
    
    // Send an authorization request for storing certificate
    static func sendAuthorizeStoreCertificateRequest(errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendAuthorizeStoreCertificateRequest(errorHandler: errorHandler)
    }
    
    // Send an execution request for storing certificate
    static func sendExecuteStoreCertificateRequest(data: String, userCert: String, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendExecuteStoreCertificateRequest(data: data, userCert: userCert, errorHandler: errorHandler)
    }
    
    // Send an authorization request for submitting certificate
    static func sendAuthorizeSubmitCertificateRequest(useProxy: Bool, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendAuthorizeSubmitCertificateRequest(useProxy: useProxy, errorHandler: errorHandler)
    }
    
    // Send an execution request for submitting certificate
    static func sendExecuteSubmitCertificateRequest(data: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendExecuteSubmitCertificateRequest(data: data, useProxy: useProxy, errorHandler: errorHandler)
    }
    
    // Send an authorization request for file signing
    static func sendAuthorizeFileSigning(fileName: String, mimeType: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendAuthorizeFileSigning(fileName: fileName, mimeType: mimeType, fileData: fileData, useProxy: useProxy, errorHandler: errorHandler)
    }
    
    // Send an execution request for file signing
    static func sendExecuteFileSigning(data: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendExecuteFileSigning(data: data, fileData: fileData, useProxy: useProxy, errorHandler: errorHandler)
    }
    
    // Send an authorization request for hash signing
    static func sendAuthorizeHashSigning(useProxy: Bool, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendAuthorizeHashSigning(useProxy: useProxy, errorHandler: errorHandler)
    }
    
    // Send an execution request for hash signing
    static func sendExecuteHashSigning(data: String, hashData: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
        MiSignetHelper.sendExecuteHashSigning(data: data, hashData: hashData, useProxy: useProxy, errorHandler: errorHandler)
    }
    
    // Send a request to view the certificate
    static func viewCertificate(errorHandler: @escaping () -> Void) {
        MiSignetHelper.viewCertificate(errorHandler: errorHandler)
    }
    
    // Send a request to retrieve the registration state of the Mi-Signet Client app
    static func getState(errorHandler: @escaping () -> Void) {
        MiSignetHelper.getState(errorHandler: errorHandler)
    }
    
    // send the request to retrive engine version
    static func getEngineVersion(versionNumber: String, errorHandler: @escaping () -> Void) {
        MiSignetHelper.getEngineVersion(errorHandler: errorHandler)
    }
    
    // Verify an URL response
    static func verifyURL(_ url: URL, packageName: String, options: [UIApplication.OpenURLOptionsKey: Any]) -> ObjC_MiSignetResponse? {
        guard let response = MiSignetHelper.verifyURL(url, packageName: packageName, options: options) else {
            return nil
        }
        
        return ObjC_MiSignetResponse(response: response)
    }
}
