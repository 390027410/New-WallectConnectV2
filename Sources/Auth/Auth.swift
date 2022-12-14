import Foundation
import WalletConnectRelay
import Combine

/// Auth instatnce wrapper
///
/// ```Swift
/// let metadata = AppMetadata(
///         name: "Swift wallet",
///         description: "wallet",
///         url: "wallet.connect",
///         icons:  ["https://my_icon.com/1"])
/// Auth.configure(metadata: metadata, account: account)
/// try await Auth.instance.pair(uri: uri)
/// ```
public class Auth {

    /// Auth client instance
    public static var instance: AuthClient = {
        guard let config = Auth.config else {
            fatalError("Error - you must call Auth.configure(_:) before accessing the shared instance.")
        }
        return AuthClientFactory.create(
            metadata: config.metadata,
            account: config.account,
            relayClient: Relay.instance)
    }()

    private static var config: Config?

    private init() { }

    /// Auth instance config method
    /// - Parameters:
    ///   - metadata: App metadata
    ///   - account: account that wallet will be authenticating with. Should be nil for non wallet clients.
    static public func configure(metadata: AppMetadata, account: Account?) {
        Auth.config = Auth.Config(
            metadata: metadata,
            account: account)
    }
}
