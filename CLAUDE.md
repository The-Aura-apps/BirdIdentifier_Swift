# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project overview

BirdId is a SwiftUI iOS app for identifying birds from photos/audio and browsing bird info (habitats, articles, history). No backend code lives in this repo — it talks to a remote REST API at `https://bird.auraapps.org` (see `BirdId/Helpers/Constants/Constants.swift`) and to RevenueCat for subscriptions.

## Build & test commands

Build for the simulator (no code signing):
```bash
xcodebuild -project BirdId.xcodeproj -scheme BirdId -destination 'generic/platform=iOS Simulator' build CODE_SIGNING_ALLOWED=NO
```

List schemes/targets/resolved SPM package versions:
```bash
xcodebuild -list -project BirdId.xcodeproj
```

Run tests (Swift Testing framework, not XCTest — uses `@Test` / `#expect`):
```bash
xcodebuild test -project BirdId.xcodeproj -scheme BirdId -destination 'platform=iOS Simulator,name=<simulator name>'
```
There is no CLI test runner shortcut configured yet; `BirdIdTests/BirdIdTests.swift` is currently a placeholder. There's also a `BirdIdUITests` target.

Simulator management: `xcrun simctl ...` (pre-approved in `.claude/settings.local.json`).

There is no Podfile or Package.swift — dependencies are Swift Package Manager references resolved directly inside the `.xcodeproj` (Alamofire, RevenueCat/RevenueCatUI, Kingfisher, Lottie, KeychainAccess). Don't add a Podfile/CocoaPods.

## Architecture

**Pattern:** MVVM + a single centralized `Coordinator` for navigation, all under `BirdId/Core/`.

