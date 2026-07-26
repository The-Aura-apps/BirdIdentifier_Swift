# CODING_STANDARD.md — Ali Bakhsha's Swift/SwiftUI Coding DNA

Forensic audit of the BirdId repository (single author: `alibakhsha <bakhshaali@gmail.com>`,
32 commits, 8,014 lines of Swift across 40 files, single Xcode target + 2 test targets,
zero SwiftLint/SwiftFormat config, Xcode 16-style filesystem-synchronized groups).

This document describes REALITY, not best practice. Where the author does something
unconventional but consistent, it is recorded as a rule. All "you should fix this" ideas
live only in the Appendix at the end.

## How to use this document

Drop this file in as `CLAUDE.md` (or reference it from one) at the root of any new Swift/
SwiftUI project by this author. It tells a future Claude Code session exactly how to
structure files, name things, handle networking/concurrency/errors, and where the author's
taste diverges from "idiomatic Swift" — so generated code blends in rather than sticking
out as obviously AI-written.

## Table of Contents

0. How to use this document
1. UI framework reality
2. Architecture pattern as practiced
3. Layering and import direction
4. Module strategy
5. Folder structure
6. File granularity
7. Core / Shared / Helpers / Extensions meaning
8. struct vs class vs enum vs actor
9. Protocols
10. Access control
11. Optionals
12. Error handling
13. Extensions organization
14. Generics
15. Naming
16. Property wrappers
17. Value semantics
18. Trailing closures / functional style
19. MARK / TODO / comment language
20. Doc comments
21. async/await vs Combine vs callbacks
22. @MainActor / Task
23. Sendable / actors
24. Combine habits
25. View decomposition
26. State/Binding/StateObject/ObservedObject/Environment
27. ViewModel shape
28. Navigation
29. ViewModifiers
30. Design tokens
31. Reusable components
32. Loading/empty/error states
33. Lists/ScrollView/Lazy*
34. Animation
35. Previews
36. UIKit usage (programmatic/storyboard)
37. ViewController lifecycle
38. Delegates/DataSources
39. Networking
40. Request/response models & Codable
41. API error mapping / retry
42. Persistence
43. Caching / image loading
44. DI
45. Localization
46. Persian/Jalali/RTL handling
47. Assets
48. Config / build flags
49. Logging / analytics
50. Permissions / StoreKit / paywall
51. Third-party dependencies
52. Lint/format rules
53. Import ordering / formatting quirks
54. Tests
55. Git conventions
56. ❌ Anti-patterns (zero occurrences)
57. Cheat-sheet
58. New Project Bootstrap
59. How to work with me (rules for Claude Code)

Appendix A — Improvement ideas (NOT rules, opt-in only)
Open Questions (Phase 4)
Self-check (Phase 5)

---

## 56. ❌ Anti-patterns: constructs that appear ZERO times in my code

Every item below was searched for across all 40 Swift files and confirmed absent. Treat
every one of these as off-limits when generating new code for this author unless they
explicitly ask for it:

- `@Observable` macro on a ViewModel — always `class X: ObservableObject` (R-2).
- `struct X: ViewModifier` + `.modifier(X())` — always a `View` extension method (R-31).
- The `actor` keyword anywhere — isolation is `@MainActor`-or-manual-dispatch only (R-10, R-25).
- `Sendable`/`@unchecked Sendable` conformance — strict concurrency is not adopted (R-25).
- `Result<Success, Failure>` as a return type — Combine's `Error` completion channel does this job (R-14).
- `try!` — even in previews/mocks, failable calls are `try?` (R-13).
- `fileprivate` — `private` is used even for single-file scoping (R-12).
- An explicit `internal` modifier — always the implicit default (R-12).
- `NavigationLink(destination:)` — all pushes go through `coordinator.push(.route)` + one `navigationDestination` (R-30).
- `struct X_Previews: PreviewProvider` — always the `#Preview` macro (R-37).
- `UITableView`/`UICollectionView`, `dequeueReusableCell`, cell registration, or a diffable data source — every list is a SwiftUI `Lazy*Grid`/`ScrollView` (R-39, R-40).
- `CoreData`, `SwiftData` (`@Model`, `.modelContext`), or `Realm` — persistence is Keychain + `@AppStorage` + a hand-rolled image cache only (R-44).
- Any analytics SDK (`Firebase`, `Mixpanel`, `Amplitude`, `Segment`) — 0 occurrences despite a paywall/IAP flow existing (R-49).
- A constraint DSL (`SnapKit` or similar) — the one hand-written Auto Layout call site uses raw anchors (R-38).
- A DI container/service locator (`Swinject`, `Factory`, a hand-rolled `ServiceLocator`) — always default-arg constructor injection or `.shared` (R-46).
- `RxSwift`/`RxCocoa` — Combine is the only reactive framework used.
- `os.log`/`Logger` — logging is `print()` with an emoji-severity convention, always (R-51).
- `NSLocalizedString`, `String(localized:)`, or a String Catalog (`.xcstrings`) — every UI string is a hardcoded English literal (R-47).
- `JSONDecoder().dateDecodingStrategy` — dates are always decoded as raw `String` (R-42).
- `.assign(to:on:)` — every publisher output goes through `.sink` instead (R-26).
- `Task.detached`, `TaskGroup`, or `withTaskCancellationHandler` — structured concurrency beyond a bare `Task { }` is never used (R-24).
- `mutating func` on any `struct` — value types are treated as immutable data (R-19).
- A custom `@propertyWrapper` declaration — only Apple's stock wrappers are used (R-18).
- A `Podfile`/CocoaPods, or a local SPM `Package.swift` splitting the app into modules — single target, remote SPM only (R-5).
- `.xcconfig` files, or `#if DEBUG`-gated behavior — one hardcoded configuration for everything (R-50).
- A `.swiftlint.yml`/`.swiftformat` file — no automated style enforcement exists (R-54).
- Conventional Commits syntax (`feat:`, `fix:`, `chore(scope):`) or a ticket reference in a commit message — every commit since the initial scaffold is `UPDATE: <free text>` (32/34; R-57).
- Direct `StoreKit`/`StoreKit2` calls (`Product.products(for:)`, `Transaction.currentEntitlements`) — IAP is 100% delegated to RevenueCat's `Purchases` API (R-52).
- An explicit `AVAudioSession.requestRecordPermission`/`AVAudioApplication.requestRecordPermission()` call — microphone access relies on the implicit system prompt (R-52).
- A generic `Repository<Model>` base class, or `associatedtype` in any protocol — every Repository is concretely typed, every protocol only abstracts a network call (R-11, R-16).
- A custom, app-level `protocol XDelegate` — internal communication is always Combine/`@Published`/closures; delegate conformance is only ever to an Apple-framework protocol (R-40).

## 57. Cheat-sheet

| ID | One-liner |
|---|---|
| R-1 | SwiftUI by default; UIKit only via `UIViewControllerRepresentable`/`UIViewRepresentable` wrapping a system API |
| R-2 | MVVM: every screen is `View` + `class XViewModel: ObservableObject`, never `@Observable` |
| R-3 | Coordinator is injected into a ViewModel late, via `setCoordinator()`, not init |
| R-4 | View → ViewModel → Repository(protocol) → ApiService, one-way, Models have zero outgoing deps |
| R-5 | Single target, SPM pinned in the `.xcodeproj`, no `Package.swift`/CocoaPods/local packages |
| R-6 | Screens are feature-first folders; Repositories/Models are flat and type-first |
| R-7 | Xcode groups are filesystem-synchronized — no manual group/path divergence possible |
| R-8 | 21/40 files bundle more than one top-level type — not strict one-type-per-file |
| R-9 | `Core/` = screens+repos+networking; `Helpers/<Purpose>/` = everything else; no `Shared`/`Common`/`Utilities` |
| R-10 | `struct` for Views/DTOs, `class` for anything with identity/mutable state, `actor` never |
| R-11 | Protocols only at the Repository/ApiService DI seam, suffixed `Protocol`, no `associatedtype` |
| R-12 | `private` everywhere; `fileprivate`/explicit `internal` never; `public` only where UIKit forces it |
| R-13 | `guard let` for preconditions, `if let` for branching, force-unwrap only for provably-safe casts, `try!` never |
| R-14 | One `APIError: LocalizedError` enum; Combine's `Error` channel end to end; `throws` almost never |
| R-15 | `// MARK: - Section` banners split a file into regions instead of splitting into more files |
| R-16 | Generics only at the Decodable-networking / `CachedAsyncImage` boundary |
| R-17 | Booleans: `is*` for in-flight state, `show*` for UI-branch state, `has*` for `@AppStorage` flags |
| R-18 | Only stock property wrappers; never a custom `@propertyWrapper` |
| R-19 | Structs are immutable data; `mutating func` never written |
| R-20 | Trailing closures everywhere; `for`-in preferred over chained `.map`/`.filter` for anything non-trivial |
| R-21 | Structural comments/identifiers in English; debug `print()`/some error strings in Persian |
| R-22 | `///` reserved for genuinely surprising behavior, not applied systematically |
| R-23 | Combine is the app's currency; `async/await` only for system APIs; callbacks only to match a callback-based SDK |
| R-24 | `@MainActor` class annotation and manual `.receive(on:)`/`DispatchQueue.main` both used — not unified |
| R-25 | `Sendable`/`actor` never adopted — isolation is `@MainActor`-or-nothing |
| R-26 | `AnyPublisher<T, Error>` everywhere; `cancellables` (one `cancelBag` outlier); `.sink { } receiveValue: { }`; `.assign` never |
| R-27 | Decompose into same-file computed `some View` first; promote to a file only when reused by 2+ screens |
| R-28 | `@StateObject` at the owner, `@ObservedObject` when passed down; `@EnvironmentObject` only for Coordinator/TabManager |
| R-29 | ViewModel is self-owned `@StateObject` by default; constructor-injected only to survive a tab switch |
| R-30 | One `NavigationStack`/`Route`/`navigationDestination`; paywall is the one exception, done via local `fullScreenCover` |
| R-31 | Custom modifiers are `View` extensions with `@ViewBuilder`, never a `ViewModifier` struct |
| R-32 | `Font.app(_:)` token used everywhere; brand colors are hex literals repeated inline, never tokenized |
| R-33 | `CustomView/` for reused components; bare names unless a SwiftUI-API-name collision forces a `Custom` prefix |
| R-34 | Two loading flavors and two error flavors coexist, never unified into a shared component |
| R-35 | `LazyVGrid`/`LazyHGrid` with hardcoded `.fixed()` columns; `ForEach(0..<N, id:\.self)` only for decorative content |
| R-36 | `.easeInOut` for toggles, `.spring(response:dampingFraction:)` for tactile selection; no shared `Animation` token |
| R-37 | `#Preview` macro always; `.mock` static vars for complex models, inline literals for simple ones |
| R-38 | 100% programmatic UIKit, 0 XIBs, boilerplate-only storyboard, raw `NSLayoutConstraint` anchors |
| R-39 | One `UIViewController` (camera preview); `setupX`/`checkX` naming; no table/collection view anywhere |
| R-40 | Delegate conformance only for Apple-framework protocols; never a custom app-level delegate |
| R-41 | `URLSession` for JSON, `Alamofire` for multipart only; no Router/Endpoint enum, raw string-interpolated URLs |
| R-42 | `Decodable`-only vs `Codable` by need; `CodingKeys` written by default even 1:1; dates always `String` |
| R-43 | No auth/token-refresh (no login system); retry is always a manual button re-calling the same fetch |
| R-44 | Keychain for the device UUID, `@AppStorage` for flags, `NSCache`+disk for images; no CoreData/SwiftData/Realm |
| R-45 | Two parallel image systems: hand-rolled `CachedAsyncImage` (default) + Kingfisher's `KFImage` (`ArticleScreen` only) |
| R-46 | Default-arg constructor injection for protocols; `.shared` singletons for cross-cutting infra; no DI container |
| R-47 | All UI copy hardcoded English literals; no `.strings`/String Catalog/`NSLocalizedString` |
| R-48 | File headers are Jalali-calendar timestamps (Mac locale artifact); 2 files break the pattern (copied from elsewhere) |
| R-49 | Custom assets named Title-Case-with-spaces; SF Symbols only as a generic-icon fallback |
| R-50 | No `.xcconfig`, no `#if DEBUG`; secrets/base URL are hardcoded literals |
| R-51 | `print()` only, emoji-prefixed by severity; no `os.log`/`Logger`, no analytics SDK |
| R-52 | Camera permission requested explicitly; mic permission implicit; IAP 100% via RevenueCat, no raw StoreKit |
| R-53 | 5 SPM deps, each scoped to one job; no DI container/Rx/constraint-DSL/CocoaPods |
| R-54 | No SwiftLint/SwiftFormat config exists at all — zero automated style enforcement |
| R-55 | Imports not alphabetized; pervasive double-space-after-colon typo (72 occurrences) — don't drive-by fix it |
| R-56 | Test targets are unused Xcode scaffolding; Mock repos (2/7) exist for previews, not for actual tests |
| R-57 | 32/34 commits (every one after the initial scaffold) are `UPDATE: <free text>`; no Conventional Commits, no ticket refs, large bundled commits |

## 58. New Project Bootstrap

### Exact folder tree for a new project by this author

```
NewApp/
├── NewApp.xcodeproj                      (filesystem-synchronized groups — just add files in Finder/Xcode, no manual group wrangling)
├── CLAUDE.md                             (this file, or a reference to it)
├── NewApp/
│   ├── NewAppApp.swift                   (@main, SplashScreen -> Onboarding|MainScreen)
│   ├── Info.plist
│   ├── Assets.xcassets/
│   │   └── Colors/                       (TextColor, StrikeTextColor, DarkColor, ... asset-catalog color sets)
│   ├── Core/
│   │   ├── Screens/
│   │   │   ├── Splash/SplashScreen.swift
│   │   │   ├── Onboarding/OnboardingScreen.swift, OnboardingData.swift
│   │   │   ├── Home/HomeScreen.swift, HomeScreenViewModel.swift, HomeScreenSubViews/
│   │   │   ├── <Feature>/<Feature>Screen.swift, <Feature>ViewModel.swift, <Feature>SubViews/
│   │   │   ├── PaymentScreen/PaymentScreen.swift, PaymentScreenViewModel.swift, PaymentScreenSubView/
│   │   │   └── Setting/SettingView.swift
│   │   ├── Repositories/
│   │   │   └── <Feature>Repository.swift             (protocol + real class + Mock class, all in one file)
│   │   └── InternetServices/
│   │       └── ApiService.swift                        (ApiServiceProtocol + ApiService + APIError)
│   ├── Models/
│   │   └── <Resource>Model.swift                       (Decodable/Codable structs matching each API resource)
│   ├── CustomView/
│   │   ├── BackButtonView.swift, CheckedView.swift, SearchTextField.swift, TabBar.swift
│   ├── Helpers/
│   │   ├── Coordinator/Coordinator.swift
│   │   ├── TabManager/TabManager.swift
│   │   ├── Constants/Constants.swift
│   │   ├── KeyChainAccess/DeviceIdManager.swift
│   │   ├── CacheImage/CachedAsyncImage.swift, ImageCacheLoader.swift
│   │   ├── SubscriptionManager/SubscriptionManager.swift
│   │   ├── LottieView/LottieView.swift
│   │   ├── MockData/MockData.swift
│   │   ├── Extension/Color+Extention.swift, Font+Extension.swift, GlassEffect.swift, IosVersion.swift, RoundedCorner.swift, ShimmerEffect.swift, UIScreen+Extension.swift
│   │   └── Jsons/                                       (Lottie .json animation files)
├── NewAppTests/NewAppTests.swift          (Swift Testing @Test placeholder, matching Xcode default)
└── NewAppUITests/                         (XCTest UI-test template, matching Xcode default)
```

