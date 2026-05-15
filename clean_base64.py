import re

INPUT = "backup_inserts.sql"
OUTPUT = "backup_inserts_clean.sql"

# Dans le format --inserts, les valeurs base64 sont entre quotes SQL: 'data:...;base64,...'
BASE64_PATTERN = re.compile(r"'data:[^']{0,50};base64,[^']*'")

count = 0
lines_processed = 0

print("Nettoyage de " + INPUT + "...")

with open(INPUT, 'r', encoding='utf-8', errors='replace') as fin, \
     open(OUTPUT, 'w', encoding='utf-8') as fout:
    for line in fin:
        lines_processed += 1
        if lines_processed % 10000 == 0:
            print("  " + str(lines_processed) + " lignes, " + str(count) + " remplacements...")

        if 'base64,' in line:
            new_line, n = BASE64_PATTERN.subn(lambda m: "NULL", line)
            count += n
            fout.write(new_line)
        else:
            fout.write(line)

print("Done!")
print("  Lignes: " + str(lines_processed))
print("  Images remplacees par NULL: " + str(count))
size_mb = 0
import os
size_mb = os.path.getsize(OUTPUT) / 1024 / 1024
print("  Fichier: " + OUTPUT + " (" + str(round(size_mb, 1)) + " Mo)")