- **`Core/Screens/<Feature>/`** — each feature has a `View` (`XScreen.swift`), an `ObservableObject` `XViewModel.swift`, and sometimes a `<Feature>SubViews/` folder for private child views. Follow this triplet when adding a new screen.
- **`Core/Repositories/`** — one repository per feature/API resource (e.g. `BirdDetailRepository`, `HabitatsRepository`, `HistoryRepository`, `ArticleRepository`, `UploadRepository`, `BirdSearchRepository`, `DeviceSettingsRepository`). Each repository is defined behind a `XRepositoryProtocol` and takes `apiService: ApiServiceProtocol = ApiService()` as an injectable default, and each ships a `MockXRepository` alongside the real implementation for previews/tests. ViewModels depend on the protocol, not the concrete type, and default-inject the concrete repository the same way.
- **`Core/InternetServices/ApiService.swift`** — single networking layer, Combine-based (`AnyPublisher<T, Error>`), built on `URLSession` for JSON requests and Alamofire for multipart uploads. Errors funnel through the `APIError` enum (`httpError`, `decodingError`, `networkError`, `unknownError`). New network calls go through `ApiServiceProtocol.request`/`multipartRequest`, not raw `URLSession`/`AF` calls in repositories.
- **`Helpers/Coordinator/Coordinator.swift`** — app-wide `ObservableObject` holding a `NavigationStack` path (`[Route]`). `Route` is a hashable enum listing every push destination (`birdDetail`, `ResultScreen`, `IdentifyScreen`, `HabitatScreen`, `ArticleScreen`); `Coordinator.buildView(for:)` is the single place mapping a route to its view. New navigable screens must add a `Route` case + a branch in `buildView`. Screens navigate via `@EnvironmentObject var coordinator: Coordinator` and `coordinator.push(...)`.
- **`Helpers/TabManager/TabManager.swift`** — separate `ObservableObject` owning the selected bottom tab (`TabBarItem`); `MainScreen.swift` switches on `tabManager.selectedTab` to render `HomeScreen` / `IdentifyScreen` / `HistoryScreen` / `SettingView`, all sharing the one `Coordinator` navigation stack.
- **App entry (`BirdIdApp.swift`)**: shows `SplashScreen` first, then either `OnboardingScreen` (first launch, gated by `@AppStorage("hasSeenOnboarding")`) or `MainScreen`. `SubscriptionManager.shared` is touched in `init()` purely to trigger RevenueCat configuration at launch.
- **`Helpers/SubscriptionManager/SubscriptionManager.swift`** — `@MainActor` singleton wrapping RevenueCat (`Purchases`). Tracks `isPremium` by checking a fixed list of entitlement identifiers (`premium`, `Pro`, `premium_access`, `premium access`). `MainScreen` shows `PaymentScreen` as a one-time post-onboarding paywall (`@AppStorage("hasSeenPostOnboardingPaywall")`) for non-premium users.
- **`Helpers/KeyChainAccess/DeviceIdManager.swift`** — `DeviceIDManager.shared.getDeviceUUID()` provides a persistent per-device UUID (Keychain-backed) used to identify the device to the backend without an account system.
- **`Models/`** — plain `Decodable`/`Hashable` structs per API resource, matching repository names (`BirdDetailModels` types live inline in the repository's response type, etc.).
- **`Helpers/MockData/MockData.swift`** — `static var mock` extensions on response models, used by `MockXRepository` implementations and SwiftUI `#Preview`s.
- **`CustomView/`** — small reusable SwiftUI components shared across screens (tab bar, back button, search field, checkbox).
- **`Helpers/Extension/`** — SwiftUI/Foundation extensions (Color, Font, glass effect, rounded corners, shimmer, iOS-version checks).
- **`Helpers/CacheImage/`** — custom async image caching (`CachedAsyncImage` + `ImageCacheLoader`); Kingfisher is also available as a dependency.

## Conventions to follow when extending the app

- New API-backed feature: add URL constants to `Constants.Urls`, a `Repository` (protocol + real class + `Mock` class) in `Core/Repositories/`, a `ViewModel` that injects the repository protocol, and a `Screen` view — mirroring the existing `BirdDetail*` / `Habitats*` triplets.
- New pushable screen: add a case to `Route` in `Coordinator.swift` (with its `hash(into:)` and `==` arms) and a corresponding case in `Coordinator.buildView(for:)`.
- Networking always goes through `ApiService`/`ApiServiceProtocol`, returning Combine `AnyPublisher<T, Error>`; multipart/file uploads use `multipartRequest`.
- Logging is `print()` only, emoji-prefixed by severity — do not introduce `os.log`/`Logger` or any analytics SDK (Firebase/Mixpanel/etc.) unprompted.
- `private` is used even for single-file scoping; `fileprivate` and explicit `internal` are never used — don't add them.
- No localization system — UI strings are hardcoded English literals; don't introduce `NSLocalizedString`/String Catalog unprompted.
- No SwiftLint/SwiftFormat config exists — don't add one, and don't do drive-by formatting passes (import ordering, spacing fixes) as part of an unrelated change.
- Commit messages in this repo's own style are `UPDATE: <free text>` (see recent `git log`) — if asked to draft one in-style, flag the conflict with Claude Code's own trailer convention rather than silently dropping it.

- ViewModels are always `class X: ObservableObject`, never the `@Observable` macro. Previews use the `#Preview` macro, never `PreviewProvider`.

### Always ask before

- Adding a new third-party SPM dependency, or introducing a `.swiftlint.yml`/`.swiftformat`.
- Unifying the two image-loading systems (`CachedAsyncImage` vs Kingfisher's `KFImage`) or the two loading/error-state flavors — known, real inconsistencies; don't silently pick a winner mid-task.
- Modeling the paywall (`PaymentScreen`) as a `Route` instead of its existing local-boolean `fullScreenCover` pattern (used from `MainScreen`, `IdentifyScreen`, and `SettingView`) — that's an architecture change, not a bug fix.
- Renaming the `HaditatScreen` folder typo, "fixing" `AppFont`'s PascalCase enum cases, or correcting the `SubscriptionViewModel.swift` (in `Core/Screens/PaymentScreen/PaymentScreenViewModel.swift`) header comment — known-quirky but harmless; the author's call, not a drive-by.
- Changing `PRODUCT_BUNDLE_IDENTIFIER`, deployment target, code-signing settings, or the `NSAppTransportSecurity` exception in `Info.plist`.
- Adding analytics/crash reporting — none exists today; may be a deliberate privacy stance rather than an oversight.
- Any change spanning more than ~5 files or more than one feature folder, unless the user explicitly asked for a broad refactor (the author's own commits are large and bundle unrelated concerns, but that's not license to do the same unprompted).

### Full author style guide

`CODING_STANDARD.md` at the repo root is a much more detailed, forensic "coding DNA" reference for this author (naming, error handling, state ownership, view decomposition, known quirks/inconsistencies, and the full "ask first before..." list this section summarizes). Consult it for anything not covered above.
