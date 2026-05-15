import re
import os

INPUT = "backup_inserts_clean.sql"
OUTPUT = "backup_final.sql"

print("Lecture de " + INPUT + "...")

with open(INPUT, 'r', encoding='utf-8', errors='replace') as f:
    content = f.read()

# Séparer en 3 parties: schema, data, post-data (constraints/indexes)
# Les INSERTs commencent après les CREATE TABLE / ALTER TABLE initiaux
# On va identifier les sections de données

lines = content.split('\n')

schema_lines = []
data_lines = []
postdata_lines = []

# Sections dans le dump:
# 1. Header + CREATE TABLE + sequences + ALTER TABLE (defaults)
# 2. INSERT INTO ... (data)
# 3. setval + ALTER TABLE ADD CONSTRAINT + CREATE INDEX (post-data)

phase = 'schema'
in_insert_section = False

for line in lines:
    stripped = line.strip()
    
    # Ignorer la ligne \restrict
    if stripped.startswith('\\restrict') or stripped.startswith('\\unrestrict'):
        continue
    
    # Detecter début des données
    if stripped.startswith('INSERT INTO '):
        if phase == 'schema':
            phase = 'data'
    
    # Detecter début post-data (setval ou ALTER TABLE ADD CONSTRAINT apres les inserts)
    if phase == 'data':
        if stripped.startswith('SELECT pg_catalog.setval') or stripped.startswith('setval'):
            phase = 'postdata'
        # Les CREATE INDEX et ALTER TABLE ADD CONSTRAINT après les données
        if stripped.startswith('CREATE INDEX') or stripped.startswith('CREATE UNIQUE INDEX'):
            if not any(stripped.startswith('INSERT') for stripped in data_lines[-5:] if stripped.strip()):
                phase = 'postdata'
    
    if phase == 'schema':
        schema_lines.append(line)
    elif phase == 'data':
        data_lines.append(line)
    else:
        postdata_lines.append(line)

print("Schema: " + str(len(schema_lines)) + " lignes")
print("Data: " + str(len(data_lines)) + " lignes")
print("Post-data: " + str(len(postdata_lines)) + " lignes")

# Réorganiser les INSERTs dans le bon ordre (tables parents avant enfants)
# Ordre correct: users -> decks -> cards -> deck_cards -> puis le reste
TABLE_ORDER = [
    'alembic_version',
    'audio_items',
    'definition_cache',
    'users',
    'decks',
    'cards',
    'deck_cards',
    'card_performance',
    'quiz_sessions',
    'user_audio',
    'user_decks',
    'user_scores',
]

# Grouper les inserts par table
table_inserts = {t: [] for t in TABLE_ORDER}
other_inserts = []
current_comment = []
current_table = None

for line in data_lines:
    stripped = line.strip()
    
    if stripped.startswith('-- Data for Name:'):
        current_comment = [line]
        # Extraire nom de table
        m = re.search(r'Data for Name: (\w+)', stripped)
        if m:
            current_table = m.group(1)
        else:
            current_table = None
    elif stripped.startswith('INSERT INTO public.') or stripped == '':
        if current_table and current_table in table_inserts:
            if current_comment:
                table_inserts[current_table].extend(current_comment)
                current_comment = []
            table_inserts[current_table].append(line)
        else:
            if current_comment:
                other_inserts.extend(current_comment)
                current_comment = []
            other_inserts.append(line)
    else:
        if current_comment:
            other_inserts.extend(current_comment)
            current_comment = []
        other_inserts.append(line)

# Reconstruire les lignes de données dans le bon ordre
reordered_data = []
for t in TABLE_ORDER:
    if table_inserts[t]:
        reordered_data.extend(table_inserts[t])
        reordered_data.append('')

reordered_data.extend(other_inserts)

print("Ecriture de " + OUTPUT + "...")

with open(OUTPUT, 'w', encoding='utf-8') as f:
    # Header: désactiver les FK constraints
    f.write("-- Import final avec FK désactivés\n")
    f.write("SET session_replication_role = replica;\n")
    f.write("SET client_min_messages = WARNING;\n\n")
    
    # Schema (sans la ligne \restrict)
    f.write('\n'.join(schema_lines))
    f.write('\n\n')
    
    # Data réordonnée
    f.write('\n'.join(reordered_data))
    f.write('\n\n')
    
    # Post-data
    f.write('\n'.join(postdata_lines))
    f.write('\n')
    
    # Réactiver les FK
    f.write("\nSET session_replication_role = DEFAULT;\n")

size_mb = os.path.getsize(OUTPUT) / 1024 / 1024
print("Done! " + OUTPUT + " = " + str(round(size_mb, 1)) + " Mo")
