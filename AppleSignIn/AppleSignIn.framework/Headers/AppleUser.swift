// Copyright (c) 2019 Anton Vizgin

// Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

// The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

import Foundation
import AuthenticationServices

public class AppleUser {
    
    public var id: String
    public var authorizationCode: String
    public var identityToken: String
    public var firstName: String
    public var lastName: String
    public var fullName: String {
         return firstName + " " + lastName
    }
    public var email: String
    
    init(_ credentials: ASAuthorizationAppleIDCredential) {
        
        self.id = credentials.user
        self.firstName = credentials.fullName?.givenName ?? ""
        self.lastName = credentials.fullName?.familyName ?? ""
        self.email = credentials.email ?? ""
        
        if let token = credentials.identityToken {
            self.identityToken = String(data: token, encoding: .utf8) ?? ""
        } else {
            self.identityToken = ""
        }
        if let code = credentials.authorizationCode {
            self.authorizationCode = String(data: code, encoding: .utf8) ?? ""
        } else {
            self.authorizationCode = ""
        }
    }
    
    public func toString() -> String {
        return "id: \(id) email: \(email) lastName: \(lastName) firstName: \(firstName) authorizationCode: \(authorizationCode) identityToken: \(String(describing: identityToken))"
    }
    
}
