# 🍃 MintFlow — Smart Budgeting App

> *Your money, flowing smarter.*

MintFlow is a SwiftUI-based budgeting application built with clean architecture, protocol-oriented design, and a simulated backend authentication system. It provides a solid foundation for a full-featured personal finance app.

---

## 📁 Project Structure

```
MintFlow/
├── MintFlowApp.swift              ← App entry point
│
├── Models/
│   ├── User.swift                 ← Authenticated user model
│   ├── Transaction.swift          ← Financial transaction + TransactionType
│   ├── Budget.swift               ← Budget, Category, BudgetPeriod
│   └── AuthModels.swift           ← AuthError, LoginRequest, RegisterRequest, AuthResponse
│
├── Views/
│   ├── ContentView.swift          ← Root view (screen router)
│   ├── LandingView.swift          ← Welcome/onboarding screen
│   ├── LoginView.swift            ← Login form
│   ├── SignupView.swift           ← Registration form
│   ├── HomeView.swift             ← Post-login dashboard
│   └── Components/
│       ├── PrimaryButton.swift    ← Reusable CTA button with loading state
│       ├── InputField.swift       ← Reusable text input with icon
│       └── SharedComponents.swift ← ErrorBanner, BackButton, SectionHeader
│
├── ViewModels/
│   ├── AppViewModel.swift         ← Root nav + auth session state
│   ├── LoginViewModel.swift       ← Login validation + async auth call
│   ├── SignupViewModel.swift      ← Registration validation + async auth call
│   └── HomeViewModel.swift        ← Dashboard data + formatting
│
├── Services/
│   ├── Protocols/
│   │   ├── AuthServiceProtocol.swift       ← Auth interface (loose coupling)
│   │   └── ValidationServiceProtocol.swift ← Validation interface
│   ├── MockAuthService.swift      ← In-memory auth backend (actor)
│   ├── ValidationService.swift    ← Email/password/name validation
│   └── ServiceContainer.swift     ← Dependency injection container
│
└── Utilities/
    └── Constants.swift            ← App-wide colours, layout tokens
```

---

## 🚀 Getting Started (Xcode Setup)

Since this project was authored outside Xcode, follow these steps to run it:

1. **Open Xcode** → *File → New → Project* → **App** (iOS)
2. Set **Product Name** to `MintFlow`, **Interface** to `SwiftUI`, **Language** to `Swift`
3. **Delete** the auto-generated `ContentView.swift` and `MintFlowApp.swift` (from the Xcode template)
4. **Drag the entire `MintFlow/` folder** into the Xcode project navigator
   - Make sure "Copy items if needed" is checked
   - Target membership is set to `MintFlow`
5. Build & run on the iOS Simulator (**⌘R**)

> **Minimum target:** iOS 16.0 | Xcode 15+

---

## 🏗️ Architecture Overview

### MVVM + Service Layer

```
┌──────────┐     ┌─────────────┐     ┌─────────────────┐
│   Views   │ ──▶ │  ViewModels  │ ──▶ │    Services      │
│ (SwiftUI) │     │ (@Published) │     │  (Protocols)     │
└──────────┘     └─────────────┘     └─────────────────┘
                                           │
                                     ┌─────┴──────┐
                                     │ MockAuth   │  ← Swap with
                                     │ Firebase   │     real backend
                                     │ REST API   │
                                     └────────────┘
```

- **Views** only render UI and send user actions to ViewModels
- **ViewModels** own `@Published` state, run validation, call services
- **Services** are accessed only through protocols — implementations are interchangeable
- **ServiceContainer** centralises dependency creation (simple DI)

---

## 🔐 Backend Authentication System

### How It Works

The `MockAuthService` is a Swift `actor` that simulates a real REST API:

