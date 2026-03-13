# REPortfolio-iOS

Real estate portfolio tracker for Indian property investors. Lets users add properties, get live valuations from 99acres data, compare returns against Gold/Nifty benchmarks, and monitor rental income.

## Tech Stack

- **SwiftUI** (iOS 16.0+, Swift 5.9)
- **Supabase** (auth + cloud CRUD, only external dependency)
- **XcodeGen** (`project.yml` generates `.xcodeproj`)
- **99acres valuation API** hosted on Render (scraper service)

## Project Structure

```
REPortfolioApp.swift        # Entry point, auth routing
DesignSystem/               # Colors, Typography, Tokens (spacing/sizing)
Data/                       # Models, PropertyRepository (shared state), AuthManager
  Network/                  # API clients (valuation, portfolio, Supabase)
UI/
  Screens/                  # Full-page views (Portfolio, PropertyDetail, AddProperty, SignIn, Profile)
  Components/               # 21 reusable SwiftUI components
Utils/                      # INR formatters, URL builders
```

## Key Patterns

- **Singleton state:** `PropertyRepository.shared` holds all property data as `@Published` vars
- **Dual persistence:** UserDefaults (offline fallback) + Supabase (cloud source of truth)
- **Navigation:** `AppScreen` enum + ZStack transitions (no NavigationStack)
- **Async/await** for all network calls
- **INR formatting:** Indian numbering system (Lakhs, Crores) via `Formatters.swift`

## Build

```bash
xcodegen generate   # Generates REPortfolio-iOS.xcodeproj from project.yml
open REPortfolio-iOS.xcodeproj
```

## Conventions

- Keep views under ~350 lines; extract reusable components to `UI/Components/`
- Use design tokens from `DesignSystem/` (Colors, Typography, Tokens) — don't hardcode colors or spacing
- Network DTOs live in `Data/Network/`, domain models in `Data/Models.swift`
- Commit messages are descriptive, often prefixed with task/phase labels (e.g., P3, P4)
