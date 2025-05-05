After 3 days, I realized that I can't run the computer 24/7 just to run the application. We need other way to store data.
- [x] Use file, but in binary form, it will be many times smaller than text file (csv).
- [x] Some basic operation to interact with file.
  - [x] Create
  - [x] Update
  - [x] Delete:
    - The current strategy is to write the new data to the new file, then remove the old file and rename the new file into the old filename.
  - [x] Read: Find and ReadAll