| Feature               | Implementation                                      |
|-----------------------|-----------------------------------------------------|
| User storage          | In-memory dictionary keyed by email                 |
| Password hashing      | SHA-256 via `CryptoKit` (prod would use bcrypt)     |
| Network latency       | Random 0.5–1.5 s delay via `Task.sleep`             |
| Duplicate registration| Throws `AuthError.userAlreadyExists`                |
| Wrong credentials     | Throws `AuthError.invalidCredentials`               |
| Token generation      | UUID-based mock bearer token                        |
| Thread safety         | Guaranteed by Swift actor isolation                 |

### Auth Flow

```
User taps "Sign In"
    → LoginViewModel.login()
        → ValidationService.validateEmail()     ← client-side check
        → MockAuthService.login(request:)       ← async "API" call
            → Simulate 0.5–1.5 s delay
            → Look up email in userStore
            → Compare SHA-256 password hashes
            → Return AuthResponse (user + token)
        → AppViewModel.handleAuthSuccess()      ← navigate to Home
```

### Swapping to a Real Backend

1. Create `FirebaseAuthService` (or `RESTAuthService`) conforming to `AuthServiceProtocol`
2. In `ServiceContainer.makeAuthService()`, return the new implementation
3. **Zero** changes needed in any ViewModel or View

```swift
// Example: REST API implementation
final class RESTAuthService: AuthServiceProtocol {
    func login(request: LoginRequest) async throws -> AuthResponse {
        var urlRequest = URLRequest(url: URL(string: "https://api.example.com/auth/login")!)
        urlRequest.httpMethod = "POST"
        urlRequest.httpBody = try JSONEncoder().encode(request)
        urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")

        let (data, response) = try await URLSession.shared.data(for: urlRequest)

        guard let http = response as? HTTPURLResponse, http.statusCode == 200 else {
            throw AuthError.invalidCredentials
        }

        return try JSONDecoder().decode(AuthResponse.self, from: data)
    }
    // ... register, logout
}
```

---

## ✅ Rubric Criteria Mapping

### 1. Data Modelling
- **User**, **Transaction**, **Budget**, **Category** are strongly-typed `struct`/`enum` models
- Uses `Decimal` for monetary amounts (avoids floating-point errors)
- `Codable` conformance enables JSON serialisation
- `Identifiable` enables direct use in SwiftUI `ForEach`

### 2. Immutable Data & Idempotent Methods
- All model properties use `let` — mutation requires creating a new instance
- `ValidationService` methods are **pure functions** — no side effects
- ViewModel `@Published` properties use `private(set)` — Views cannot mutate state directly
- `MockAuthService` registration is idempotent: re-registering the same email returns a consistent error

