# Horde

A 2D top-down action survival game built in **Godot 4**. The player must survive against endless waves of varied zombies using a diverse arsenal of weapons.

## Game Mechanics & Features

- **Movement & Combat:** Smooth WASD movement, precise mouse aiming, and dynamic firing modes (automatic for ARs/SMGs/LMGs, manual for Pistols/Shotguns/Snipers).
- **Weapon System:**
  - **Infinite Ammo:** Total ammo is unlimited, bound only by magazine size and reload speeds.
  - **Advanced Mechanics:** Features burst-fire loops, random bullet spread, critical hit chances, and bullet penetration (allowing shots to pass through multiple enemies).
- **Enemies:** Face off against multiple enemy variants including Normals, Brutes, and Specials, all driven by state machine logic.

## Code Architecture

- **BaseWeapon Inheritance:** The core `BaseWeapon` class (`scripts/baseweapon.gd`) handles the complex logic for firing, reloading, burst timing, and spawning projectiles. Specific weapons (e.g., `scripts/gun scripts/smg1.gd`, `scripts/gun scripts/snpr2.gd`) inherit from this base class and override default stats in their `_init()` functions.
- **Enemy State Machine:** Enemies utilize a straightforward state machine (`CHASE`, `ATTACK`, `DEAD`) in their scripts (e.g., `scripts/normal.gd`) to determine their behavior and current animations.
- **Bullet Logic:** The `Bullet` scene (`scripts/bullet.gd`) manages its own movement and pre-calculates critical hits upon spawning. It handles penetration by decrementing a counter each time it hits a valid target.

## Credits

This project utilizes several fantastic free asset packs:

- **[Kenney's Isometric Blocks](https://kenney.nl/)**
- **PostApocalypse Asset Pack v1.1.2**
- **Ranitayas Guns Pack (16+ pixelart guns)**
- **The Ultimate Weapons Pack**
- **Tiny Swords (Free Pack)**