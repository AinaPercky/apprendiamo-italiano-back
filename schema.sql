-- schema.sql
-- Schéma PostgreSQL pour le module de conjugaison italien

-- Base de données: italian_verbs

BEGIN;

-- Table des verbes
CREATE TABLE IF NOT EXISTS verbs (
    id SERIAL PRIMARY KEY,
    infinitive VARCHAR(100) UNIQUE NOT NULL,
    verb_class VARCHAR(10) NOT NULL CHECK (verb_class IN ('are','ere','ire','unknown')),
    auxiliary VARCHAR(10) NOT NULL CHECK (auxiliary IN ('avere','essere','both')),
    is_irregular BOOLEAN DEFAULT FALSE,
    is_pronominal BOOLEAN DEFAULT FALSE,
    frequency_rank INTEGER,
    notes TEXT
);

-- Table des temps
CREATE TABLE IF NOT EXISTS tenses (
    id SERIAL PRIMARY KEY,
    name VARCHAR(80) UNIQUE NOT NULL,
    mood VARCHAR(30) NOT NULL,
    tense_type VARCHAR(10) NOT NULL CHECK (tense_type IN ('simple','compound','invariable')),
    label_fr VARCHAR(120),
    sort_order INTEGER NOT NULL
);

-- Table des conjugaisons
CREATE TABLE IF NOT EXISTS conjugations (
    id SERIAL PRIMARY KEY,
    verb_id INTEGER NOT NULL REFERENCES verbs(id) ON DELETE CASCADE,
    tense_id INTEGER NOT NULL REFERENCES tenses(id) ON DELETE CASCADE,
    person VARCHAR(10) NOT NULL,
    form VARCHAR(300) NOT NULL,
    UNIQUE (verb_id, tense_id, person)
);

-- Indexes recommandés
CREATE INDEX IF NOT EXISTS idx_verbs_infinitive ON verbs (infinitive);
CREATE INDEX IF NOT EXISTS idx_verbs_class ON verbs (verb_class);
CREATE INDEX IF NOT EXISTS idx_verbs_freq ON verbs (frequency_rank);
CREATE INDEX IF NOT EXISTS idx_conj_verb_id ON conjugations (verb_id);
CREATE INDEX IF NOT EXISTS idx_conj_tense_id ON conjugations (tense_id);
CREATE INDEX IF NOT EXISTS idx_conj_lower_form ON conjugations (lower(form));

-- Insérer la liste des 21 temps dans l'ordre demandé
TRUNCATE TABLE tenses RESTART IDENTITY CASCADE;

INSERT INTO tenses (name, mood, tense_type, label_fr, sort_order) VALUES
('Indicativo Presente', 'indicativo', 'simple', 'Présent de l''indicatif', 1),
('Indicativo Imperfetto', 'indicativo', 'simple', 'Imparfait de l''indicatif', 2),
('Indicativo Passato Remoto', 'indicativo', 'simple', 'Passé simple', 3),
('Indicativo Futuro Semplice', 'indicativo', 'simple', 'Futur simple', 4),
('Indicativo Passato Prossimo', 'indicativo', 'compound', 'Passé composé', 5),
('Indicativo Trapassato Prossimo', 'indicativo', 'compound', 'Plus-que-parfait', 6),
('Indicativo Trapassato Remoto', 'indicativo', 'compound', 'Passé antérieur', 7),
('Indicativo Futuro Anteriore', 'indicativo', 'compound', 'Futur antérieur', 8),
('Congiuntivo Presente', 'congiuntivo', 'simple', 'Subjonctif présent', 9),
('Congiuntivo Imperfetto', 'congiuntivo', 'simple', 'Subjonctif imparfait', 10),
('Congiuntivo Passato', 'congiuntivo', 'compound', 'Subjonctif passé', 11),
('Congiuntivo Trapassato', 'congiuntivo', 'compound', 'Subjonctif plus-que-parfait', 12),
('Condizionale Presente', 'condizionale', 'simple', 'Conditionnel présent', 13),
('Condizionale Passato', 'condizionale', 'compound', 'Conditionnel passé', 14),
('Imperativo Presente', 'imperativo', 'simple', 'Impératif présent', 15),
('Infinito Presente', 'infinito', 'invariable', 'Infinitif présent', 16),
('Infinito Passato', 'infinito', 'compound', 'Infinitif passé', 17),
('Participio Presente', 'participio', 'invariable', 'Participe présent', 18),
('Participio Passato', 'participio', 'invariable', 'Participe passé', 19),
('Gerundio Presente', 'gerundio', 'invariable', 'Gérondif présent', 20),
('Gerundio Passato', 'gerundio', 'compound', 'Gérondif passé', 21)
ON CONFLICT (name) DO NOTHING;

COMMIT;
