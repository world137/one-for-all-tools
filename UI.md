# Web UI Design Guide — dev-tools

## 1. Purpose

This document defines the UI/UX standards for all web-based tools in the `dev-tools` repository.

Every web tool should feel like it belongs to the same product.

The design goal is:

> **Google-like, minimal, clean, fast, familiar, and easy to use.**

The UI should prioritize:

1. Ease of use
2. Clarity
3. Speed
4. Minimal visual noise
5. Consistent interaction
6. Accessibility

Do not create visually complicated interfaces unless the tool genuinely requires it.

---

# 2. Design Philosophy

The overall design should feel inspired by modern Google products:

- Google Search
- Google Drive
- Google Docs
- Google Fonts
- Material-style interfaces

However:

> Do NOT blindly copy Google's UI.

Use the same design principles:

```text
Simple
        ↓
Clear
        ↓
Focused
        ↓
Fast
        ↓
Predictable
```

The user should immediately understand:

- What the tool does
- What input is required
- What action to perform
- What the result means

---

# 3. Core UI Principles

## 3.1 Minimal

Avoid unnecessary UI elements.

Bad:

```text
┌───────────────────────────────────────────────┐
│ Logo     Dashboard   Tools   Settings   Help │
├───────────────────────────────────────────────┤
│                                               │
│             BIG DECORATIVE IMAGE              │
│                                               │
│          Welcome to JSON Formatter            │
│                                               │
│  This is a very powerful JSON formatting tool │
│                                               │
│       [ Start ] [ Learn More ] [ Settings ]   │
│                                               │
└───────────────────────────────────────────────┘
```

Prefer:

```text
JSON Formatter

[ Paste JSON here...                     ]

                [ Format ]

Result
[ { ... } ]
```

Every element should have a purpose.

---

# 4. Visual Style

The visual style should be:

```text
Clean
Modern
Neutral
Light
Simple
Professional
```

Avoid:

```text
Heavy gradients
Large shadows
Excessive rounded cards
Neon colors
Decorative backgrounds
Animations everywhere
Huge typography
Crowded navigation
```

---

# 5. Color System

Use a mostly neutral color palette.

Recommended:

```text
Background
#FFFFFF

Primary text
#202124

Secondary text
#5F6368

Border
#DADCE0

Hover background
#F8F9FA

Primary action
#1A73E8

Success
#188038

Warning
#F9AB00

Error
#D93025
```

The UI should normally use:

```text
80–90% neutral colors
10–20% accent colors
```

Do not use many colors simultaneously.

---

# 6. Dark Mode

Dark mode is optional.

If implemented, it should use a neutral dark palette.

Example:

```text
Background
#202124

Surface
#292A2D

Primary text
#E8EAED

Secondary text
#9AA0A6

Border
#3C4043
```

Do not simply invert the light theme.

---

# 7. Typography

Prefer:

```css
font-family:
  Inter,
  "Google Sans",
  Roboto,
  Arial,
  sans-serif;
```

The interface should have clear hierarchy.

Example:

```text
Tool Name
24–32px

Section
18–20px

Normal text
14–16px

Secondary text
13–14px

Small metadata
12px
```

Avoid excessive font sizes.

---

# 8. Layout

Use a centered content layout.

Recommended:

```text
┌──────────────────────────────────────────────┐
│                                              │
│              Tool Name                       │
│              Description                     │
│                                              │
│        ┌────────────────────────────┐        │
│        │                            │        │
│        │        Main Content        │        │
│        │                            │        │
│        └────────────────────────────┘        │
│                                              │
└──────────────────────────────────────────────┘
```

Recommended maximum width:

```text
800px – 1200px
```

depending on the tool.

For text-focused tools:

```text
max-width: 800px;
```

For editors and data tools:

```text
max-width: 1200px;
```

Do not stretch content across the entire browser unless necessary.

---

# 9. Spacing

Use a consistent spacing scale.

Preferred:

```text
4px
8px
12px
16px
24px
32px
48px
64px
```

Avoid arbitrary spacing such as:

```text
13px
27px
37px
51px
```

unless there is a specific reason.

The most common spacing should be:

```text
8px
16px
24px
32px
```

---

# 10. Header

Headers should be simple.

Preferred:

```text
┌──────────────────────────────────────────────┐
│ dev-tools                 Tool Name          │
└──────────────────────────────────────────────┘
```

or:

```text
┌──────────────────────────────────────────────┐
│ Tool Name                         ⋮           │
└──────────────────────────────────────────────┘
```

Avoid large marketing-style headers.

Do not use:

```text
BIG LOGO
BIG HERO IMAGE
BIG GRADIENT
BIG TEXT
```

unless the tool specifically requires it.

---

# 11. Navigation

Navigation should be minimal.

