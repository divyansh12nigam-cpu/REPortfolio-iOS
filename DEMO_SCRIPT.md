# Demo Script: Claude Code for Product Managers

**Duration:** 35 minutes | **Audience:** Product Manager (non-technical)
**Core message:** "Describe what you want in product language. Claude builds it."

---

## Before You Start (Checklist)

- [ ] Terminal open with Claude Code ready
- [ ] `CLAUDE.md` present in project root (Claude reads this automatically)
- [ ] Have the user story text below ready to paste
- [ ] Optional: Xcode open with Simulator to show before/after

---

## Segment 1: "Meet the Project" (5 min)

**Setup:** Open a fresh Claude Code session in the REPortfolio-iOS directory.

**What to type:**

> Explain what this app does and who it's for, in simple terms.

**What to say while Claude works:**
_"I start every session like this. Claude reads our CLAUDE.md — think of it as a product brief for AI — and instantly understands the app. No onboarding, no context-switching. It's like a team member who actually reads the docs."_

**Expected outcome:** Claude gives a clear, PM-friendly summary of the app — real estate portfolio tracking, Indian market, valuations from 99acres, rental monitoring.

**Transition:** _"So Claude understands the product. Now let's see what happens when I give it a user story."_

---

## Segment 2: "From User Story to Code" (15 min) — THE MAIN EVENT

**What to type:**

> As a new user opening REPortfolio for the first time, I want to see a welcoming empty state that highlights the app's 3 key benefits — track property value, compare returns with Gold/Nifty, and monitor rental income — so I feel confident adding my first property.
>
> Enhance the empty state in PortfolioSummaryView. Add 3 benefit cards with icons above the existing "Add Property" button. Use our existing design tokens for colors and spacing.

**What to say while Claude works:**
_"Watch what's happening. I described the feature the way I'd write a user story — in product language, not code. Claude is now:"_
1. _"Finding the right file to change"_
2. _"Understanding the existing design system"_
3. _"Writing the actual SwiftUI code"_

_"I didn't tell it which file, which line, or which function. It figured that out."_

**Expected outcome:** Claude modifies `PortfolioSummaryView.swift` — adds 3 benefit cards (SF Symbol icons + titles + descriptions) in the empty state, above the Add Property CTA.

**Talking point after it's done:**
_"That was about [X] minutes from user story to working code. In a traditional workflow, this is a ticket, a sprint planning discussion, a design spec, implementation, and review. Here it's a conversation."_

**Transition:** _"But shipping the first version is just the start. Let's iterate."_

---

## Segment 3: "Iterate Like a PM" (8 min)

**What to type:**

> The benefit cards look good. Two tweaks:
> 1. Change the headline to "Start Building Your Portfolio"
> 2. Make the icon circles use our brandPrimary color with 10% opacity background instead of gray

**What to say:**
_"This is the loop I use every day. Build, look at it, give feedback in plain English, and see the changes immediately. No context switching — the conversation IS the spec."_

**Expected outcome:** Claude makes targeted edits to the same view — updates the headline text and adjusts the icon styling to use brand colors.

**If the audience asks "can you change X?":**
Go ahead and type their suggestion live. This is the best demo moment — the audience sees their own idea implemented in real-time.

**Transition:** _"Happy with how this looks. Let's ship it."_

---

## Segment 4: "Ship It" (5 min)

**What to type:**

> /commit

**What to say:**
_"Claude writes the commit message from the changes it made — it knows what changed and why. From user story to committed code in one session."_

**Expected outcome:** A clean commit with a descriptive message summarizing the empty state enhancement.

---

## Wrap-up & Q&A (5 min)

**Key messages to land:**

1. **Product language in, working code out** — You describe the _what_, Claude handles the _how_
2. **Instant iteration** — Feedback loop is conversational, not asynchronous
3. **Context-aware** — CLAUDE.md gives it product knowledge; it follows existing patterns automatically
4. **Complete workflow** — From idea to pull request without leaving the terminal

**Likely PM questions and answers:**

**"Does it always get it right?"**
_"Not always on the first try — just like any engineer. But the iteration is so fast that it doesn't matter. A round-trip that used to take hours takes seconds."_

**"Can it work from Figma designs?"**
_"Not directly from Figma files yet, but I can paste design specs or describe the visual requirements and it matches our design system."_

**"What about complex business logic?"**
_"It handles that too. Our 99acres valuation caching, the investment comparison math — Claude built and iterated on all of that. The key is giving it good context through CLAUDE.md."_

**"Is it replacing engineers?"**
_"No — it's making engineers faster. I still make all the product and architecture decisions. Claude handles the boilerplate so I focus on what matters."_

---

## Backup Plans

**If Claude is slow:**
Fill time by explaining what it's doing: _"It's reading through our design system to match the existing visual language..."_

**If the output isn't quite right:**
This is actually a GREAT demo moment — iterate on it live. _"See? First try wasn't perfect, but watch how fast the feedback loop is."_

**If something breaks:**
_"This happens in real development too. Watch how Claude diagnoses and fixes the issue."_
Then type: "That doesn't look right, can you fix [specific issue]?"
