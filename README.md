# MP3 Organizer PowerShell Script

## Introduction

This PowerShell script automates organizing your MP3 files by moving them from a downloads folder to a music_files folder, removing duplicate tracks based on title metadata, and renaming numeric filenames to a consistent 5-digit zero-padded format.

**Note:** This project works only in conjunction with the **[Youtube-Toolkit project](https://github.com/MoreKronos/Youtube-Toolkit)**, as it relies on the folder structure and files created by that toolkit.

## Prerequisites

- Windows with PowerShell (v5+ recommended)
- The Youtube-Toolkit project set up properly
- downloads and music_files folders created by the Youtube-Toolkit

## Features

- Moves MP3 files from downloads to music_files
- Removes duplicate MP3 files based on Title metadata tag
- Renames numeric MP3 filenames to zero-padded 5-digit format (e.g., 12.mp3 → 00012.mp3)
- Creates a duplicates_found.flag file if duplicates are found and removed

## Usage

- Place the PowerShell script inside the scripts folder within your project directory.
- Make sure the **[Youtube-Toolkit](https://github.com/MoreKronos/Youtube-Toolkit)** has downloaded files into the downloads folder.

## License

Copyright (c) 2025 **[MoreKronos](https://github.com/MoreKronos/)**

All rights reserved.

Permission is hereby granted to use this software solely in its original form and solely for its intended purpose.

No part of this software may be copied, modified, distributed, sublicensed, or incorporated into derivative works without prior express written permission from the copyright holder.

This license does not grant any rights to reverse engineer, decompile, or disassemble the software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE, AND NON-INFRINGEMENT.

In no event shall the copyright holder be liable for any claim, damages, or other liability arising from the use of this software.

csharp
Copy
Edit

## Contact

If you have questions or requests, contact me on Discord:  
**[Morekronos#5898](http://discordapp.com/users/589826883596713998)**

## Notes

- The script uses Windows Shell COM objects to read MP3 metadata.
- Only intended for use with **[Youtube-Toolkit](https://github.com/MoreKronos/Youtube-Toolkit)** folder structure.