If the tool only has one screen:

> Do not create a navigation bar.

If multiple sections exist:

```text
Home
Tool
History
Settings
```

Use simple navigation.

Avoid:

```text
Home
Dashboard
Workspace
Projects
Analytics
Reports
Notifications
Integrations
Settings
Help
Profile
```

when the application only needs 2–3 screens.

---

# 12. Buttons

Buttons should be simple and recognizable.

Primary button:

```text
┌─────────────────┐
│     Format      │
└─────────────────┘
```

Secondary button:

```text
┌─────────────────┐
│     Clear       │
└─────────────────┘
```

Use one primary action per section whenever possible.

Preferred hierarchy:

```text
Primary
[ Format ]

Secondary
[ Clear ]

Tertiary
Cancel
```

Do not make every button visually dominant.

---

# 13. Button Rules

Primary buttons should:

- Have clear labels
- Describe the action
- Be easy to find
- Not contain unnecessary icons

Good:

```text
Format
Copy
Download
Save
Run
Validate
```

Bad:

```text
Go
Do It
Submit
Action
Process
```

unless the meaning is obvious from context.

---

# 14. Icons

Icons should support understanding.

Use icons for:

```text
Copy
Delete
Download
Settings
Search
Close
Menu
```

Do not use icons purely for decoration.

Prefer familiar iconography.

If an icon is not universally obvious, include a tooltip or text label.

---

# 15. Forms

Forms should be simple.

Example:

```text
JSON Input

┌──────────────────────────────────────────┐
│                                          │
│ {                                        │
│   "name": "John"                         │
│ }                                        │
│                                          │
└──────────────────────────────────────────┘

             [ Format ]
```

Labels should appear above inputs.

Prefer:

```text
Label
Input
Help text
```

instead of:

```text
Input [Label inside placeholder]
```

Placeholders are not substitutes for labels.

---

# 16. Text Areas / Editors

Developer tools often require large input areas.

Use:

```text
┌──────────────────────────────────────────┐
│                                          │
│                                          │
│              Input                       │
│                                          │
│                                          │
└──────────────────────────────────────────┘
```

Recommended:

```css
font-family:
  "SFMono-Regular",
  Consolas,
  "Liberation Mono",
  monospace;
```

for:

- JSON
- YAML
- SQL
- Code
- Logs
- CLI output

---

# 17. Input and Output

When a tool transforms data, use a clear input → output relationship.

Preferred:

```text
Input

┌──────────────────────────────┐
│                              │
│                              │
└──────────────────────────────┘

             [ Format ]

Output

┌──────────────────────────────┐
│                              │
│                              │
└──────────────────────────────┘
```

For wide screens:

```text
┌─────────────────────┬─────────────────────┐
│                     │                     │
│       Input         │       Output        │
│                     │                     │
│                     │                     │
└─────────────────────┴─────────────────────┘
```

Use the layout that best fits the task.

---

# 18. Cards

Cards should be used sparingly.

Good use:

```text
┌─────────────────────────────┐
│ JSON Formatter              │
│                             │
│ Format and validate JSON.   │
│                             │
│ [ Open ]                    │
└─────────────────────────────┘
```

Bad:

```text
Card inside card
  Card inside card
    Card inside card
```

Do not use cards simply because cards look modern.

---

# 19. Borders and Shadows

Prefer borders over heavy shadows.

Good:

```css
border: 1px solid #dadce0;
```

Use subtle shadows only when necessary.

Avoid:

```css
box-shadow:
  0 20px 50px rgba(...);
```

for normal components.

The interface should feel lightweight.

---

# 20. Border Radius

Use small to moderate radius.

Recommended:

```text
4px
6px
8px
12px
```

For example:

```css
border-radius: 8px;
```

Avoid excessive pill-shaped components.

Use pills primarily for:

- Tags
- Status
- Filters

---

# 21. Responsive Design

Every web tool must work on:

```text
Desktop
Tablet
Mobile
```

Desktop should not be the only target.

For mobile:

```text
┌─────────────────────┐
│ Tool Name           │
├─────────────────────┤
│                     │
│ Input               │
│                     │
│                     │
├─────────────────────┤
│                     │
│ Output              │
│                     │
└─────────────────────┘
```

Desktop:

```text
┌────────────────────────────────────────────┐
│                                            │
│ Input                 Output               │
│                                            │
│                                            │
└────────────────────────────────────────────┘
```

Use CSS Grid/Flexbox rather than JavaScript for layout.

---

# 22. Responsive Breakpoint

A simple breakpoint is usually sufficient:

```css
@media (max-width: 768px) {
    ...
}
```

Do not create many breakpoints unless necessary.

---

# 23. Accessibility

Every tool must consider accessibility.

Requirements:

