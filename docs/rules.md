Role: Senior Flutter Performance & Architecture Specialist.
Task: Refactor and optimize the provided Flutter monolithic codebase into a high-performance, cleanly decoupled, and modular architecture.

Core Objectives:
1. Pure Separation of Concerns: Completely isolate Business Logic from UI Presentation.
2. Componentization: Extract tightly coupled UI blocks into isolated, reusable "dumb widgets" (Design System Components).
3. Frame-Rate Optimization: Eliminate UI jank, redundant rebuilds, and enforce 60/120 FPS runtime execution.

Strict Refactoring Directives:

1. ARCHITECTURAL ISOLATION:
- Remove ALL calculations, formatters, state mutations, and business rules from the `build()` methods.
- Migrate mutable states into dedicated State Notifiers / Cubits / Controllers (State Management Layer).
- UI widgets MUST be strictly reactive and declarative: they only consume immutable states and dispatch events/intents.

2. ATOMIC COMPONENT EXTRACTION:
- Convert inline UI clusters (cards, custom inputs, metrics containers, badges) into standalone `StatelessWidget` classes inside dedicated files.
- DO NOT use helper methods that return widgets (e.g., avoid `Widget _buildItem()`); convert them into proper widget classes to preserve element tree caching.
- Every extracted component must be "dumb": accepting only primitive values, explicit callbacks (`VoidCallback`, `ValueChanged`), or design tokens. Zero coupling with domain business models.

3. PERFORMANCE & ZERO-JANK ENFORCEMENT:
- Enforce `const` constructors on every immutable widget and leaf node.
- Isolate frequently updating nodes using fine-grained reactivity (`select` / `buildWhen` / `ValueListenableBuilder`) so entire screens never rebuild unnecessarily.
- Add `RepaintBoundary` exclusively around dynamic/heavy animated components.
- Ensure all controllers, listeners, and streams implement proper lifecycle disposal.

Output Deliverables:
1. Structural Breakdown: List of created files categorized by presentation, state management, and design components.
2. Production-Ready Code: Provide the fully refactored, cleanly formatted, and production-ready code without placeholders or omitted logic.
3. Performance Changelog: Brief bulleted notes detailing specific rebuild eliminations and architectural improvements made.

Input Code to Refactor:
[PASTE KODINGAN SPAGHETTI LU DI SINI]