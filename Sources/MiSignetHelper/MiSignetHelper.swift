//
//  MiSignetHelper.swift
//  MiSignetHelper
//
//  Created by MIMOS Berhad on 17/08/2018.
//  Refactored by Adiman to MiSignetHelper Package on 20/11/2024
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//

import Foundation
import UIKit

struct MiSignetHelper {
    private static let misignetPackageNameInfoName = "Mi-Signet Package Name"
    private static let misignetRequestURLSchemeInfoName = "Mi-Signet Request URL Scheme"
    private static let misignetResponseURLSchemeInfoName = "Mi-Signet Response URL Scheme"
    private static let misignetAppCertificateNameInfoName = "Mi-Signet App Certificate File Name"
    private static let misignetAppCertificateTypeInfoName = "Mi-Signet App Certificate File Type"
    private static let misignetEngineVersion = "1.0.0"
    private static let urlidentifier = "URL-identifier"
    var miSignetResponse: MiSignetResponse?

    // Check if Mi-Signet is installed
    @MainActor
    static func isMiSignetInstalled() -> Bool {
        if let url = getRequestURL(nil) {
            return UIApplication.shared.canOpenURL(url)
        } else {
            return false
        }
    }
    
    // Send an authorization request for registration
    static func sendAuthorizeRegistrationRequest(fullName: String, icNumber: String, errorHandler: @escaping () -> Void) {
        let parameters = ["fullname": fullName, "ic": icNumber]
        sendRequest(.authorizeRegistration, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for registration
    static func sendExecuteRegistrationRequest(data: String, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data]
        sendRequest(.executeRegistration, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for storing certificate
    static func sendAuthorizeStoreCertificateRequest(errorHandler: @escaping () -> Void) {
        sendRequest(.authorizeStoreCertificate, parameters: [:], errorHandler: errorHandler)
    }
    
    // Send an execution request for storing certificate
    static func sendExecuteStoreCertificateRequest(data: String, userCert: String, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "usercert": userCert]
        sendRequest(.executeStoreCertificate, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for submitting certificate
    static func sendAuthorizeSubmitCertificateRequest(useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["useproxy": String(useProxy)]
        sendRequest(.authorizeSubmitCertificate, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for submitting certificate
    static func sendExecuteSubmitCertificateRequest(data: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "useproxy": String(useProxy)]
        sendRequest(.executeSubmitCertificate, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for file signing
    static func sendAuthorizeFileSigning(fileName: String, mimeType: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["filename": fileName, "mimetype": mimeType, "filedata": fileData.base64EncodedString(), "useproxy": String(useProxy)]
        sendRequest(.authorizeFileSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for file signing
    static func sendExecuteFileSigning(data: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "filedata": fileData.base64EncodedString(), "useproxy": String(useProxy)]
        sendRequest(.executeFileSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for hash signing
    static func sendAuthorizeHashSigning(useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["useproxy": String(useProxy)]
        sendRequest(.authorizeHashSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for hash signing
    static func sendExecuteHashSigning(data: String, hashData: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "hash": hashData, "useproxy": String(useProxy)]
        sendRequest(.executeHashSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send a request to view the certificate
    static func viewCertificate(errorHandler: @escaping () -> Void) {
        sendRequest(.viewCertificate, parameters: [:], errorHandler: errorHandler)
    }
    
    // Send a request to retrieve the registration state of the Mi-Signet Client app
    static func getState(errorHandler: @escaping () -> Void) {
        sendRequest(.getState, parameters: [:], errorHandler: errorHandler)
    }
    
    // Send a request to retrieve the version number of the engine
    static func getEngineVersion(errorHandler: @escaping () -> Void) {
        sendRequest(.getEngineVersion, parameters: [:], errorHandler: errorHandler)
    }
    
    // Verify an URL response
    public static func verifyURL(_ url: URL, packageName: String, options: [UIApplication.OpenURLOptionsKey: Any]) -> MiSignetResponse? {
        // Extract URL components
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              let scheme = urlComponents.scheme else {
            return nil
        }

        // Ensure the URL scheme matches the expected scheme
        guard scheme == getMiSignetResponseURLScheme() else {
            return nil
        }

        // Process query items if present
        if let queryItems = urlComponents.queryItems {
            return MiSignetResponse.fromURLQueryItems(queryItems)
        }
        
        return nil
    }

    
    // MARK: - private functions
    // Create an Mi-Signet request URL
    private static func sendRequest(_ type: MiSignetRequestType, parameters: [String: String], errorHandler: @escaping () -> Void) {
        // Extract required information
        guard let appCert = getMiSignetAppCert(),
              let requestURLScheme = getMiSignetRequestURLScheme(),
              let packageName = getMiSignetPackageName(),
              let responseURLScheme = getMiSignetResponseURLScheme(),
              let urlIdentifier = getURLIdentifier() else {
            errorHandler()
            return
        }
        
        // Initialize the base query items
        let typeItem = URLQueryItem(name: "type", value: String(type.rawValue))
        let appCertItem = URLQueryItem(name: "appcert", value: appCert)
        let urlSchemeItem = URLQueryItem(name: "scheme", value: responseURLScheme)
        let urlPackageNameItem = URLQueryItem(name: "urlidentifier", value: urlIdentifier)

        // Prepare query items based on the request type
        var queryItems: [URLQueryItem] = [typeItem, appCertItem, urlSchemeItem, urlPackageNameItem]
        
        switch type {
        case .authorizeRegistration:
            addAuthorizeRegistrationItems(to: &queryItems, parameters: parameters)
        case .authorizeStoreCertificate:
            addAuthorizeStoreCertificateItems(to: &queryItems)
        case .authorizeSubmitCertificate, .authorizeHashSigning:
            addAuthorizeSubmitCertificateItems(to: &queryItems, parameters: parameters)
        case .authorizeFileSigning:
            addAuthorizeFileSigningItems(to: &queryItems, parameters: parameters)
        case .executeRegistration:
            addExecuteRegistrationItems(to: &queryItems, parameters: parameters)
        case .executeStoreCertificate:
            addExecuteStoreCertificateItems(to: &queryItems, parameters: parameters)
        case .executeSubmitCertificate:
            addExecuteSubmitCertificateItems(to: &queryItems, parameters: parameters)
        case .executeHashSigning:
            addExecuteHashSigningItems(to: &queryItems, parameters: parameters)
        case .executeFileSigning:
            addExecuteFileSigningItems(to: &queryItems, parameters: parameters)
        case .viewCertificate, .getState, .getEngineVersion:
            break
        case .callMyDigitalId:
            addCallMyDigitalIdItems(to: &queryItems, parameters: parameters)
        }
        
        // Construct the URL
        if let url = buildURL(with: queryItems, scheme: requestURLScheme, host: packageName) {
            openURLIfNeeded(url: url, type: type)
        }
    }

    // Helper methods to add query items for specific request types

    private static func addAuthorizeRegistrationItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let fullName = parameters["fullname"], let icNumber = parameters["ic"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "fullname", value: fullName),
                URLQueryItem(name: "ic", value: icNumber)
            ])
        }
    }

    private static func addAuthorizeStoreCertificateItems(to queryItems: inout [URLQueryItem]) {
        if let appName = getAppName() {
            queryItems.append(URLQueryItem(name: "appname", value: appName))
        }
    }

    private static func addAuthorizeSubmitCertificateItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let appName = getAppName(), let useProxy = parameters["useproxy"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "appname", value: appName),
                URLQueryItem(name: "useproxy", value: useProxy)
            ])
        }
    }

    private static func addAuthorizeFileSigningItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let fileName = parameters["filename"], let fileData = parameters["filedata"], let mimeType = parameters["mimetype"], let appName = getAppName(), let useProxy = parameters["useproxy"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "filename", value: fileName),
                URLQueryItem(name: "filedata", value: fileData),
                URLQueryItem(name: "mimetype", value: mimeType),
                URLQueryItem(name: "appname", value: appName),
                URLQueryItem(name: "useproxy", value: useProxy)
            ])
        }
    }

    private static func addExecuteRegistrationItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let data = parameters["data"] {
            queryItems.append(URLQueryItem(name: "data", value: data))
        }
    }

    private static func addExecuteStoreCertificateItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let data = parameters["data"], let userCert = parameters["usercert"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "data", value: data),
                URLQueryItem(name: "usercert", value: userCert)
            ])
        }
    }

    private static func addExecuteSubmitCertificateItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let data = parameters["data"], let useProxy = parameters["useproxy"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "data", value: data),
                URLQueryItem(name: "useproxy", value: useProxy)
            ])
        }
    }

    private static func addExecuteHashSigningItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let data = parameters["data"], let useProxy = parameters["useproxy"], let hashData = parameters["hash"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "data", value: data),
                URLQueryItem(name: "useproxy", value: useProxy),
                URLQueryItem(name: "hash", value: hashData)
            ])
        }
    }

    private static func addExecuteFileSigningItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let data = parameters["data"], let useProxy = parameters["useproxy"], let fileData = parameters["filedata"] {
            queryItems.append(contentsOf: [
                URLQueryItem(name: "data", value: data),
                URLQueryItem(name: "useproxy", value: useProxy),
                URLQueryItem(name: "filedata", value: fileData)
            ])
        }
    }

    private static func addCallMyDigitalIdItems(to queryItems: inout [URLQueryItem], parameters: [String: String]) {
        if let data = parameters["data"] {
            queryItems.append(URLQueryItem(name: "data", value: data))
        }
    }

    // Helper method to build the URL
    private static func buildURL(with queryItems: [URLQueryItem], scheme: String, host: String) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = host
        urlComponents.queryItems = queryItems
        return urlComponents.url
    }

    // Helper method to open the URL if needed
    private static func openURLIfNeeded(url: URL, type: MiSignetRequestType) {
        // Check if the URL should be opened for the given request type
        let shouldOpenURL: Bool
        switch type {
        case .authorizeRegistration, .executeRegistration, .authorizeSubmitCertificate, .executeSubmitCertificate, .authorizeStoreCertificate, .executeStoreCertificate, .viewCertificate, .getState, .authorizeHashSigning, .executeHashSigning:
            shouldOpenURL = true
        default:
            shouldOpenURL = false
        }

        if shouldOpenURL {
            if #available(iOS 10.0, *) {
                DispatchQueue.main.async {
                    UIApplication.shared.open(url, options: [:], completionHandler: nil)
                }
            }
        }
    }

    
    // Get the Mi-Signet request URL
    private static func getRequestURL(_ queryItems: [URLQueryItem]?) -> URL? {
        // Get the URL scheme and package name
        guard let urlScheme = getMiSignetRequestURLScheme(),
              let packageName = getMiSignetPackageName() else {
            return nil
        }

        // Create URLComponents and assign values
        var urlComponents = URLComponents()
        urlComponents.scheme = urlScheme
        urlComponents.host = packageName
        urlComponents.queryItems = queryItems

        return urlComponents.url
    }

    
    // Get the name of the app
    private static func getAppName() -> String? {
        // Try to retrieve the app name from CFBundleDisplayName or CFDisplayName
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String
            ?? Bundle.main.infoDictionary?["CFDisplayName"] as? String
    }

    // Create the request URL
    private static func createResponseURL(scheme: String, packageName: String, response: MiSignetResponse) -> URL? {
        var urlComponents = URLComponents()
        urlComponents.scheme = scheme
        urlComponents.host = packageName
        urlComponents.queryItems = response.asURLQueryItems()
        
        return urlComponents.url
    }
    
    // Return a property value
    private static func getValueFromInfoList(_ name: String) -> String? {
        return Bundle.main.infoDictionary?[name] as? String
    }
    
    // get version number
    private static func getEngineNumber() -> String? {
        return getValueFromInfoList(misignetEngineVersion)
    }
    
    // Get the package name of Mi-Signet
    private static func getMiSignetPackageName() -> String? {
        return getValueFromInfoList(misignetPackageNameInfoName)
    }

    // Get the URL scheme to send a request to Mi-Signet
    private static func getMiSignetRequestURLScheme() -> String? {
        return getValueFromInfoList(misignetRequestURLSchemeInfoName)
    }
    
    // Get the URL scheme for Mi-Signet to return the response
    private static func getMiSignetResponseURLScheme() -> String? {
        return getValueFromInfoList(misignetResponseURLSchemeInfoName)
    }
    
    // Get the URL Identifier as a Package Name
    private static func getURLIdentifier() -> String? {
        return getValueFromInfoList(urlidentifier)
    }

    // Get the app certificate if exists
    private static func getMiSignetAppCert() -> String? {
        // Retrieve the certificate name and type from info list
        guard let certName = getValueFromInfoList(misignetAppCertificateNameInfoName),
              let certType = getValueFromInfoList(misignetAppCertificateTypeInfoName) else {
            return nil
        }

        // Construct the file path and ensure it exists
        guard let filePath = Bundle.main.path(forResource: certName, ofType: certType) else {
            return nil
        }
        
        let fileUrl = URL(fileURLWithPath: filePath)
        
        // Attempt to load the file's content and convert it to a string
        do {
            let data = try Data(contentsOf: fileUrl)
            return String(data: data, encoding: .utf8)
        } catch {
            // Handle the error if needed (e.g., log it)
            return nil
        }
    }
}