- Semantic HTML
- Keyboard navigation
- Visible focus states
- Proper labels
- Sufficient color contrast
- Buttons must be keyboard accessible
- Do not rely only on color to communicate state
- Images need appropriate `alt` text
- Form controls need labels

Example:

```html
<label for="json-input">
  JSON Input
</label>

<textarea
  id="json-input"
  aria-describedby="json-help">
</textarea>
```

---

# 24. Keyboard Shortcuts

Developer tools can benefit from keyboard shortcuts.

Examples:

```text
Cmd/Ctrl + Enter
Run / Format

Cmd/Ctrl + K
Clear

Cmd/Ctrl + Shift + C
Copy
```

Do not introduce shortcuts that conflict with common browser behavior.

Always provide a visible way to perform the same action.

---

# 25. Loading States

Do not leave the user wondering whether something happened.

Bad:

```text
[ Run ]
```

then nothing.

Better:

```text
[ Running... ]
```

or:

```text
Running...
```

For longer operations:

```text
Processing...

████████████░░░░░░ 65%
```

For fast operations, avoid unnecessary loading animations.

---

# 26. Empty States

Empty states should explain what the user should do.

Bad:

```text
No data
```

Better:

```text
No results yet.

Enter your input and click "Format".
```

Keep empty states short.

---

# 27. Error Messages

Errors should explain:

1. What happened
2. Why it happened when known
3. How to fix it

Example:

```text
Invalid JSON

Line 4 contains an unexpected comma.

Fix the JSON and try again.
```

Avoid technical stack traces in the primary UI.

Technical details may be available through:

```text
Show details
```

---

# 28. Success Messages

Use short confirmations.

Good:

```text
Copied to clipboard
```

```text
File downloaded
```

```text
Saved successfully
```

Avoid:

```text
🎉 Congratulations! Your operation has been completed successfully!
```

Keep it simple.

---

# 29. Toast Notifications

Use toast notifications for lightweight feedback.

Example:

```text
┌──────────────────────────────┐
│ ✓ Copied to clipboard        │
└──────────────────────────────┘
```

Do not use toasts for important information that must remain visible.

---

# 30. Animation

Animation should be subtle and functional.

Good:

```text
Button hover
Modal open
Toast appearance
Loading indicator
```

Avoid:

```text
Floating everything
Bouncing buttons
Large page transitions
Continuous animations
```

General rule:

> If removing the animation improves usability, remove it.

---

# 31. Icons and Images

Developer tools generally do not need decorative images.

Prefer:

```text
Typography
Whitespace
Icons
Simple shapes
```

over:

```text
Hero images
Illustrations
Background graphics
Decorative patterns
```

Use images only when they improve understanding.

---

# 32. Page Structure

A typical tool should follow:

```text
┌──────────────────────────────────────────────┐
│ Header                                       │
├──────────────────────────────────────────────┤
│                                              │
│ Tool title                                   │
│ Short description                            │
│                                              │
│ Main tool                                     │
│                                              │
│                                              │
│ Optional help                                │
│                                              │
└──────────────────────────────────────────────┘
```

Example:

```text
JSON Formatter

Format, validate and inspect JSON.

┌──────────────────────────────────────────────┐
│ Input                                        │
│                                              │
│ {                                            │
│   "name": "John"                             │
│ }                                            │
│                                              │
└──────────────────────────────────────────────┘

[ Format ]   [ Clear ]

Output

┌──────────────────────────────────────────────┐
│ {                                            │
│   "name": "John"                             │
│ }                                            │
└──────────────────────────────────────────────┘
```

---

# 33. Information Hierarchy

Every screen should have a clear hierarchy.

```text
1. What is this?
2. What should I enter?
3. What should I click?
4. What happened?
5. What can I do next?
```

If users need to read documentation before understanding the screen, the UI is probably too complicated.

---

# 34. Avoid Unnecessary UI

Do not add:

- Dashboard
- Sidebar
- Breadcrumbs
- Tabs
- Modal
- Settings page
- Login
- Profile
- Notifications

unless the tool actually requires them.

A small tool should feel like a small tool.

---

# 35. Tool Consistency

All web tools inside `dev-tools` should share:

```text
Typography
Spacing
Colors
Buttons
Inputs
Error messages
Toast messages
Header
Responsive behavior
```

A user should be able to move from:

```text
JSON Formatter
```

to:

```text
SQL Formatter
```

and immediately understand the second tool.

---

# 36. Shared CSS

If multiple web tools use the same UI system, prefer creating shared styles.

Example:

```text
web/
├── _shared/
│   ├── styles.css
│   ├── components.css
│   └── theme.css
│
├── json-formatter/
├── sql-formatter/
└── yaml-validator/
```

Do not copy the same CSS into every tool.

---

# 37. Component Style

