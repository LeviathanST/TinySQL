# Episode 3: Soul Forge
*Hours after the soul flood*
- **The Pain**: The void’s a relentless bastard—100 slots melted under infinite souls like a cheap coffee filter. Charlie’s in, but thousands more are piling up, screaming, “Reap me!” I’m slamming coffee, but TinySQL’s a toy truck in a soul avalanche—arrays are cracking, my ledger’s a joke, and the void’s howling, “Out of memory, punk!” I’m a reaper, not a RAM babysitter—this ends now!
- **The Call**: 
  - TinySQL’s gotta grow infinite - no more half-assed hacks. The void wants a war, I’m bringing the C arsenal.
  - But first—loose vars are trash! Souls in random arrays? It’s so suck—no meaning, just a chaotic data puke. Forge ‘em right, then bust the memory chains!

# Peparement
- **Thoughts:**
    - **Struct:** This is like a constructor for everything. Suitable for make our people information more meaning.
    - **Memory Barrier:** Array are fixed-length garbage, 100 slots. Hmmm...! So we need a way to be able to change the length of that array. YESSSSS, that's it! `malloc`, `realloc` - stretch that ledger infinite, baby!!

# Battle
- **The Forge Ignites** [(My Pull Request)](https://github.com/LeviathanST/TinySQL/pull/11) Three commits:
  - Commit 1 [Struct Soul](https://github.com/LeviathanST/TinySQL/pull/11/commits/954d3847175e5cc0b0a3ac40270f6db9fc7fca88): Loose vars? Suck’s over—structs weld name and age into soul steel. Charlie’s a real reap now, not a data ghost! MUAHAHAHA!
  - Commit 2 [Typedef swagger](https://github.com/LeviathanST/TinySQL/pull/11/commits/5e6e129f159eaf16256d16c188549133ceaec0fd): Soul’s a type soon—clean, fierce, reaper-coded. Style meets scale!
  - Commit 3 [Memory Unleashed](https://github.com/LeviathanST/TinySQL/pull/11/commits/2606d92af0ccccec9238217a6b974dd54c589395): `malloc` and `realloc` smash the fixed-length curse. Infinite souls flood in, ledger grows—void’s “out of memory” taunt’s my new war cry!
   
