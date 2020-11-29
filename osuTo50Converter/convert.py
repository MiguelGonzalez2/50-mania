''' Python script that allows to import osu!mania 4k song charts into 50!Mania, allowing
 the user to play already mapped songs without much effort.

 Author: Miguel Gonzalez (miguel.gonzalezg01@estudiante.uam.es)'''

import argparse

def convert(input_file,output_file):
    ''' Converts an osu file onto a 50!mania file'''
    hit_objects = False
    metadata = False
    notes = []
    params = {}
    #Read
    with open(input_file, "r", errors='replace') as f:
        for line in f.readlines():

            # Wait till the metadata section is reached
            if not metadata and "[Metadata]" in line:
                metadata = True
                continue
            elif metadata:
                if line == "":
                    metadata = False
                    continue

                #Parse params
                param = line.split(":")
                if param[0] == "Title":
                    params["title"] = param[1][:-1]
                    params["songName"] = param[1][:-1]
                elif param[0] == "Artist":
                    params["songAuthor"] = param[1][:-1]
                elif param[0] == "Creator":
                    params["author"] = param[1][:-1]
                elif param[0] == "Version":
                    params["difficulty"] = param[1][:-1]

            # Wait till the hit objects section is reached
            if not hit_objects and "[HitObjects]" in line:
                hit_objects = True
                metadata = False
                continue
            elif hit_objects:
                # Colons will also be separators
                pre_note = line.replace(":",",").split(",")
                
                #Note has its lower bit up
                if int(pre_note[3]) % 2 == 1:
                    # Column is parsed depending on x coord
                    notes.append((int(int(pre_note[0]) * 4 / 512 + 1), int(pre_note[2]), -1))

                #Long note has its 7th bit up
                elif (int(pre_note[3])//128) % 2 == 1:
                    notes.append((int(int(pre_note[0]) * 4 / 512 + 1), int(pre_note[2]), int(pre_note[5])))
    
    #Write
    with open(output_file, "w") as f:
        f.write("50!ManiaV1\n")
        for param in params:
            f.write(param + "=" + params[param] + ";")
        f.write("\n")
        for note in notes:
            f.write(str(note[0]) + ":" + str(note[1]))
            #Write long note
            if note[2] > 0:
                f.write(":" + str(note[2]))
            f.write("\n")


if __name__ == '__main__':
    parser = argparse.ArgumentParser()
    parser.add_argument('input', metavar='input_file', help = 'Name of the osu!mania file to convert.')
    parser.add_argument('output', metavar='output_file', help = 'Name of the resulting 50!mania file.')

    args = parser.parse_args()

    convert(args.input, args.output)