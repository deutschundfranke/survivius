# Collisions

This file documents all the collision decisions for the game.

## Levels

All collidable entities in Godot are assigned to layers, and layer
masks define which entities may collide with which. By default, all entities are
assigned layer 1, and may collide with everything.

For efficiency, we define the layers as such:

* 1: Player Ship
* 2: Player-owned projectiles
* 3: Enemies
* 4: Collectibles
* 5: Shop areas
* 6: Solid scenery (i.e. shop dividers)

## Monitored collisions

We monitor collisions one-way. The monitoring entity selects the monitored layers
in their mask, and is the one to emit the signal, if applicable.

* Player: collides with solid scenery `6`
* Player-owned projectiles: collide with enemies `3`
* Enemies: collide with the player `1`
* Collectables: collide with the player `1`
* Shop areas: collide with the player `1`

(At the time many layers are not even monitored; this may change if we ever reverse the
direction of the monitoring.)
