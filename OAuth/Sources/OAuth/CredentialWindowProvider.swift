#if os(iOS)
import UIKit
#else
import Cocoa
#endif
import AuthenticationServices

public class CredentialWindowProvider: NSObject {
}

extension CredentialWindowProvider: WebAuthenticationSessionConfiguring {
    public func configureAuthenticationSession(_ session: ASWebAuthenticationSession) {
        session.prefersEphemeralWebBrowserSession = true
        session.presentationContextProvider = self
    }
}

extension CredentialWindowProvider: ASWebAuthenticationPresentationContextProviding {
    public func presentationAnchor(for session: ASWebAuthenticationSession) -> ASPresentationAnchor {
        #if os(iOS)
        #else
        return NSApp.keyWindow ?? NSApp.mainWindow ?? NSApp.orderedWindows.first!
        #endif
    }
}
