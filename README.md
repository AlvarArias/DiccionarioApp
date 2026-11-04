# DiccionarioApp — Dixio

![Swift](https://img.shields.io/badge/Swift-6.0-orange?style=flat&logo=swift)
![SwiftUI](https://img.shields.io/badge/SwiftUI-blue?style=flat&logo=apple)
![iOS](https://img.shields.io/badge/iOS-26+-blue?style=flat&logo=apple)
![License](https://img.shields.io/badge/license-MIT-lightgrey?style=flat)

**Dixio** is a Swedish–Spanish dictionary iOS app that queries the [Lexin API](http://lexin.nada.kth.se) (KTH) in real time, delivering word definitions, phonetics, inflections, and translations. The app includes an App Clip for instant access, premium AI-powered features, and a quiz mode for learning vocabulary.

---

## Screenshots

| Search | Word Detail | Saved Words | Settings |
|--------|-------------|-------------|----------|
| ![search](https://user-images.githubusercontent.com/7523384/228346593-ee0dda12-2a77-4e26-9b0b-04a58db97e00.png) | ![word](https://user-images.githubusercontent.com/7523384/228346598-ddbaa92c-3359-4e0d-8cb0-c3e207db3e85.png) | ![saved](https://user-images.githubusercontent.com/7523384/228346584-6468183a-55e7-49e8-bd9e-e262b2ded99b.png) | ![settings](https://user-images.githubusercontent.com/7523384/228346595-3eab6a2f-0de2-4296-bd33-1e34951ef379.png) |

---

## Features

- Bidirectional lookup — Swedish → Spanish and Spanish → Swedish
- Phonetic audio playback via AVFoundation
- Word inflections, meanings, synonyms, and example sentences
- Save words to favourites with Core Data persistence
- App Clip (DixioClip) for lightweight, instant dictionary access
- Multilingual UI — English, Swedish, and Spanish
- **Premium:** AI chat for word queries and examples (ChatGPT)
- **Premium:** Flashcard quiz and trivia game using saved vocabulary
- RevenueCat paywall integration
- Swift 6 strict concurrency throughout

---

## Tech Stack

| Layer | Technologies |
|-------|-------------|
| UI | SwiftUI, NavigationStack |
| Architecture | MVVM, `ObservableObject`, `@MainActor` |
| Networking | URLSession, Combine |
| Persistence | Core Data (`NSPersistentContainer`), UserDefaults |
| Audio | AVFoundation |
| AI | ChatGPTSwift |
| Payments | RevenueCat |
| Testing | XCTest, XCUITest |

---

## Project Structure

| Target | Type | Description |
|--------|------|-------------|
| `DiccionarioApp/` | iOS App | Main dictionary app |
| `DixioClip/` | App Clip | Lightweight instant-access entry point |
| `DiccionarioAppTests/` | Unit tests | ViewModel and model tests |
| `DiccionarioAppUITests/` | UI tests | End-to-end UI flows |

### Source layout

```
DiccionarioApp/
├── View Model/
│   ├── WordViewModel.swift        ← Lexin API fetch, publishes [Result]
│   ├── AppEnv.swift               ← Language direction state
│   ├── DataController.swift       ← Core Data stack
│   ├── FavoriteModel.swift        ← UserDefaults-backed word list
│   └── OpenAPIViewModel.swift     ← ChatGPT integration
├── Views/
│   ├── Home/                      ← Search, results, language toggle, paywall
│   ├── Detail/                    ← Word info, phonetics, audio playback
│   ├── Tool Bar Views/            ← Settings, Favourites, Saved Words
│   └── Shared/                    ← Reusable components
└── PremiumViews/
    ├── ChatView.swift             ← AI word assistant
    ├── QuizView.swift             ← Flashcard quiz
    └── TriviaView.swift           ← Vocabulary trivia game
```

---

## Architecture

Data flows in one direction:

```
Lexin API (JSON)
      ↓
WordViewModel (URLSession + Combine)
      ↓
SwiftUI Views (read-only, no business logic)
      ↓
Core Data / UserDefaults (persistence)
```

Environment objects are injected at the app root:

```swift
@StateObject private var appEnvironment = AppEnvironment()   // language direction
@StateObject private var dataController = DataController()   // Core Data context
@StateObject var userViewModel = UserViewModel(...)          // subscription state
```

All `ObservableObject` classes are `@MainActor`-annotated for Swift 6 concurrency safety.

---

## API

Dixio uses the **Lexin API** — no authentication required:

```
GET http://lexin.nada.kth.se/lexin/service?searchinfo={dir},swe_spa,{word}&output=JSON
```

| `dir` value | Direction |
|-------------|-----------|
| `swe` | Swedish → Spanish |
| `spa` | Spanish → Swedish |
| `both` | Both directions |

The network layer is encapsulated in the [`CallDixio`](https://github.com/AlvarArias/CallDixio) Swift package.

---

## Getting Started

```bash
git clone https://github.com/AlvarArias/DiccionarioApp.git
cd DiccionarioApp
open DiccionarioApp.xcodeproj
```

> Requires Xcode 26+ and an iOS 26 simulator or physical device.  
> RevenueCat and ChatGPT API keys are needed to test premium features — configure them in the app settings.

---

## License

Available under the [MIT](LICENSE) license.

---

Developed by [Alvar Arias](https://github.com/AlvarArias) · [LinkedIn](https://www.linkedin.com/in/alvararias/) · [Portfolio](https://alvararias.github.io/)
