#  LFConcurrencyKit (CY)

LFConcurrencyKit is a lightweight infrastructure framework providing low-level concurrency and execution utilities.
The framework is designed to host system-oriented components such as:
Dedicated threads
Run loop–based execution contexts
Scheduling and synchronization helpers
Its goal is to offer explicit control over execution environments while remaining independent from UI and high-level application logic.

- Naming Convention

All public types exposed by LFConcurrencyKit use the CY prefix.
This convention is enforced to:
• Avoid naming collisions across modules
• Clearly identify framework-owned symbols
• Preserve clarity when interacting with system APIs

Any new type added to this framework must follow this naming rule.

- Design Principles

• Explicit lifecycle management
• Predictable execution contexts
• Minimal abstractions over system primitives
• No UI dependencies

- Scope

LFConcurrencyKit intentionally focuses on infrastructure-level concerns.
Application logic and domain-specific behavior should live outside this framework.
