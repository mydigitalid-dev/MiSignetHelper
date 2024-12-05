//
//  MiSignetHelper.swift
//  MiSignetHelper
//
//  Created by MIMOS Berhad on 17/08/2018.
//  Copyright © 2018 MIMOS Berhad. All rights reserved.
//

import Foundation
import UIKit

public struct MiSignetHelper {
    private static var isDebug = false
    var miSignetResponse: MiSignetResponse?

    // Check if Mi-Signet is installed
    public static func isMiSignetInstalled() -> Bool {
        if let url = getRequestURL(nil) {
            return UIApplication.shared.canOpenURL(url)
        }
        else {
            return false
        }
    }

    public static func debugMode(_ debugFlag: Bool) {
        print("🆔 MiSignetHelper debug mode: \(debugFlag)")
        isDebug = debugFlag
    }

    // Send an authorization request for registration
    //    public static func sendAuthorizeRegistrationRequest(fullName: String, icNumber: String, errorHandler: @escaping () -> Void) {
    //        // print("sendAuthorizeRegistrationRequest MiSignetHelper")
    //        let parameters = ["fullname": fullName, "ic": icNumber]
    //        sendRequest(.authorizeRegistration, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send an execution request for registration
    //    public static func sendExecuteRegistrationRequest(data: String, errorHandler: @escaping () -> Void) {
    //        let parameters = ["data": data]
    //        sendRequest(.executeRegistration, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send an authorization request for storing certificate
    //    public static func sendAuthorizeStoreCertificateRequest(errorHandler: @escaping () -> Void) {
    //        sendRequest(.authorizeStoreCertificate, parameters: [:], errorHandler: errorHandler)
    //    }

    // Send an execution request for storing certificate
    //    public static func sendExecuteStoreCertificateRequest(data: String, userCert: String, errorHandler: @escaping () -> Void) {
    //        let parameters = ["data": data, "usercert": userCert]
    //        sendRequest(.executeStoreCertificate, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send an authorization request for submitting certificate
    public static func sendAuthorizeSubmitCertificateRequest(useProxy: Bool, errorHandler: @escaping (MiSignetValidationError) -> Void) {
        let parameters = ["useproxy": String(useProxy)]
        sendRequest(.authorizeSubmitCertificate, parameters: parameters, errorHandler: errorHandler)
    }

    // Send an execution request for submitting certificate
    public static func sendExecuteSubmitCertificateRequest(data: String, useProxy: Bool, errorHandler: @escaping (MiSignetValidationError) -> Void) {
        let parameters = ["data": data, "useproxy": String(useProxy)]
        sendRequest(.executeSubmitCertificate, parameters: parameters, errorHandler: errorHandler)
    }

    // Send an authorization request for file signing
    //    public static func sendAuthorizeFileSigning(fileName: String, mimeType: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
    //        let parameters = ["filename": fileName, "mimetype": mimeType, "filedata": fileData.base64EncodedString(), "useproxy": String(useProxy)]
    //        sendRequest(.authorizeFileSigning, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send an execution request for file signing
    //    public static func sendExecuteFileSigning(data: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
    //        let parameters = ["data": data, "filedata": fileData.base64EncodedString(), "useproxy": String(useProxy)]
    //        sendRequest(.executeFileSigning, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send an authorization request for hash signing
    //    public static func sendAuthorizeHashSigning(useProxy: Bool, errorHandler: @escaping () -> Void) {
    //        let parameters = ["useproxy": String(useProxy)]
    //        sendRequest(.authorizeHashSigning, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send an execution request for hash signing
    //    public static func sendExecuteHashSigning(data: String, hashData: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
    //        let parameters = ["data": data, "hash": hashData, "useproxy": String(useProxy)]
    //        sendRequest(.executeHashSigning, parameters: parameters, errorHandler: errorHandler)
    //    }

    // Send a request to view the certificate
    public static func viewCertificate(errorHandler: @escaping (MiSignetValidationError) -> Void) {
        sendRequest(.viewCertificate, parameters: [:], errorHandler: errorHandler)
    }

    // Send a request to retrieve the registration state of the Mi-Signet Client app
    public static func getState(errorHandler: @escaping (MiSignetValidationError) -> Void) {
        sendRequest(.getState, parameters: [:], errorHandler: errorHandler)
    }

    // Send a request to retrieve the version number of the engine
    public static func getEngineVersion(errorHandler: @escaping (MiSignetValidationError) -> Void) {
        sendRequest(.getEngineVersion, parameters: [:], errorHandler: errorHandler)
    }

    // Verify an URL response
    public static func verifyURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> MiSignetResponse? {
        guard let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false),
              urlComponents.scheme == getMiSignetResponseURLScheme(),
              let queryItems = urlComponents.queryItems else
        {
            return nil
        }

        return MiSignetResponse.fromURLQueryItems(queryItems)
    }
}

// MARK: - helper functions
extension MiSignetHelper {
    private static let misignetPackageNameInfoName = "Mi-Signet Package Name"
    private static let misignetRequestURLSchemeInfoName = "Mi-Signet Request URL Scheme"
    private static let misignetResponseURLSchemeInfoName = "Mi-Signet Response URL Scheme"
    private static let misignetAppCertificateNameInfoName = "Mi-Signet App Certificate File Name"
    private static let misignetAppCertificateTypeInfoName = "Mi-Signet App Certificate File Type"
    private static let misignetEngineVersion = "1.0.0"
    private static let urlidentifier = "URL-identifier"