Common components should have consistent appearance.

### Button

```text
Primary
██████████████
```

### Input

```text
┌────────────────────────────┐
│                            │
└────────────────────────────┘
```

### Select

```text
┌────────────────────────────┐
│ Option                  ▼  │
└────────────────────────────┘
```

### Status

```text
● Ready
```

### Error

```text
! Invalid input
```

---

# 38. Google-like Interaction Principles

Use familiar interaction patterns.

Examples:

### Search

```text
🔍 Search tools
```

### Copy

```text
Copy
```

### Download

```text
Download
```

### Clear

```text
Clear
```

### Settings

```text
⚙ Settings
```

Do not invent unusual interactions when standard patterns already exist.

---

# 39. Performance

Web tools should load quickly.

Prefer:

```text
Vanilla JS
Small CSS
Small dependencies
Lazy loading when needed
```

Avoid adding a large framework for a tiny tool unless there is a clear benefit.

For a simple formatter:

```text
HTML
CSS
JavaScript
```

may be preferable to:

```text
React
Redux
Router
UI Framework
State Library
```

The simplest technology that solves the problem should be preferred.

---

# 40. Dependency Rules

Before adding a UI dependency, ask:

```text
Does this dependency significantly improve the tool?

Can this be implemented with native HTML/CSS/JS?

Will it increase maintenance?

Will it increase bundle size?

Does every web tool need it?
```

Avoid dependencies for trivial functionality.

---

# 41. Browser Compatibility

Target modern browsers:

```text
Chrome
Edge
Firefox
Safari
```

Avoid browser-specific APIs unless necessary.

When using a browser-specific feature, provide a graceful fallback where practical.

---

# 42. Design Before Implementation

When AI generates a new web tool, it should first define:

```text
Purpose
Primary action
Input
Output
Error states
Empty state
Responsive behavior
```

Example:

```text
Tool:
JSON Formatter

Primary action:
Format

Input:
JSON text

Output:
Formatted JSON

Secondary actions:
Copy
Clear
Download

Errors:
Invalid JSON

Mobile:
Input and output stacked vertically
```

Then implement the UI.

---

# 43. AI UI Development Rules

AI agents MUST:

- Keep interfaces minimal
- Reuse existing styles/components
- Follow the shared color system
- Follow the spacing system
- Use semantic HTML
- Make interfaces responsive
- Provide keyboard-accessible controls
- Use clear labels
- Provide useful error messages
- Avoid unnecessary animations
- Avoid unnecessary dependencies
- Avoid decorative UI

AI agents MUST NOT:

- Add gradients without a clear reason
- Add excessive shadows
- Add unnecessary cards
- Add unnecessary navigation
- Add decorative animations
- Use many accent colors
- Create inconsistent buttons
- Put important actions behind obscure menus
- Create a dashboard for a single-purpose tool

---

# 44. Definition of Done

A web UI is complete when:

### UX

- [ ] Purpose is immediately obvious
- [ ] Primary action is obvious
- [ ] Input and output are clear
- [ ] Error states are understandable
- [ ] Empty states are useful
- [ ] No unnecessary UI exists

### Visual

- [ ] Google-like minimal design
- [ ] Neutral color palette
- [ ] Consistent typography
- [ ] Consistent spacing
- [ ] Subtle borders/shadows
- [ ] Consistent buttons
- [ ] Consistent form controls

### Responsive

- [ ] Desktop works
- [ ] Tablet works
- [ ] Mobile works
- [ ] No horizontal overflow

### Accessibility

- [ ] Keyboard navigation works
- [ ] Inputs have labels
- [ ] Focus state is visible
- [ ] Contrast is sufficient
- [ ] Semantic HTML is used

### Performance

- [ ] Page loads quickly
- [ ] No unnecessary dependencies
- [ ] No unnecessary network requests
- [ ] No unnecessary animations

---

# 45. Final Design Rule

Before adding any UI element, ask:

> **Does this help the user accomplish the task?**

If the answer is no, remove it.

The ideal `dev-tools` web application should feel like:

```text
                    ┌──────────────────────────┐
                    │                          │
                    │       Tool Name           │
                    │       Description         │
                    │                          │
                    │  ┌────────────────────┐  │
                    │  │                    │  │
                    │  │      Main Tool     │  │
                    │  │                    │  │
                    │  └────────────────────┘  │
                    │                          │
                    │        [ Primary ]       │
                    │                          │
                    └──────────────────────────┘
```

Not:

```text
Dashboard
├── Sidebar
├── Header
├── Notifications
├── Profile
├── Analytics
├── Multiple Cards
├── Multiple Tabs
├── Multiple Modals
└── The actual tool
```

**Simple is the default.**

When in doubt:

> **Remove UI rather than add UI.**