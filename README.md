# 50!Mania - CS50G final project by Miguel Gonzalez

<img alt="screen" src="https://user-images.githubusercontent.com/44068372/100547206-c13cb900-3265-11eb-98e0-fad26fba13e4.png" width="600"/>

## Usage

This repository constitutes a LOVE2D project that can be run with Love2D as specified on https://love2d.org/wiki/Getting_Started.

If using windows, you can use the contents of WindowsInstall instead, which do not require to install Love2D. 
To do so, copy the contents of the WindowsInstall directory somewhere, and copy the "levels" folder to the same place. You can then run
50!mania.exe and it should detect the levels.

## About

50!Mania is a rythm-based DDR-like game such as stepmania or osu!mania made with LOVE (2D), made by Miguel Gonzalez. The game audio was made by Kevin McLeod from incompetech as part of his royalty-free
music library. Showcase video can be found [here](https://www.youtube.com/watch?v=POeyXxUaCU0).

## Levels

50!Mania's levels are loaded from the "levels" directory and are organized as follows:

1. On the levels directory, there's a subdirectory (any name works) containing an .mp3 file which constitutes the level song.
2. On the same subdirectory, any number of .50m files can be placed. These are the levels themselves, tied to the audio file.
3. The same subdirectory can contain a png or jpg file which will constitute the level background.
4. The .50m files have the following format:

- Line 1 -> 50!ManiaV1
- Line 2 -> Parameters in the format name=value separated by semicolon
- Line 3 onwards: Notes with format column:timestamp(ms):release(ms)
- Release only appears if it's a long note. Column ranges from 1 to 4. Timestamps are measured from the beginning of the audio file.

5. Supported parameters are:

- title: Level title
- author: Level author
- songName: Name of the song that plays
- songAuthor: Author of the song that plays
- difficulty: String describing the difficulty of the song
- diffColor: r,g,b containing a color for the difficulty (ex: 255,0,0 for red)

### Frequently asked questions about the levels

1. **Can I create a level?** : Yes, following the explanations above you can create a level subdirectory and drop the audio/image/level file. The game will load it normally.
2. **Can I place level files directly on the levels directory?** : No, the files need to be placed on a subdirectory that also contains the audio and the image.
3. **What happens if I dont include a background image?** : A black background will display instead.
4. **What formats are supported for level files?** : mp3 for audio, jpg/png for backgrounds and 50m (explained above) for levels.
5. **Can I omit some/all of the level parameters?** : Yes! Although the game will display some placeholder values if needed.
6. **Can I somehow use levels from other games such as stepmania or osu!mania?** : Check the section below for some details on that.
7. **Can I create multiple levels with the same song/background?** : Yes! Either by creating different sub-directories or by having multiple .50m files on the same one.
8. **What happens if I have multiple .mp3/.jpg/.png in one level sub-directory?** : Dont do that! If you need different songs, create different directories. Otherwise an undefined file will be picked.

### Converting levels from osu!mania

Osu!Mania levels have their own format, so my game can't load them. However, you can use the OsuTo50Converter provided in the repository. In order to do so, grab the osu!mania level file (.osu file), place
it on the OsuTo50Converter folder, and run the python script (converter.py) passing the .osu file name and a destination file name as parameters. For example: python converter.py source.osu dest.50m. This
will generate the level in 50!mania format, however some of the parameters, specially diffColor, cant be converted and have to be inputed manually if wanted.