### App entry

```swift
// NewAppApp.swift
import SwiftUI

@main
struct NewAppApp: App {
    @AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
    @StateObject var coordinator = Coordinator()
    @StateObject private var tabManager = TabManager()
    @State private var showSplash = true

    init() {
        _ = SubscriptionManager.shared
    }

    var body: some Scene {
        WindowGroup {
            ZStack {
                if showSplash {
                    SplashScreen {
                        withAnimation(.easeInOut(duration: 0.5)) { showSplash = false }
                    }
                    .transition(.opacity)
                } else {
                    rootContent.transition(.opacity)
                }
            }
        }
    }

    @ViewBuilder
    private var rootContent: some View {
        if hasSeenOnboarding {
            MainScreen()
                .environmentObject(coordinator)
                .environmentObject(tabManager)
        } else {
            OnboardingScreen()
        }
    }
}
```

### DI / composition root

There is no separate composition-root file — DI is distributed: every Repository-consuming
type declares `init(repository: XRepositoryProtocol = XRepository())` at its own
declaration (R-46). Do not create a `DIContainer.swift`/`AppDependencies.swift` — it would
be inventing a pattern with 0 precedent in this author's code.

### Router / Coordinator

```swift
// Helpers/Coordinator/Coordinator.swift
import Foundation
import SwiftUI
import Combine

enum Route: Hashable {
    case birdDetail(birdId: Int)
    // one case per pushable destination; add hash(into:)/== by hand for any case
    // whose associated value isn't natively Hashable (see BirdId's Route for the pattern)

    func hash(into hasher: inout Hasher) { /* switch self { ... } */ }
    static func == (lhs: Route, rhs: Route) -> Bool { /* switch (lhs, rhs) { ... } */ }
}

class Coordinator: ObservableObject {
    @Published var path: [Route] = []

    func push(_ route: Route) { path.append(route) }
    func pop() { if !path.isEmpty { path.removeLast() } }
    func popToRoot() { path.removeAll() }

    @ViewBuilder
    func buildView(for route: Route) -> some View {
        switch route {
        case .birdDetail(let id):
            EmptyView() // ResultScreen(birdId: id) — swap in the real destination view
        }
    }
}
```

### DesignSystem (Color / Font / Spacing)

```swift
// Helpers/Extension/Color+Extention.swift
import SwiftUI
extension Color {
    init(hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        self.init(red: Double((rgb >> 16) & 0xFF) / 255,
                  green: Double((rgb >> 8) & 0xFF) / 255,
                  blue: Double(rgb & 0xFF) / 255)
    }
}

// Helpers/Extension/Font+Extension.swift
import SwiftUI
enum AppFont { case Title1, Headline1, Headline2, Headline3, Headline4, Headline5, Sub1, Sub2, Sub3, Micro1, Micro2 }
extension Font {
    static func app(_ style: AppFont) -> Font {
        switch style {
        case .Title1: return .system(size: 32, weight: .bold)
        case .Headline1: return .system(size: 24, weight: .bold)
        // ... match BirdId's exact size/weight table
        default: return .system(size: 16, weight: .regular)
        }
    }
}
```
No `Spacing` token file — pad with inline numeric literals, matching R-32's documented gap
(don't invent one unless the user asks; see Appendix A-8 for the improvement idea).

### APIClient + Endpoint + APIError

```swift
// Core/InternetServices/ApiService.swift
protocol ApiServiceProtocol {
    func request<T: Decodable>(_ url: String, method: HTTPMethod, body: [String: Any]?,
                                headers: [String: String]?, expecting: T.Type) -> AnyPublisher<T, Error>
    func multipartRequest<T: Decodable>(_ url: String, method: HTTPMethod, parameters: [String: Any]?,
                                         files: [String: (data: Data, fileName: String, mimeType: String)]?,
                                         headers: [String: String]?, expecting: T.Type) -> AnyPublisher<T, Error>
}
// No Endpoint/Router enum — Repositories build raw URL strings from Constants.Urls.*
enum APIError: LocalizedError {
    case httpError(statusCode: Int, data: Data)
    case decodingError(underlyingError: DecodingError, data: Data)
    case networkError(underlyingError: URLError)
    case unknownError
}
```

### Base ViewModel

There is no shared `BaseViewModel` class — every ViewModel independently declares its own
`@Published isLoading`/`errorMessage`/`showError` and its own `cancellables` (see R-26). Do
not introduce a shared base class; it has 0 precedent (each ViewModel is a flat, standalone
`class X: ObservableObject`).

### Standard Loading / Empty / Error views

There is no shared component today (R-34 documents this as an open inconsistency, not a
convention). If asked to add one, follow the "flavor B" shapes as the more recent/preferred
ones: `ProgressView().progressViewStyle(CircularProgressViewStyle(tint: .white))` for
loading, and native `.alert("Error", isPresented:)` with Retry/Cancel for errors — but check
with the user first before consolidating existing screens onto it (see Appendix A-3).

### PreviewMocks

```swift
// Helpers/MockData/MockData.swift
extension SomeResponse {
    static var mock: SomeResponse { SomeResponse(/* fully populated realistic fields */) }
}
```
Add a `.mock` only once a model is annoying to hand-construct inline in a `#Preview` block
(R-37) — trivial models get an inline literal instead.

### Exact dependency list (SPM URLs + versions actually used)

```
https://github.com/Alamofire/Alamofire.git           5.10.2   (multipart upload only)
https://github.com/kishikawakatsumi/KeychainAccess    master   (device UUID persistence)
https://github.com/onevcat/Kingfisher                 8.6.2    (image loading — used sparingly, see R-45)
https://github.com/airbnb/lottie-ios                  4.5.2    (all animated illustrations)
https://github.com/RevenueCat/purchases-ios-spm.git   5.78.0   (all IAP/subscription logic)
```

### `.swiftlint.yml` / `.swiftformat`

Neither exists in this author's projects (R-54). Do not create one when bootstrapping a
new project unless the user explicitly asks — adding lint config unprompted would be
introducing a convention with zero precedent.

### Info.plist keys and build settings always changed from default

- `NSAppTransportSecurity` → `NSExceptionDomains` carved out for the current dev backend
  host/IP with `NSExceptionAllowsInsecureHTTPLoads = true` while pointing at a raw IP or
  non-HTTPS host during development (R-50) — remove once the real HTTPS domain is live, but
  don't be surprised to find a stale one left behind.
- `CFBundleURLTypes` → present as an empty placeholder array even with nothing configured.
- `PRODUCT_BUNDLE_IDENTIFIER` → `com.<company>.<appname>` (e.g. `com.aura.
  birdidentification`), test targets keep Xcode's default `com.mycompany.<Target>` rather
  than being renamed to match.
- `SWIFT_VERSION = 5.0`, `CODE_SIGN_STYLE = Automatic`, `MARKETING_VERSION = 1.0`.

## 59. How to work with me (rules for Claude Code in my future repos)

**Assume without asking:**
- MVVM + one centralized `Coordinator`, feature-first `Core/Screens/<Feature>/` folders,
  type-first `Core/Repositories/`/`Models/`.
- Every Repository gets a protocol + real class + default-arg injection
  (`init(x: XProtocol = XReal())`) in the same file.
- ViewModels are `class X: ObservableObject`, never `@Observable`.
- Networking returns `AnyPublisher<T, Error>` via `ApiService`, not `async throws`.
- `print()` with an emoji-severity prefix for logging — never introduce `os.log`/`Logger`
  or an analytics SDK unprompted.
- `#Preview` macro, not `PreviewProvider`.
- English identifiers/MARK banners; hardcoded English UI strings (no localization system).
- `private` by default; `fileprivate` and explicit `internal` are never used — don't add them.
- Don't run a repo-wide formatter pass (fixing the double-space-after-colon typos, import
  ordering, etc.) as a drive-by part of an unrelated change — that's Appendix A-2 territory,
  opt-in only.

**Always ask first before:**
- Adding a new third-party SPM dependency, or introducing a `.swiftlint.yml`/`.swiftformat`.
- Consolidating the two image-loading systems (`CachedAsyncImage` vs `KFImage`) or the two
  loading/error-state flavors (R-34, R-45) — these are known, real inconsistencies; don't
  silently pick a winner mid-task.
- Modeling the paywall as a `Route` (R-30) instead of the existing local-boolean
  `fullScreenCover` pattern — that's an architecture change, not a bug fix.
- Renaming the `HaditatScreen` folder typo, "fixing" `AppFont`'s PascalCase enum cases, or
  correcting the `SubscriptionViewModel.swift` "LogoGenerator" header — these are
  known-quirky but load-bearing/harmless; treat them as the author's call, not a drive-by.
- Changing `PRODUCT_BUNDLE_IDENTIFIER`, deployment target, code-signing settings, or the
  `NSAppTransportSecurity` exception in `Info.plist`.
- Adding analytics/crash reporting, given none exists today and it may be a deliberate
  privacy stance rather than an oversight.

**Max change size before checking in:** the author's own commits are large and bundle
unrelated concerns (R-57), but that is not license for Claude Code to do the same
unprompted — default to smaller, single-purpose diffs, and check in before a change that
spans more than ~5 files or touches more than one feature folder at once, unless the user
has explicitly asked for a broad refactor.

**Naming, commenting, and commit conventions to follow:**
- New types/files: PascalCase type name = file name; screens get the `<Feature>Screen.swift`
  + `<Feature>ViewModel.swift` pair; booleans get `is`/`show`/`has` prefixes (R-17).
- `// MARK: - Section` banners inside a file instead of splitting into more files, matching
  R-8/R-15's granularity.
- `TODO` without a ticket reference is consistent with existing style — don't invent a
  ticket ID.
- If asked to draft a commit message in this author's own style, it is `UPDATE: <short
  free-text, lowercase-ish>` — but flag to the user that this conflicts with Claude Code's
  own default instruction to append a `Co-Authored-By: Claude` trailer, and let them decide
  which wins for that commit, rather than silently dropping the trailer.

---

## Appendix A — Improvement ideas (NOT rules — opt-in only, never applied without being asked)

- **A-1 (Q8):** Unify the two image-loading systems. Either drop Kingfisher (unused
  everywhere except `ArticleScreen`) and use `CachedAsyncImage` everywhere, or the reverse.
- **A-2 (R-55):** Run a one-time SwiftFormat pass to fix the ~72 double-space-after-colon
  typos and normalize import ordering — as a dedicated, opt-in cleanup commit, not mixed
  into a feature change.
- **A-3 (Q6/R-34):** Extract one shared `LoadingView`, `ErrorView`, and `EmptyStateView`
  component and migrate all 7+ screens onto them instead of each re-implementing its own.
- **A-4 (Q4/R-30):** Give the paywall a `Route.paywall` case and route it through
  `Coordinator`, removing the three duplicated local `@State`/`fullScreenCover` pairs.
- **A-5 (Q1/R-14):** Replace `UploadRepository`'s ad hoc `NSError(domain: "BirdId", code:
  ...)` with two new `APIError` cases (e.g. `.processingIncomplete`, `.uploadRejected`) so
  error handling has one currency end to end.
- **A-6 (R-54):** Introduce a baseline `.swiftlint.yml`/`.swiftformat` now that the codebase
  is 8,000+ lines — would have caught the spacing typos and casing inconsistency early.
- **A-7 (Q2/R-6):** Rename the `HaditatScreen` folder to `HabitatScreen` (purely cosmetic,
  git-history-preserving `git mv`, low risk) — only if the author wants it, since Xcode's
  filesystem-synchronized groups mean this is now a trivial one-command fix.
- **A-8 (Q5/R-32):** Extract the repeated `Color(hex: "#5B765C")`/`"#BCB22A"`/etc. literals
  into a `Color` extension (`Color.brandGreen`, `Color.accentGold`, ...) mirroring the
  existing `Font.app` token treatment.
- **A-9 (R-49):** Add lightweight analytics around the paywall/IAP funnel (impressions,
  plan selection, purchase completion) — currently invisible with 0 analytics integrated.
- **A-10 (Q3/R-24):** Standardize on one main-thread-safety idiom — either `@MainActor` on
  every ViewModel class, or `.receive(on: DispatchQueue.main)` everywhere — instead of the
  current 4-vs-3 split.

## Open Questions (Phase 4)

**Q1:** `UploadRepository.swift:70,79` throws a raw `NSError(domain: "BirdId", code: 1001/
1002, ...)` instead of extending the app's own `APIError` enum, which every other error
path uses. Option A: leave it (it's isolated to one file and works). Option B: add
`.processingIncomplete`/`.uploadRejected` cases to `APIError` and use those instead. My
recommendation: Option B — it's a small change and gives error handling one consistent
currency, but it's your call since it's the only place doing it and doesn't cause bugs today.

**Q2:** `AppFont`'s enum cases (`Title1`, `Headline1`, `Sub1`, `Micro1`) are PascalCase,
while every other enum in the codebase (`OnboardingData`, `IdentificationMode`, `PlanType`,
`CheckedState`, `TabBarItem`) uses standard lowerCamelCase cases. Option A: keep `AppFont`
as a deliberate exception (it visually mirrors the design-token names). Option B: rename to
`title1`/`headline1`/`sub1`/`micro1` for consistency (a small breaking change,
find-and-replace across every `.font(.app(.X))` call site). My recommendation: Option A —
it reads fine as-is and a rename touches every screen file for a purely cosmetic gain.

**Q3:** Four files use class-level `@MainActor` (`HomeScreenViewModel`, `HistoryViewModel`,
`SubscriptionManager`, `PhotoPickerController`); the rest rely on `.receive(on:
DispatchQueue.main)` / manual `DispatchQueue.main.async`. Option A: standardize on
`@MainActor` everywhere (the more modern, Swift-6-ready idiom). Option B: standardize on
`.receive(on:)` (matches the majority of existing ViewModels, smaller diff). My
recommendation: Option A, done gradually — but only as a deliberate, opt-in modernization
pass, not mixed into feature work.

**Q4:** The paywall (`PaymentScreen`) is presented via three independent local
`@State`/`.fullScreenCover` pairs (`MainScreen`, `IdentifyScreen`, `SettingView`) rather
than a `Route` case, even though every other cross-screen navigation goes through
`Coordinator`. Option A: this is intentional — a paywall genuinely is a modal interruption,
not a stack push, so it doesn't belong in `Route`. Option B: it's an oversight and should
become `Route.paywall` to remove the duplication. My recommendation: Option A is defensible
UX-wise (paywalls are typically modal, not pushed), but the *duplication* (three separate
local booleans doing the identical thing) is worth collapsing into one shared modifier
regardless of which Option you pick.

**Q5:** Brand colors (`#5B765C`, `#BCB22A`, `#194632`, `#6B6B6B`, `#BCBCBC`) are repeated as
inline `Color(hex:)` literals across many files, while typography went through a full
`Font.app(_:)` token system. Option A: leave colors as inline hex (low urgency, it's a small
app). Option B: add a matching `Color.app`/named-token file. My recommendation: Option B —
cheap to do and removes several silently-drifting duplicate literals of the same brand green.

