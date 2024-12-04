import Foundation
@testable import MiSignetHelper
import Testing

@MainActor
@Test("This will always return false as fresh simulator does not pre installed with signet clinet")
func testIsMiSignetInstalled_not_installed() {
    #expect(MiSignetHelper.isMiSignetInstalled() == false)
}

@Suite("display name")
struct signetRequestTest {
    var mockErrorHandler: () -> Void
    var mockFullName: String!
    var mockIcNumber: String!

    init() {
        // Swizzle infoDictionary before each test
        Bundle.swizzleInfoDictionaryMethod()

        mockFullName = "John Doe"
        mockIcNumber = "123456789"
        mockErrorHandler = { print("Error occurred") }
    }

    @Test func testSendAuthorizeRegistrationRequest_Success() async throws {
        let infoDict = Bundle.main.infoDictionary
        let mockSendRequest: (MiSignetRequestType, [String: String], @escaping () -> Void) -> Void = { miSignetRequestType, parameters, errorHandler in
            #expect(miSignetRequestType == .authorizeRegistration)
            #expect(parameters["fullname"] == self.mockFullName)
            #expect(parameters["ic"] == self.mockIcNumber)
            #expect(errorHandler == nil)
        }

        //#expect(Bundle.misignetPackageNameInfoName == "Mi-Signet Package Name")
        // TODO: Override the actual sendRequest function with the mock
        // unable to do tests as the request will check for physical cert and cannot be mocked. 
        // MiSignetHelper.sendRequest = mockSendRequest

        // Call the method under test
        MiSignetHelper.sendAuthorizeRegistrationRequest(fullName: mockFullName, icNumber: mockIcNumber, errorHandler: mockErrorHandler)
    }
}

private extension Bundle {
    static let misignetPackageNameInfoName = "Mi-Signet Package Name"
    static let misignetRequestURLSchemeInfoName = "Mi-Signet Request URL Scheme"
    static let misignetResponseURLSchemeInfoName = "Mi-Signet Response URL Scheme"
    static let misignetAppCertificateNameInfoName = "Mi-Signet App Certificate File Name"
    static let misignetAppCertificateTypeInfoName = "Mi-Signet App Certificate File Type"
    static let misignetEngineVersion = "1.0.0"
    static let urlidentifier = "URL-identifier"
    
    private static let swizzleInfoDictionary: Void = {
        let originalSelector = #selector(getter: Bundle.infoDictionary)
        let swizzledSelector = #selector(getter: Bundle.mock_infoDictionary)

        let originalMethod = class_getInstanceMethod(Bundle.self, originalSelector)
        let swizzledMethod = class_getInstanceMethod(Bundle.self, swizzledSelector)

        if let originalMethod = originalMethod, let swizzledMethod = swizzledMethod {
            method_exchangeImplementations(originalMethod, swizzledMethod)
        }
    }()

    @objc var mock_infoDictionary: [String: Any]? {
        return [
            Bundle.misignetPackageNameInfoName: "MockPackageName",
            Bundle.misignetRequestURLSchemeInfoName: "MockRequestURLScheme",
            Bundle.misignetResponseURLSchemeInfoName: "MockResponseURLScheme",
            Bundle.misignetAppCertificateNameInfoName: "MockAppCertificateName",
            Bundle.misignetAppCertificateTypeInfoName: "MockAppCertificateType",
            Bundle.misignetEngineVersion: "1.0.0",
            Bundle.urlidentifier: "MockURL",
            "CFBundleDisplayName": "MockAppName",
            "CFDisplayName": "MockCFDisplayName"
        ]
    }

    static func swizzleInfoDictionaryMethod() {
        _ = swizzleInfoDictionary
    }
}
