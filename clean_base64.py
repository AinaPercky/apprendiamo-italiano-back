import re

INPUT = "backup_local_plain.sql"
OUTPUT = "backup_clean.sql"

BASE64_PATTERN = re.compile(r'data:[a-zA-Z0-9/+.\-]+;base64,[A-Za-z0-9+/=\r\n]+')
NULL_REPLACEMENT = r'\N'

count = 0
lines_processed = 0
in_copy_block = False

print("Nettoyage de " + INPUT + "...")

with open(INPUT, 'r', encoding='utf-8', errors='replace') as fin, \
     open(OUTPUT, 'w', encoding='utf-8') as fout:
    for line in fin:
        lines_processed += 1
        if lines_processed % 5000 == 0:
            print("  " + str(lines_processed) + " lignes, " + str(count) + " remplacements...")

        if line.startswith('COPY '):
            in_copy_block = True
        elif line.strip() == '\\.':
            in_copy_block = False

        if in_copy_block and 'base64,' in line:
            new_line, n = BASE64_PATTERN.subn(lambda m: r'\N', line)
            count += n
            fout.write(new_line)
        else:
            fout.write(line)

print("Done!")
print("  Lignes: " + str(lines_processed))
print("  Images remplacees: " + str(count))
print("  Fichier: " + OUTPUT)