**Q6:** Loading spinners have two flavors (bare `.tint(.text)` + `.scaleEffect(1.5)` vs
`.progressViewStyle(CircularProgressViewStyle(tint: .white))`), and error states have two
flavors (inline SF-Symbol block vs native `.alert`). Option A: leave as-is (each screen's
choice is locally reasonable). Option B: consolidate into one shared component per state.
My recommendation: Option B, but only if/when a new design pass touches these screens
anyway — not worth a dedicated refactor commit on its own for an app this size.

**Q7:** `Color` and `Font` both got dedicated token extensions; `Animation` never did —
every `.spring(...)`/`.easeInOut(...)` call retypes its parameters as literals. Option A:
leave it (animations are simple enough that literals are fine). Option B: add
`Animation.appSpring`/`Animation.appEase` static tokens. My recommendation: Option A — the
values already vary intentionally by context (tactile vs simple toggle), so forcing them
into 1-2 shared constants may lose nuance that was added on purpose.

**Q8:** Kingfisher (`KFImage`) is a full SPM dependency used in exactly one screen
(`ArticleScreen`), while a hand-rolled `CachedAsyncImage`/`ImageCacheManager` covers every
other screen. Option A: drop Kingfisher, migrate `ArticleScreen` to `CachedAsyncImage` (one
fewer dependency). Option B: drop the hand-rolled cache, migrate everything to Kingfisher
(less code to maintain, gets Kingfisher's more mature caching/prefetching for free). My
recommendation: Option B — Kingfisher is a mature, well-tested library; the hand-rolled
cache duplicates functionality it already provides for free.

**Q9:** `SubscriptionManager.swift` and `SubscriptionViewModel`/`PaymentScreenViewModel.swift`
have a different author name in their header comment ("Ali Movahedzade") and a Gregorian
(not Jalali) date format, and one still says `// LogoGenerator` instead of `// BirdId` as
the project name — strong evidence they were copy-pasted in from a different project of the
same person's. Option A: leave the headers as-is (harmless, doesn't affect behavior).
Option B: correct them to this project/author for consistency. My recommendation: Option A
— purely cosmetic, and "fixing" file-creation metadata on files you didn't just author risks
looking like rewriting history for no functional benefit.

## Self-check (Phase 5)

| # | Dimension | Covered? | Rules | Code examples |
|---|---|---|---|---|
| 1 | UI framework reality | ✅ | R-1 | 1 |
| 2 | Architecture pattern | ✅ | R-2, R-3 | 3 |
| 3 | Layering/import direction | ✅ | R-4 | 2 |
| 4 | Module strategy | ✅ | R-5 | 1 |
| 5 | Folder structure | ✅ | R-6, R-7 | 2 |
| 6 | File granularity | ✅ | R-8 | 1 |
| 7 | Core/Shared/Utilities meaning | ✅ | R-9 | 1 |
| 8 | struct/class/enum/actor | ✅ | R-10 | 2 |
| 9 | Protocols | ✅ | R-11 | 1 |
| 10 | Access control | ✅ | R-12 | 2 |
| 11 | Optionals | ✅ | R-13 | 2 |
| 12 | Error handling | ✅ | R-14 | 2 (incl. conflict) |
| 13 | Extensions organization | ✅ | R-15 | 2 |
| 14 | Generics | ✅ | R-16 | 1 |
| 15 | Naming | ✅ | R-17 | 2 (incl. conflict) |
| 16 | Property wrappers | ✅ | R-18 | 1 |
| 17 | Value semantics | ✅ | R-19 | 1 |
| 18 | Trailing closures/functional style | ✅ | R-20 | 2 |
| 19 | MARK/TODO/comment language | ✅ | R-21 | 2 |
| 20 | Doc comments | ✅ | R-22 | 2 |
| 21 | async/await vs Combine vs callbacks | ✅ | R-23 | 3 |
| 22 | @MainActor/Task/cancellation | ✅ | R-24 | 2 (conflict) |
| 23 | Sendable/actors | ✅ | R-25 | 1 |
| 24 | Combine habits | ✅ | R-26 | 1 |
| 25 | View decomposition threshold | ✅ | R-27 | 1 |
| 26 | State/Binding/StateObject/etc. | ✅ | R-28 | 2 |
| 27 | ViewModel shape/injection | ✅ | R-29 | 2 |
| 28 | Navigation | ✅ | R-30 | 1 (conflict) |
| 29 | ViewModifier definitions | ✅ | R-31 | 1 |
| 30 | Design tokens | ✅ | R-32 | 2 (conflict) |
| 31 | Reusable components library | ✅ | R-33 | 1 |
| 32 | Loading/empty/error states | ✅ | R-34 | 4 (conflict) |
| 33 | Lists/ScrollView/Lazy* | ✅ | R-35 | 2 |
| 34 | Animation/transition style | ✅ | R-36 | 2 |
| 35 | Previews | ✅ | R-37 | 2 |
| 36 | Programmatic/Storyboard/XIB | ✅ | R-38 | 1 |
| 37 | ViewController lifecycle | ✅ | R-39 | 1 |
| 38 | Delegates/DataSource/diffable | ✅ | R-40 | 1 |
| 39 | Networking client shape | ✅ | R-41 | 3 |
| 40 | Request/response models/Codable | ✅ | R-42 | 2 |
| 41 | API error mapping/retry | ✅ | R-43 | 1 |
| 42 | Persistence | ✅ | R-44 | 2 |
| 43 | Caching/image loading | ✅ | R-45 | 2 (conflict) |
| 44 | DI | ✅ | R-46 | 2 |
| 45 | Localization | ✅ | R-47 | 1 |
| 46 | Persian digits/Jalali/RTL | ✅ | R-48 | 2 (conflict) |
| 47 | Assets | ✅ | R-49 | 2 |
| 48 | Config/build flags | ✅ | R-50 | 2 |
| 49 | Logging/analytics | ✅ | R-51 | 1 |
| 50 | Permissions/StoreKit/paywall | ✅ | R-52 | 2 |
| 51 | Third-party dependencies | ✅ | R-53 | 1 |
| 52 | Lint/format rules | ✅ | R-54 | 0 (absence documented directly) |
| 53 | Import ordering/formatting quirks | ✅ | R-55 | 2 |
| 54 | Tests | ✅ | R-56 | 2 |
| 55 | Git conventions | ✅ | R-57 | 2 |

All 55 dimensions covered, all 57 rules backed by at least one verbatim file:line citation
(R-54 is the sole exception by nature — it documents an absence, verified by a `find`
command shown inline rather than a code snippet). 9 explicit `[CONFLICT]` items carried
through to Open Questions rather than silently resolved. No rule references a symbol that
was not directly read in this session.


## 46. Persian digits, number/price formatting, Jalali dates

### R-48: N/A for UI content (no Persian digits, no Jalali display, no RTL handling anywhere) — but every file-header timestamp is auto-generated in the Jalali (Persian) calendar, revealing the author's Mac is set to a Persian-calendar locale  [LAW — Jalali headers in every author-written file / CONFLICT — 2 files break the pattern]
**Why I do it:** This isn't a deliberate design choice, it's a side effect of Xcode's
"Created by X on <date>" file-header template reading the system calendar — but it is
100% consistent across every file the author personally created, and is a strong repo-wide
fingerprint.
**Canonical example** (nearly every file, e.g. `Core/Screens/HistoryScreen/HistoryScreen.swift:1-6`):
```swift
//
//  HistoryScreen.swift
//  BirdId
//
//  Created by ali bakhsha on 8/20/1404 AP.
//
```
**CONFLICT — two files break this fingerprint entirely,** using a different author name and
a Gregorian-style date, confirming they were copied in from a different project rather than
written fresh in this repo (see also R-14/Open Questions for the same two files' error
handling and naming quirks):
```swift
//  SubscriptionManager.swift
//  BirdId
//
//  Created by Ali Movahedzade on 6/7/26.
```
```swift
//  SubscriptionViewModel.swift
//  LogoGenerator          <-- wrong project name, never fixed
//
//  Created by Ali Movahedzade on 5/19/26.
```
No Persian-digit number formatting, no Jalali date display in the UI, and no
`\.layoutDirection`/RTL handling exist anywhere in the app itself — the app's user-facing
content is 100% English/Gregorian; only the source file *metadata* is Jalali. See Open
Questions Q9.
**Never:** a `PersianCalendar`/Jalali date-conversion helper for in-app display, or an RTL
layout override — 0 occurrences of either.

## 47. Assets: naming, generated accessors, SF Symbols vs custom icons

### R-49: Asset catalog entries are named in Title Case with spaces (generating camelCase Swift accessors automatically); custom SVG/PNG assets are used for anything with brand identity, SF Symbols (`Image(systemName:)`) only as a fallback for generic/utility icons that don't need a custom look  [LAW — 50 custom `Image(.x)` references vs 11 `Image(systemName:)` references]
**Why I do it:** Every icon that's part of the app's visual identity (tab bar, camera/mic
buttons, habitat categories) is a hand-picked custom SVG/PNG in `Assets.xcassets`, named
with spaces (`"Back Button"`, `"Close Icon"`, `"Confetti Minimalistic"`, `"Square Top
Down"`, `"Star Circle"`) so Xcode's asset-symbol generator turns them into clean camelCase
(`.backButton`, `.closeIcon`, `.confettiMinimalistic`, `.squareTopDown`, `.starCircle`).
`Image(systemName:)` is reached for only when there's no matching custom asset — almost
always a generic/utility glyph (`"xmark"`, `"exclamationmark.triangle"`,
`"magnifyingglass"`, `"folder.fill.badge.plus"`).
**Canonical example, custom asset by default** (`Core/Screens/HomeScreen/HomeScreen.swift:40`):
```swift
Image(.camera)
```
**Canonical example, SF Symbol fallback for a generic glyph** (`Core/Screens/HistoryScreen/HistoryScreen.swift:72`):
```swift
Image(systemName: "bird.fill")
```
Habitat images are grouped in their own `Assets.xcassets/Habitat/` subfolder, one PNG per
habitat name (`Desert`, `Forest`, `Grassland`, `Marine`, `Savanna`, `Scrub`,
`Subterranean`, `Wetlands`) matching the API's habitat `name` strings exactly, looked up
via `HomeScreenViewModel.getHabitatImage(for:)`'s `switch habitatName.lowercased()`
(`HomeScreenViewModel.swift:152-173`).
**Never:** a custom SVG for a purely utilitarian, non-branded icon (close/dismiss/error
glyphs are always `systemName`) — the two icon sources are never mixed for the same
concept.

## 48. Config: xcconfig, schemes, build flags, `#if DEBUG`

### R-50: No `.xcconfig` files, no Debug/Release code branching, secrets and the backend URL are hardcoded string literals directly in source  [LAW — 0 xcconfig files, 0 `#if DEBUG` occurrences]
**Why I do it:** There's exactly one backend (`https://auraapps.org`, `Helpers/Constants/
Constants.swift:11`) and it's reached the same way in every build configuration — no
dev/staging/prod URL switching exists, so there's no `#if DEBUG`/xcconfig-driven
environment selection to write.
**Canonical example, hardcoded secret** (`Helpers/SubscriptionManager/SubscriptionManager.swift:36`):
```swift
Purchases.configure(withAPIKey: "appl_TNoJmWSwGQEQoShMmREpTQTnmmh")
```
**Canonical example, hardcoded base URL** (`Helpers/Constants/Constants.swift:11`):
```swift
let baseUrl: String = "https://auraapps.org"
```
An App Transport Security exception carved out in `Info.plist` for one specific raw IP
(`185.125.103.136`, allowing insecure HTTP) is a leftover from pointing the app at a
development server by IP before `auraapps.org` existed — kept in place rather than removed
once the domain was live (git history: `b3de989 "UPDATE: add new server."` swapped the
`Constants.swift` URL but did not touch this ATS exception).
**Never:**
```swift
#if DEBUG
let baseUrl = "https://staging.auraapps.org"
#else
let baseUrl = "https://auraapps.org"
#endif
```
— 0 occurrences; there is exactly one hardcoded URL for all configurations.

## 49. Logging (print / os.log / Logger) and analytics

### R-51: `print()` is the only logging mechanism, always emoji-prefixed to convey severity/category at a glance; no `os.log`/`Logger`, no analytics SDK of any kind  [LAW — 145 `print()` calls / 0 `os.log`/`Logger` / 0 analytics SDK references]
**Why I do it:** A small, informal emoji vocabulary substitutes for log levels: ✅ success,
❌ failure/error, ⚠️ warning, 🔍/📦/🐦/🔗/🚀 domain-specific informational context. No
`os.log`/`Logger` API is used anywhere, and despite the app having a paywall and IAP flow
(exactly where a team would normally want conversion analytics), no analytics SDK
(Firebase, Mixpanel, Amplitude, etc.) is integrated at all.
**Canonical example** (`Core/Screens/HaditatScreen/HabitatViewModel.swift:62-67`):
```swift
case .finished:
    print("✅ Successfully loaded habitat birds")
case . failure(let error):
    let errorMsg = error.localizedDescription
    self?.errorMessage = errorMsg
    print("❌ Error loading habitat birds: \(errorMsg)")
```
**Never:**
```swift
import os
let logger = Logger(subsystem: "com.aura.birdidentification", category: "network")
logger.info("...")     // 0 occurrences anywhere — always print()
Analytics.logEvent("paywall_viewed", parameters: nil)   // no analytics call exists in the paywall flow
```

## 50. Permissions, App Store / StoreKit / IAP / paywall code

### R-52: Camera permission requested imperatively via `AVCaptureDevice.authorizationStatus`/`requestAccess`; microphone permission is never explicitly requested in code (relies on the implicit system prompt from `AVAudioSession.setActive`); IAP is 100% delegated to RevenueCat — no direct StoreKit/StoreKit2 call exists  [LAW — 1/1 explicit permission flow (camera) / 0 direct StoreKit API calls]
**Why I do it:** `CameraController` is the only place that manually checks/requests a
system permission, because AVFoundation demands it before configuring a capture session;
recording audio relies on `AVAudioSession.sharedInstance().setActive(true)` triggering the
OS's own microphone-permission alert rather than an explicit
`AVAudioSession.requestRecordPermission` call. RevenueCat's `Purchases` class is the only
purchasing API touched anywhere — no `StoreKit`/`Product`/`Transaction` symbol appears in
the codebase.
**Canonical example, explicit camera permission flow** (`Core/Screens/IdentifyScreen/Camera/CameraController.swift:43-58`):
```swift
switch AVCaptureDevice.authorizationStatus(for: .video) {
case .authorized: setupCamera()
case .notDetermined:
    AVCaptureDevice.requestAccess(for: .video) { [weak self] granted in ... }
```
Paywall gating is a single boolean check at the point of use, not a route/screen wrapper:
`Core/Screens/IdentifyScreen/IdentifyScreenViewModel.swift:60-64`:
```swift
if !SubscriptionManager.shared.isPremium {
    showPaywall = true
    return
}
```
**Never:**
```swift
try await AVAudioApplication.requestRecordPermission()   // never called explicitly — 0 occurrences
Product.products(for: ["premium_weekly"])                 // raw StoreKit2 — never used, always Purchases (RevenueCat)
```

## 51. Third-party dependencies I actually reach for, and what I refuse to import