    // Create an Mi-Signet request URL
    private static func sendRequest(_ type: MiSignetRequestType, parameters: [String: String], errorHandler: @escaping (MiSignetValidationError) -> Void) {
        print("🆔 sendRequest(type: \(type), parameters: \(parameters), errorHandler: \(String(describing: errorHandler))")

        // check cert is exist
        guard let appCert = getMiSignetAppCert() else {
            errorHandler(MiSignetValidationError.certNotFound)
            return
        }

        // Early guard to check plist parameters
        guard let requestURLScheme = getMiSignetRequestURLScheme(),
              let packageName = getMiSignetPackageName(),
              let responseURLScheme = getMiSignetResponseURLScheme(),
              let urlidentifier = getURLIdentifier() else
        {
            errorHandler(MiSignetValidationError.invalidPlist)
            return
        }

        print("🆔 if let appCert = \(appCert), let requestURLScheme = \(requestURLScheme), let packageName = \(packageName), let responseURLScheme = \(responseURLScheme)")

        var queryItems: [URLQueryItem] = [
            URLQueryItem(name: "type", value: String(type.rawValue)),
            URLQueryItem(name: "appcert", value: appCert),
            URLQueryItem(name: "scheme", value: responseURLScheme),
            URLQueryItem(name: "urlidentifier", value: urlidentifier)
        ]

        // Switch statement to append query items based on request type
        switch type {
        case .authorizeRegistration:
            if let fullName = parameters["fullname"], let icNumber = parameters["ic"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "fullname", value: fullName),
                    URLQueryItem(name: "ic", value: icNumber)
                ])
            }

        case .authorizeStoreCertificate:
            if let appName = getAppName() {
                queryItems.append(URLQueryItem(name: "appname", value: appName))
            }

        case .authorizeSubmitCertificate, .authorizeHashSigning:
            if let appName = getAppName(), let useProxy = parameters["useproxy"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "appname", value: appName),
                    URLQueryItem(name: "useproxy", value: useProxy)
                ])
            }

        case .authorizeFileSigning:
            if let fileName = parameters["filename"], let fileData = parameters["filedata"], let mimeType = parameters["mimetype"], let appName = getAppName(), let useProxy = parameters["useproxy"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "filename", value: fileName),
                    URLQueryItem(name: "filedata", value: fileData),
                    URLQueryItem(name: "mimetype", value: mimeType),
                    URLQueryItem(name: "appname", value: appName),
                    URLQueryItem(name: "useproxy", value: useProxy)
                ])
            }

        case .executeRegistration:
            if let data = parameters["data"] {
                queryItems.append(URLQueryItem(name: "data", value: data))
            }

        case .executeStoreCertificate:
            if let data = parameters["data"], let userCert = parameters["usercert"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "data", value: data),
                    URLQueryItem(name: "usercert", value: userCert)
                ])
            }

        case .executeSubmitCertificate:
            if let data = parameters["data"], let useProxy = parameters["useproxy"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "data", value: data),
                    URLQueryItem(name: "useproxy", value: useProxy)
                ])
            }

        case .executeHashSigning:
            if let data = parameters["data"], let useProxy = parameters["useproxy"], let hashData = parameters["hash"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "data", value: data),
                    URLQueryItem(name: "useproxy", value: useProxy),
                    URLQueryItem(name: "hash", value: hashData)
                ])
            }

        case .executeFileSigning:
            if let data = parameters["data"], let useProxy = parameters["useproxy"], let fileData = parameters["filedata"] {
                queryItems.append(contentsOf: [
                    URLQueryItem(name: "data", value: data),
                    URLQueryItem(name: "useproxy", value: useProxy),
                    URLQueryItem(name: "filedata", value: fileData)
                ])
            }

        case .viewCertificate, .getState, .getEngineVersion:
            // These don't need additional parameters, so we don't do anything here
            break
        }

        // Construct URL from query items manually
        var urlComponents = URLComponents()
        urlComponents.scheme = requestURLScheme
        urlComponents.host = packageName
        urlComponents.queryItems = queryItems

        if let url = urlComponents.url {
            if isDebug { print("🆔 let url = \(url)") }
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            errorHandler(MiSignetValidationError.unknownError)
        }
    }

    // Get the Mi-Signet request URL
    private static func getRequestURL(_ queryItems: [URLQueryItem]?) -> URL? {
        guard let urlScheme = getMiSignetRequestURLScheme(),
              let packageName = getMiSignetPackageName() else
        {
            return nil
        }

        var urlComponents = URLComponents()
        urlComponents.scheme = urlScheme
        urlComponents.host = packageName
        urlComponents.queryItems = queryItems

        return urlComponents.url
    }

    // Get the name of the app
    private static func getAppName() -> String? {
        return Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String ??
            Bundle.main.infoDictionary?["CFBundleName"] as? String
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
        guard let value = Bundle.main.infoDictionary?[name] as? String,
                !value.trimmingCharacters(in: .whitespaces).isEmpty else {
            return nil
        }
        return value
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
        guard let certName = getValueFromInfoList(misignetAppCertificateNameInfoName),
              let certType = getValueFromInfoList(misignetAppCertificateTypeInfoName),
              let filePath = Bundle.main.path(forResource: certName, ofType: certType) else
        {
            return nil
        }

        let fileUrl = NSURL.fileURL(withPath: filePath)

        do {
            let data = try Data(contentsOf: fileUrl)
            return String(data: data, encoding: .utf8)
        } catch {
            return nil
        }
    }
}
