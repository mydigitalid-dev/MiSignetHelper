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
    private static let misignetPackageNameInfoName = "Mi-Signet Package Name"
    private static let misignetRequestURLSchemeInfoName = "Mi-Signet Request URL Scheme"
    private static let misignetResponseURLSchemeInfoName = "Mi-Signet Response URL Scheme"
    private static let misignetAppCertificateNameInfoName = "Mi-Signet App Certificate File Name"
    private static let misignetAppCertificateTypeInfoName = "Mi-Signet App Certificate File Type"
    private static let misignetEngineVersion = "1.0.0"
    private static let urlidentifier = "URL-identifier"
    private static var isDebug = false
    var miSignetResponse: MiSignetResponse?

    // Check if Mi-Signet is installed
    public static func isMiSignetInstalled() -> Bool {
        if let url = getRequestURL(nil) {
            return UIApplication.shared.canOpenURL(url)
        } else {
            return false
        }
    }
    
    public static func debugMode(_ debugFlag: Bool) {
        print("MiSignetHelper debug mode: \(debugFlag)")
        isDebug = debugFlag
    }
    
    // Send an authorization request for registration

    public static func sendAuthorizeRegistrationRequest(fullName: String, icNumber: String, errorHandler: @escaping () -> Void) {
        // print("sendAuthorizeRegistrationRequest MiSignetHelper")
        let parameters = ["fullname": fullName, "ic": icNumber]
        sendRequest(.authorizeRegistration, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for registration
    public static func sendExecuteRegistrationRequest(data: String, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data]
        sendRequest(.executeRegistration, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for storing certificate
    public static func sendAuthorizeStoreCertificateRequest(errorHandler: @escaping () -> Void) {
        sendRequest(.authorizeStoreCertificate, parameters: [:], errorHandler: errorHandler)
    }
    
    // Send an execution request for storing certificate
    public static func sendExecuteStoreCertificateRequest(data: String, userCert: String, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "usercert": userCert]
        sendRequest(.executeStoreCertificate, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for submitting certificate
    public static func sendAuthorizeSubmitCertificateRequest(useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["useproxy": String(useProxy)]
        sendRequest(.authorizeSubmitCertificate, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for submitting certificate
    public static func sendExecuteSubmitCertificateRequest(data: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "useproxy": String(useProxy)]
        sendRequest(.executeSubmitCertificate, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for file signing
    public static func sendAuthorizeFileSigning(fileName: String, mimeType: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["filename": fileName, "mimetype": mimeType, "filedata": fileData.base64EncodedString(), "useproxy": String(useProxy)]
        sendRequest(.authorizeFileSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for file signing
    public static func sendExecuteFileSigning(data: String, fileData: Data, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "filedata": fileData.base64EncodedString(), "useproxy": String(useProxy)]
        sendRequest(.executeFileSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an authorization request for hash signing
    public static func sendAuthorizeHashSigning(useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["useproxy": String(useProxy)]
        sendRequest(.authorizeHashSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send an execution request for hash signing
    public static func sendExecuteHashSigning(data: String, hashData: String, useProxy: Bool, errorHandler: @escaping () -> Void) {
        let parameters = ["data": data, "hash": hashData, "useproxy": String(useProxy)]
        sendRequest(.executeHashSigning, parameters: parameters, errorHandler: errorHandler)
    }
    
    // Send a request to view the certificate
    public static func viewCertificate(errorHandler: @escaping () -> Void) {
        sendRequest(.viewCertificate, parameters: [:], errorHandler: errorHandler)
    }
    
    // Send a request to retrieve the registration state of the Mi-Signet Client app
    public static func getState(errorHandler: @escaping () -> Void) {
        sendRequest(.getState, parameters: [:], errorHandler: errorHandler)
    }

    // Send a request to retrieve the version number of the engine
    public static func getEngineVersion(errorHandler: @escaping () -> Void) {
        sendRequest(.getEngineVersion, parameters: [:], errorHandler: errorHandler)
    }
    
    // Verify an URL response
    public static func verifyURL(_ url: URL, options: [UIApplication.OpenURLOptionsKey: Any]) -> MiSignetResponse? {
        var response: MiSignetResponse?
        let urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false)
        if let urlComponents = urlComponents {
            if urlComponents.scheme == getMiSignetResponseURLScheme() {
                if let queryItems = urlComponents.queryItems {
                    response = MiSignetResponse.fromURLQueryItems(queryItems)
                }
            }
        }
        return response
    }
    
    // Create an Mi-Signet request URL
    private static func sendRequest(_ type: MiSignetRequestType, parameters: [String: String], errorHandler: @escaping () -> Void) {
        // print("sendRequest(type: \(type), parameters: \(parameters), errorHandler: \(String(describing: errorHandler))")
        var url: URL?
        if let appCert = getMiSignetAppCert(), let requestURLScheme = getMiSignetRequestURLScheme(), let packageName = getMiSignetPackageName(), let responseURLScheme = getMiSignetResponseURLScheme(), let urlidentifier = getURLIdentifier() {
            // print("if let appCert = \(appCert), let requestURLScheme = \(requestURLScheme), let packageName = \(packageName), let responseURLScheme = \(responseURLScheme)")
            var queryItems: [URLQueryItem]?
            let typeItem = URLQueryItem(name: "type", value: String(type.rawValue))
            let appCertItem = URLQueryItem(name: "appcert", value: appCert)
            let urlSchemeItem = URLQueryItem(name: "scheme", value: responseURLScheme)
            let urlPackageName = URLQueryItem(name: "urlidentifier", value: urlidentifier)
            switch type {
            case .authorizeRegistration:
                // print(".authorizeRegistration")
                if let fullName = parameters["fullname"], let icNumber = parameters["ic"] {
                    // print("if let fullName = \(fullName), let icNumber = \(icNumber)")
                    let fullNameItem = URLQueryItem(name: "fullname", value: fullName)
                    let icNumberItem = URLQueryItem(name: "ic", value: icNumber)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, fullNameItem, icNumberItem, urlPackageName]
                }

            case .authorizeStoreCertificate:
                if let appName = getAppName() {
                    let appNameItem = URLQueryItem(name: "appname", value: appName)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, appNameItem, urlPackageName]
                }

            case .authorizeSubmitCertificate, .authorizeHashSigning:
                if let appName = getAppName(), let useProxy = parameters["useproxy"] {
                    let appNameItem = URLQueryItem(name: "appname", value: appName)
                    let useProxyItem = URLQueryItem(name: "useproxy", value: useProxy)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, appNameItem, useProxyItem, urlPackageName]
                }

            case .authorizeFileSigning:
                if let fileName = parameters["filename"], let fileData = parameters["filedata"], let mimeType = parameters["mimetype"], let appName = getAppName(), let useProxy = parameters["useproxy"] {
                    let fileNameItem = URLQueryItem(name: "filename", value: fileName)
                    let fileDataItem = URLQueryItem(name: "filedata", value: fileData)
                    let mimeTypeItem = URLQueryItem(name: "mimetype", value: mimeType)
                    let appNameItem = URLQueryItem(name: "appname", value: appName)
                    let useProxyItem = URLQueryItem(name: "useproxy", value: useProxy)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, fileNameItem, fileDataItem, mimeTypeItem, appNameItem, useProxyItem, urlPackageName]
                }

            case .executeRegistration:
                if let data = parameters["data"] {
                    let dataItem = URLQueryItem(name: "data", value: data)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, dataItem, urlPackageName]
                }

            case .executeStoreCertificate:
                if let data = parameters["data"], let userCert = parameters["usercert"] {
                    let dataItem = URLQueryItem(name: "data", value: data)
                    let userCertItem = URLQueryItem(name: "usercert", value: userCert)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, dataItem, userCertItem, urlPackageName]
                }

            case .executeSubmitCertificate:
                if let data = parameters["data"], let useProxy = parameters["useproxy"] {
                    let dataItem = URLQueryItem(name: "data", value: data)
                    let useProxyItem = URLQueryItem(name: "useproxy", value: useProxy)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, dataItem, useProxyItem, urlPackageName]
                }

            case .executeHashSigning:
                if let data = parameters["data"], let useProxy = parameters["useproxy"], let hashData = parameters["hash"] {
                    let dataItem = URLQueryItem(name: "data", value: data)
                    let useProxyItem = URLQueryItem(name: "useproxy", value: useProxy)
                    let hashItem = URLQueryItem(name: "hash", value: hashData)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, dataItem, useProxyItem, hashItem, urlPackageName]
                }

            case .executeFileSigning:
                if let data = parameters["data"], let useProxy = parameters["useproxy"], let fileData = parameters["filedata"] {
                    let dataItem = URLQueryItem(name: "data", value: data)
                    let useProxyItem = URLQueryItem(name: "useproxy", value: useProxy)
                    let fileDataItem = URLQueryItem(name: "filedata", value: fileData)
                    queryItems = [typeItem, appCertItem, urlSchemeItem, dataItem, useProxyItem, fileDataItem, urlPackageName]
                }

            case .viewCertificate, .getState, .getEngineVersion:
                queryItems = [typeItem, appCertItem, urlSchemeItem, urlPackageName]
            }
            if let queryItems = queryItems {
                // print("if let queryItems = \(queryItems)")
                var urlComponents = URLComponents()
                urlComponents.scheme = requestURLScheme
                urlComponents.host = packageName
                urlComponents.queryItems = queryItems
                url = urlComponents.url
            }
        }
        if let url = url {
            if isDebug { print("let url = \(url)") }
            DispatchQueue.main.async {
                UIApplication.shared.open(url, options: [:], completionHandler: nil)
            }
        } else {
            errorHandler()
        }
    }
    
    // Get the Mi-Signet request URL
    private static func getRequestURL(_ queryItems: [URLQueryItem]?) -> URL? {
        var url: URL?
        if let urlScheme = getMiSignetRequestURLScheme(), let packageName = getMiSignetPackageName() {
            var urlComponents = URLComponents()
            urlComponents.scheme = urlScheme
            urlComponents.host = packageName
            if let queryItems = queryItems {
                urlComponents.queryItems = queryItems
            }
            url = urlComponents.url
        }
        return url
    }
    
    // Get the name of the app
    private static func getAppName() -> String? {
        if let appName = Bundle.main.infoDictionary?["CFBundleDisplayName"] as? String {
            return appName
        } else if let appName = Bundle.main.infoDictionary?["CFBundleName"] as? String {
            return appName
        } else {
            return nil
        }
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
        var appCert: String?
        if let certName = getValueFromInfoList(misignetAppCertificateNameInfoName), let certType = getValueFromInfoList(misignetAppCertificateTypeInfoName), let filePath = Bundle.main.path(forResource: certName, ofType: certType) {
            let fileUrl = NSURL.fileURL(withPath: filePath)
            do {
                let data = try Data(contentsOf: fileUrl)
                appCert = String(data: data, encoding: .utf8)
            } catch {}
        }
        return appCert
    }
}
