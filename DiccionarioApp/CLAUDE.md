# DiccionarioApp — CLAUDE.md

## Project Overview

**Dixio** is a Swedish–Spanish dictionary iOS app that queries the [Lexin API](http://lexin.nada.kth.se) (KTH) and displays word definitions, phonetics, translations, and synonyms. It includes premium features gated behind a RevenueCat paywall.

| Target | Type | Purpose |
|--------|------|---------|
| `DiccionarioApp/` | Xcode App | Main dictionary app |
| `DixioClip/` | App Clip | Lightweight clip entry point |

**Frameworks:** SwiftUI, CoreData, Combine, NaturalLanguage, FoundationModels, Speech, RevenueCat  
**iOS Target:** 26.0  
**Swift version:** 6.0 (strict concurrency enabled)

---

## Architecture

### Data Flow
Lexin API (JSON) → `WordViewModel` (async/await) → SwiftUI Views

### View Model Layer (`View Model/`)
| File | Class | Responsibility |
|------|-------|----------------|
| `WordViewModel.swift` | `WordViewModel: ObservableObject` | Fetches words from Lexin API via `URLSession` (injectable), publishes `[Result]` |
| `WordSearchViewModel.swift` | `WordSearchViewModel: ObservableObject` | Search logic: `performSearch`, `suggestions`, `voiceLocale`, language detection, UITextChecker |
| `DetailViewModel.swift` | `DetailViewModel: ObservableObject` | CoreData save, duplicate detection, AVSpeechSynthesizer, `isSaved`/`isDuplicate` state |
| `TriviaViewModel.swift` | `TriviaViewModel: ObservableObject` | Trivia game logic: `startGame`, `checkAnswer`, `updateRandomIndex`, score, game-end |
| `QuizViewModel.swift` | `QuizViewModel: ObservableObject` | Flashcard random index: `updateRandomIndex` |
| `SpeechRecognizer.swift` | `SpeechRecognizer: ObservableObject` | Voice search via `SFSpeechRecognizer`; publishes `transcript`, `isRecording`, `permissionDenied` |
| `AppEnv.swift` | `AppEnvironment: ObservableObject` | Holds `currentLanguage` string, drives locale switching |
| `DataController.swift` | `DataController: ObservableObject` | CoreData stack (`NSPersistentContainer` — model: `WordModel`) |
| `FavoriteModel.swift` | `WordListViewModel: ObservableObject` | `UserDefaults`-backed list of saved words |
| `OpenAPIViewModel.swift` | `ViewModel: ObservableObject` | **PENDING DELETION** — ChatGPT/OpenAI (replaced by Apple Intelligence) |
| `PlaySound.swift` | — | Audio playback for phonetic files |
| `Extentions/UserViewModell.swift` | `UserViewModel: ObservableObject` | Subscription state (`isSubscriptionActive: Bool`) |
| `Extentions/Extensions.swift` | — | General SwiftUI/Foundation helpers |
| `Extentions/PayWallExtention.swift` | — | RevenueCat paywall helpers |

### View Layer (`Views/`)
```
Views/
├── Home/
│   ├── WordView.swift              ← Root view: search + results + toolbar buttons
│   ├── SearchBarView.swift         ← Replaced by .searchable in WordView (kept for reference)
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
│   ├── AudioPlaybackView.swift     ← Plays phonetic audio file
│   └── ExampleSentenceView.swift   ← AI-generated example sentences (FoundationModels)
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
| `ChatView.swift` | **PENDING DELETION** — AI chat using OpenAI (to be removed) |
| `QuizView.swift` | Flashcard quiz — uses `QuizViewModel`; empty-state guard |
| `QuizView2.swift` | Alternative quiz layout (placeholder) |
| `TriviaView.swift` | Trivia game — uses `TriviaViewModel`; requires ≥2 words, empty-state guard |

---

## Key Models (`WordViewModel.swift`)

```swift
Words           // Top-level API response: status, wordbase, result (optional), corrections (optional)
Result          // Single dictionary entry: value, type, variantID, baseLang, targetLang
BaseLang        // Swedish side: phonetic, inflections, meaning, illustrations
TargetLang      // Spanish side: translation, synonyms, comment
Phonetic        // file (audio URL), content (IPA string)
Inflection      // content string (e.g., "springer, sprang, sprungit")
Illustration    // type + value (example sentence)
```

`Words.result` is `[Result]?` (optional) — the API omits the `Result` key and returns `Corrections` instead when no exact match is found.

CoreData entity (`WordModel`): `Word` with fields `value`, `type`, `translation`, `phonetic`, `file`, `synonym`, `meaning`.

---

## API

**Lexin API** (no auth required):
```
GET http://lexin.nada.kth.se/lexin/service?searchinfo={dir},swe_spa,{word}&output=JSON
```

### Correct `dir` values
| Value | Meaning |
|-------|---------|
| `"swe"` | Search Swedish → show Spanish translation |
| `"spa"` | Search Spanish → show Swedish meaning |

**Do NOT use `"both"`, `"to"`, or `"from"` — they produce invalid JSON or wrong results.**

### Lexin API JSON bug
The API encodes `\"` (escaped quote) as `\"` (literal backslash from `\` + `"` that terminates the JSON string). This causes `JSONDecoder` to fail on words with quoted idioms/examples.

Fix applied in `WordViewModel.fetchPosts()` before decoding:
```swift
let rawString = String(data: data, encoding: .utf8) ?? ""
let fixedString = rawString.replacingOccurrences(of: "\\u005c\"", with: "\\\"")
let fixedData = Data(fixedString.utf8)
let myresults = try JSONDecoder().decode(Words.self, from: fixedData)
```

### Language direction in `WordView.performSearch()`
- Words are lowercased before the API call
- `NLLanguageRecognizer` auto-detects Swedish vs Spanish
- `selectedLang = true` → Swedish input, `dir = "swe"`, show Spanish translation
- `selectedLang = false` → Spanish input, `dir = "spa"`, show Swedish meaning
- Ambiguous/short words default to `selectedLang = true` / `dir = "swe"`

---

## NaturalLanguage Framework

`WordView` imports `NaturalLanguage` and uses `NLLanguageRecognizer` to auto-detect the search language:

```swift
private func detectLanguage(for input: String) -> Bool? {
    let recognizer = NLLanguageRecognizer()
    recognizer.processString(input)
    switch recognizer.dominantLanguage {
    case .swedish: return true   // → dir="swe"
    case .spanish: return false  // → dir="spa"
    default:       return nil    // → default to swe
    }
}
```

---

## Foundation Models Framework (iOS 26)

`ExampleSentenceView.swift` uses on-device Apple Intelligence to generate one example sentence per word. Key points:
- Check `SystemLanguageModel.default.isAvailable` before using
- Stream the response with `session.streamResponse(to:)` for progressive display
- Must be added to the Xcode target manually if created outside Xcode (right-click → "Add Files to DiccionarioApp...")

---

## Speech Framework

`SpeechRecognizer.swift` (`View Model/`) — `@MainActor ObservableObject` that handles voice search:
- `toggle(locale:)` — starts or stops recording
- Requests microphone + speech recognition permissions automatically on first use
- Publishes `transcript` in real time (text appears in search bar while speaking)
- When speech ends (`isFinal == true`), stops recording and `WordView` fires `performSearch()` automatically
- Locale follows `selectedLang`: `sv-SE` (Swedish) or `es-MX` (Spanish)
- Permissions declared in `Info.plist`: `NSSpeechRecognitionUsageDescription` + `NSMicrophoneUsageDescription`
- **Does not work in simulator** — test on physical device only (`AVAudioEngine` requires real microphone hardware)

---

## Apple AI Frameworks — Decision Log

| Framework | Status | Reason |
|-----------|--------|--------|
| `NaturalLanguage` | Implemented | Language auto-detection |
| `FoundationModels` | Implemented | On-device example sentences |
| `Speech` | Implemented | Voice search |
| `Translation` | Pending | Fallback when Lexin finds no match |
| `NLTagger` | Considered | Part-of-speech tagging — not prioritized |
| `Vision` | Rejected | Image analysis — not relevant for dictionary |
| `Core ML` | Rejected | Requires custom trained model |
| `SoundAnalysis` | Rejected | Classifies ambient sounds (birds, rain, alarms) — not relevant. Different from Speech which transcribes spoken words |
| `Create ML` | Rejected | Only for training models, not runtime use |

---

## Search (`.searchable`)

`WordView` uses SwiftUI `.searchable` instead of the old `SearchBarView`:
- Placement: `.navigationBarDrawer(displayMode: .always)` (required for iOS 26 to keep bar at top)
- Suggestions combine session history (`searchWords`) + `WordListViewModel.favoriteWords`
- Suggestions are filtered by current text, case-insensitive, sorted alphabetically

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

## Git — Multi-Remote Setup

| Remote | Repo | Purpose |
|--------|------|---------|
| `origin` | Public GitHub repo | Portfolio / open source |
| `private` | Private GitHub repo (`DiccionarioApp-Private`) | App Store version with AI features |

Push to both independently. The user handles all commits and pushes manually.

**IMPORTANT: Never commit or push on the user's behalf.**

---

## Development Guidelines

- Keep views dumb: no business logic inside View structs — use ViewModels
- Prefer `async/await` over `DispatchQueue.main.async`
- CoreData context is passed via `.environment(\.managedObjectContext, ...)`; never access it directly from views
- Language direction string must be URL-safe before appending to Lexin query
- `UserDefaults` key for saved words: `"FavoriteWords"`
- Always lowercase search input before calling `fetchPosts(word:dir:)`

---

## Swift 6 Concurrency — Patterns Applied

All `ObservableObject` classes are annotated `@MainActor`:
- `AppEnvironment`, `WordViewModel`, `DataController`, `WordListViewModel`
- `UserViewModel`, `PlayerWord`, `SpeechRecognizer`
- `WordSearchViewModel`, `DetailViewModel`, `TriviaViewModel`, `QuizViewModel`

`DispatchQueue` replaced throughout:

- `URLSession.dataTask` → `async/await` + `Task { }` in `WordViewModel`
- `DispatchQueue.main.asyncAfter` → `Task { try? await Task.sleep(for:) ... }` in `DetailViewModel`, `TriviaViewModel`
- `.receive(on: DispatchQueue.main)` → `.receive(on: RunLoop.main)` in `PlaySound`

`NavigationView` → `NavigationStack` in `WordView`, `SettingsView`.

---

## Testing

**Test target:** `DiccionarioAppTests` — 43 unit tests, `@testable import DiccionarioApp`

**`MockURLProtocol`** — `URLProtocol` subclass registered on an ephemeral `URLSession`. Injected via `WordViewModel(session: .mock)`. Intercepts all requests and returns controlled responses without hitting the network.

| Area | Tests | What's covered |
| --- | --- | --- |
| API errors | 9 | `notConnectedToInternet`, HTTP 500, HTTP 404, malformed JSON, corrections-only, empty results, valid response, `dir="swe"`, `dir="spa"` |
| Lexin quote bug | 1 | `\"` → `\"` transformation |
| Model decoding | 3 | Full decode, missing optionals, corrections-only response |
| `WordSearchViewModel` | 9 | `performSearch`, suggestions, `voiceLocale` |
| `WordListViewModel` | 4 | add, remove, persist, load |
| `AppEnvironment` | 2 | default language, change language |
| `UserViewModel` | 2 | inactive/active state |
| `TriviaViewModel` | 6 | `startGame`, index bounds, index uniqueness, `checkAnswer`, game-end |
| `QuizViewModel` | 2 | valid index, empty list no-crash |
| `DetailViewModel` | 2 | save new word → `isSaved`, duplicate → `isDuplicate` |

**CoreData in tests:** `makeInMemoryContext()` creates an `NSPersistentContainer` with `NSInMemoryStoreType`. Uses `DiccionarioApp.myWord` (fully qualified) to avoid conflict if `WordModel.xcdatamodeld` is also added to the test target.

---

## Known Issues / TODOs

| Location | Issue |
|----------|-------|
| `DixioClip/ContentView.swift` | Placeholder content — not implemented |
| `Test View Model/` | `TestModel.swift`, `PostListView.swift` — test/scratch files, not shipped |
| `DetailView.swift` | `myWord` CoreData entity name inconsistency with `Word` in `DataController` |
| `ExampleSentenceView.swift` | Requires Apple Intelligence (iOS 26, device-side model) — degrades gracefully if unavailable |
| `OpenAPIViewModel.swift` | Pending deletion in Xcode — right-click → Delete |
| `ChatView.swift` | Pending deletion in Xcode — right-click → Delete |
| Package Dependencies | `ChatGPTSwift` pending removal — Xcode → Project → Package Dependencies |

## Next Planned Features

- **Translation framework (iOS 17.4+)** — on-device Apple fallback when `errorMessage == "No word match"`. Show result in `WordView` with "Translated by Apple" label.
