# EveryAI iOS SDK — Binary Distribution

Prebuilt, **zero-dependency** XCFramework distribution of the EveryAI iOS SDK
(Swift / SwiftUI / Combine, **iOS 15+**). This repository ships only the
compiled `EveryAI.xcframework` and its Swift Package manifest — no source.

> Looking for the source / issues? That lives in the private `EveryAI-IOS`
> repository. Integrators only need this repository.

## Installation (Swift Package Manager)

In Xcode:

1. **File ▸ Add Package Dependencies…**
2. Paste the package URL:
   `https://github.com/V2-Technologies-LTD/EveryAI-IOS-Binary.git`
3. Set the version rule to **Up to Next Major Version**, starting from `1.0.0`.
4. Click **Add Package**, then add the **EveryAI** library to your app target.

Or in a `Package.swift`:

```swift
dependencies: [
    .package(url: "https://github.com/V2-Technologies-LTD/EveryAI-IOS-Binary.git", from: "1.0.0")
]
```

No third-party dependencies are pulled in, and no extra build settings are
required. (If you vendor the framework manually instead, drag
`EveryAI.xcframework` into your target's **Frameworks, Libraries, and Embedded
Content** and set it to **Embed & Sign**.)

## Permissions

The EveryAI chat lets users attach photos, files, and audio, and can save
generated images. Add these keys to your app's **Info.plist**:

| Key | Suggested value |
|-----|-----------------|
| `NSCameraUsageDescription` | Need access to camera for taking photos to upload |
| `NSPhotoLibraryUsageDescription` | Need photo library access to select photos for upload |
| `NSPhotoLibraryAddUsageDescription` | Need access to save generated images to your photo library |
| `NSMicrophoneUsageDescription` | Need access to microphone for recording audio |
| `NSDocumentsFolderUsageDescription` | Need access to your documents to allow file uploads in chat |

## Quick start

Token generation is **owned by your app** — the SDK ships no credentials and
never calls a token endpoint itself. Your app fetches the initial token at
launch and passes it in; whenever a request later gets a `403`, the SDK calls
back for a fresh token and automatically retries the failed request.

### 1. Conform to `EveryAITokenHandler`

The SDK calls `didReceiveTokenError()` whenever the bearer token is invalid or
expired (e.g. a `403`). Return a fresh token so operations continue.

```swift
import EveryAI

final class TokenGenerator: EveryAITokenHandler {
    // 403 callback: return a fresh token; the SDK retries the failed request.
    func didReceiveTokenError() async throws -> String {
        return try await fetchToken()
    }
    // Also used at launch to seed the initial token. Replace with your backend.
    func fetchToken() async throws -> String { "bearer_token_from_your_backend" }
}
```

### 2. Create an `EveryAIManager` and present the chat

Fetch a token first, then create the manager with it. The SDK works with both
SwiftUI and UIKit hosts.

**SwiftUI**

```swift
import SwiftUI
import EveryAI

struct ContentView: View {
    private let tokenHandler = TokenGenerator()
    @State private var manager: EveryAIManager?

    var body: some View {
        NavigationView {
            if let manager {
                NavigationLink("AI Chat") {
                    manager.view(.aiChat)
                }
            } else {
                ProgressView()
            }
        }
        .task {
            guard manager == nil,
                  let token = try? await tokenHandler.fetchToken() else { return }
            #if DEBUG
            manager = EveryAIManager(token: token, tokenHandler: tokenHandler, env: .dev)
            #else
            manager = EveryAIManager(token: token, tokenHandler: tokenHandler, env: .prod)
            #endif
        }
    }
}
```

**UIKit**

```swift
import UIKit
import EveryAI

final class ViewController: UIViewController {
    private let tokenHandler = TokenGenerator()
    private var manager: EveryAIManager?

    override func viewDidLoad() {
        super.viewDidLoad()
        Task {
            guard let token = try? await tokenHandler.fetchToken() else { return }
            manager = EveryAIManager(token: token, tokenHandler: tokenHandler, env: .dev)
        }
    }

    @IBAction func openChat(_ sender: Any) {
        guard let manager else { return }
        navigationController?.pushViewController(manager.hostingController(.aiChat), animated: true)
    }
}
```

> Present the chat inside a navigation stack (`NavigationView` / `UINavigationController`)
> so its in-screen back button can dismiss. To dismiss programmatically, call
> `manager.dismissView()`.

### 3. (Optional) Purchase callbacks

Conform to `EveryAISubscriptionPurchaseHandler` and register it to receive
in-app purchase information:

```swift
manager.setPaymentDelegate(self)

func didReceivePurchaseInfo(response: [String: String], viewType: EveryAIView) { … }
```

## Appearance & localization

- **Light / dark** — the chat ships an in-app light/dark toggle in the sidebar
  that overrides the host appearance and persists the choice (defaults to dark).
- **Language** — English and Bangla, with an in-app `EN / BN` switch.

## Versioning

Releases are tagged with semantic versions (`1.0.0`, …). Pin with
**Up to Next Major Version** from `1.0.0`.
