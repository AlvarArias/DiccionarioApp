# DiccionarioApp — CLAUDE.md

## Project Overview

**Dixio** is a Swedish–Spanish dictionary iOS app that queries the [Lexin API](http://lexin.nada.kth.se) (KTH) and displays word definitions, phonetics, translations, and synonyms. It includes premium features gated behind a RevenueCat paywall.

| Target | Type | Purpose |
|--------|------|---------|
| `DiccionarioApp/` | Xcode App | Main dictionary app |
| `DixioClip/` | App Clip | Lightweight clip entry point |

**Frameworks:** SwiftUI, CoreData, Combine, RevenueCat, ChatGPTSwift  
**iOS Target:** 26.0  
**Swift version:** 6.0 (strict concurrency enabled)

---

## Architecture

### Data Flow
Lexin API (JSON) → `WordViewModel` (Combine) → SwiftUI Views

### View Model Layer (`View Model/`)
| File | Class | Responsibility |
|------|-------|----------------|
| `WordViewModel.swift` | `WordViewModel: ObservableObject` | Fetches words from Lexin API via `URLSession`, publishes `[Result]` |
| `AppEnv.swift` | `AppEnvironment: ObservableObject` | Holds `currentLanguage` string, drives locale switching |
| `DataController.swift` | `DataController: ObservableObject` | CoreData stack (`NSPersistentContainer` — model: `WordModel`) |
| `FavoriteModel.swift` | `WordListViewModel: ObservableObject` | `UserDefaults`-backed list of saved words |
| `OpenAPIViewModel.swift` | `ViewModel: ObservableObject` | ChatGPT integration via `ChatGPTSwift` for synonyms/examples |
| `PlaySound.swift` | — | Audio playback for phonetic files |
| `Extentions/UserViewModell.swift` | `UserViewModel: ObservableObject` | Subscription state (`isSubscriptionActive: Bool`) |
| `Extentions/Extensions.swift` | — | General SwiftUI/Foundation helpers |
| `Extentions/PayWallExtention.swift` | — | RevenueCat paywall helpers |

### View Layer (`Views/`)
```
Views/
├── Home/
│   ├── WordView.swift              ← Root view: search + results + toolbar buttons
│   ├── SearchBarView.swift         ← Search input, triggers WordViewModel.fetchPosts()
│   ├── LanguageSelectionView.swift ← Toggles swe→spa / spa→swe direction
│   ├── ResultListView.swift        ← List of Result cards
│   └── Paywall/
│       ├── PayWallView.swift
│       ├── PayWallContentView.swift
│       ├── SimplePayWallView.swift
│       └── ProfileView.swift
├── Detail/
│   ├── DetailView.swift            ← Full word detail
│   ├── WordInfoView.swift          ← Phonetics, meaning, inflections
│   ├── LanguageInfoView.swift      ← Translation + synonyms
│   └── AudioPlaybackView.swift     ← Plays phonetic audio file
├── Tool Bar Views/
│   ├── SettingsView.swift          ← Language, API key, app info
│   ├── FavoriteView.swift          ← Search history list
│   └── SavedWordView.swift         ← CoreData saved words list
├── Shared/
│   ├── SharedView.swift            ← Reusable card/shared UI
│   └── ConfettiView.swift
├── SplashView.swift
└── Notifications.swift
```

### Premium Views (`PremiumViews/`)
| File | Purpose |
|------|---------|
| `ChatView.swift` | AI chat for word queries (uses `ViewModel`) |
| `QuizView.swift` | Flashcard quiz with saved words |
| `QuizView2.swift` | Alternative quiz layout |
| `TriviaView.swift` | Trivia game with Swedish words |

---

## Key Models (`WordViewModel.swift`)

```swift
Words           // Top-level API response: status, wordbase, [Result]
Result          // Single dictionary entry: value, type, variantID, baseLang, targetLang
BaseLang        // Swedish side: phonetic, inflections, meaning, illustrations
TargetLang      // Spanish side: translation, synonyms, comment
Phonetic        // file (audio URL), content (IPA string)
Inflection      // content string (e.g., "springer, sprang, sprungit")
Illustration    // type + value (example sentence)
```

CoreData entity (`WordModel`): `Word` with fields `value`, `type`, `translation`, `phonetic`, `file`, `synonym`, `meaning`.

---

## API

**Lexin API** (no auth required):
```
GET http://lexin.nada.kth.se/lexin/service?searchinfo={dir},swe_spa,{word}&output=JSON
```
- `dir` examples: `"both"`, `"swe"`, `"spa"`
- Language direction controlled by `AppEnvironment.currentLanguage` and `selectedLang` toggle

---

## Environment Objects (injected at app root)

```swift
@StateObject private var appEnvironment = AppEnvironment()   // .environmentObject
@StateObject private var dataController = DataController()   // .environment(\.managedObjectContext)
@StateObject var userViewModel = UserViewModel(...)          // .environmentObject
```

---

## RevenueCat

- Configured in `DiccionarioAppApp.init()` with `Purchases.configure(withAPIKey:)`
- `UserViewModel.isSubscriptionActive` gates premium views
- Paywall helpers in `PayWallExtention.swift`

---

## Development Guidelines

- Keep views dumb: no business logic inside View structs — use ViewModels
- Prefer `async/await` over `DispatchQueue.main.async` (currently mixed — migrate gradually)
- `WordViewModel` uses `URLSession` + `Combine`-style error publishing — keep this pattern
- CoreData context is passed via `.environment(\.managedObjectContext, ...)`; never access it directly from views
- Language direction string must be URL-safe before appending to Lexin query
- `UserDefaults` key for saved words: `"FavoriteWords"`

---

## Swift 6 Concurrency — Patterns Applied

All `ObservableObject` classes are annotated `@MainActor`:
- `AppEnvironment`, `WordViewModel`, `DataController`, `WordListViewModel`
- `UserViewModel`, `PlayerWord`, `ViewModel` (OpenAPI)

`DispatchQueue` replaced throughout:
- `URLSession.dataTask` → `async/await` + `Task { }` in `WordViewModel`
- `DispatchQueue.main.async` in `OpenAPIViewModel` → removed (class is `@MainActor`)
- `DispatchQueue.main.asyncAfter` → `Task { try? await Task.sleep(for:) ... }` in `DetailView`, `TriviaView`, `QuizView`
- `.receive(on: DispatchQueue.main)` → `.receive(on: RunLoop.main)` in `PlaySound`

`NavigationView` → `NavigationStack` in `WordView`, `SettingsView`.

## Known Issues / TODOs

| Location | Issue |
|----------|-------|
| `DixioClip/ContentView.swift` | Placeholder content — not implemented |
| `Test View Model/` | `TestModel.swift`, `PostListView.swift` — test/scratch files, not shipped |
| `DetailView.swift` | `myWord` CoreData entity name inconsistency with `Word` in `DataController` |