### 3. Functional Separation (MVVM)
- **Models/** — pure data structures, zero UI awareness
- **Views/** — purely declarative SwiftUI, no business logic
- **ViewModels/** — `@Published` state + async service calls
- **Services/** — stateless request/response operations behind protocols
- **Utilities/** — shared constants and design tokens

### 4. Loose Coupling
- `AuthServiceProtocol` and `ValidationServiceProtocol` decouple ViewModels from implementations
- `ServiceContainer` acts as a composition root — change implementations in one place
- ViewModels accept services via **init injection** for testability
- Views use `@EnvironmentObject` — they never instantiate ViewModels' dependencies

### 5. Extensibility
- **New categories:** Add a `case` to `Category` enum → automatically appears in `allCases`
- **New features:** Create new ViewModel + View + Service protocol without touching existing code
- **New auth provider:** Conform to `AuthServiceProtocol`, swap in `ServiceContainer`
- **Analytics:** Add an `AnalyticsServiceProtocol`, inject into ViewModels, no existing code modified

### 6. Error Handling
- `AuthError` enum covers 10 distinct failure cases with user-friendly messages
- `ValidationService` returns `Result<Void, AuthError>` for composable validation
- ViewModels catch errors at the service boundary and surface them as `@Published errorMessage`
- UI shows `ErrorBanner` with animated transitions
- Password strength requirements are broken down into specific feedback messages

---

## 📱 Screen Flow

```
┌─────────────┐     ┌─────────────┐     ┌──────────────┐
│   Landing    │ ──▶ │    Login     │ ──▶ │     Home      │
│   Screen     │     │    Screen    │     │   Dashboard   │
└──────┬──────┘     └─────────────┘     └──────────────┘
       │                                       │
       │            ┌─────────────┐            │
       └──────────▶ │   Signup    │ ───────────┘
                    │   Screen    │     (on success)
                    └─────────────┘
```

- **Landing:** Branding, feature highlights, Get Started / Sign In buttons
- **Login:** Email + password, validation, error display, async auth
- **Signup:** Name + email + password + confirm, validation, error display
- **Home:** Greeting, balance card, quick actions, recent transactions, logout

---

## 👥 Team Feature Ideas (Future Development)

These features can be added **without modifying** existing code thanks to the protocol-oriented, modular architecture:

### 1. Expense Tracking
- Create `TransactionServiceProtocol` + `MockTransactionService`
- Add `AddTransactionView` + `AddTransactionViewModel`
- The `Transaction` model already exists

### 2. Budget Management
- Create `BudgetServiceProtocol` + `MockBudgetService`
- Add `BudgetListView`, `AddBudgetView` with ViewModels
- The `Budget` and `Category` models are ready

### 3. Spending Analytics (Charts)
- Use Swift Charts framework (`import Charts`)
- Create `AnalyticsViewModel` that queries transaction data
- Add `AnalyticsView` with pie/bar charts per category

### 4. Notifications
- Create `NotificationServiceProtocol`
- Implement budget threshold alerts
- Can use `UNUserNotificationCenter` for local push notifications

### 5. Savings Goals
- Create `SavingsGoal` model + `SavingsServiceProtocol`
- The home screen already has a progress bar placeholder

### 6. Multi-device Sync
- Replace `MockAuthService` with Firebase/CloudKit backend
- Add `SyncServiceProtocol` for data synchronisation
- Models are already `Codable` for serialisation

### 7. Recurring Transactions
- Extend `Transaction` with recurrence rules
- Add a scheduler service for automatic entries

### How to Add a New Feature (Template)

```
1. Define models in Models/ (if needed)
2. Create a protocol in Services/Protocols/
3. Implement a mock in Services/
4. Register in ServiceContainer
5. Create ViewModel in ViewModels/
6. Create View in Views/
7. Add navigation case in AppScreen enum
```

---

## 🧪 Testing Guide

The architecture is designed for testability:

```swift
// Example: Testing LoginViewModel with a mock service
class MockTestAuthService: AuthServiceProtocol {
    var shouldFail = false

    func login(request: LoginRequest) async throws -> AuthResponse {
        if shouldFail { throw AuthError.invalidCredentials }
        return AuthResponse(
            user: User(email: request.email, fullName: "Test"),
            token: "test-token",
            expiresAt: Date()
        )
    }

    func register(request: RegisterRequest) async throws -> AuthResponse { ... }
    func logout() async {}
}

@MainActor
func testLoginSuccess() async {
    let vm = LoginViewModel(
        authService: MockTestAuthService(),
        validationService: ValidationService()
    )
    vm.email = "test@example.com"
    vm.password = "Password1"
    let result = await vm.login()
    assert(result != nil)
    assert(vm.errorMessage == nil)
}
```

---

## 📋 Technical Notes

| Aspect               | Decision                                              |
|-----------------------|-------------------------------------------------------|
| iOS Target            | 16.0+                                                |
| Architecture          | MVVM + Service Layer + DI Container                  |
| Concurrency           | Swift `actor` + `async/await`                        |
| Password Hashing      | SHA-256 (`CryptoKit`) — mock only; use bcrypt in prod|
| State Management      | `@Published` + `@StateObject` + `@EnvironmentObject` |
| Dependency Injection  | Protocol-based with `ServiceContainer`               |
| Navigation            | Enum-driven via `AppViewModel.currentScreen`         |
| Thread Safety         | `@MainActor` ViewModels + `actor` services           |

---

*Built as the foundation layer of a group project. Designed for extensibility — teammates can add features by following the established patterns without modifying existing code.*