### R-53: Five SPM dependencies, each scoped to exactly one job; no DI container, no reactive-extensions beyond Combine, no constraint DSL, no CocoaPods  [LAW — 5/5 dependencies each single-purpose]
**Why I do it:** `Alamofire` → multipart upload only (never plain JSON, see R-41).
`KeychainAccess` → the one persistent device UUID. `Kingfisher` → image loading in exactly
one screen (`ArticleScreen`, duplicating the hand-rolled `CachedAsyncImage` used everywhere
else — see R-45). `lottie-ios` → all animated illustrations. `purchases-ios-spm`
(RevenueCat) → all IAP/subscription logic.
**Canonical example** (`Package.resolved`):
```json
{ "identity": "lottie-ios", "state": { "version": "4.5.2" } },
{ "identity": "purchases-ios-spm", "state": { "version": "5.78.0" } }
```
**Never:** `SnapKit`, `Realm`, `Firebase`, `RxSwift`/`RxCocoa`, `Swinject`/`Factory`, or a
`Podfile` — none exist; Combine + manual init-injection cover everything those would
otherwise be reached for.

## 52. SwiftLint/SwiftFormat rules honored vs routinely ignored

### R-54: No SwiftLint, no SwiftFormat config exists — there is no automated style enforcement at all  [LAW — 0 `.swiftlint.yml`, 0 `.swiftformat` in the repo]
**Why I do it:** Every stylistic consistency documented in this file (private-by-default,
MARK banners, trailing-closure Combine, etc.) is self-imposed by habit, not enforced by
tooling — which also explains why some things (R-55's spacing typos, the `AppFont` casing
exception, the `HaditatScreen` folder typo) survive uncorrected across dozens of commits.
**Canonical example:** `find . -iname "*.swiftlint*" -o -iname "*.swiftformat*"` returns
nothing in this repository.
**Never:** a CI step or pre-commit hook running `swiftlint`/`swiftformat` — none exists;
nothing blocks a commit from introducing an inconsistency.

## 53. Import ordering, line length, spacing, brace and formatting quirks

### R-55: Imports are NOT alphabetized — Apple frameworks and third-party imports are freely interleaved in whatever order they were added; a pervasive double-space-after-colon typo runs through the whole codebase  [WEAK for import order — no fixed rule / LAW for the spacing quirk — 72 occurrences]
**Why I do it (as observed):** Import order tracks "the order I started needing things,"
not a convention — `ApiService.swift` imports `Foundation, Alamofire, UIKit, Combine` (a
third-party package sandwiched between two system frameworks), while
`SubscriptionManager.swift` imports `Foundation, RevenueCat, Combine, UIKit`. Neither
alphabetical nor "system-first" ordering is followed consistently.
**Canonical example** (`Core/InternetServices/ApiService.swift:8-11`):
```swift
import Foundation
import Alamofire
import UIKit
import Combine
```
Far more consistent (if unintentional) is a double-space typo after a colon in type
annotations, parameter labels, and dictionary literals — 72 occurrences across the
codebase, e.g. (`Models/HabitatDetailModels.swift:19,26,29`):
```swift
struct HabitatBirdDetail:  Codable, Identifiable {
    let size: BirdSize
    let lifeExpectancyYears: String
    let taxonomy: TaxonomyHabitatDetail
```
(note `HabitatBirdDetail:  Codable` — two spaces before `Codable`) and
(`Core/Repositories/HabitatsRepository.swift:47,50`):
```swift
func getHabitatDetail(id:  Int) -> AnyPublisher<HabitatDetailResponse, Error> {
    "\(Constants.Urls.habitats)/\(id)", method:  .get,
```
This is reality, not a style to imitate deliberately going forward — new code should use a
single space, but do not "fix" it in existing files as a drive-by edit (see Appendix A-2).
**Never:** a 120-character line-length limit enforced anywhere — several lines in
`BirdInfoItem.swift` and `PaymentScreen.swift` run well past 120 characters uninterrupted.

## 54. Tests: existence, structure, naming, mocking approach

