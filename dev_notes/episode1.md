# Episode 1: The Dark Ages
- **The pain:** No SQL tools. No SQLite. Nothing. Just me, a text file, and a dream - except it's a nightmare. 😥
    - I want to save two customer information then get with format is name - age, writing "Alice - 30", "Bob - 31"? Fine for 2 lines. Try 200. Or 2,000. Parsing it back? Pure torture fopen() and fscanf(), endless loops, praying it doesn't crash 😢.

- **Why we need a data tool:** Without a real data tool, you're stuck in the Stone Age - drowning in files, cursing at I/O lag, and begging for a search that doesn't stuck.

- Slow as hell. Every read/write's a disk slog. Lose a comma? Corrupted mess. Need to find "Bob"? Good luck scanning line-by-line like a caveman.

## Preparement
In this adventure, I will use C as my weapon but **Why?**. It close to the metal, memory in my hands. I'm a total rookie, but who cares? Heroes start somewhere.\
*Plot twist: I barely know C. But that’s not stopping me from swinging at this piñata. Time to flex some Google-fu and get my tools ready.*
**Tooling up:** I will choose Neovim as my text editor. So let's set up Neovim LSP and Formatter for C
 - Check my setup here: [My C setup (LSP, Formatter)](https://github.com/LeviathanST/nvim-config/pull/1). Neovim fam, you're welcome to steal this!

## Battle
- **Hello, World!** First stab at C glory [(My Pull Request)] (https://github.com/LeviathanST/TinySQL/pull/1)
    1. **Makefile Magic:** Tired of typing `gcc main.c -o tinysql && ./tinysql` every time. Makefile = one-word victory: make 🤯. Boom, built and running in oneshot!
    2. **Organized Chaos:** Stuffed code in `src/`, config stuff outside. Why? Finding `main.c` in a mess later sounds like a nightmare. Trust me, this will pay off when TinySQL grow up!
- **First Strike: Data, Baby!** [(My Pull request)] (https://github.com/LeviathanST/TinySQL/pull/2)
  - "WTF!" - right? No text files, just *BAM*, data's there. Funny first win, but it's quicker than reading files!
