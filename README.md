# 🎮 Arcade Survival Dodger (Godot 4.x MVP)

A fast-paced 2D arcade survival game built in **Godot 4.x** where the player must dodge escalating hazards across multiple phases: cannons, a central pit, and a final survival “safe zone” bomb phase.

---

## Game Overview

You control a small player character trying to survive as long as possible against progressively harder hazard systems:

### Level 1 — Cannon Phase
- Cannons spawn at screen edges
- Cannons aim at the player
- Telegraph laser warning
- Shoot projectiles after a delay
- Difficulty increases over time

---

### Level 2 — Pit Phase
- A central Pit appears
- 4 directional “guns” (top, bottom, left, right)
- Each attack randomly selects a direction per side
- Laser telegraph warning before firing
- Pit becomes more aggressive over time
- Cannons remain active (frozen difficulty scaling)

---

###  Level 3  — Final Bomb Phase
- Cannons and Pit are removed
- Arena enters survival rounds (5 total)
- A safe zone appears randomly each round
- Everything outside safe zone is lethal
- Red blinking warning phase
- White flash explosion phase
- Survive all rounds to win

---

## Core Gameplay Loop

```text
Survive time → New phase unlocks → Difficulty escalates → Final survival test → Victory
