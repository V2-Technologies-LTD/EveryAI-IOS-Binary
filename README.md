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

### 1. Conform to `EveryAITokenHandler`

The SDK calls `didReceiveTokenError()` whenever the bearer token is invalid or
expired (e.g. a `403`). Return a fresh token so operations continue.

```swift
import EveryAI

final class TokenGenerator: EveryAITokenHandler {
    func didReceiveTokenError() async throws -> String {
        return try await requestNewToken()   // your token-refresh logic
    }
    private func requestNewToken() async throws -> String { "new_bearer_token" }
}
```

### 2. Create an `EveryAIManager` and present the chat

The SDK works with both SwiftUI and UIKit hosts.

**SwiftUI**

```swift
import SwiftUI
import EveryAI

struct ContentView: View {
    private let tokenHandler = TokenGenerator()
    private let manager: EveryAIManager

    init() {
        #if DEBUG
        manager = EveryAIManager(token: "", tokenHandler: tokenHandler, env: .dev)
        #else
        manager = EveryAIManager(token: "", tokenHandler: tokenHandler, env: .prod)
        #endif
    }

    var body: some View {
        NavigationView {
            NavigationLink("AI Chat") {
                manager.view(.aiChat)
            }
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
    private lazy var manager = EveryAIManager(token: "", tokenHandler: tokenHandler, env: .dev)

    @IBAction func openChat(_ sender: Any) {
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
