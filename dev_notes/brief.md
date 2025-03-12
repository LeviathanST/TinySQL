# Plan
*In somewhere there isn't any data saving tools, we are a digital grim reaper, no cloak and list soon-will-be-die, just a comupter and a coffee, we created one inspired by SQLite*
- Data saving? No text files - no I/O slow and dump.
  - Data is hardcoded and compiled in our code.
    - Use variable and array.
    - Then use struct to make more sense.
  - Hm... But we need more data!
    - User input - add input to fixed length array
    - `malloc`, `realloc` for unlimited length array
- Comeback to file but smarter!
  - Exploded RAM => Using disk
    - Writting and reading data in a file with binary data