### R-56: Test targets are Xcode-template scaffolding, essentially unused; when a Repository IS given a `Mock`, it's for SwiftUI preview support, not for actual unit tests  [LAW — 0 real test cases / 2 of 7 repositories have a Mock class]
**Why I do it:** `BirdIdTests.swift` is the untouched Swift Testing (`@Test`/`#expect`)
placeholder from project creation; `BirdIdUITests`/`BirdIdUITestsLaunchTests` are the
untouched XCTest UI-test templates. No test in the repo asserts anything. Two repositories
(`BirdDetailRepository`, `HistoryRepository`) do get a `MockXRepository` class, but its
purpose — per the `// MARK: - Mock Repository for Testing` banner and its use of
`.delay(for:scheduler:)` to simulate latency — reads as SwiftUI-preview/manual-QA support
rather than an actual `XCTestCase`/`@Test` consumer, since no test file imports either mock.
**Canonical example** (`Core/Repositories/HistoryRepository.swift:39-44`):
```swift
// MARK: - Mock Repository for Testing
class MockHistoryRepository: HistoryRepositoryProtocol {
    var shouldFail = false
    var mockData: [HistorySimpleModel] = HistorySimpleModel.mockList
    var delaySeconds: TimeInterval = 1.0
```
The still-blank placeholder (`BirdIdTests/BirdIdTests.swift:11-16`):
```swift
struct BirdIdTests {
    @Test func example() async throws {
        // Write your test here and use APIs like `#expect(...)` to check expected conditions.
    }
}
```
**Never:** a populated `@Test` function, an `XCTAssert` beyond the template's own
`testLaunchPerformance`, or a `MockArticleRepository`/`MockUploadRepository`/
`MockHabitatsRepository`/`MockBirdSearchRepository`/`MockDeviceSettingsRepository` — the
other 5 of 7 repositories have no mock at all.

## 55. Git: branch names, commit message grammar, commit size

### R-57: Every commit message starts with the literal token `UPDATE:` regardless of whether it's a feature, a fix, or a refactor; no Conventional Commits, no ticket references, no commit body; commits are large and bundle multiple unrelated concerns  [STRONG — 32/34 commits start with `UPDATE:`]
**Why I do it:** The commit subject line format is always `UPDATE: <free-text, lowercase-
ish, no period usually>` — used identically for a brand-new feature
(`UPDATE: add revenucat and domin`), a bug fix (`UPDATE: fix some bug`, and the typo
`UPDATE: fox bugs` for "fix bugs" — kept as committed, never amended), and a large batch of
unrelated changes in one commit (the RevenueCat commit alone touches 17 files spanning
paywall UI, the SubscriptionManager, Coordinator/Route, and three unrelated ViewModels).
**Canonical example** (`git log --oneline`):
```
4190ab2 UPDATE: add revenucat and domin
9fffe71 UPDATE: add splash screen.
95831e2 UPDATE: fox bugs
661648c UPDATE: add DivideSettings API call
```
**CORRECTION (self-audit):** the repo has 34 commits total, not 32 — the two that don't
start with `UPDATE:` are the very first two, `Initial Commit` and `first commit`
(`git log --format=%s` tail). Every commit from the third one onward (32 of the remaining
32) uses `UPDATE:`, so the convention is "adopted after the initial scaffold," not
literally universal — still the dominant, load-bearing pattern for anything you'd actually
imitate going forward.
No commit message has a body (`git log --format='%b'` is empty for all 34 commits) and no
commit references an issue/ticket number. All 34 commits are authored by
`alibakhsha <bakhshaali@gmail.com>` on `main`/`develop` directly — no PR-based workflow, no
feature-branch merge commits in this snapshot's history.
**Never:**
```
feat(paywall): integrate RevenueCat offerings   # Conventional Commits style — never used, 0/34
Fixes #142                                      # ticket references — never appear
Initial Commit                                  # the generic Xcode-template message — only the first 2 commits, never again after
```


## 36. Programmatic vs Storyboard vs XIB; Auto Layout style

### R-38: 100% programmatic UIKit, zero XIBs, the only storyboard is Xcode's untouched `LaunchScreen.storyboard`; Auto Layout is done with `NSLayoutConstraint.activate([anchor...])`, never a DSL library  [LAW — 0 XIBs / 1 storyboard (boilerplate only) / 1 NSLayoutConstraint call site]
**Why I do it:** The only place layout constraints are written by hand is
`LottieView.swift`, wrapping a UIKit `LottieAnimationView` inside a SwiftUI
`UIViewRepresentable` — and it uses plain anchor syntax, not a DSL (no SnapKit dependency
exists).
**Canonical example** (`Helpers/LottieView/LottieView.swift:36,39-44`):
```swift
animationView.translatesAutoresizingMaskIntoConstraints = false
NSLayoutConstraint.activate([
    animationView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
    animationView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
    animationView.topAnchor.constraint(equalTo: view.topAnchor),
    animationView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
])
```
**Never:**
```swift
view.snp.makeConstraints { make in make.edges.equalToSuperview() }   // no constraint DSL library — 0 occurrences, SnapKit is not a dependency
```

## 37. ViewController lifecycle habits; setup method naming

### R-39: UIKit `ViewController`s exist only to host a camera preview layer; lifecycle overrides are minimal (`viewDidLoad`/`viewDidLayoutSubviews`/`viewDidAppear`); private configuration methods are always named `setupX`/`checkX`  [LAW — 1/1 UIViewController subclass, consistent verb-noun private method naming across all Controller classes]
**Why I do it:** `CameraViewController` is the only `UIViewController` subclass in the repo;
its three lifecycle overrides do exactly one job each (build the preview layer, resize it,
restart the session), and every "do the initial setup" private method across the whole
Camera/Audio stack is named with the same `setupX`/`checkX` verb pattern.
**Canonical example** (`Core/Screens/IdentifyScreen/Camera/CameraLiveView.swift:30-46`):
```swift
override func viewDidLoad() { super.viewDidLoad(); setupPreviewLayer() }
override func viewDidLayoutSubviews() { super.viewDidLayoutSubviews(); previewLayer?.frame = view.bounds }
override func viewDidAppear(_ animated: Bool) { ...; if controller.isConfigured { controller.start() } }
private func setupPreviewLayer() { ... }
```
Same naming convention: `CameraController.checkPermissions()` / `.setupCamera()`
(`CameraController.swift:43,66`). There is no `UITableView`/`UICollectionView`,
`dequeueReusableCell`, or cell-registration code anywhere in the repo — every list in the
app is a SwiftUI `LazyVGrid`/`LazyHGrid`/`ScrollView` (see R-35).
**Never:** a `UITableViewDataSource`/`UICollectionViewDataSource` conformance, or a
`register(_:forCellReuseIdentifier:)` call — 0 occurrences.

## 38. Delegates, DataSource, diffable data sources, coordinators

### R-40: `NSObject`-based delegate conformance is adopted only when a system framework requires it — never a custom app-level delegate protocol  [LAW — 4/4 delegate conformances are Apple-framework protocols]
**Why I do it:** `AVCapturePhotoCaptureDelegate`, `AVAudioPlayerDelegate`,
`UIDocumentPickerDelegate`, and (via a `@retroactive` extension)
`UIGestureRecognizerDelegate` are the only delegate protocols conformed to anywhere — all
four are Apple's own, required to receive a callback from `AVFoundation`/`UIKit`. Internal,
app-to-app communication never uses a custom delegate protocol; it goes through
`@Published`/Combine or a plain closure instead (see R-2, R-26).
**Canonical example** (`Core/Screens/IdentifyScreen/Camera/CameraController.swift:180-181`):
```swift
extension CameraController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
```
Where a UIKit API specifically requires a `Coordinator` object (SwiftUI's own convention,
distinct from this app's navigation `Coordinator`), it is nested inside the
`UIViewControllerRepresentable` struct itself (`AudioPickerController.swift:54`:
`class Coordinator: NSObject, UIDocumentPickerDelegate`). No `UITableViewDiffableDataSource`
or `UICollectionViewDiffableDataSource` exists — there is no `UITableView`/
`UICollectionView` in the app at all.
**Never:**
```swift
protocol CameraControllerDelegate: AnyObject { func didCapturePhoto(_ image: UIImage) }
// 0 custom delegate protocols anywhere — @Published/closures do this job instead
```

## 39. Networking: URLSession vs Alamofire; client shape; endpoint definition

### R-41: `URLSession` (via Combine's `dataTaskPublisher`) for every plain JSON request; `Alamofire` reserved exclusively for multipart file uploads; no Router/Endpoint enum — URLs are raw string interpolation onto flat constants  [LAW — 1/1 JSON path is URLSession, 1/1 multipart path is Alamofire]
**Why I do it:** `ApiService` has exactly two methods, `request` (URLSession, all plain
GET/POST JSON calls — 7/7 repositories use only this for JSON) and `multipartRequest`
(Alamofire's `AF.upload`, used only by `UploadRepository` for the photo/audio upload).
Alamofire is never used for a plain JSON GET/POST even though it's already a dependency.
There is no `Endpoint`/`Router` enum — every URL is built by string-interpolating an ID or
query parameter onto a `Constants.Urls.*` string constant, and `method`/`body`/`headers`
are passed as ordinary positional/keyword arguments to `ApiService.request(...)`.
**Canonical example, URLSession JSON path** (`Core/InternetServices/ApiService.swift:45,76`):
```swift
func request<T: Decodable>(_ url: String, method: HTTPMethod, body: [String: Any]? = nil, ...) -> AnyPublisher<T, Error> {
    ...
    return URLSession.shared.dataTaskPublisher(for: request)
```
**Canonical example, Alamofire multipart-only path** (`Core/InternetServices/ApiService.swift:114,128`):
```swift
func multipartRequest<T: Decodable>(...) -> AnyPublisher<T, Error> {
    Future { promise in
        ...
        AF.upload(multipartFormData: { multipartFormData in ... }, to: url, method: method, headers: ...)
```
**Canonical example, raw string-interpolated URL, no Endpoint enum** (`Core/Repositories/BirdDetailRepository.swift:24`):
```swift
let url = "\(Constants.Urls.birdDetail)\(id)"
```
**Never:**
```swift
enum Endpoint { case birdDetail(id: Int); var path: String { ... } }  // no Router/Endpoint abstraction — 0 occurrences
AF.request(url).responseDecodable(...)   // Alamofire never used for a plain JSON call — always URLSession for that
```

## 40. Request/response models; Codable style; CodingKeys; date strategy

### R-42: `Decodable`-only for anything the app never encodes (34 occurrences); `Codable` reserved for models the app both decodes AND uses value-semantically elsewhere (9 occurrences); an explicit `CodingKeys` enum is written by default even when it's a 1:1 no-op mapping; dates are always decoded as raw `String`, never `Date`  [LAW — 34 Decodable / 9 Codable / 1 Encodable / 21 `createdAt/updatedAt: String` fields / 0 `dateDecodingStrategy` uses]
**Why I do it:** Response DTOs that only ever flow one direction (server → app) declare
`Decodable`; the one model the app builds and sends (`DeviceSettingsRequest`) is the only
`Encodable`. `CodingKeys` is written as a matter of course, not only when a key needs
renaming — it appears even when every case name matches the property name verbatim.
**Canonical example, boilerplate 1:1 CodingKeys** (`Models/ArticleModel.swift:11-26`):
```swift
struct Article: Codable, Identifiable {
    let id: String
    let title: String
    ...
    enum CodingKeys: String, CodingKey {
        case id
        case title
        case content
        case photoUrl
        case createdAt
        case updatedAt
    }
```
**Canonical example, dates as `String`, parsed ad hoc on the model** (`Models/ArticleModel.swift:36-45`):
```swift
let createdAt: String
...
var formattedDate: String {
    let formatter = ISO8601DateFormatter()
    guard let date = formatter.date(from: createdAt) else { return "Unknown date" }
    ...
```
`JSONDecoder().decode(...)` in `ApiService.swift:99` never sets a `dateDecodingStrategy` —
every date field decodes as `String` and is converted to `Date` (if at all) later, in a
computed property on the model, never centrally.
**Never:**
```swift
let createdAt: Date   // dates are never decoded directly as Date, 0/21 date fields
decoder.dateDecodingStrategy = .iso8601   // never set — 0 occurrences
```

## 41. API error mapping and retry/auth-refresh logic

### R-43: No auth/token-refresh logic exists (the app has no login, only a device UUID); "retry" is always a manual user-tapped button that re-calls the exact same fetch method  [LAW — 2/2 retry-capable screens use the identical shape, 0 auto-retry/backoff logic anywhere]
**Why I do it:** Since there's no account system, there's nothing to refresh — every
network failure surfaces to the user via `errorMessage`/`showError` and a `Button("Retry")`
that just calls `viewModel.retry()`, which is always a one-line wrapper re-invoking the
original fetch.
**Canonical example** (`Core/Screens/HistoryScreen/HistoryViewModel.swift:91-93`,
`Core/Screens/HistoryScreen/HistoryScreen.swift:56-60`):
```swift
func retry() { loadHistory() }
...
Button("Retry") { viewModel.retry() }
```
Identical shape in `BirdDetailViewModel.retry(id:)` (`BirdDetailViewModel.swift:44-46`) /
`ResultScreen.swift:86-88`.
**Never:**
```swift
.retry(3)                          // Combine's built-in retry operator — 0 occurrences, retry is always a manual user action
refreshAuthToken() { ... }         // no auth/token refresh exists anywhere — there is no auth system
```

## 42. Persistence

### R-44: Keychain for the one durable identifier, `@AppStorage`/`UserDefaults` for one-time UI flags, `NSCache` + manual disk cache for images — no CoreData, no SwiftData, no Realm  [LAW — 0/40 files reference CoreData/SwiftData/Realm]
**Why I do it:** There is no local database in this app; persistence needs are narrow and
each gets the simplest matching tool: `Keychain` (via the `KeychainAccess` SPM package) for
a UUID that must survive reinstalls, `@AppStorage` for boolean "have I shown this already"
flags, and a hand-rolled `NSCache`+`FileManager` pair for images.
**Canonical example, Keychain for a durable ID** (`Helpers/KeyChainAccess/DeviceIdManager.swift:15-19`):
```swift
private let keychain = Keychain(service: "com.birdid.app.deviceid")
    .accessibility(.always)
    .synchronizable(false)
private let deviceIDKey = "persistent_device_uuid"
```
**Canonical example, `@AppStorage` for a one-time flag** (`BirdIdApp.swift:12`,
`Core/Screens/MainScreen.swift:19`):
```swift
@AppStorage("hasSeenOnboarding") private var hasSeenOnboarding: Bool = false
@AppStorage("hasSeenPostOnboardingPaywall") private var hasSeenPostOnboardingPaywall = false
```
**Never:**
```swift
@Environment(\.modelContext) var modelContext   // SwiftData — 0 occurrences
NSManagedObjectContext                            // CoreData — 0 occurrences
Realm()                                           // Realm — 0 occurrences, despite being a common third-party alternative
```

## 43. Caching, image loading

### R-45: Two parallel image-loading systems coexist in the same app — a hand-rolled `CachedAsyncImage`/`ImageCacheManager` (used almost everywhere) and Kingfisher's `KFImage` (used in exactly one screen)  [CONFLICT — 4 files use the hand-rolled system, 1 file uses Kingfisher]
**Why I do it (as observed, not endorsed):** `CachedAsyncImage` (a bespoke
`AsyncImage`-style view backed by `NSCache` + a base64-filename disk cache) is the
default everywhere — `HomeScreen`/`HighlightsCard`, `HistoryItem`, `HabitatItem`,
`ResultScreen` all use it. `ArticleScreen` alone uses Kingfisher's `KFImage` instead, even
though Kingfisher is already an SPM dependency listed in `Package.resolved` and is not used
anywhere else — the two systems were never consolidated.
**Canonical example, the hand-rolled default** (`Core/Screens/HistoryScreen/HistoryScreenSubViews/HistoryItem.swift:60-68`):
```swift
CachedAsyncImage(url: URL(string: bird.image)) { image in
    image.resizable().scaledToFill()...
} placeholder: { ZStack { Color.gray.opacity(0.3); ProgressView().tint(.white) } }
```
**Canonical example, the one Kingfisher outlier** (`Core/Screens/ArticleScreen/ArticleScreen.swift:71-76`):
```swift
KFImage(URL(string: article.photoUrl))
    .resizable()
    .scaledToFill()
```
See Open Questions Q8.
**Never:** `AsyncImage` (SwiftUI's own built-in) — 0 occurrences; the author always reaches
for one of the two systems above instead of the stock API.

## 44. DI: manual init injection, singletons — the honest picture

### R-46: Constructor injection with a concrete default argument for anything protocol-abstracted (Repositories, `ApiService`); `.shared` singletons for infrastructure that is not naturally screen-scoped; no DI container/framework  [LAW — 15/15 repository-consuming initializers use the default-arg pattern, 3/3 singletons are `.shared`]
**Why I do it:** Every ViewModel/Screen that needs a Repository declares
`init(repository: XRepositoryProtocol = XRepository())` — production code never passes an
argument (the default IS the real implementation), and tests/previews override it with a
`Mock`. Things that are cross-cutting infrastructure rather than a per-screen dependency
(`DeviceIDManager`, `ImageCacheManager`, `SubscriptionManager`) are `.shared` singletons
reached by direct static access, not injected.
**Canonical example, default-arg protocol injection** (`Core/Screens/HaditatScreen/HabitatViewModel.swift:24-27`):
```swift
init(repository: HabitatsRepositoryProtocol = HabitatsRepository()) {
    self.repository = repository
    setupSearchDebounce()
}
```
**Canonical example, singleton for infrastructure** (`Helpers/KeyChainAccess/DeviceIdManager.swift:11-13`,
`Helpers/CacheImage/ImageCacheLoader.swift:11-12`, `Helpers/SubscriptionManager/SubscriptionManager.swift:22`):
```swift
static let shared = DeviceIDManager()
static let shared = ImageCacheManager()
static let shared = SubscriptionManager()
```
**Never:** a DI container/resolver (`Swinject`, `Factory`, a hand-rolled `ServiceLocator`)
— 0 occurrences; every dependency is either a default-arg constructor parameter or a
`.shared` static.

## 45. Localization: String Catalog / .strings / hardcoded

### R-47: All user-facing UI copy is a hardcoded English string literal directly in the SwiftUI view — no `.strings` file, no String Catalog (`.xcstrings`), no `NSLocalizedString`  [LAW — 0/40 files reference localization APIs]
**Why I do it:** The app ships one locale (English UI copy); the reality is every `Text(...)`
call embeds its literal string directly at the call site.
**Canonical example** (`Core/Screens/HistoryScreen/HistoryScreen.swift:23`):
```swift
Text("Records")
    .font(.app(.Headline1))
```
Persian text that DOES appear in the codebase is confined to `print()` debug output and a
handful of `errorMessage` strings surfaced only in a `Text(viewModel.errorMessage ??
"Unknown error")` fallback — never a `Text("...")` literal written directly for Persian UI
copy (see R-21). There is no `Localizable.strings`, no `.xcstrings` catalog, and
`NSLocalizedString`/`String(localized:)` are never called.
**Never:**
```swift
Text(String(localized: "history.title"))   // 0 occurrences — no localization key/catalog system exists
```


## 25. View decomposition: body length threshold, subview vs computed var

### R-27: Decompose first into a same-file computed `var`/`func` returning `some View`; only promote to a separate file when the piece is reused by more than one screen  [LAW — 55 same-file `some View` computed properties vs a handful of promoted files]
**Why I do it:** `IdentifyScreen.swift` is 461 lines and the largest file in the repo, but
its `body` itself is only ~40 lines — everything else is `private extension IdentifyScreen`
computed properties (`backgroundView`, `mainContent`, `headerSection`,
`currentScreenContent`) and private structs (`CameraScreenContent`, `MicScreenContent`,
`BottomBarView`) that are only ever used by this one screen, so they stay in the same file.
A subview only earns its own file in `<Feature>SubViews/` once a second screen needs it
(`HistoryItem.swift`, `HabitatItem.swift`, `BirdHabitatItem.swift`).
**Canonical example** (`Core/Screens/IdentifyScreen/IdentifyScreen.swift:26-42,68-78`):
```swift
var body: some View {
    ZStack {
        backgroundView
        mainContent
        ...
private extension IdentifyScreen {
    var backgroundView: some View {
        Group { if camera.isConfigured && currentMode == .camera { CameraLiveView(...) } ... }
    }
```
**Never:** a `body` that is one giant flat `VStack`/`ZStack` several hundred lines deep with
no extracted computed properties — even the 461-line file keeps `body` itself short.

## 26. `@State`/`@Binding`/`@StateObject`/`@ObservedObject`/`@Environment` — the ownership rule

### R-28: `@StateObject` at the point of instantiation (the owner), `@ObservedObject` everywhere a reference is merely passed down; `@EnvironmentObject` reserved for exactly two app-wide singletons (`Coordinator`, `TabManager`)  [LAW — 14 StateObject / 10 ObservedObject / 18 EnvironmentObject, always `Coordinator` or `TabManager`]
**Why I do it:** Whichever type creates a ViewModel/Controller with `= XViewModel()` marks
it `@StateObject`; every child view that receives that same instance as a parameter marks it
`@ObservedObject` instead, so SwiftUI never accidentally re-creates it.
**Canonical example, owner** (`Core/Screens/IdentifyScreen/IdentifyScreen.swift:13-17`):
```swift
@StateObject private var viewModel = IdentifyViewModel()
@StateObject private var camera = CameraController()
```
**Canonical example, passed-through** (`Core/Screens/HomeScreen/HomeScreenSubViews/BirdHabitatItem.swift:13`):
```swift
@ObservedObject var viewModel: HomeScreenViewModel   // owned by HomeScreen, observed here
```
`@EnvironmentObject` is never introduced for a third type — every one of the 18 occurrences
is `Coordinator` or `TabManager`. The one exception to Apple's newest API:
`@Environment(\.presentationMode)` (the pre-iOS 15 dismiss API) is used instead of the
newer `@Environment(\.dismiss)` — the only `@Environment` call in the repo
(`Core/Screens/PaymentScreen/PaymentScreen.swift:17,29,240`).
**Never:**
```swift
@EnvironmentObject var subscriptionManager: SubscriptionManager  // SubscriptionManager is always reached via .shared, never injected as an EnvironmentObject — 0 occurrences
@Environment(\.dismiss) var dismiss                               // the modern dismiss action — never used, presentationMode is used instead
```

## 27. ViewModel shape: instantiation and injection

### R-29: `@StateObject private var viewModel = XViewModel()` (self-owned, default-arg init) unless a parent must keep the same instance alive across a tab switch — then it is constructor-injected  [STRONG — 6/7 self-owned, 1/7 constructor-injected for a specific lifecycle reason]
**Why I do it:** `MainScreen` swaps `HomeScreen`/`IdentifyScreen`/`HistoryScreen`/
`SettingView` in and out based on `tabManager.selectedTab`; if `HomeScreen` created its own
`HomeScreenViewModel` internally, switching tabs and back would reset its search state. So
`MainScreen` owns `homeViewModel` and passes it in.
**Canonical example, the one constructor-injected case** (`Core/Screens/MainScreen.swift:16,33`):
```swift
@StateObject private var homeViewModel = HomeScreenViewModel()
...
HomeScreen(viewModel: homeViewModel)
```
**Canonical example, the default self-owned case** (`Core/Screens/HistoryScreen/HistoryScreen.swift:11`):
```swift
struct HistoryScreen: View {
    @StateObject private var viewModel = HistoryViewModel()
```
**Never:** a global ViewModel factory/container object that hands out ViewModels — every
ViewModel is either `= XViewModel()` inline or received via a plain `init` parameter, never
resolved from a registry.

## 28. Navigation: `NavigationStack`, `Route`, sheets/fullScreenCovers

### R-30: One `NavigationStack` bound to `coordinator.path`, one `Route` enum, one `.navigationDestination(for: Route.self)` call-site in the whole app; `.fullScreenCover`/`.sheet` are used instead of a `Route` for modal, non-stack content  [LAW — 1/1 navigationDestination site]
**Why I do it:** All pushed (non-modal) navigation funnels through `Coordinator.push(_:
Route)`; `MainScreen` is the only place that declares `.navigationDestination(for:
Route.self)`, delegating to `Coordinator.buildView(for:)`.
**Canonical example** (`Core/Screens/MainScreen.swift:23,52-54`):
```swift
NavigationStack(path: $coordinator.path){
    ...
    .navigationDestination(for: Route.self) { route in
        coordinator.buildView(for: route)
    }
```
**CONFLICT — the paywall is never a `Route`:** `PaymentScreen` (the paywall) is presented
via a local `@State private var show... = false` + `.fullScreenCover` at three independent
call sites (`MainScreen.swift:19-20,68-70`, `IdentifyScreenViewModel.swift:19` +
`IdentifyScreen.swift:60-62`, `SettingView.swift:12,48-50`) rather than a
`Route.paywall` case pushed through the `Coordinator` — every other cross-screen navigation
goes through `Route`, but the paywall is the one recurring exception, duplicated three
times with its own local boolean each time. See Open Questions Q4.
**Never:**
```swift
case .PaymentScreen                          // no Route case for the paywall — 0/5 Route cases
NavigationLink(destination: HabitatScreen(...))  // NavigationLink is never used for pushes — always coordinator.push(.someRoute) + navigationDestination
```

## 29. ViewModifier definitions

### R-31: Custom "modifiers" are always a `View` extension method with `@ViewBuilder`, never a formal `ViewModifier` struct  [LAW — 3/3 custom modifier-like helpers, 0 `ViewModifier` conformances]
**Why I do it:** `adaptiveGlassEffect(style:cornerRadius:)`, `shimmering(active:)`, and
`ifAvailable(_:)` are all plain `extension View { @ViewBuilder func ... -> some View }` —
never `struct X: ViewModifier` + `.modifier(X())`.
**Canonical example** (`Helpers/Extension/GlassEffect.swift:17-19`):
```swift
extension View {
    @ViewBuilder
    func adaptiveGlassEffect(style: GlassStyle? = nil, cornerRadius: CGFloat = 24) -> some View {
```
**Never:**
```swift
struct GlassEffectModifier: ViewModifier { func body(content: Content) -> some View { ... } }
view.modifier(GlassEffectModifier())   // 0 occurrences of the ViewModifier protocol anywhere
```

## 30. Design tokens: Color/Font/Spacing vs hardcoded literals

### R-32: `Font.app(_:)` token enum is used everywhere body/label text needs a font — but brand colors are hardcoded `Color(hex:)` literals repeated inline, never lifted into a shared token  [STRONG for fonts — 5 raw `.system(size:)` calls outside `Font+Extension.swift`, all confined to one file, all sizing SF Symbol icons rather than text / CONFLICT for colors — same hex repeated in 4+ files]
**Why I do it:** Typography went through the one-time cost of an `AppFont` enum + `Font.app`
static function and every screen calls it (`.font(.app(.Sub1))`); colors never got the same
treatment — the brand green `#5B765C` is retyped as a literal in at least 4 separate files
instead of becoming, say, `Color.brandGreen` next to the existing `Color(hex:)` initializer.
**CORRECTION (self-audit):** the original draft of this rule claimed zero raw
`.system(size:)` calls outside `Font+Extension.swift` — that was wrong. `HabitatItem.swift`
has 5 occurrences, all sizing an SF Symbol glyph (`.font(.system(size: 50))` on
`Image(systemName: "exclamationmark.triangle")`/`"bird"`/`"magnifyingglass"`), never body
text. The rule is narrowed accordingly: `Font.app` is used with zero exceptions for actual
label/body text; `.system(size:)` is tolerated only for sizing an SF Symbol icon glyph.
**Canonical example, the tolerated icon-sizing exception** (`Core/Screens/HaditatScreen/HabitatSubViews/HabitatItem.swift:101-102`):
```swift
Image(systemName: "bird.fill")
    .font(.system(size: 50))
```
**Canonical example, font token used consistently** (`Core/Screens/HomeScreen/HomeScreen.swift:43-44`):
```swift
Text("Photo\nIdentification")
    .font(.app(.Sub2))
```
**Canonical example, color literal duplicated instead of tokenized**
(`Core/Screens/Splash/SplashScreen.swift:19`, `Core/Screens/IdentifyScreen/IdentifyScreenMode.swift:26`,
`Core/Screens/IdentifyScreen/IdentifyScreen.swift:74`, `Core/Screens/Result/ResultScreenSubViews/BirdInfoItem.swift:377`):
```swift
private let splashGreen = Color(hex: "#5B765C")     // SplashScreen.swift
default: return Color(hex: "#5B765C")               // IdentifyScreenMode.swift
Color(hex: "#5B765C")                               // IdentifyScreen.swift (background fallback)
.background(Color(hex: "#5B765C"))                  // BirdInfoItem.swift (preview only)
```
Semantic colors that DO exist as asset-catalog entries (`Colors/DarkColor`,
`Colors/StrikeTextColor`, `Colors/TextColor`) are referenced via SwiftUI's generated
`Color.text` / `.strikeText`, so the pattern is: named UI-chrome colors go through the asset
catalog, one-off brand/background colors are inline hex. See Open Questions Q5.
**Never:** a `Spacing` token enum/extension — padding values are always inline numeric
literals (`.padding(.horizontal, 24)`, `.padding(.bottom, 16)`) or computed from
`UIScreen.screenHeight / <magic divisor>` (see R-33); no `Spacing.medium` style token exists.

## 31. Reusable components library

### R-33: `CustomView/` holds screen-agnostic, genuinely-reused SwiftUI components; the type name is bare/descriptive unless it would collide with a SwiftUI API name, in which case it gets a `Custom` prefix  [LAW — 4/4 components in CustomView/]
**Why I do it:** `BackButtonView`, `CheckedView`, `SearchTextField` are named plainly; the
one component that wraps a concept SwiftUI itself names (`TabView`) is called
`CustomTabBar` to avoid the collision and signal "this is our bespoke version."
**Canonical example** (`CustomView/TabBar.swift:11`):
```swift
struct CustomTabBar: View {
```
Common sizing idiom across every custom component: dimensions are `UIScreen.screenWidth /
<divisor>` / `UIScreen.screenHeight / <divisor>` magic-number ratios rather than fixed
points (e.g. `UIScreen.screenWidth / 8.18`, `UIScreen.screenHeight / 17.75` for every
circular icon button — `BackButtonView.swift:30`, `IdentifyBackButton.swift:32`,
`InfoCircleButton.swift:25` all use the exact same two divisors).
**Never:** a component named with a `View` suffix when it's a screen-agnostic reusable
piece with no natural collision risk (`SearchTextField`, not `SearchTextFieldView`) —
`View` suffix is reserved for cases like `CheckedView`/`BackButtonView` where the bare noun
alone (`Checked`, `BackButton`) would read oddly.

## 32. Loading / empty / error view states

### R-34: Three different "loading" idioms and two different "error" idioms coexist — never unified into one shared component  [CONFLICT — 2 loading flavors / 2 error flavors]
**Why I do it (as observed, not endorsed):** Each screen's loading/error state was written
independently at the time that screen was built, so the exact spinner styling and error
presentation drifted.
**Canonical example, loading flavor A — bare tint** (`Core/Screens/HistoryScreen/HistoryScreen.swift:34-36`,
`Core/Screens/Result/ResultScreen.swift:51-53`):
```swift
ProgressView()
    .scaleEffect(1.5)
    .tint(.text)
```
**Canonical example, loading flavor B — CircularProgressViewStyle** (`Core/Screens/HomeScreen/HomeScreen.swift:108-109`,
`Core/Screens/ArticleScreen/ArticleScreen.swift:27-28`, `Core/Screens/HomeScreen/HomeScreenSubViews/HighlightsCard.swift:33-34`):
```swift
ProgressView()
    .progressViewStyle(CircularProgressViewStyle(tint: .white))
```
**Canonical example, error flavor A — inline SF Symbol + text** (`Core/Screens/HaditatScreen/HabitatSubViews/HabitatItem.swift:31-46`):
```swift
Image(systemName: "exclamationmark.triangle")
    .font(.system(size: 50))
    .foregroundColor(.red.opacity(0.7))
```
**Canonical example, error flavor B — native `.alert`** (`Core/Screens/HistoryScreen/HistoryScreen.swift:56-63`,
`Core/Screens/Result/ResultScreen.swift:84-93`):
```swift
.alert("Error", isPresented: $viewModel.showError) {
    Button("Retry") { viewModel.retry() }
    Button("Cancel", role: .cancel) {}
} message: { Text(viewModel.errorMessage ?? "Unknown error") }
```
Empty states DO get a named, extracted struct when the state is a first-class "nothing
here yet" screen (`EmptyHistoryView` in `HistoryScreen.swift:68-89`), but stay as inline
private computed properties when they're one of several branches in a grid
(`HabitatItem.emptyStateView`/`emptySearchStateView`, `HabitatItem.swift:99-123`).
See Open Questions Q6.
**Never:** a shared `LoadingView`/`ErrorView`/`EmptyStateView` component reused across
screens — every screen re-implements its own loading/error presentation from scratch.

## 33. Lists, ScrollView, Lazy* habits; id/Identifiable handling

### R-35: `LazyVGrid`/`LazyHGrid` with hardcoded `.fixed(UIScreen.screenWidth / 2 - N)` columns for real data; `ForEach(0..<N, id: \.self)` reserved strictly for decorative/fixed-count content, never real API data  [LAW — 4/4 `ForEach(0..<N` occurrences are decorative]
**Why I do it:** Two-column bird grids always use two `GridItem(.fixed(...))` entries with
a hand-computed width (`UIScreen.screenWidth / 2 - 32` or `- 24` depending on the screen's
outer padding) — never `.adaptive(minimum:)` or `.flexible()`. The `ForEach(0..<N, id:
\.self)` "loop N times" idiom appears exactly 4 times in the codebase, and every single
time it's for placeholder/decorative content, never real model data (which always iterates
by the model's own `Identifiable` id or `\.food.id`/`\.offset`).
**Canonical example, real-data grid** (`Core/Screens/HistoryScreen/HistoryScreenSubViews/HistoryItem.swift:22-25`):
```swift
private let columns = [
    GridItem(.fixed(UIScreen.screenWidth / 2 - 32), spacing: 16),
    GridItem(.fixed(UIScreen.screenWidth / 2 - 32), spacing: 16)
]
```
**Canonical example, decorative-count loop** (`Core/Screens/HomeScreen/HomeScreenSubViews/BirdHabitatItem.swift:20`
— 4 loading-placeholder circles, not 4 real habitats):
```swift
ForEach(0..<4, id: \.self) { index in ... }   // loading skeleton, not data
```
**Never:**
```swift
ForEach(0..<viewModel.birds.count, id: \.self) { i in ... }   // real data is never iterated by raw index — always by the model's id
GridItem(.adaptive(minimum: 150))                              // adaptive/flexible grid columns — 0 occurrences, always .fixed
```

## 34. Animation and transition style

### R-36: `.easeInOut` for simple toggles, `.spring(response:dampingFraction:)` for anything that should feel tactile/selectable — duration/response values are always inline literals, never named constants  [STRONG — 23 animation call sites, 0 shared `Animation` token]
**Why I do it:** State toggles that just show/hide something (search overlay blur, MARK
transitions between onboarding steps) use `.easeInOut(duration: 0.3)`; anything the user
directly taps to select (plan cards, mode-switch buttons, onboarding answers) uses
`.spring(response: 0.3...0.45, dampingFraction: 0.75...0.8)` so it feels bouncier/more alive.
**Canonical example, simple toggle** (`Core/Screens/HomeScreen/HomeScreen.swift:128`):
```swift
.animation(.easeInOut(duration: 0.3), value: viewModel.showSearchResults)
```
**Canonical example, tactile selection** (`Core/Screens/IdentifyScreen/IdentifyScreen.swift:387`,
`Core/Screens/PaymentScreen/PaymentScreen.swift:81,94`):
```swift
withAnimation(. spring(response: 0.45, dampingFraction: 0.75)) { currentMode = mode }
withAnimation(.easeInOut(duration: 0.25)) { selectedPlan = plan.type }
```
Unlike `Font` and `Color`, animation curves never got their own `extension Animation { static
let ... }` token file — every value is retyped as a literal at the call site (a gap; see
Open Questions Q7).
**Never:**
```swift
extension Animation { static let snappy = Animation.spring(...) }  // no shared animation tokens exist, 0/40 files
```

## 35. Previews

### R-37: `#Preview` macro (never the old `PreviewProvider` protocol); fresh `Coordinator()`/`TabManager()` injected per preview; mock data via a dedicated `.mock` static var for anything reused, or an inline literal for one-off simple cases  [LAW — 25 `#Preview` blocks, 0 `PreviewProvider` structs]
**Why I do it:** Every preview is the lightweight `#Preview { ... }` trailing-closure macro
(Xcode 15+), never `struct X_Previews: PreviewProvider`. A model gets a `MockData.swift`
`.mock` extension once it's complex enough to be annoying to construct by hand
(`BirdDetailResponse.mock`, `UploadResponse.mock`/`.mockProcessing`/`.mockFailed`,
`HistorySimpleModel.mock`/`.mockList`); a simple model is just constructed inline in the
`#Preview` block itself.
**Canonical example, macro + fresh environment objects** (`Core/Screens/HistoryScreen/HistoryScreen.swift:91-94`):
```swift
#Preview {
    HistoryScreen()
        .environmentObject(Coordinator())
}
```
**Canonical example, inline mock for a simple model** (`Core/Screens/HomeScreen/HomeScreenSubViews/HighlightsCard.swift:65-73`):
```swift
#Preview {
    HighlightsCard(article: Article(
        id: "1", title: "Best secrets of attracting birds to your garden", ...
    ))
    .environmentObject(Coordinator())
}
```
**Never:**
```swift
struct HistoryScreen_Previews: PreviewProvider {
    static var previews: some View { HistoryScreen() }
}   // 0 occurrences — always the #Preview macro
```


## 16. Property wrappers

### R-18: Only Apple's stock property wrappers — never a custom `@propertyWrapper`  [LAW — 0/40 custom wrappers, 128 stock-wrapper occurrences]
**Why I do it:** Every piece of observable/injected state uses a built-in SwiftUI/Combine
wrapper (`@Published` ×59, `@State` ×21, `@EnvironmentObject` ×18, `@StateObject` ×14,
`@ObservedObject` ×10, `@AppStorage` ×2, `@FocusState` ×1, `@Namespace` ×2,
`@Environment(\.presentationMode)` ×1) — no custom wrapper is ever defined to, say, add
validation, clamping, or persistence sugar.
**Canonical example** (`Core/Screens/HomeScreen/HomeScreenViewModel.swift:14-26`):
```swift
@Published var searchText = ""
@Published var habitats: [HabitatsModel] = []
```
**Never:**
```swift
@propertyWrapper struct Clamped<T: Comparable> { ... }   // 0 occurrences — no custom property wrappers anywhere
```

## 17. Value semantics

### R-19: Structs are treated as immutable data — `mutating func` is never written  [LAW — 0/77 structs]
**Why I do it:** Every `struct` in the repo (SwiftUI views, DTOs, `RoundedCorner: Shape`) is
either recreated wholesale or has all-`let` stored properties; there is not one
`mutating func` anywhere. Mutable, evolving state always lives in a `class` behind
`@Published`, never as an in-place-mutated struct.
**Canonical example** (`Models/HistorySimpleModel.swift:10-14`):
```swift
struct HistorySimpleModel: Codable, Identifiable, Equatable {
    let birdId: Int
    let scientificName: String
    let image: String
```
**Never:**
```swift
struct HistorySimpleModel {
    var viewCount = 0
    mutating func markViewed() { viewCount += 1 }   // 0 occurrences of mutating func in the repo
}
```

## 18. Trailing closures, shorthand args, functional style vs for-loops

### R-20: Trailing closures everywhere SwiftUI/Combine call for them; `for`-in loops preferred over chained `.map`/`.filter`/`.reduce` for anything beyond a one-liner; `$0` reserved for short one-line transforms  [STRONG — 10 for-in vs 7 functional-chain call sites, 11 `$0` uses]
**Why I do it:** SwiftUI's own DSL (`Button { } label: { }`, `.sink { } receiveValue: { }`)
is always used in its native multi-trailing-closure form. Beyond that, iterating a
collection to build up debug output or side effects reads as an explicit `for bird in
response.prefix(3) { print(...) }` rather than a `.forEach`/`.map` chain; `.map`/`.filter`
are reserved for short, single-expression transforms.
**Canonical example, preferred for-in** (`Core/Screens/HaditatScreen/HabitatViewModel.swift:79-81`):
```swift
response.prefix(3).forEach { bird in
    print("   🐦 \(bird.scientificName) - ID: \(bird.birdId)")
}
```
**Canonical example, `$0` for a short transform** (`Core/Repositories/BirdSearchRepository.swift:25`):
```swift
let encodedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? query
```
(and, e.g., `.compactMap { $0 }` in `AudioPickerController.swift:40`).
**Never:**
```swift
response.data.map { $0.scientificName }.forEach { print($0) }   // stacked functional chains for control flow — avoided in favor of a plain for/forEach
```

## 19. `// MARK:` / `// TODO:` / comment language

### R-21: Structural comments and identifiers are English; ad hoc debug `print()` output and some user-facing error strings are Persian (Farsi)  [WEAK — 2/40 files, but internally exhaustive within those files]
**Why I do it:** The author is a Persian speaker; when debugging network/error flows under
time pressure, the diagnostic narration and the string shown to the user in an alert
switches to Farsi, while all type/property/method names and MARK banners stay English.
**Canonical example** (`Core/Screens/IdentifyScreen/IdentifyScreenViewModel.swift:103,112,139,150`):
```swift
print("درخواست با موفقیت تمام شد (ولی ممکنه success قبلاً فراخوانی شده باشه)")
print("   دلیل: تایم‌اوت — سرور پاسخ نداد")
errorMessage = "اتصال به اینترنت برقرار نیست"
print("نمایش خطا به کاربر: \(errorMessage ?? "نامشخص")")
```
and (`Core/Repositories/UploadRepository.swift:36`):
```swift
print("🚀 ============ شروع آپلود ============")
```
`TODO` is rare (3 occurrences total) and always a bare `//TODO:` or `//TODO: ...` with no
ticket reference (`Core/Screens/IdentifyScreen/IdentifyScreenSubViews/InfoCircleButton.swift:15`,
`Core/Screens/Setting/SettingView.swift:36,40`).
**Never:** a JIRA/Linear ticket ID inside a `TODO` comment — none of the 3 TODOs reference
an external tracker.

## 20. Doc comments (`///`)

### R-22: `///` reserved for the handful of functions whose behavior is genuinely non-obvious from the signature — not applied systematically  [WEAK — 6 genuine `///` comments across 2 files]
**Why I do it:** Most functions get zero doc comment; the six that exist explain a
surprising *consequence* (an empty array is intentional; a debug-only reset function exists)
rather than restating the signature.
**Canonical example** (`Helpers/KeyChainAccess/DeviceIdManager.swift:23,46`):
```swift
/// Always returns one consistent UUID
func getDeviceUUID() -> String { ... }
/// For debugging only
func resetDeviceUUID() -> String { ... }
```
and (`Core/Screens/PaymentScreen/PaymentScreen.swift:155-156`):
```swift
/// Builds plans from RevenueCat offerings (real prices, not mock).
/// Returns an empty array until offerings load, so the UI can show a loader.
private var dynamicPlans: [PlanItem] { ... }
```
**Never:** a `/// - Parameter x:` / `/// - Returns:` Apple-style structured doc block —
0 occurrences; every `///` here is one or two plain prose lines.

## 21. async/await vs Combine vs callbacks

### R-23: Combine (`AnyPublisher`) is the app's own concurrency currency; `async/await` only when consuming a modern system API; completion-handler callbacks only when wrapping a third-party SDK that is itself callback-based  [LAW — 7/7 repositories are Combine, 1/1 async-native consumption, RevenueCat calls are 100% callback-style]
**Why I do it:** Every Repository/ViewModel network call returns `AnyPublisher<T, Error>`.
`async/await` shows up exactly where a system API is async-only (`PhotosPickerItem.
loadTransferable`, `Task.sleep` for the splash delay) — the author does not wrap those back
into Combine. RevenueCat's SDK is callback-based (`Purchases.shared.getOfferings { offerings,
error in }`), so `SubscriptionViewModel`/`SubscriptionManager` stay callback-based to match it,
wrapped in `Task { }` only where the RevenueCat method itself is `async throws`.
**Canonical example, Combine as the default** (`Core/Repositories/HistoryRepository.swift:24-35`):
```swift
func fetchHistory() -> AnyPublisher<[HistorySimpleModel], Error> {
    ...
    return apiService.request(url, method: .get, body: nil, headers: nil,
                               expecting: [HistorySimpleModel].self)
}
```
**Canonical example, async/await only for a system API** (`Core/Screens/IdentifyScreen/Gallery/PhotoPickerController.swift:27-28`):
```swift
Task {
    if let data = try? await selection.loadTransferable(type: Data.self) { ... }
}
```
**Canonical example, callback because the SDK is callback-based** (`Core/Screens/PaymentScreen/PaymentScreenViewModel.swift:27-37`):
```swift
Purchases.shared.getOfferings { offerings, error in
    DispatchQueue.main.async { ... }
}
```
**Never:**
```swift
func fetchHistory() async throws -> [HistorySimpleModel]   // no repository is ever rewritten to async/await — 0/7
```

## 22. `@MainActor` usage; Task; cancellation

### R-24: Two competing main-thread-safety patterns coexist: class-level `@MainActor` (newer files) and manual `.receive(on: DispatchQueue.main)` / `DispatchQueue.main.async` (older files)  [CONFLICT — 4 files `@MainActor` vs remaining ViewModels manual-dispatch]
**Why I do it:** `HomeScreenViewModel`, `HistoryViewModel`, `SubscriptionManager`, and
`PhotoPickerController` are annotated `@MainActor` at the class level; `IdentifyViewModel`,
`BirdDetailViewModel`, `HabitatViewModel`, `ArticleViewModel` rely instead on
`.receive(on: DispatchQueue.main)` in the Combine chain and ad hoc
`DispatchQueue.main.asyncAfter` calls for delayed UI transitions. Both achieve correctness,
but the codebase has not converged on one.
**Canonical example, class-level `@MainActor`** (`Core/Screens/HomeScreen/HomeScreenViewModel.swift:12-13`):
```swift
@MainActor
class HomeScreenViewModel: ObservableObject {
```
**Canonical example, manual dispatch** (`Core/Screens/Result/BirdDetailViewModel.swift:27-28`):
```swift
repository.fetchBirdDetail(id: id)
    .receive(on: DispatchQueue.main)
```
In-flight search requests are explicitly cancelled before starting a new one — the only
place `.cancel()` is called by hand (`HomeScreenViewModel.swift:83`,
`HabitatViewModel.swift:89`): `searchCancellable?.cancel()`. See Open Questions Q3.
**Never:** `Task.detached`, `TaskGroup`, or any structured-concurrency cancellation handler
(`withTaskCancellationHandler`) — 0 occurrences; cancellation is Combine's
`AnyCancellable.cancel()` only.

## 23. Sendable, actors, isolation

### R-25: `Sendable` and Swift's `actor` type are never adopted — isolation is `@MainActor`-or-nothing  [LAW — 0/40 files]
**Why I do it:** The codebase predates/ignores strict-concurrency adoption; thread-safety
for shared mutable state (`ImageCacheManager`, `DeviceIDManager`) is achieved by the data
structure itself being thread-safe (`NSCache`) or by every call happening to originate on
the main thread, not by explicit `Sendable` conformance or `actor` isolation.
**Canonical example** (`Helpers/CacheImage/ImageCacheLoader.swift:11-14`):
```swift
class ImageCacheManager {
    static let shared = ImageCacheManager()
    private let cache = NSCache<NSString, UIImage>()
```
**Never:**
```swift
actor ImageCacheManager { ... }              // 0 occurrences
final class Foo: @unchecked Sendable { ... } // Sendable conformance never declared, checked or unchecked
```

## 24. Combine: publisher naming, cancellables storage, operator habits

### R-26: `AnyPublisher<T, Error>` is the universal return type; cancellables live in `Set<AnyCancellable>` named `cancellables` (one outlier: `cancelBag`); `.sink { completion } receiveValue: { }` trailing-closure form only; `.assign` never used  [LAW — 7/7 AnyPublisher-typed repositories / STRONG — 6/7 named `cancellables`]
**Why I do it:** Every async boundary is erased to `AnyPublisher<T, Error>` so callers never
see Alamofire's or URLSession's concrete publisher types. Cancellables collect in a
`Set<AnyCancellable>` on the ViewModel, always named `cancellables` — except
`IdentifyViewModel`, which calls it `cancelBag` (`IdentifyScreenViewModel.swift:22`), the
one deviation. `.sink(receiveCompletion:receiveValue:)`'s labeled-argument form is never
used — always the two-trailing-closure form. `.assign(to:on:)` is never used (0
occurrences) — every publisher output is routed through `.sink` and assigned manually so a
`print()`/side-effect can sit alongside the assignment.
**Canonical example** (`Core/Screens/ArticleScreen/ArticleViewModel.swift:32-49`):
```swift
private var cancellables = Set<AnyCancellable>()
...
repository.fetchArticles()
    .sink { [weak self] completion in
        ...
    } receiveValue: { [weak self] articles in
        ...
    }
    .store(in: &cancellables)
```
Debounced search (`HomeScreenViewModel.swift:72-73`, `HabitatViewModel.swift:31-32`) always
pairs `.debounce(for: .milliseconds(N), scheduler: DispatchQueue.main)` with
`.removeDuplicates()`, at 300ms (home bird search) or 500ms (habitat filter search).
**Never:**
```swift
$searchText.assign(to: &$debouncedText)   // .assign is never used, 0/40 files
publisher.sink(receiveCompletion: { ... }, receiveValue: { ... })  // labeled-argument sink form — 0 occurrences, always the trailing-closure form
```


## 8. struct vs class vs enum vs actor

### R-10: struct for views and DTOs, class for anything with identity/shared mutable state, `actor` never used  [LAW — 77 structs / 29 classes / 0 actors]
**Why I do it:** Every SwiftUI `View` is a `struct` (SwiftUI requirement, 0 exceptions).
Every network response model is a `struct: Decodable`. `class` is reserved for things with
reference identity: ViewModels (`ObservableObject`), Repositories, Controllers that own
`AVCaptureSession`/`AVAudioRecorder` state, and singletons.
**Canonical example** (`Core/Screens/IdentifyScreen/Camera/CameraController.swift:13`):
```swift
final class CameraController: NSObject, ObservableObject {
    @Published var capturedImage: UIImage?
    let session = AVCaptureSession()
```
vs. (`Models/HabitatsModel.swift:11`):
```swift
struct HabitatsModel: Codable, Identifiable, Hashable {
    let id: Int
    let name: String
```
Swift's native `actor` type is never used (0/40 files) — concurrency isolation is done with
`@MainActor` on the class instead (see R-22).
**Never:**
```swift
actor CameraController { ... }              // 0 occurrences of the actor keyword anywhere
struct HistoryViewModel: ObservableObject   // ViewModels are never structs — impossible with ObservableObject anyway, but confirms the mental model
```

## 9. Protocols

### R-11: One protocol per Repository plus one for ApiService — never for ViewModels, Views, or Models  [LAW — 8/8 protocols]
**Why I do it:** The DI seam is exactly at the network boundary. Every one of the 8
protocols in the codebase is `<Feature>RepositoryProtocol` (7) or `ApiServiceProtocol` (1),
always with the literal suffix `Protocol`, always satisfied by exactly one real class plus
(for 3 of them) one `Mock` class.
**Canonical example** (`Core/Repositories/HistoryRepository.swift:13,17,40`):
```swift
protocol HistoryRepositoryProtocol {
    func fetchHistory() -> AnyPublisher<[HistorySimpleModel], Error>
}
class HistoryRepository: HistoryRepositoryProtocol { ... }
class MockHistoryRepository: HistoryRepositoryProtocol { ... }
```
`associatedtype` is never used (0 occurrences) — every protocol here only needs to abstract
over a network call, never over a generic algorithm.
**Never:**
```swift
protocol HistoryViewModelProtocol { ... }     // ViewModels are never abstracted behind a protocol
protocol BirdDisplayable { associatedtype ... }   // no associatedtype-based protocols anywhere
```

## 10. Access control

### R-12: `private` used liberally, `fileprivate` never, explicit `internal` never, `public`/`open` only where UIKit forces it  [LAW — 160 `private` / 0 `fileprivate` / 0 explicit `internal` / 1 forced `public`]
**Why I do it:** Every ViewModel's repository/cancellables/state is `private`; every
`internal` (the default, i.e. every `struct`/`class`/`func` declared with no modifier) is
implicit — access control is binary in this codebase: private-to-the-file/type, or
default-internal. There is exactly one `public` in the whole repo, and it's not a choice —
it's `UINavigationController`'s `UIGestureRecognizerDelegate` conformance, which requires
matching Objective-C's public visibility.
**Canonical example** (`Core/Screens/IdentifyScreen/IdentifyScreenViewModel.swift:22-24`):
```swift
private var cancelBag = Set<AnyCancellable>()
private let uploadRepo: UploadRepositoryProtocol
private weak var coordinator: Coordinator?
```
The one forced exception (`Helpers/Extension/UIScreen+Extension.swift:17-23`):
```swift
extension UINavigationController: @retroactive UIGestureRecognizerDelegate {
    open override func viewDidLoad() { ... }
    public func gestureRecognizerShouldBegin(_ gestureRecognizer: UIGestureRecognizer) -> Bool
```
**Never:**
```swift
fileprivate func helper() { ... }   // 0 occurrences — private is used even for single-file scoping
internal struct Foo { ... }         // explicit `internal` never written — always implicit
```

## 11. Optionals

### R-13: `guard let` at the top of a function for early exit, `if let` for branching mid-view; force-unwrap tolerated only for "provably safe" casts/date math; `try!` never  [STRONG — 39 guard-let / 60 if-let / ~8 force-unwraps / 0 `try!`]
**Why I do it:** `guard let` reads as a precondition ("bail if missing"); `if let` reads as
a UI branch ("show A or B"). Force-unwrap (`!`) is allowed only where the author has just
proven, one line above, that the value must exist (a hardcoded `DateComponents`, a known
`CALayer` subclass, a `.coolFacts!` after checking a switch `case` that only renders when
the tab is `.coolFacts`) — never on network/user input.
**Canonical example, guard-let precondition** (`Core/Repositories/HabitatsRepository.swift:64-66`):
```swift
guard let url = components?.url?.absoluteString else {
    return Fail(error: URLError(.badURL)).eraseToAnyPublisher()
}
```
**Canonical example, tolerated force-unwrap** (`Core/Screens/Result/ResultScreenSubViews/BirdInfoItem.swift:341`
and `CameraPreview.swift:21`):
```swift
let date = Calendar.current.date(from: DateComponents(month: month))!
private var previewLayer: AVCaptureVideoPreviewLayer { return layer as! AVCaptureVideoPreviewLayer }
```
`try!` never appears (0/40 files) — even in previews and mock data, failable throwing calls
go through `try?` (`DeviceIdManager.swift:29`: `try? keychain.getString(...)`).
**Never:**
```swift
let data = try! JSONEncoder().encode(model)   // try! — 0 occurrences anywhere
let user = response.user!                      // force-unwrapping a raw network response field — 0 occurrences
```

## 12. Error handling

### R-14: One custom `APIError: LocalizedError` enum for the network layer; Combine's `Error` channel end to end; `throws` almost never used directly  [LAW — 1 error enum / STRONG — Combine-only propagation]
**Why I do it:** `ApiService` maps every failure mode (HTTP status, decoding, network,
unknown) into `APIError`, and every Repository/ViewModel signature is
`AnyPublisher<T, Error>` rather than a `throws` function — errors flow as Combine
completions, handled in a `.sink { completion in switch completion { case .failure(let e) ...` }`.
**Canonical example** (`Core/InternetServices/ApiService.swift:183-201`):
```swift
enum APIError: LocalizedError {
    case httpError(statusCode: Int, data: Data)
    case decodingError(underlyingError: DecodingError, data: Data)
    case networkError(underlyingError: URLError)
    case unknownError
```
**CONFLICT — inconsistent error currency in one file:** `UploadRepository.swift:70,79`
throws a raw `NSError` with a magic string domain and numeric codes instead of extending
`APIError` — this is the ONLY place in the repo that manufactures its own ad hoc error type:
```swift
throw NSError(domain: "BirdId", code: 1001,
    userInfo: [NSLocalizedDescriptionKey: "Processing is not completed yet. Status: \(uploadResponse.status)"])
```
See Open Questions Q1.
**Never:**
```swift
func fetchHistory() throws -> [HistorySimpleModel]   // a throwing (non-Combine) repository method — 0/7 repositories
Result<T, APIError>                                    // Result type never used — Combine's Error channel does this job instead
```

## 13. Extensions: organization and MARK conventions

### R-15: `// MARK: - <Section>` banners split a file into logical regions; `private extension View`/`extension Screen` blocks group private helpers — never one-extension-per-protocol-per-file  [LAW — 100 `// MARK:` occurrences across 40 files]
**Why I do it:** Long screen files stay navigable in Xcode's jump bar by grouping related
computed properties/methods under a same-file `extension`, tagged with `// MARK: - Name`,
rather than splitting into many small files.
**Canonical example** (`Core/Screens/IdentifyScreen/IdentifyScreen.swift:67-68,159-160,393-394`):
```swift
// MARK: - View Components
private extension IdentifyScreen { var backgroundView: some View { ... } }
// MARK: - Action Handlers
private extension IdentifyScreen { func handleCapturePhoto() { ... } }
// MARK: - View Modifiers
private extension View { func setupLifecycle(...) -> some View { ... } }
```
Model files use the same banner convention per nested DTO rather than per protocol
conformance (`Models/UploadModel.swift`: `// MARK: - Media`, `// MARK: - Bird Foods`, etc. —
16 banners in one file, one per struct, not one per `Codable`/`Decodable` extension).
**Never:**
```swift
// IdentifyScreen+Codable.swift  — a file whose only content is one protocol's extension
extension IdentifyScreen: Codable { ... }
```

## 14. Generics

### R-16: Generics reached for only at the networking/image-loading boundary — never in app/domain code  [STRONG — 12/12 generic-code occurrences confined to 3 files]
**Why I do it:** `ApiService.request<T: Decodable>` and `multipartRequest<T: Decodable>`
need to be generic because every Repository decodes a different response type; outside of
that boundary (and `CachedAsyncImage<Content: View, Placeholder: View>`, which mirrors
SwiftUI's own `AsyncImage` API), no ViewModel, Repository, or domain enum is ever made
generic — each Repository has concrete, spelled-out return types.
**Canonical example** (`Core/InternetServices/ApiService.swift:45-51`):
```swift
func request<T: Decodable>(
    _ url: String, method: HTTPMethod, body: [String: Any]? = nil,
    headers: [String: String]? = nil, expecting: T.Type
) -> AnyPublisher<T, Error> {
```
**Never:**
```swift
class Repository<Model: Decodable> { ... }        // no generic Repository base class — every repo is concretely typed
protocol Fetchable { associatedtype Response }    // no generic-abstraction protocols
```

## 15. Naming

### R-17: Types PascalCase, members lowerCamelCase, booleans `is`/`show`/`has`-prefixed, single-letter `T` for the only generic param used  [LAW — 38/38 boolean properties sampled]
**Why I do it:** Standard Swift casing throughout, with one very consistent boolean-naming
convention: state that gates a UI branch is `show*` (`showSearchResults`,
`showLoadingScreen`, `showCheckedView`, `showPaywall`, `showError`), state that reflects an
in-flight operation is `is*` (`isLoading`, `isSearching`, `isLoadingHabitats`,
`isLoadingBirdDetail`, `isPremium`, `isPurchasing`), and persisted one-time flags are
`has*` via `@AppStorage` (`hasSeenOnboarding`, `hasSeenPostOnboardingPaywall`).
**Canonical example** (`Core/Screens/HomeScreen/HomeScreenViewModel.swift:14-26`):
```swift
@Published var isLoadingHabitats = false
@Published var isSearching = false
@Published var showSearchResults = false
@Published var showLoadingScreen = false
```
Generic parameters are always the bare single letter `T` (never `Element`, `Value`, or a
descriptive name) — 12/12 generic-function occurrences use `T`.
**CONFLICT — enum case casing is inconsistent:** almost every enum uses lowerCamelCase
cases (`OnboardingData.firstPage`, `IdentificationMode.camera`, `PlanType.discount`,
`CheckedState.success`), but `AppFont` uses PascalCase cases matching the type names they
mirror (`Font+Extension.swift:12-26`):
```swift
enum AppFont {
    case Title1
    case Headline1
    case Sub1
    case Micro1
```
This is the only enum in the repo with capitalized cases — 1 file against 10 that follow
standard casing. Treat `AppFont`'s casing as a special, deliberate exception (it visually
mirrors a type-style naming for design tokens), not as license to capitalize new enum cases
elsewhere. See Open Questions Q2.
**Never:**
```swift
case IsLoading = false           // properties are never PascalCase
var loadingHabitatsFlag: Bool    // booleans never named without is/show/has prefix
```


## 1. UI framework reality

### R-1: SwiftUI is the default; UIKit only where SwiftUI has no native API  [LAW — 40/40 files]
**Why I do it:** SwiftUI covers 34 of the 40 Swift files outright. UIKit appears in exactly
6 files, every time to wrap a system capability SwiftUI cannot reach directly: live camera
session (`AVCaptureSession`), document picking, and Lottie's `UIView`-based renderer.
**Canonical example** (`Core/Screens/IdentifyScreen/Camera/CameraLiveView.swift:12-24`):
```swift
struct CameraLiveView: UIViewControllerRepresentable {
    @ObservedObject var controller: CameraController
    func makeUIViewController(context: Context) -> CameraViewController { ... }
    func updateUIViewController(_ uiViewController: CameraViewController, context: Context) {}
}
```
The UIKit boundary is always exactly at `UIViewControllerRepresentable`/`UIViewRepresentable`
— never a bare `UIViewController` pushed via `UINavigationController`. Occurrences:
`CameraLiveView.swift`, `AudioPickerController.swift` (`UIDocumentPickerViewController`),
`LottieView.swift` (`LottieAnimationView`), `CameraPreview.swift` (unused legacy variant),
`CameraController.swift`/`AudioRecorderController.swift` (pure `AVFoundation`, no UI).
**Never:**
```swift
// A UIKit UIViewController pushed directly onto a UINavigationController.
class SomeScreenViewController: UIViewController { ... }
```

## 2. Architecture pattern as actually practiced

### R-2: MVVM with one centralized Coordinator — every screen  [LAW — 7/7 screens]
**Why I do it:** Every feature that has state gets a `View` + an `ObservableObject`
ViewModel; navigation is never handled inside the View itself, it always goes through
the single app-wide `Coordinator`.
**Canonical example** (`Core/Screens/HistoryScreen/HistoryViewModel.swift:19`,
`Core/Screens/HistoryScreen/HistoryScreen.swift:11`):
```swift
@MainActor
class HistoryViewModel: ObservableObject { ... }
struct HistoryScreen: View {
    @StateObject private var viewModel = HistoryViewModel()
    @EnvironmentObject var coordinator: Coordinator
```
All 7 ViewModels found (`HomeScreenViewModel`, `IdentifyViewModel`, `HistoryViewModel`,
`HabitatViewModel`, `ArticleViewModel`, `BirdDetailViewModel`, `SubscriptionViewModel`) are
`class X: ObservableObject`, never a struct, never the `@Observable` macro (0 occurrences).
**Never:**
```swift
@Observable
class HistoryViewModel { ... }   // macro-based observation — never used, 0/7
```

### R-3: ViewModels get the Coordinator late, via `setCoordinator()`, not init injection  [STRONG — 2/2 that navigate]
**Why I do it:** The `Coordinator` is an `@EnvironmentObject`, not always available at
ViewModel construction time (ViewModels are built as `@StateObject` before the view enters
the environment), so it's threaded in during `.onAppear` instead of the initializer.
**Canonical example** (`Core/Screens/IdentifyScreen/IdentifyScreenViewModel.swift:24,41-43`
and `Core/Screens/IdentifyScreen/IdentifyScreen.swift:402-404`):
```swift
private weak var coordinator: Coordinator?
func setCoordinator(_ coordinator: Coordinator) { self.coordinator = coordinator }
...
.onAppear { viewModel.setCoordinator(coordinator) }
```
Same pattern in `HomeScreenViewModel.setCoordinator` (`HomeScreenViewModel.swift:44-46`,
called from `HomeScreen.swift:147`). Repositories, by contrast, ARE init-injected
(see R-44). Coordinator is always `weak` where stored on a ViewModel — 2/2.
**Never:**
```swift
init(coordinator: Coordinator, repository: ... ) { ... }  // Coordinator passed at init — 0/7
```

## 3. Layering and import direction

### R-4: Strict one-way layering: View → ViewModel → Repository(protocol) → ApiService  [LAW — 7/7 repositories]
**Why I do it:** Keeps networking testable — every ViewModel depends on a `XRepositoryProtocol`,
never the concrete `ApiService` or `Alamofire`/`URLSession` directly.
**Canonical example** (`Core/Screens/ArticleScreen/ArticleViewModel.swift:19,23-25`):
```swift
private let repository: ArticleRepositoryProtocol
init(repository: ArticleRepositoryProtocol = ArticleRepository()) {
    self.repository = repository
}
```
Models (`Models/*.swift`) sit at the bottom with zero outgoing dependencies except
`CodingKeys`. `Coordinator` and `TabManager` are siblings injected via `@EnvironmentObject`,
never imported by a Repository or Model. No file in `Models/` or `Core/Repositories/`
imports `SwiftUI` — confirmed 0/17 (7 repos + 10 model files).
**Never:**
```swift
// Repository reaching past ApiServiceProtocol into Alamofire's AF directly
AF.request(...).responseDecodable { ... }   // only ApiService.swift itself does this
```

## 4. Module strategy

### R-5: Single app target, dependencies pinned straight in the .xcodeproj, no local SPM packages  [LAW — 1/1 project]
**Why I do it:** No `Package.swift`, no CocoaPods, no local Swift package split — five
remote SPM dependencies (`Alamofire`, `KeychainAccess`, `Kingfisher`, `lottie-ios`,
`purchases-ios-spm`) are resolved directly by Xcode and locked in
`project.xcworkspace/xcshareddata/swiftpm/Package.resolved`.
**Canonical example** (`BirdId.xcodeproj/.../Package.resolved`):
```json
{ "identity": "alamofire", "kind": "remoteSourceControl",
  "location": "https://github.com/Alamofire/Alamofire.git",
  "state": { "revision": "513364f8...", "version": "5.10.2" } }
```
**Never:** a `Package.swift` manifest, a `Podfile`, or a local `Packages/` folder split
into feature modules — none exist.

## 5. Folder structure

### R-6: Feature-first for screens, type-first for everything else  [LAW — 10/10 screen folders, 7/7 repos]
**Why I do it:** Each screen is its own world (`Core/Screens/<Feature>/`, containing the
View, the ViewModel, and sometimes a `<Feature>SubViews/` folder) — but cross-cutting
concerns (`Core/Repositories/`, `Models/`, `Helpers/*`) are grouped by technical role, flat,
not nested per feature.
**Canonical example** (directory listing):
```
Core/Screens/HaditatScreen/HabitatScreen.swift
Core/Screens/HaditatScreen/HabitatViewModel.swift
Core/Screens/HaditatScreen/HabitatSubViews/HabitatItem.swift
Core/Repositories/HabitatsRepository.swift      <- flat, not under HaditatScreen/
Models/HabitatsModel.swift                       <- flat, not under HaditatScreen/
```
Note the misspelled folder `HaditatScreen` (should be `HabitatScreen`) — kept exactly as
typed, never renamed across 6 commits that touch it. This is reality, not a typo to silently
fix (see Appendix A-1 for the only place it's flagged as an improvement).
**Never:** a `Core/Screens/HabitatScreen/Repository.swift` or `Core/Screens/HabitatScreen/
Models.swift` colocated inside the feature folder — repositories and models never live
inside `Screens/`.

### R-7: Xcode groups exactly mirror the filesystem — filesystem-synchronized groups  [LAW — 3/3 root groups]
**Why I do it:** The project uses Xcode's modern `PBXFileSystemSynchronizedRootGroup`
(`BirdId`, `BirdIdTests`, `BirdIdUITests` groups all declared this way in
`project.pbxproj`), so there is no divergence to reconcile — dragging a file in Finder is
enough, no manual "Add Files to target" step, and the Xcode navigator can never show a
stale/renamed reference.
**Canonical example** (`BirdId.xcodeproj/project.pbxproj`):
```
83A8922C2E8DA1AB00337242 /* BirdId */ = {
    isa = PBXFileSystemSynchronizedRootGroup;
```
**Never:** a manually-curated `PBXGroup` tree with `path`/`name` overrides that differ
from the real folder path.

## 6. File granularity

### R-8: Related types are bundled into one file per screen/resource — NOT strict one-type-per-file  [LAW — 21/40 files]
**Why I do it:** A screen's private subviews, and a resource's nested response DTOs, are
kept next to the type that uses them so the whole feature/resource reads top-to-bottom in
one file. 21 of 40 Swift files declare more than one top-level `struct`/`class`/`enum`.
**Canonical example** (`Models/UploadModel.swift` — 16 top-level types in one file:
`UploadResponse`, `ObservationInfo`, `BirdDetailResponse`, `Size`, `RangeValue`,
`CommonName`, `Taxonomy`, `ConservationStatus`, `BirdHabitat`, `BirdFoodWrapper`, `Food`,
`Distribution`, `Location`, `Coordinates`, `Media`, `MediaMetadata` — all separated by
`// MARK: - <Name>` banners):
```swift
// MARK: - Main Upload Response (Root)
struct UploadResponse:  Decodable { ... }
// MARK: - Observation Info
struct ObservationInfo: Decodable { ... }
// MARK:  - Bird Detail Response
struct BirdDetailResponse: Decodable { ... }
```
Same pattern in screens: `IdentifyScreen.swift` (4 types: `IdentifyScreen`,
`CameraScreenContent`, `MicScreenContent`, `BottomBarView` — 461 lines, the largest file in
the repo), `HomeScreen.swift` (3 types: `HomeScreen`, `SearchResultsOverlay`,
`BirdSearchResultRow`), `HabitatItem.swift` (3 types), `HistoryItem.swift` (2 types: grid +
card).
**Never:** splitting `BottomBarView` or `SearchResultsOverlay` out into their own file just
because they're a distinct `struct` — private subviews of a screen stay in that screen's
file unless they're reused across screens (then they move to `<Feature>SubViews/` or
`CustomView/`, e.g. `HistoryItem.swift`, `HabitatItem.swift`).

## 7. My actual meaning of Core / Shared / Common / Utilities / Extensions

### R-9: `Core/` = feature screens + repos + networking; `Helpers/` = everything cross-cutting; no `Shared/`, no `Common/`, no `Utilities/`  [LAW — 1/1 naming scheme]
**Why I do it:** Two top-level buckets only. `Core/Screens`, `Core/Repositories`,
`Core/InternetServices` hold feature/networking code; `Helpers/` holds every
non-feature-specific concern, each in its own named subfolder
(`Helpers/Coordinator`, `Helpers/TabManager`, `Helpers/SubscriptionManager`,
`Helpers/KeyChainAccess`, `Helpers/CacheImage`, `Helpers/LottieView`, `Helpers/MockData`,
`Helpers/Extension`, `Helpers/Constants`, `Helpers/Jsons`).
**Canonical example** (directory listing):
```
BirdId/Core/Screens/...
BirdId/Core/Repositories/...
BirdId/Core/InternetServices/ApiService.swift
BirdId/Helpers/Coordinator/Coordinator.swift
BirdId/Helpers/CacheImage/CachedAsyncImage.swift
```
Reusable, cross-screen SwiftUI *views* (not services) get their own top-level bucket,
`CustomView/` (`BackButtonView`, `CheckedView`, `SearchTextField`, `TabBar`) — distinct from
`Helpers/`, which is non-view code plus a couple of UIViewRepresentable wrappers
(`LottieView`, `CachedAsyncImage`).
**Never:** a folder literally named `Shared/`, `Common/`, or `Utilities/` — none exist;
every helper gets a purpose-named subfolder under `Helpers/` instead.

