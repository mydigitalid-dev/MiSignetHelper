
# MiSignetHelper
MiSignetHelper for integrators

## Changes
Now in Swift Package Manager

Removed unused MiSignetHelper functions:
- sendAuthorizeRegistrationRequest
- sendExecuteRegistrationRequest
- sendAuthorizeStoreCertificateRequest
- sendExecuteStoreCertificateRequest
- sendAuthorizeFileSigning
- sendExecuteFileSigning
- sendAuthorizeHashSigning
- sendExecuteHashSigning
    
New debugMode() function for debug logging toggle.

Usage:
```swift
MiSignetHelper.debugMode(true)
```

New MiSignetValidationError enum and error closure now returns this. Usage:
```swift
MiSignetHelper.sendAuthorizeSubmitCertificateRequest(useProxy: false, errorHandler: { errorCode in
  print("🆘 Error requesting token 1 from MyDigitalID app. Error Code: \(errorCode)")
})
```

