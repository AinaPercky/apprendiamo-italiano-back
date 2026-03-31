--
-- PostgreSQL database dump
--

\restrict TPaaHppuITgaSsnTgkAQGPvFsb1kcVhHA4KevFtG9LOskTXgaFhNycX4S5I66HK

-- Dumped from database version 17.6
-- Dumped by pg_dump version 17.6

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: alembic_version; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.alembic_version (
    version_num character varying(32) NOT NULL
);


--
-- Name: audio_items; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.audio_items (
    id integer NOT NULL,
    title text,
    text text,
    filename text,
    category text,
    language text DEFAULT 'it'::text,
    ipa text,
    user_pk integer
);


--
-- Name: audio_items_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.audio_items_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: audio_items_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.audio_items_id_seq OWNED BY public.audio_items.id;


--
-- Name: card_performance; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.card_performance (
    performance_pk integer NOT NULL,
    user_pk integer NOT NULL,
    card_pk integer NOT NULL,
    deck_pk integer NOT NULL,
    correct_count integer NOT NULL,
    incorrect_count integer NOT NULL,
    total_attempts integer NOT NULL,
    priority_score double precision NOT NULL,
    last_reviewed_at timestamp without time zone,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: card_performance_performance_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.card_performance_performance_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: card_performance_performance_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.card_performance_performance_pk_seq OWNED BY public.card_performance.performance_pk;


--
-- Name: cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.cards (
    card_pk integer NOT NULL,
    id_json text NOT NULL,
    deck_pk integer,
    front text NOT NULL,
    back text NOT NULL,
    pronunciation text,
    image text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    box integer DEFAULT 0,
    next_review timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    tags text[] DEFAULT ARRAY[]::text[],
    easiness double precision DEFAULT 2.5 NOT NULL,
    "interval" integer DEFAULT 0 NOT NULL,
    consecutive_correct integer DEFAULT 0 NOT NULL,
    last_reviewed_at timestamp with time zone,
    definition text,
    explanation_it text,
    translation_en text,
    translation_de text,
    translation_mg text,
    example text
);


--
-- Name: cards_card_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.cards_card_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: cards_card_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.cards_card_pk_seq OWNED BY public.cards.card_pk;


--
-- Name: deck_cards; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.deck_cards (
    deck_pk integer NOT NULL,
    card_pk integer NOT NULL
);


--
-- Name: decks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.decks (
    deck_pk integer NOT NULL,
    id_json text NOT NULL,
    name text NOT NULL,
    total_correct integer DEFAULT 0,
    total_attempts integer DEFAULT 0
);


--
-- Name: decks_deck_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.decks_deck_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: decks_deck_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.decks_deck_pk_seq OWNED BY public.decks.deck_pk;


--
-- Name: definition_cache; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.definition_cache (
    id integer NOT NULL,
    term character varying NOT NULL,
    definition text NOT NULL,
    source character varying NOT NULL,
    confidence double precision NOT NULL,
    fetched_at timestamp without time zone NOT NULL
);


--
-- Name: definition_cache_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.definition_cache_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: definition_cache_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.definition_cache_id_seq OWNED BY public.definition_cache.id;


--
-- Name: quiz_sessions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.quiz_sessions (
    session_pk integer NOT NULL,
    user_pk integer NOT NULL,
    deck_pk integer NOT NULL,
    card_count integer NOT NULL,
    quiz_type character varying NOT NULL,
    cycle_number integer NOT NULL,
    used_card_pks text NOT NULL,
    correct_count integer,
    total_questions integer,
    started_at timestamp without time zone NOT NULL,
    completed_at timestamp without time zone
);


--
-- Name: quiz_sessions_session_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.quiz_sessions_session_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: quiz_sessions_session_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.quiz_sessions_session_pk_seq OWNED BY public.quiz_sessions.session_pk;


--
-- Name: user_audio; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_audio (
    audio_pk integer NOT NULL,
    user_pk integer NOT NULL,
    card_pk integer,
    filename character varying NOT NULL,
    audio_url character varying NOT NULL,
    duration integer,
    quality_score integer,
    notes text,
    created_at timestamp without time zone NOT NULL
);


--
-- Name: user_audio_audio_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_audio_audio_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_audio_audio_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_audio_audio_pk_seq OWNED BY public.user_audio.audio_pk;


--
-- Name: user_decks; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_decks (
    user_deck_pk integer NOT NULL,
    user_pk integer NOT NULL,
    deck_pk integer NOT NULL,
    correct_count integer,
    attempt_count integer,
    cards_mastered integer,
    added_at timestamp without time zone NOT NULL,
    last_studied timestamp without time zone,
    mastered_cards integer DEFAULT 0 NOT NULL,
    learning_cards integer DEFAULT 0 NOT NULL,
    review_cards integer DEFAULT 0 NOT NULL,
    total_points integer DEFAULT 0 NOT NULL,
    total_attempts integer DEFAULT 0 NOT NULL,
    successful_attempts integer DEFAULT 0 NOT NULL,
    points_frappe integer DEFAULT 0 NOT NULL,
    points_association integer DEFAULT 0 NOT NULL,
    points_qcm integer DEFAULT 0 NOT NULL,
    points_classique integer DEFAULT 0 NOT NULL
);


--
-- Name: user_decks_user_deck_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_decks_user_deck_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_decks_user_deck_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_decks_user_deck_pk_seq OWNED BY public.user_decks.user_deck_pk;


--
-- Name: user_scores; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.user_scores (
    score_pk integer NOT NULL,
    user_pk integer NOT NULL,
    deck_pk integer,
    card_pk integer,
    score integer NOT NULL,
    is_correct boolean NOT NULL,
    time_spent integer,
    created_at timestamp without time zone NOT NULL,
    quiz_type character varying DEFAULT 'classique'::character varying
);


--
-- Name: user_scores_score_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.user_scores_score_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: user_scores_score_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.user_scores_score_pk_seq OWNED BY public.user_scores.score_pk;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    user_pk integer NOT NULL,
    email character varying NOT NULL,
    username character varying NOT NULL,
    hashed_password character varying,
    google_id character varying,
    google_email character varying,
    google_picture character varying,
    first_name character varying,
    last_name character varying,
    profile_picture character varying,
    bio text,
    is_active boolean,
    is_verified boolean,
    verification_token character varying,
    total_score integer,
    total_cards_learned integer,
    total_cards_reviewed integer,
    created_at timestamp without time zone NOT NULL,
    updated_at timestamp without time zone NOT NULL,
    last_login timestamp without time zone
);


--
-- Name: users_user_pk_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_user_pk_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_user_pk_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_user_pk_seq OWNED BY public.users.user_pk;


--
-- Name: audio_items id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audio_items ALTER COLUMN id SET DEFAULT nextval('public.audio_items_id_seq'::regclass);


--
-- Name: card_performance performance_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_performance ALTER COLUMN performance_pk SET DEFAULT nextval('public.card_performance_performance_pk_seq'::regclass);


--
-- Name: cards card_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards ALTER COLUMN card_pk SET DEFAULT nextval('public.cards_card_pk_seq'::regclass);


--
-- Name: decks deck_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks ALTER COLUMN deck_pk SET DEFAULT nextval('public.decks_deck_pk_seq'::regclass);


--
-- Name: definition_cache id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.definition_cache ALTER COLUMN id SET DEFAULT nextval('public.definition_cache_id_seq'::regclass);


--
-- Name: quiz_sessions session_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions ALTER COLUMN session_pk SET DEFAULT nextval('public.quiz_sessions_session_pk_seq'::regclass);


--
-- Name: user_audio audio_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_audio ALTER COLUMN audio_pk SET DEFAULT nextval('public.user_audio_audio_pk_seq'::regclass);


--
-- Name: user_decks user_deck_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_decks ALTER COLUMN user_deck_pk SET DEFAULT nextval('public.user_decks_user_deck_pk_seq'::regclass);


--
-- Name: user_scores score_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_scores ALTER COLUMN score_pk SET DEFAULT nextval('public.user_scores_score_pk_seq'::regclass);


--
-- Name: users user_pk; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN user_pk SET DEFAULT nextval('public.users_user_pk_seq'::regclass);


--
-- Data for Name: alembic_version; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.alembic_version (version_num) FROM stdin;
add_deck_cards
\.


--
-- Data for Name: audio_items; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.audio_items (id, title, text, filename, category, language, ipa, user_pk) FROM stdin;
3	Roberto Begnini	Oggi vi parlo di Roberto Benigni. Roberto Benigni è stato un attore, regista e sceneggiatore italiano molto famoso. Lui è nato il 27 ottobre 1952 in Toscana, vicino alla città di Arezzo. Ha passato la sua infanzia in campagna, con i suoi genitori e le sue tre sorelle. La sua famiglia è stata semplice e lavoratrice. Suo padre ha lavorato come contadino e falegname. Sua madre ha lavorato in una fabbrica di tessuti. Roberto ha vissuto un’infanzia tranquilla e molto serena.  Da ragazzo, Roberto ha studiato a Firenze. Durante questo periodo, lui ha lavorato anche come apprendista mago. Gli è piaciuto molto divertire le persone. Gli è piaciuto creare piccole scene e far ridere gli altri. Questo è stato il suo grande talento.  Quando ha avuto vent’anni, un regista di Roma lo ha visto durante uno spettacolo. Il regista lo ha invitato a entrare nella sua compagnia teatrale. Roberto ha accettato e ha iniziato a recitare a teatro. Ha fatto molti spettacoli. Ha imparato a parlare davanti al pubblico, a muoversi sul palco e a creare personaggi divertenti.  Dopo alcuni anni, Roberto è diventato famoso in televisione. Ha partecipato a un programma molto popolare che si è chiamato The Other Sunday. La carriera nel cinema è iniziata nel 1976 con il film Berlinguer ti voglio bene. Roberto ha scritto il film e ha recitato nel ruolo principale. Poi lui ha lavorato con registi famosi come Costa-Gavras, Marco Ferreri e Jim Jarmusch. Con Jarmusch, Roberto ha girato film importanti come Down by Law.  Nel 1983, Roberto ha diretto il suo primo film, Tu mi turbi. Durante questo film, lui ha incontrato Nicoletta Braschi. Nicoletta è diventata sua moglie e sua collaboratrice.  Il suo successo più grande è arrivato nel 1997 con La vita è bella. Roberto ha scritto, ha diretto e ha interpretato il film. Il film ha avuto un enorme successo nel mondo. Roberto ha ricevuto premi molto importanti, come l’Oscar per il Miglior Attore.  Negli anni seguenti, Roberto ha continuato a lavorare nel cinema. Ha fatto film come Pinocchio e La tigre e la neve. Ha collaborato anche con Woody Allen nel film To Rome with Love.  Oggi Roberto Benigni è stato considerato un artista creativo, simpatico e molto amato.	0cb95c218d1047c3af7492e590084042.mp3	mot	it	\N	\N
4	Pilots and rest	Many airports in India have problems. The company called Indigo cancels many flights. Passengers wait for a long time and pay a lot of money. All this happens because of new rules. These rules give pilots more rest. The rules make flying safe.  Indigo does not have enough pilots and workers. The company cannot follow the new rules. Flights are late or stop. Authorities give Indigo a short break from some rules.  Indigo flies most of the flights in India. Experts say that there should be smaller airlines, too. This stops one airline from making big problems. People can travel more safely.  Difficult words: cancel (to stop something), passenger (a person who travels on a plane, bus, or train), rest (time to stop work or activity to feel better).	206ab9f83320466f817c13db8a5a2ae6.mp3	texte	en	\N	\N
5	Senza tende a Milano	La città è bella perché hai le finestre di fronte. A Milano amano le tende, ma Giovanna è stata fortunata. Di fronte a lei, dall'altro lato della via e al suo stesso piano, è andata ad abitare una coppia nuova. Hanno circa quarant'anni, lei alta e bella , lui con la faccia di artista. Lavorano in casa, non fanno orari da ufficio, non hanno le tende, come Giovanna. Hanno cominciato notarsi perché di sera , con luci accese, vedi se il tuo vicino mangia o legge, chiacchera o lavora, fa la doccia o il bucato. Giovanna ha cominciato a sentirsi "voyeuse"... Un giorno la dirimpettaia al bar sotto casa ha detto :"Ma tu abiti di fronte al sette di Via Mazzini?" Oh, ha pensato Giovanna, se anche lei mi ha riconosciuto vuol dire che mi ha visto girare in mutande. E all'improvviso si è sentita bene e ha sorriso come la sua dirimpettaia, contenta di aver trovato, in una città che ama le tende, una delle poche abitanti che le detesta.	761f8a6e92754cbdb91ba10905a0418a.mp3	texte	it	\N	\N
6	A1 Principiante	Riesce a comprendere e utilizzare espressioni familiari di uso quotidiano e formule molto comuni per soddisfare bisogni di tipo concreto. Sa presentare se stesso/a e altri ed è in grado di porre domande su dati personali e rispondere a domande analoghe (il luogo dove abita, le persone che conosce, le cose che possiede). È in grado di interagire in modo semplice purché l'interlocutore parli lentamente e chiaramente e sia disposto a collaborare.	bccc185c92454e679d28edb7dc35a086.mp3	texte	it	\N	\N
7	A2  Elementare	Riesce a comprendere frasi isolate ed espressioni di uso frequente relative ad ambiti di immediata rilevanza (ad es.: informazioni di base sulla persona e sulla famiglia, acquisti, geografia locale, lavoro). Riesce a comunicare in attività semplici e di routine che richiedono solo uno scambio di informazioni semplice e diretto su argomenti familiari e abituali. Riesce a descrivere in termini semplici aspetti del proprio vissuto e del proprio ambiente ed elementi che si riferiscono a bisogni immediati.	d3a5b3c72f9a43b1a223d5a61ab767a7.mp3	mot	it	\N	\N
8	B1 Intermedio	È in grado di comprendere i punti essenziali di messaggi chiari in lingua standard su argomenti familiari che affronta normalmente al lavoro, a scuola, nel tempo libero, ecc. Se la cava in molte situazioni che si possono presentare viaggiando in una regione dove si parla la lingua in questione. Sa produrre testi semplici e coerenti su argomenti che gli siano familiari o siano di suo interesse. È in grado di descrivere esperienze e avvenimenti, sogni, speranze, ambizioni, di esporre brevemente ragioni e dare spiegazioni su opinioni e progetti.	e94a1cbf98ab4109b8652a608c0c68e5.mp3	mot	it	\N	\N
9	B2 Super intermedio	È in grado di comprendere le idee fondamentali di testi complessi su argomenti sia concreti sia astratti, comprese le discussioni tecniche nel proprio settore di specializzazione. È in grado di interagire con relativa scioltezza e spontaneità, tanto che l'interazione con un parlante nativo si sviluppa senza eccessiva fatica e tensione. Sa produrre testi chiari e articolati su un'ampia gamma di argomenti e esprimere un'opinione su un argomento d'attualità, esponendo i pro e i contro delle diverse opzioni.	e317652f6bfd40ca97945466d8b56995.mp3	mot	it	\N	\N
10	C1 Anvanzato	È in grado di comprendere un'ampia gamma di testi complessi e piuttosto lunghi, cogliendo anche il significato implicito. Si esprime in modo scorrevole e spontaneo, senza un eccessivo sforzo per cercare le parole. Usa la lingua in modo flessibile ed efficace per scopi sociali, accademici e professionali. Sa produrre testi chiari, ben strutturati e articolati su argomenti complessi, mostrando di saper controllare le strutture discorsive, i connettivi e i meccanismi di coesione.	00532aeca2764befbbfbc5f6dbe9b3e6.mp3	mot	it	\N	\N
11	C2 Avanzato	È in grado di comprendere senza sforzo praticamente tutto ciò che ascolta o legge. Sa riassumere informazioni tratte da diverse fonti, orali e scritte, ristrutturando in modo coerente le argomentazioni e le parti informative. Si esprime completamente, in modo naturale e con grande scioltezza, riconoscendo anche sottili sfumature di significato anche in situazioni piuttosto complesse.	bfe95b506b71401d8966f8191664d4c2.mp3	mot	it	\N	\N
12	Ferrari	La Ferrari è una famosa marca di automobili sportive italiana. È nata nel 1947 grazie a Enzo Ferrari, un uomo appassionato di motori e di competizioni automobilistiche. Fin dall’inizio, il suo obiettivo era creare auto molto veloci, eleganti e di alta qualità.  L’azienda ha sede a Maranello, una città nel nord dell’Italia, che è diventata un luogo simbolico per gli amanti delle auto sportive. A Maranello si trovano le fabbriche Ferrari, dove le automobili vengono costruite con grande attenzione ai dettagli, al design e alla tecnologia. Molti lavoratori specializzati partecipano alla produzione di ogni vettura.  Oggi, la Ferrari è conosciuta in tutto il mondo per le sue auto veloci ed eleganti. Le auto Ferrari sono molto potenti e hanno un design moderno. Molti modelli possono superare i 300 chilometri all’ora. Il motore è una parte molto importante della Ferrari, perché produce un suono forte e facilmente riconoscibile. Per questo motivo, molte persone amano ascoltare il rumore di una Ferrari quando passa per strada.  La Ferrari è anche molto famosa nelle competizioni automobilistiche, soprattutto in Formula 1. Il team Ferrari ha vinto molte gare e campionati nel corso degli anni. Questo successo nello sport aiuta l’azienda a migliorare continuamente la tecnologia delle sue auto.  In generale, possedere una Ferrari è un sogno per molte persone. Non è solo un’auto, ma un vero simbolo di lusso, passione e tradizione italiana, conosciuto e apprezzato in tutto il mondo.	8077a71a9b674bbfab331908bf3e191e.mp3	texte	it	\N	\N
14	Rapeto	Nelle altre terre del Madagascar viveva un gigante che si chiamava Rapeto. Era così alto che la sua testa toccava quasi il cielo. Sulla sua fronte bruciava una fiamma blu che illuminava le notti scure. Le sue braccia erano lunghe come fiumi, le sue mani grandi come colline. Quando camminava, la terra tremava. Con una sola mano strappava alberi enormi e, con un solo gesto, spostava rocce gigantesche. Rapeto attraversava l’isola: ogni volta che appoggiava il piede al suolo lasciava un’impronta profonda. Con il tempo la pioggia riempiva quelle impronte e così nascevano laghi e valli sugli altopiani. Le montagne sembravano piccole accanto a lui e, da lontano, la sua figura pareva una montagna viva che si muoveva. Ma Rapeto si vantava. Si sentiva più forte del vento, più potente delle tempeste. Un giorno ha deciso di sfidare gli dei: ha gridato verso il cielo e ha detto che nessuno era più grande di lui. Gli dei se la sono presa con lui. Il cielo si è oscurato, il vento ha soffiato con violenza e la terra ha tremato più forte di prima. Una forza invisibile ha colpito il gigante: il suo corpo si è rotto in tanti pezzi che sono caduti su tutta l’isola. Ogni frammento è diventato una collina, una roccia, una montagna. Oggi, vicino a Antananarivo, alcune rocce portano ancora il suo nome, ad esempio Ambohidrapeto. La gente parla ancora del piede di Rapeto e del suo dorso pietrificato. Così è finito il gigante che aveva voluto toccare il cielo. Ma la leggenda diceva che il suo spirito era rimasto nella terra.	028228ed1d0049068298764bb887e47c.mp3	texte	it	\N	\N
16	Corsa contro il tempo in ufficio	Sì è quasi pronto, devo solo aggiungere i grafici sulle vendite. Se vuoi, te lo mando via email tra dieci minuti, così puoi dargli un’occhiata.  Stefano dice che ha avuto un problema con il computer, ma mi ha assicurato che ce le spedirà entro mezzogiorno. Appena le ricevo, te le giro immediatamente.  Esatto, me ne ha parlato perché vuole che io la coordini. Mi ha chiesto se potevo occuparmene e io gliel’ho confermato. È un progetto impegnativo, ma molto interessante.  Oh, scusami Giulia! Hai ragione te lo avrei dovuto restituire lunedì. Ce l’ho qui nello zaino, te lo riporto subito sulla scrivania.  L’ha presa Lucia prima, aveva bisogno di copiare alcuni file. Se vuoi vado a chiederle di ridarcela	9eed886d19574850a6983500263e6a5f.mp3	texte	it	\N	\N
18	Corsa ufficio 1	Sì è quasi pronto, devo solo aggiungere i grafici sulle vendite. Se vuoi, te lo mando via email tra dieci minuti, così puoi dargli un’occhiata.	11394efd1e364ed0bb8df5e0a45b1d12.mp3	texte	it	\N	\N
19	Corsa ufficio 2	Stefano dice che ha avuto un problema con il computer, ma mi ha assicurato che ce le spedirà entro mezzogiorno. Appena le ricevo, te le giro immediatamente	3c96a574dc7c41cab300ebc8b2b0f48d.mp3	texte	it	\N	\N
20	Corsa ufficio 3	Esatto, me ne ha parlato perché vuole che io la coordini. Mi ha chiesto se potevo occuparmene e io gliel’ho confermato. È un progetto impegnativo, ma molto interessante	7d13eebdafe449b0ac79e492bea6e2d6.mp3	texte	it	\N	\N
21	Corsa ufficio 4	Oh, scusami Giulia! Hai ragione te lo avrei dovuto restituire lunedì. Ce l’ho qui nello zaino, te lo riporto subito sulla scrivania.	4ecafc0335244b92b2278484628df982.mp3	texte	it	\N	\N
22	Corsa ufficio 5	L’ha presa Lucia prima, aveva bisogno di copiare alcuni file. Se vuoi vado a chiederle di ridarcela	7c8133e44a5a43159a7457758e831f49.mp3	texte	it	\N	\N
\.


--
-- Data for Name: card_performance; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.card_performance (performance_pk, user_pk, card_pk, deck_pk, correct_count, incorrect_count, total_attempts, priority_score, last_reviewed_at, created_at) FROM stdin;
462	13	266	10	3	2	5	1	2025-12-05 14:24:46.725792	2025-12-05 14:24:45.627107
464	13	169	10	2	2	4	2	2025-12-05 14:24:46.891781	2025-12-05 14:24:45.639739
413	13	254	10	2	1	3	0	2025-12-05 14:24:46.850263	2025-12-05 14:24:45.205207
486	13	187	10	2	0	2	-2	2025-12-05 14:24:46.826994	2025-12-05 14:24:45.82627
438	13	225	10	3	0	3	-3	2025-12-05 14:24:46.779428	2025-12-05 14:24:45.423352
468	13	221	10	1	2	3	3	2025-12-05 14:24:46.690868	2025-12-05 14:24:45.664556
6	11	200	10	1	0	1	-1	2025-12-04 14:17:03.372022	2025-12-04 14:17:03.356251
431	13	181	10	1	1	2	1	2025-12-05 14:24:46.627833	2025-12-05 14:24:45.361957
432	13	194	10	2	0	2	-2	2025-12-05 14:24:47.013425	2025-12-05 14:24:45.370845
428	13	217	10	2	0	2	-2	2025-12-05 14:24:46.958396	2025-12-05 14:24:45.338016
466	13	260	10	2	0	2	-2	2025-12-05 14:24:46.666912	2025-12-05 14:24:45.652464
477	13	173	10	2	0	2	-2	2025-12-05 14:24:46.885534	2025-12-05 14:24:45.745134
455	13	226	10	3	1	4	-1	2025-12-05 14:24:46.927629	2025-12-05 14:24:45.55822
485	13	183	10	3	2	5	1	2025-12-05 14:24:46.774986	2025-12-05 14:24:45.816396
473	13	186	10	3	1	4	-1	2025-12-05 14:24:46.924551	2025-12-05 14:24:45.691827
460	13	231	10	1	2	3	3	2025-12-05 14:24:46.843377	2025-12-05 14:24:45.614958
407	13	234	10	3	1	4	-1	2025-12-05 14:24:47.107992	2025-12-05 14:24:45.160161
456	13	253	10	3	1	4	-1	2025-12-05 14:24:46.930876	2025-12-05 14:24:45.585823
458	13	258	10	3	1	4	-1	2025-12-05 14:24:46.901683	2025-12-05 14:24:45.600143
469	13	262	10	4	0	4	-4	2025-12-05 14:24:46.894814	2025-12-05 14:24:45.670606
426	13	197	10	1	0	1	-1	2025-12-05 14:24:45.327459	2025-12-05 14:24:45.325038
445	13	172	10	3	0	3	-3	2025-12-05 14:24:46.977801	2025-12-05 14:24:45.483073
449	13	252	10	2	1	3	0	2025-12-05 14:24:46.963179	2025-12-05 14:24:45.516377
434	13	251	10	2	1	3	0	2025-12-05 14:24:46.703835	2025-12-05 14:24:45.387689
427	13	170	10	2	1	3	0	2025-12-05 14:24:47.056203	2025-12-05 14:24:45.332066
465	13	249	10	2	0	2	-2	2025-12-05 14:24:46.805425	2025-12-05 14:24:45.646465
478	13	174	10	3	1	4	-1	2025-12-05 14:24:47.019243	2025-12-05 14:24:45.754127
476	13	171	10	3	0	3	-3	2025-12-05 14:24:47.036399	2025-12-05 14:24:45.736749
446	13	246	10	3	0	3	-3	2025-12-05 14:24:46.846925	2025-12-05 14:24:45.49101
463	13	223	10	2	1	3	0	2025-12-05 14:24:46.720253	2025-12-05 14:24:45.633209
483	13	180	10	3	0	3	-3	2025-12-05 14:24:47.060779	2025-12-05 14:24:45.798088
470	13	216	10	3	1	4	-1	2025-12-05 14:24:47.030525	2025-12-05 14:24:45.676009
415	13	236	10	2	0	2	-2	2025-12-05 14:24:46.249533	2025-12-05 14:24:45.250199
454	13	257	10	2	2	4	2	2025-12-05 14:24:46.917472	2025-12-05 14:24:45.551354
410	13	167	10	3	0	3	-3	2025-12-05 14:24:46.860227	2025-12-05 14:24:45.185391
457	13	204	10	3	0	3	-3	2025-12-05 14:24:46.752376	2025-12-05 14:24:45.592167
439	13	178	10	3	1	4	-1	2025-12-05 14:24:46.840361	2025-12-05 14:24:45.432448
421	13	193	10	2	1	3	0	2025-12-05 14:24:46.987127	2025-12-05 14:24:45.289871
440	13	230	10	2	0	2	-2	2025-12-05 14:24:46.549624	2025-12-05 14:24:45.44202
435	13	198	10	3	0	3	-3	2025-12-05 14:24:46.98234	2025-12-05 14:24:45.396948
488	13	190	10	3	1	4	-1	2025-12-05 14:24:46.972817	2025-12-05 14:24:45.846357
448	13	207	10	3	2	5	1	2025-12-05 14:24:47.128595	2025-12-05 14:24:45.508489
419	13	218	10	2	1	3	0	2025-12-05 14:24:46.681778	2025-12-05 14:24:45.274926
461	13	202	10	2	1	3	0	2025-12-05 14:24:46.786829	2025-12-05 14:24:45.621281
482	13	179	10	2	1	3	0	2025-12-05 14:24:46.256292	2025-12-05 14:24:45.789707
430	13	263	10	2	0	2	-2	2025-12-05 14:24:47.051808	2025-12-05 14:24:45.352222
450	13	240	10	3	1	4	-1	2025-12-05 14:24:46.837056	2025-12-05 14:24:45.523242
475	13	168	10	5	0	5	-5	2025-12-05 14:24:46.864009	2025-12-05 14:24:45.729502
429	13	210	10	4	1	5	-2	2025-12-05 14:24:46.714419	2025-12-05 14:24:45.343887
479	13	175	10	3	1	4	-1	2025-12-05 14:24:47.096721	2025-12-05 14:24:45.762939
423	13	200	10	3	0	3	-3	2025-12-05 14:24:46.677017	2025-12-05 14:24:45.304677
420	13	188	10	1	2	3	3	2025-12-05 14:24:47.042229	2025-12-05 14:24:45.281894
425	13	250	10	3	0	3	-3	2025-12-05 14:24:46.910988	2025-12-05 14:24:45.318034
414	13	245	10	3	0	3	-3	2025-12-05 14:24:46.857041	2025-12-05 14:24:45.2431
409	13	256	10	4	0	4	-4	2025-12-05 14:24:47.133383	2025-12-05 14:24:45.179952
418	13	196	10	2	2	4	2	2025-12-05 14:24:46.878371	2025-12-05 14:24:45.2689
481	13	177	10	3	1	4	-1	2025-12-05 14:24:47.104495	2025-12-05 14:24:45.780709
487	13	189	10	2	1	3	0	2025-12-05 14:24:46.738393	2025-12-05 14:24:45.83684
412	13	206	10	4	0	4	-4	2025-12-05 14:24:46.814973	2025-12-05 14:24:45.198383
443	13	237	10	3	0	3	-3	2025-12-05 14:24:46.671934	2025-12-05 14:24:45.469369
424	13	203	10	3	1	4	-1	2025-12-05 14:24:46.797594	2025-12-05 14:24:45.31013
416	13	244	10	3	0	3	-3	2025-12-05 14:24:46.801363	2025-12-05 14:24:45.256634
459	13	205	10	1	1	2	1	2025-12-05 14:24:46.90466	2025-12-05 14:24:45.606485
441	13	185	10	1	2	3	3	2025-12-05 14:24:46.820746	2025-12-05 14:24:45.451838
422	13	243	10	3	0	3	-3	2025-12-05 14:24:46.817992	2025-12-05 14:24:45.297293
453	13	195	10	2	0	2	-2	2025-12-05 14:24:46.83365	2025-12-05 14:24:45.544667
474	13	222	10	3	1	4	-1	2025-12-05 14:24:46.790101	2025-12-05 14:24:45.697653
444	13	199	10	2	1	3	0	2025-12-05 14:24:47.065106	2025-12-05 14:24:45.475979
436	13	235	10	2	0	2	-2	2025-12-05 14:24:46.207373	2025-12-05 14:24:45.405698
417	13	209	10	3	0	3	-3	2025-12-05 14:24:46.9346	2025-12-05 14:24:45.26261
411	13	224	10	3	0	3	-3	2025-12-05 14:24:46.888726	2025-12-05 14:24:45.192709
442	13	214	10	2	1	3	0	2025-12-05 14:24:46.686506	2025-12-05 14:24:45.461846
433	13	229	10	3	0	3	-3	2025-12-05 14:24:46.868815	2025-12-05 14:24:45.377322
452	13	184	10	3	0	3	-3	2025-12-05 14:24:46.991814	2025-12-05 14:24:45.538061
437	13	219	10	2	0	2	-2	2025-12-05 14:24:47.024852	2025-12-05 14:24:45.414497
484	13	182	10	2	0	2	-2	2025-12-05 14:24:46.759433	2025-12-05 14:24:45.806562
471	13	211	10	4	0	4	-4	2025-12-05 14:24:47.002591	2025-12-05 14:24:45.681926
408	13	213	10	2	1	3	0	2025-12-05 14:24:46.764888	2025-12-05 14:24:45.171472
447	13	228	10	2	1	3	0	2025-12-05 14:24:46.783337	2025-12-05 14:24:45.500167
472	13	191	10	1	1	2	1	2025-12-05 14:24:46.83025	2025-12-05 14:24:45.686745
451	13	212	10	3	0	3	-3	2025-12-05 14:24:46.948757	2025-12-05 14:24:45.530484
467	13	238	10	2	0	2	-2	2025-12-05 14:24:46.794055	2025-12-05 14:24:45.658585
480	13	176	10	3	2	5	1	2025-12-05 14:24:46.997036	2025-12-05 14:24:45.77134
134	12	184	10	0	1	1	2	2025-12-05 14:08:37.183529	2025-12-05 14:08:37.181338
109	12	212	10	2	1	3	0	2025-12-05 14:08:38.129728	2025-12-05 14:08:36.981317
138	12	197	10	2	0	2	-2	2025-12-05 14:08:37.949434	2025-12-05 14:08:37.206548
172	12	227	10	0	2	2	4	2025-12-05 14:08:37.987773	2025-12-05 14:08:37.480714
119	12	231	10	1	1	2	1	2025-12-05 14:08:37.962489	2025-12-05 14:08:37.045125
139	12	211	10	1	0	1	-1	2025-12-05 14:08:37.218758	2025-12-05 14:08:37.214903
140	12	261	10	1	0	1	-1	2025-12-05 14:08:37.226654	2025-12-05 14:08:37.223955
177	12	182	10	2	0	2	-2	2025-12-05 14:08:37.998771	2025-12-05 14:08:37.517441
142	12	262	10	1	0	1	-1	2025-12-05 14:08:37.242576	2025-12-05 14:08:37.239934
107	12	210	10	1	0	1	-1	2025-12-05 14:08:36.969004	2025-12-05 14:08:36.962406
143	12	208	10	2	0	2	-2	2025-12-05 14:08:38.102725	2025-12-05 14:08:37.246791
182	12	222	10	1	1	2	1	2025-12-05 14:08:37.784106	2025-12-05 14:08:37.547459
110	12	255	10	1	0	1	-1	2025-12-05 14:08:36.990784	2025-12-05 14:08:36.988454
111	12	215	10	1	0	1	-1	2025-12-05 14:08:36.996753	2025-12-05 14:08:36.993909
128	12	176	10	1	1	2	1	2025-12-05 14:08:38.019405	2025-12-05 14:08:37.143437
187	12	172	10	2	0	2	-2	2025-12-05 14:08:37.859688	2025-12-05 14:08:37.579871
137	12	167	10	1	1	2	1	2025-12-05 14:08:37.980075	2025-12-05 14:08:37.199204
115	12	234	10	1	0	1	-1	2025-12-05 14:08:37.024778	2025-12-05 14:08:37.022374
116	12	218	10	1	0	1	-1	2025-12-05 14:08:37.030181	2025-12-05 14:08:37.028215
117	12	236	10	0	1	1	2	2025-12-05 14:08:37.035085	2025-12-05 14:08:37.033107
118	12	169	10	0	1	1	2	2025-12-05 14:08:37.041171	2025-12-05 14:08:37.03845
114	12	263	10	2	0	2	-2	2025-12-05 14:08:37.974062	2025-12-05 14:08:37.015602
184	12	249	10	1	1	2	1	2025-12-05 14:08:37.793765	2025-12-05 14:08:37.561467
179	12	193	10	1	1	2	1	2025-12-05 14:08:37.844464	2025-12-05 14:08:37.530033
122	12	180	10	1	0	1	-1	2025-12-05 14:08:37.068985	2025-12-05 14:08:37.066389
148	12	219	10	1	1	2	1	2025-12-05 14:08:38.069979	2025-12-05 14:08:37.276119
130	12	168	10	2	0	2	-2	2025-12-05 14:08:37.93966	2025-12-05 14:08:37.156074
196	12	209	10	2	0	2	-2	2025-12-05 14:08:38.04033	2025-12-05 14:08:37.630022
121	12	178	10	1	1	2	1	2025-12-05 14:08:37.840533	2025-12-05 14:08:37.05997
127	12	179	10	1	0	1	-1	2025-12-05 14:08:37.140376	2025-12-05 14:08:37.138465
161	12	235	10	1	1	2	1	2025-12-05 14:08:38.025865	2025-12-05 14:08:37.387697
129	12	230	10	1	0	1	-1	2025-12-05 14:08:37.152152	2025-12-05 14:08:37.149743
153	12	170	10	3	0	3	-3	2025-12-05 14:08:37.944565	2025-12-05 14:08:37.314792
131	12	243	10	0	1	1	2	2025-12-05 14:08:37.164674	2025-12-05 14:08:37.162684
132	12	245	10	1	0	1	-1	2025-12-05 14:08:37.170359	2025-12-05 14:08:37.167955
133	12	204	10	1	0	1	-1	2025-12-05 14:08:37.177257	2025-12-05 14:08:37.174282
157	12	244	10	0	2	2	4	2025-12-05 14:08:38.110212	2025-12-05 14:08:37.362487
135	12	246	10	1	1	2	1	2025-12-05 14:08:38.123241	2025-12-05 14:08:37.187009
145	12	213	10	0	1	1	2	2025-12-05 14:08:37.260949	2025-12-05 14:08:37.259011
146	12	238	10	1	0	1	-1	2025-12-05 14:08:37.265805	2025-12-05 14:08:37.263942
113	12	252	10	1	1	2	1	2025-12-05 14:08:37.855218	2025-12-05 14:08:37.008238
166	12	257	10	2	0	2	-2	2025-12-05 14:08:38.075976	2025-12-05 14:08:37.428388
149	12	237	10	1	0	1	-1	2025-12-05 14:08:37.286078	2025-12-05 14:08:37.282998
150	12	264	10	1	0	1	-1	2025-12-05 14:08:37.292115	2025-12-05 14:08:37.289603
151	12	185	10	0	1	1	2	2025-12-05 14:08:37.298428	2025-12-05 14:08:37.295774
108	12	187	10	2	0	2	-2	2025-12-05 14:08:38.096447	2025-12-05 14:08:36.974291
124	12	241	10	2	0	2	-2	2025-12-05 14:08:37.890147	2025-12-05 14:08:37.080423
112	12	191	10	2	0	2	-2	2025-12-05 14:08:38.013854	2025-12-05 14:08:37.000204
155	12	242	10	1	0	1	-1	2025-12-05 14:08:37.332868	2025-12-05 14:08:37.330683
156	12	206	10	1	0	1	-1	2025-12-05 14:08:37.338378	2025-12-05 14:08:37.336289
144	12	198	10	1	1	2	1	2025-12-05 14:08:38.116721	2025-12-05 14:08:37.253777
152	12	260	10	1	1	2	1	2025-12-05 14:08:37.869524	2025-12-05 14:08:37.302187
159	12	247	10	1	0	1	-1	2025-12-05 14:08:37.377692	2025-12-05 14:08:37.37504
160	12	190	10	0	1	1	2	2025-12-05 14:08:37.383761	2025-12-05 14:08:37.381807
125	12	181	10	2	0	2	-2	2025-12-05 14:08:38.032661	2025-12-05 14:08:37.089605
162	12	200	10	1	0	1	-1	2025-12-05 14:08:37.396616	2025-12-05 14:08:37.394028
163	12	250	10	0	1	1	2	2025-12-05 14:08:37.404783	2025-12-05 14:08:37.401418
181	12	256	10	1	1	2	1	2025-12-05 14:08:37.80926	2025-12-05 14:08:37.542546
165	12	199	10	1	0	1	-1	2025-12-05 14:08:37.423163	2025-12-05 14:08:37.419871
126	12	226	10	3	0	3	-3	2025-12-05 14:08:38.081594	2025-12-05 14:08:37.096124
167	12	224	10	1	0	1	-1	2025-12-05 14:08:37.439822	2025-12-05 14:08:37.4372
171	12	229	10	2	0	2	-2	2025-12-05 14:08:38.159913	2025-12-05 14:08:37.471267
169	12	259	10	1	0	1	-1	2025-12-05 14:08:37.456511	2025-12-05 14:08:37.45294
189	12	265	10	2	0	2	-2	2025-12-05 14:08:38.142506	2025-12-05 14:08:37.591776
186	12	171	10	2	1	3	0	2025-12-05 14:08:37.992993	2025-12-05 14:08:37.574422
173	12	239	10	1	0	1	-1	2025-12-05 14:08:37.491596	2025-12-05 14:08:37.489316
174	12	194	10	0	1	1	2	2025-12-05 14:08:37.498621	2025-12-05 14:08:37.495926
175	12	174	10	1	0	1	-1	2025-12-05 14:08:37.505138	2025-12-05 14:08:37.502806
123	12	203	10	2	0	2	-2	2025-12-05 14:08:38.062842	2025-12-05 14:08:37.073548
154	12	173	10	1	1	2	1	2025-12-05 14:08:38.004715	2025-12-05 14:08:37.323327
178	12	188	10	1	0	1	-1	2025-12-05 14:08:37.526739	2025-12-05 14:08:37.523894
147	12	258	10	0	2	2	4	2025-12-05 14:08:37.849056	2025-12-05 14:08:37.269202
180	12	220	10	0	1	1	2	2025-12-05 14:08:37.537908	2025-12-05 14:08:37.535206
141	12	177	10	1	1	2	1	2025-12-05 14:08:37.81398	2025-12-05 14:08:37.231445
120	12	201	10	1	1	2	1	2025-12-05 14:08:37.789233	2025-12-05 14:08:37.052158
183	12	251	10	1	0	1	-1	2025-12-05 14:08:37.557695	2025-12-05 14:08:37.554587
164	12	207	10	1	1	2	1	2025-12-05 14:08:37.798765	2025-12-05 14:08:37.410374
185	12	240	10	1	0	1	-1	2025-12-05 14:08:37.570145	2025-12-05 14:08:37.567522
136	12	266	10	2	1	3	0	2025-12-05 14:08:38.087195	2025-12-05 14:08:37.193493
158	12	228	10	1	1	2	1	2025-12-05 14:08:37.864249	2025-12-05 14:08:37.368375
188	12	192	10	1	0	1	-1	2025-12-05 14:08:37.588189	2025-12-05 14:08:37.585381
168	12	217	10	2	0	2	-2	2025-12-05 14:08:38.154309	2025-12-05 14:08:37.444556
190	12	196	10	1	0	1	-1	2025-12-05 14:08:37.598611	2025-12-05 14:08:37.59667
191	12	214	10	1	0	1	-1	2025-12-05 14:08:37.604859	2025-12-05 14:08:37.601707
192	12	205	10	1	0	1	-1	2025-12-05 14:08:37.610831	2025-12-05 14:08:37.609011
193	12	186	10	1	0	1	-1	2025-12-05 14:08:37.615394	2025-12-05 14:08:37.613614
194	12	225	10	1	0	1	-1	2025-12-05 14:08:37.621164	2025-12-05 14:08:37.618115
195	12	175	10	1	0	1	-1	2025-12-05 14:08:37.627148	2025-12-05 14:08:37.625191
176	12	195	10	1	1	2	1	2025-12-05 14:08:38.05215	2025-12-05 14:08:37.509571
197	12	183	10	1	0	1	-1	2025-12-05 14:08:37.65837	2025-12-05 14:08:37.655401
170	12	248	10	1	1	2	1	2025-12-05 14:08:38.135246	2025-12-05 14:08:37.462061
205	12	253	10	1	0	1	-1	2025-12-05 14:08:37.715754	2025-12-05 14:08:37.71214
198	12	189	10	1	1	2	1	2025-12-05 14:08:37.767711	2025-12-05 14:08:37.662371
200	12	216	10	1	1	2	1	2025-12-05 14:08:37.778462	2025-12-05 14:08:37.674381
508	14	235	10	1	0	1	-1	2025-12-05 14:30:44.960158	2025-12-05 14:30:44.957842
201	12	221	10	1	1	2	1	2025-12-05 14:08:37.81924	2025-12-05 14:08:37.680837
501	13	248	10	2	1	3	0	2025-12-05 14:24:46.853288	2025-12-05 14:24:45.964806
206	12	254	10	2	0	2	-2	2025-12-05 14:08:37.885068	2025-12-05 14:08:37.722949
204	12	233	10	2	1	3	0	2025-12-05 14:08:37.934122	2025-12-05 14:08:37.70078
199	12	202	10	2	1	3	0	2025-12-05 14:08:37.956883	2025-12-05 14:08:37.667512
203	12	232	10	1	1	2	1	2025-12-05 14:08:37.968253	2025-12-05 14:08:37.694063
202	12	223	10	2	0	2	-2	2025-12-05 14:08:38.148587	2025-12-05 14:08:37.687249
560	14	177	10	2	0	2	-2	2025-12-05 14:30:45.636181	2025-12-05 14:30:45.301946
500	13	247	10	3	0	3	-3	2025-12-05 14:24:46.914094	2025-12-05 14:24:45.954963
492	13	215	10	2	1	3	0	2025-12-05 14:24:46.920975	2025-12-05 14:24:45.884215
494	13	227	10	3	1	4	-1	2025-12-05 14:24:46.939175	2025-12-05 14:24:45.901393
504	13	261	10	2	1	3	0	2025-12-05 14:24:46.944015	2025-12-05 14:24:45.98849
531	14	257	10	2	0	2	-2	2025-12-05 14:30:45.677289	2025-12-05 14:30:45.142298
505	13	264	10	3	1	4	-1	2025-12-05 14:24:46.953397	2025-12-05 14:24:45.995378
537	14	227	10	2	0	2	-2	2025-12-05 14:30:45.707894	2025-12-05 14:30:45.175989
512	14	237	10	1	0	1	-1	2025-12-05 14:30:44.983511	2025-12-05 14:30:44.981612
490	13	201	10	3	0	3	-3	2025-12-05 14:24:47.047379	2025-12-05 14:24:45.863528
519	14	236	10	2	0	2	-2	2025-12-05 14:30:45.662474	2025-12-05 14:30:45.043836
499	13	242	10	2	1	3	0	2025-12-05 14:24:47.100811	2025-12-05 14:24:45.945121
493	13	220	10	3	1	4	-1	2025-12-05 14:24:47.111538	2025-12-05 14:24:45.892801
502	13	255	10	3	0	3	-3	2025-12-05 14:24:47.116492	2025-12-05 14:24:45.974121
514	14	182	10	0	1	1	2	2025-12-05 14:30:45.017951	2025-12-05 14:30:45.015291
491	13	208	10	2	1	3	0	2025-12-05 14:24:47.120928	2025-12-05 14:24:45.875223
506	13	265	10	4	1	5	-2	2025-12-05 14:24:47.125063	2025-12-05 14:24:46.001156
511	14	244	10	2	0	2	-2	2025-12-05 14:30:45.705359	2025-12-05 14:30:44.976231
509	14	167	10	0	2	2	4	2025-12-05 14:30:45.633297	2025-12-05 14:30:44.963573
517	14	216	10	1	0	1	-1	2025-12-05 14:30:45.034402	2025-12-05 14:30:45.032655
518	14	245	10	1	0	1	-1	2025-12-05 14:30:45.040075	2025-12-05 14:30:45.037764
536	14	187	10	2	0	2	-2	2025-12-05 14:30:45.669675	2025-12-05 14:30:45.171412
525	14	202	10	1	1	2	1	2025-12-05 14:30:45.618966	2025-12-05 14:30:45.086301
539	14	250	10	1	1	2	1	2025-12-05 14:30:45.695048	2025-12-05 14:30:45.186481
522	14	234	10	1	0	1	-1	2025-12-05 14:30:45.067328	2025-12-05 14:30:45.064055
523	14	233	10	0	1	1	2	2025-12-05 14:30:45.074752	2025-12-05 14:30:45.071932
524	14	189	10	1	0	1	-1	2025-12-05 14:30:45.082122	2025-12-05 14:30:45.079317
528	14	192	10	1	1	2	1	2025-12-05 14:30:45.626953	2025-12-05 14:30:45.115462
526	14	170	10	1	0	1	-1	2025-12-05 14:30:45.099741	2025-12-05 14:30:45.095291
547	14	188	10	1	1	2	1	2025-12-05 14:30:45.722404	2025-12-05 14:30:45.233157
516	14	179	10	2	0	2	-2	2025-12-05 14:30:45.629416	2025-12-05 14:30:45.027972
529	14	193	10	1	0	1	-1	2025-12-05 14:30:45.127948	2025-12-05 14:30:45.124542
530	14	247	10	1	0	1	-1	2025-12-05 14:30:45.137421	2025-12-05 14:30:45.134009
498	13	241	10	2	0	2	-2	2025-12-05 14:24:46.502286	2025-12-05 14:24:45.935859
521	14	229	10	2	0	2	-2	2025-12-05 14:30:45.689117	2025-12-05 14:30:45.057062
532	14	221	10	1	0	1	-1	2025-12-05 14:30:45.154815	2025-12-05 14:30:45.152475
495	13	232	10	4	0	4	-4	2025-12-05 14:24:46.577227	2025-12-05 14:24:45.909643
503	13	259	10	3	0	3	-3	2025-12-05 14:24:46.694462	2025-12-05 14:24:45.981639
496	13	233	10	2	1	3	0	2025-12-05 14:24:46.69859	2025-12-05 14:24:45.91858
489	13	192	10	2	0	2	-2	2025-12-05 14:24:46.769889	2025-12-05 14:24:45.854647
497	13	239	10	2	2	4	2	2025-12-05 14:24:46.810514	2025-12-05 14:24:45.927014
533	14	181	10	1	0	1	-1	2025-12-05 14:30:45.159467	2025-12-05 14:30:45.157719
534	14	232	10	0	1	1	2	2025-12-05 14:30:45.164276	2025-12-05 14:30:45.16216
535	14	223	10	1	0	1	-1	2025-12-05 14:30:45.168824	2025-12-05 14:30:45.167133
556	14	240	10	0	2	2	4	2025-12-05 14:30:45.672323	2025-12-05 14:30:45.280009
568	14	172	10	2	0	2	-2	2025-12-05 14:30:45.715054	2025-12-05 14:30:45.345292
538	14	222	10	0	1	1	2	2025-12-05 14:30:45.183051	2025-12-05 14:30:45.180628
564	14	205	10	1	1	2	1	2025-12-05 14:30:45.698014	2025-12-05 14:30:45.325037
540	14	175	10	1	0	1	-1	2025-12-05 14:30:45.194167	2025-12-05 14:30:45.191999
541	14	217	10	1	0	1	-1	2025-12-05 14:30:45.201201	2025-12-05 14:30:45.198138
542	14	180	10	1	0	1	-1	2025-12-05 14:30:45.207332	2025-12-05 14:30:45.205165
520	14	251	10	1	1	2	1	2025-12-05 14:30:45.611906	2025-12-05 14:30:45.049729
544	14	218	10	1	0	1	-1	2025-12-05 14:30:45.218592	2025-12-05 14:30:45.216419
545	14	242	10	1	0	1	-1	2025-12-05 14:30:45.223982	2025-12-05 14:30:45.221849
558	14	197	10	1	1	2	1	2025-12-05 14:30:45.653717	2025-12-05 14:30:45.291264
507	14	260	10	2	0	2	-2	2025-12-05 14:30:45.725159	2025-12-05 14:30:44.944583
548	14	186	10	1	0	1	-1	2025-12-05 14:30:45.239885	2025-12-05 14:30:45.238085
549	14	190	10	0	1	1	2	2025-12-05 14:30:45.244646	2025-12-05 14:30:45.242611
550	14	208	10	1	0	1	-1	2025-12-05 14:30:45.250605	2025-12-05 14:30:45.248296
551	14	215	10	1	0	1	-1	2025-12-05 14:30:45.255033	2025-12-05 14:30:45.253279
552	14	228	10	1	0	1	-1	2025-12-05 14:30:45.260559	2025-12-05 14:30:45.25816
553	14	168	10	0	1	1	2	2025-12-05 14:30:45.265955	2025-12-05 14:30:45.26376
554	14	201	10	1	0	1	-1	2025-12-05 14:30:45.271458	2025-12-05 14:30:45.269413
555	14	256	10	1	0	1	-1	2025-12-05 14:30:45.276709	2025-12-05 14:30:45.274753
510	14	207	10	0	2	2	4	2025-12-05 14:30:45.67486	2025-12-05 14:30:44.969864
557	14	226	10	1	0	1	-1	2025-12-05 14:30:45.28786	2025-12-05 14:30:45.285613
513	14	230	10	1	1	2	1	2025-12-05 14:30:45.659268	2025-12-05 14:30:44.986625
559	14	261	10	1	0	1	-1	2025-12-05 14:30:45.298955	2025-12-05 14:30:45.296972
562	14	241	10	1	1	2	1	2025-12-05 14:30:45.647952	2025-12-05 14:30:45.312403
561	14	253	10	0	1	1	2	2025-12-05 14:30:45.309438	2025-12-05 14:30:45.307445
546	14	238	10	1	1	2	1	2025-12-05 14:30:45.651075	2025-12-05 14:30:45.22779
563	14	173	10	1	0	1	-1	2025-12-05 14:30:45.321336	2025-12-05 14:30:45.31893
515	14	191	10	1	1	2	1	2025-12-05 14:30:45.700532	2025-12-05 14:30:45.021638
565	14	213	10	1	0	1	-1	2025-12-05 14:30:45.333112	2025-12-05 14:30:45.33108
566	14	231	10	1	0	1	-1	2025-12-05 14:30:45.338309	2025-12-05 14:30:45.336409
567	14	254	10	1	0	1	-1	2025-12-05 14:30:45.342629	2025-12-05 14:30:45.340992
527	14	266	10	1	1	2	1	2025-12-05 14:30:45.719998	2025-12-05 14:30:45.105759
569	14	210	10	1	0	1	-1	2025-12-05 14:30:45.352667	2025-12-05 14:30:45.350502
570	14	200	10	1	0	1	-1	2025-12-05 14:30:45.357879	2025-12-05 14:30:45.35594
543	14	174	10	2	0	2	-2	2025-12-05 14:30:45.607039	2025-12-05 14:30:45.210499
572	14	171	10	1	0	1	-1	2025-12-05 14:30:45.368657	2025-12-05 14:30:45.36647
589	14	265	10	2	0	2	-2	2025-12-05 14:30:45.712532	2025-12-05 14:30:45.471364
585	14	224	10	2	0	2	-2	2025-12-05 14:30:45.717594	2025-12-05 14:30:45.449814
575	14	204	10	1	0	1	-1	2025-12-05 14:30:45.388804	2025-12-05 14:30:45.386293
576	14	203	10	1	0	1	-1	2025-12-05 14:30:45.395942	2025-12-05 14:30:45.393002
578	14	262	10	1	0	1	-1	2025-12-05 14:30:45.412166	2025-12-05 14:30:45.408777
579	14	199	10	0	1	1	2	2025-12-05 14:30:45.420376	2025-12-05 14:30:45.417444
642	15	38	8	2	4	6	6	2025-12-05 14:37:16.9587	2025-12-05 14:37:16.030749
616	15	20	8	5	2	7	-1	2025-12-05 14:37:16.998437	2025-12-05 14:37:15.751601
583	14	239	10	1	0	1	-1	2025-12-05 14:30:45.441714	2025-12-05 14:30:45.439839
586	14	255	10	1	0	1	-1	2025-12-05 14:30:45.457836	2025-12-05 14:30:45.45548
587	14	252	10	1	0	1	-1	2025-12-05 14:30:45.463797	2025-12-05 14:30:45.461562
588	14	248	10	0	1	1	2	2025-12-05 14:30:45.468757	2025-12-05 14:30:45.467012
619	15	11	8	7	0	7	-7	2025-12-05 14:37:17.003223	2025-12-05 14:37:15.780389
615	15	47	8	4	2	6	0	2025-12-05 14:37:17.008134	2025-12-05 14:37:15.741501
591	14	212	10	1	0	1	-1	2025-12-05 14:30:45.482178	2025-12-05 14:30:45.480161
593	14	219	10	1	0	1	-1	2025-12-05 14:30:45.492239	2025-12-05 14:30:45.490457
594	14	178	10	1	0	1	-1	2025-12-05 14:30:45.496946	2025-12-05 14:30:45.495102
621	15	32	8	2	2	4	2	2025-12-05 14:37:16.868478	2025-12-05 14:37:15.797703
596	14	194	10	1	0	1	-1	2025-12-05 14:30:45.506489	2025-12-05 14:30:45.504468
626	15	35	8	6	0	6	-6	2025-12-05 14:37:17.012477	2025-12-05 14:37:15.847712
599	14	220	10	1	0	1	-1	2025-12-05 14:30:45.52088	2025-12-05 14:30:45.518939
624	15	24	8	5	1	6	-3	2025-12-05 14:37:16.963402	2025-12-05 14:37:15.829236
602	14	169	10	0	1	1	2	2025-12-05 14:30:45.554004	2025-12-05 14:30:45.551671
604	14	206	10	1	0	1	-1	2025-12-05 14:30:45.56332	2025-12-05 14:30:45.56153
605	14	246	10	0	1	1	2	2025-12-05 14:30:45.569651	2025-12-05 14:30:45.567519
640	15	31	8	5	1	6	-3	2025-12-05 14:37:16.967157	2025-12-05 14:37:16.018194
603	14	176	10	1	1	2	1	2025-12-05 14:30:45.600599	2025-12-05 14:30:45.557152
606	14	264	10	2	0	2	-2	2025-12-05 14:30:45.604059	2025-12-05 14:30:45.572643
571	14	195	10	2	0	2	-2	2025-12-05 14:30:45.609474	2025-12-05 14:30:45.360618
582	14	196	10	1	1	2	1	2025-12-05 14:30:45.615856	2025-12-05 14:30:45.434795
581	14	183	10	2	0	2	-2	2025-12-05 14:30:45.621889	2025-12-05 14:30:45.429576
600	14	259	10	1	1	2	1	2025-12-05 14:30:45.624561	2025-12-05 14:30:45.523615
573	14	225	10	2	0	2	-2	2025-12-05 14:30:45.638654	2025-12-05 14:30:45.371961
580	14	211	10	2	0	2	-2	2025-12-05 14:30:45.641719	2025-12-05 14:30:45.423958
590	14	258	10	1	1	2	1	2025-12-05 14:30:45.644627	2025-12-05 14:30:45.47579
595	14	198	10	2	0	2	-2	2025-12-05 14:30:45.656412	2025-12-05 14:30:45.499857
601	14	209	10	1	1	2	1	2025-12-05 14:30:45.666538	2025-12-05 14:30:45.528127
592	14	243	10	1	1	2	1	2025-12-05 14:30:45.6797	2025-12-05 14:30:45.485485
597	14	185	10	1	1	2	1	2025-12-05 14:30:45.682963	2025-12-05 14:30:45.509254
577	14	214	10	1	1	2	1	2025-12-05 14:30:45.686572	2025-12-05 14:30:45.400481
598	14	263	10	1	1	2	1	2025-12-05 14:30:45.691544	2025-12-05 14:30:45.513607
574	14	249	10	1	1	2	1	2025-12-05 14:30:45.702912	2025-12-05 14:30:45.378999
584	14	184	10	2	0	2	-2	2025-12-05 14:30:45.710221	2025-12-05 14:30:45.44491
630	15	49	8	4	1	5	-2	2025-12-05 14:37:16.826847	2025-12-05 14:37:15.886824
644	15	40	8	4	2	6	0	2025-12-05 14:37:16.97286	2025-12-05 14:37:16.043385
622	15	34	8	6	0	6	-6	2025-12-05 14:37:17.016068	2025-12-05 14:37:15.809714
618	15	17	8	7	0	7	-7	2025-12-05 14:37:17.036659	2025-12-05 14:37:15.771326
609	15	33	8	5	1	6	-3	2025-12-05 14:37:17.041775	2025-12-05 14:37:15.63057
636	15	25	8	4	2	6	0	2025-12-05 14:37:16.878377	2025-12-05 14:37:15.982842
631	15	42	8	3	0	3	-3	2025-12-05 14:37:16.437668	2025-12-05 14:37:15.897383
608	15	22	8	3	0	3	-3	2025-12-05 14:37:16.56503	2025-12-05 14:37:15.621033
934	16	257	10	4	1	5	-2	2025-12-05 14:43:51.839935	2025-12-05 14:43:48.843824
637	15	27	8	4	2	6	0	2025-12-05 14:37:16.906777	2025-12-05 14:37:15.992564
633	15	12	8	3	1	4	-1	2025-12-05 14:37:16.73681	2025-12-05 14:37:15.954392
620	15	48	8	4	1	5	-2	2025-12-05 14:37:16.693137	2025-12-05 14:37:15.787716
641	15	36	8	4	1	5	-2	2025-12-05 14:37:16.832261	2025-12-05 14:37:16.025007
639	15	29	8	5	1	6	-3	2025-12-05 14:37:16.837508	2025-12-05 14:37:16.010245
932	16	46	8	6	0	6	-6	2025-12-05 14:43:51.605326	2025-12-05 14:43:48.809225
645	15	41	8	3	3	6	3	2025-12-05 14:37:16.978729	2025-12-05 14:37:16.048806
612	15	14	8	3	1	4	-1	2025-12-05 14:37:16.773514	2025-12-05 14:37:15.711636
635	15	19	8	3	1	4	-1	2025-12-05 14:37:16.701368	2025-12-05 14:37:15.973353
646	15	45	8	5	0	5	-5	2025-12-05 14:37:17.021008	2025-12-05 14:37:16.056554
632	15	10	8	4	2	6	0	2025-12-05 14:37:16.850504	2025-12-05 14:37:15.944311
617	15	15	8	5	0	5	-5	2025-12-05 14:37:16.854696	2025-12-05 14:37:15.761295
611	15	30	8	5	0	5	-5	2025-12-05 14:37:16.984651	2025-12-05 14:37:15.65233
629	15	26	8	5	3	8	1	2025-12-05 14:37:17.026061	2025-12-05 14:37:15.8764
634	15	18	8	4	1	5	-2	2025-12-05 14:37:16.9903	2025-12-05 14:37:15.963994
623	15	37	8	3	1	4	-1	2025-12-05 14:37:16.711183	2025-12-05 14:37:15.819629
610	15	16	8	5	1	6	-3	2025-12-05 14:37:16.89746	2025-12-05 14:37:15.641789
614	15	13	8	3	2	5	1	2025-12-05 14:37:16.814973	2025-12-05 14:37:15.732335
638	15	28	8	4	2	6	0	2025-12-05 14:37:16.994476	2025-12-05 14:37:16.002009
628	15	43	8	4	1	5	-2	2025-12-05 14:37:16.821126	2025-12-05 14:37:15.866395
613	15	21	8	4	0	4	-4	2025-12-05 14:37:16.923123	2025-12-05 14:37:15.722198
627	15	46	8	4	2	6	0	2025-12-05 14:37:17.031219	2025-12-05 14:37:15.857255
625	15	23	8	6	0	6	-6	2025-12-05 14:37:16.949792	2025-12-05 14:37:15.837821
607	15	44	8	3	2	5	1	2025-12-05 14:37:16.954213	2025-12-05 14:37:15.603808
643	15	39	8	4	0	4	-4	2025-12-05 14:37:16.679789	2025-12-05 14:37:16.037525
931	16	29	8	3	1	4	-1	2025-12-05 14:43:51.61393	2025-12-05 14:43:48.802187
937	16	10	8	3	1	4	-1	2025-12-05 14:43:51.636882	2025-12-05 14:43:48.883571
927	16	25	8	5	1	6	-3	2025-12-05 14:43:51.639816	2025-12-05 14:43:48.770051
941	16	14	8	5	3	8	1	2025-12-05 14:43:51.884925	2025-12-05 14:43:48.913869
929	16	35	8	4	0	4	-4	2025-12-05 14:43:51.565466	2025-12-05 14:43:48.789289
933	16	47	8	3	0	3	-3	2025-12-05 14:43:51.552735	2025-12-05 14:43:48.815344
935	16	169	10	3	1	4	-1	2025-12-05 14:43:51.098139	2025-12-05 14:43:48.84911
936	16	219	10	4	4	8	4	2025-12-05 14:43:51.743677	2025-12-05 14:43:48.855498
930	16	37	8	4	1	5	-2	2025-12-05 14:43:51.915961	2025-12-05 14:43:48.79618
938	16	11	8	5	2	7	-1	2025-12-05 14:43:51.927399	2025-12-05 14:43:48.888592
940	16	13	8	4	1	5	-2	2025-12-05 14:43:51.59145	2025-12-05 14:43:48.906039
939	16	12	8	5	3	8	1	2025-12-05 14:43:51.89087	2025-12-05 14:43:48.896519
928	16	24	8	3	2	5	1	2025-12-05 14:43:51.906248	2025-12-05 14:43:48.781862
960	16	38	8	6	0	6	-6	2025-12-05 14:43:51.934403	2025-12-05 14:43:49.018092
943	16	16	8	4	2	6	0	2025-12-05 14:43:51.877031	2025-12-05 14:43:48.925669
962	16	40	8	4	0	4	-4	2025-12-05 14:43:51.5491	2025-12-05 14:43:49.033045
969	16	49	8	4	1	5	-2	2025-12-05 14:43:51.895768	2025-12-05 14:43:49.076919
1025	16	224	10	4	1	5	-2	2025-12-05 14:43:51.757221	2025-12-05 14:43:49.496876
1031	16	230	10	3	0	3	-3	2025-12-05 14:43:51.127516	2025-12-05 14:43:49.527598
944	16	17	8	5	0	5	-5	2025-12-05 14:43:51.625135	2025-12-05 14:43:48.932811
952	16	27	8	5	0	5	-5	2025-12-05 14:43:51.597041	2025-12-05 14:43:48.974571
999	16	197	10	5	3	8	1	2025-12-05 14:43:51.960353	2025-12-05 14:43:49.324391
1003	16	201	10	4	1	5	-2	2025-12-05 14:43:51.79399	2025-12-05 14:43:49.345343
989	16	187	10	4	1	5	-2	2025-12-05 14:43:51.697136	2025-12-05 14:43:49.273198
950	16	23	8	5	0	5	-5	2025-12-05 14:43:51.899003	2025-12-05 14:43:48.964408
955	16	31	8	4	0	4	-4	2025-12-05 14:43:51.630782	2025-12-05 14:43:48.989215
971	16	167	10	5	0	5	-5	2025-12-05 14:43:51.845179	2025-12-05 14:43:49.18277
1030	16	229	10	4	0	4	-4	2025-12-05 14:43:51.023792	2025-12-05 14:43:49.522515
945	16	18	8	5	0	5	-5	2025-12-05 14:43:51.607723	2025-12-05 14:43:48.937834
1015	16	213	10	5	2	7	-1	2025-12-05 14:43:51.823959	2025-12-05 14:43:49.431975
953	16	28	8	5	2	7	-1	2025-12-05 14:43:51.902495	2025-12-05 14:43:48.979628
958	16	34	8	6	0	6	-6	2025-12-05 14:43:51.937114	2025-12-05 14:43:49.006241
956	16	32	8	4	2	6	0	2025-12-05 14:43:51.912513	2025-12-05 14:43:48.994676
946	16	19	8	4	3	7	2	2025-12-05 14:43:51.872305	2025-12-05 14:43:48.943769
964	16	42	8	5	1	6	-3	2025-12-05 14:43:51.918646	2025-12-05 14:43:49.044606
949	16	22	8	5	2	7	-1	2025-12-05 14:43:51.556148	2025-12-05 14:43:48.959237
970	16	186	10	5	0	5	-5	2025-12-05 14:43:51.675664	2025-12-05 14:43:49.175259
942	16	15	8	6	1	7	-4	2025-12-05 14:43:51.627874	2025-12-05 14:43:48.920141
963	16	41	8	3	2	5	1	2025-12-05 14:43:51.534503	2025-12-05 14:43:49.038397
967	16	45	8	6	1	7	-4	2025-12-05 14:43:51.888004	2025-12-05 14:43:49.063594
954	16	30	8	5	2	7	-1	2025-12-05 14:43:51.881428	2025-12-05 14:43:48.984625
966	16	44	8	6	0	6	-6	2025-12-05 14:43:51.931406	2025-12-05 14:43:49.057042
968	16	48	8	5	1	6	-3	2025-12-05 14:43:51.610051	2025-12-05 14:43:49.070281
947	16	20	8	6	1	7	-4	2025-12-05 14:43:51.589019	2025-12-05 14:43:48.949559
959	16	36	8	5	2	7	-1	2025-12-05 14:43:51.924591	2025-12-05 14:43:49.012285
972	16	168	10	6	0	6	-6	2025-12-05 14:43:51.834788	2025-12-05 14:43:49.187958
1024	16	223	10	3	2	5	1	2025-12-05 14:43:51.116314	2025-12-05 14:43:49.489914
996	16	194	10	5	0	5	-5	2025-12-05 14:43:51.045344	2025-12-05 14:43:49.309438
985	16	182	10	1	1	2	1	2025-12-05 14:43:51.130464	2025-12-05 14:43:49.252577
973	16	170	10	4	1	5	-2	2025-12-05 14:43:51.246754	2025-12-05 14:43:49.19389
1016	16	214	10	5	1	6	-3	2025-12-05 14:43:51.683863	2025-12-05 14:43:49.444882
1021	16	220	10	4	1	5	-2	2025-12-05 14:43:51.784149	2025-12-05 14:43:49.475668
998	16	196	10	4	3	7	2	2025-12-05 14:43:51.964567	2025-12-05 14:43:49.319862
991	16	189	10	2	1	3	0	2025-12-05 14:43:51.265141	2025-12-05 14:43:49.283943
1009	16	207	10	4	1	5	-2	2025-12-05 14:43:51.32447	2025-12-05 14:43:49.383637
1000	16	198	10	5	0	5	-5	2025-12-05 14:43:51.703973	2025-12-05 14:43:49.330258
1006	16	204	10	4	3	7	2	2025-12-05 14:43:51.790846	2025-12-05 14:43:49.363232
982	16	179	10	4	2	6	0	2025-12-05 14:43:51.050678	2025-12-05 14:43:49.238274
1001	16	199	10	5	1	6	-3	2025-12-05 14:43:51.818433	2025-12-05 14:43:49.335772
983	16	180	10	4	1	5	-2	2025-12-05 14:43:51.065997	2025-12-05 14:43:49.24317
1017	16	215	10	5	0	5	-5	2025-12-05 14:43:51.812632	2025-12-05 14:43:49.456198
1004	16	202	10	3	2	5	1	2025-12-05 14:43:51.739599	2025-12-05 14:43:49.350885
980	16	177	10	5	0	5	-5	2025-12-05 14:43:51.176519	2025-12-05 14:43:49.228263
1014	16	212	10	6	0	6	-6	2025-12-05 14:43:51.500254	2025-12-05 14:43:49.421567
1023	16	222	10	3	1	4	-1	2025-12-05 14:43:51.14627	2025-12-05 14:43:49.48513
951	16	26	8	6	0	6	-6	2025-12-05 14:43:51.921622	2025-12-05 14:43:48.968862
988	16	185	10	3	1	4	-1	2025-12-05 14:43:51.20791	2025-12-05 14:43:49.268553
1028	16	227	10	5	0	5	-5	2025-12-05 14:43:51.236493	2025-12-05 14:43:49.513156
1011	16	209	10	5	0	5	-5	2025-12-05 14:43:51.78777	2025-12-05 14:43:49.398289
979	16	176	10	4	1	5	-2	2025-12-05 14:43:51.772752	2025-12-05 14:43:49.223369
978	16	175	10	5	0	5	-5	2025-12-05 14:43:51.735428	2025-12-05 14:43:49.21803
1010	16	208	10	4	3	7	2	2025-12-05 14:43:51.775515	2025-12-05 14:43:49.389997
1007	16	205	10	3	3	6	3	2025-12-05 14:43:51.7209	2025-12-05 14:43:49.36961
984	16	181	10	4	1	5	-2	2025-12-05 14:43:51.747115	2025-12-05 14:43:49.247848
1019	16	217	10	3	1	4	-1	2025-12-05 14:43:51.272099	2025-12-05 14:43:49.465742
987	16	184	10	3	3	6	3	2025-12-05 14:43:51.169074	2025-12-05 14:43:49.263142
1018	16	216	10	4	0	4	-4	2025-12-05 14:43:51.33221	2025-12-05 14:43:49.461105
997	16	195	10	3	1	4	-1	2025-12-05 14:43:51.082945	2025-12-05 14:43:49.315163
981	16	178	10	4	1	5	-2	2025-12-05 14:43:51.80342	2025-12-05 14:43:49.233323
965	16	43	8	3	0	3	-3	2025-12-05 14:43:51.577193	2025-12-05 14:43:49.051163
1026	16	225	10	5	0	5	-5	2025-12-05 14:43:51.119715	2025-12-05 14:43:49.502891
957	16	33	8	5	1	6	-3	2025-12-05 14:43:51.622222	2025-12-05 14:43:49.000514
976	16	173	10	3	2	5	1	2025-12-05 14:43:51.161594	2025-12-05 14:43:49.20853
961	16	39	8	3	1	4	-1	2025-12-05 14:43:51.538007	2025-12-05 14:43:49.025026
1027	16	226	10	6	0	6	-6	2025-12-05 14:43:51.730199	2025-12-05 14:43:49.507989
994	16	192	10	5	0	5	-5	2025-12-05 14:43:51.842571	2025-12-05 14:43:49.300187
1013	16	211	10	4	1	5	-2	2025-12-05 14:43:51.707515	2025-12-05 14:43:49.414786
1005	16	203	10	5	0	5	-5	2025-12-05 14:43:51.84776	2025-12-05 14:43:49.356426
995	16	193	10	3	2	5	1	2025-12-05 14:43:51.764386	2025-12-05 14:43:49.304691
1022	16	221	10	4	0	4	-4	2025-12-05 14:43:51.232666	2025-12-05 14:43:49.480039
1008	16	206	10	4	0	4	-4	2025-12-05 14:43:51.109236	2025-12-05 14:43:49.376748
1002	16	200	10	2	3	5	4	2025-12-05 14:43:51.053508	2025-12-05 14:43:49.340203
1012	16	210	10	4	1	5	-2	2025-12-05 14:43:51.292839	2025-12-05 14:43:49.406495
975	16	172	10	5	1	6	-3	2025-12-05 14:43:51.753807	2025-12-05 14:43:49.203425
948	16	21	8	4	3	7	2	2025-12-05 14:43:51.909274	2025-12-05 14:43:48.954279
974	16	171	10	5	1	6	-3	2025-12-05 14:43:51.82114	2025-12-05 14:43:49.198595
992	16	190	10	5	1	6	-3	2025-12-05 14:43:51.679888	2025-12-05 14:43:49.288808
990	16	188	10	3	4	7	5	2025-12-05 14:43:51.75073	2025-12-05 14:43:49.278816
1032	16	231	10	3	1	4	-1	2025-12-05 14:43:51.214893	2025-12-05 14:43:49.532767
977	16	174	10	4	1	5	-2	2025-12-05 14:43:51.797175	2025-12-05 14:43:49.213308
1029	16	228	10	5	0	5	-5	2025-12-05 14:43:51.761272	2025-12-05 14:43:49.517731
993	16	191	10	3	1	4	-1	2025-12-05 14:43:51.062997	2025-12-05 14:43:49.2949
986	16	183	10	4	2	6	0	2025-12-05 14:43:51.174067	2025-12-05 14:43:49.257214
1020	16	218	10	4	0	4	-4	2025-12-05 14:43:51.140383	2025-12-05 14:43:49.470505
1081	2	35	8	2	0	2	-2	2025-12-11 08:37:57.491841	2025-12-05 15:16:12.128701
1072	2	34	8	2	0	2	-2	2025-12-11 08:37:16.737724	2025-12-05 15:13:56.680015
1075	2	25	8	2	2	4	2	2025-12-11 08:39:43.08767	2025-12-05 15:15:19.176652
1051	16	250	10	4	1	5	-2	2025-12-05 14:43:51.329447	2025-12-05 14:43:49.63006
1268	18	242	10	0	1	1	2	2025-12-06 15:52:10.963203	2025-12-06 15:52:10.954704
1048	16	247	10	3	1	4	-1	2025-12-05 14:43:51.335055	2025-12-05 14:43:49.61511
1036	16	235	10	3	2	5	1	2025-12-05 14:43:51.664926	2025-12-05 14:43:49.553963
1069	2	27	8	2	0	2	-2	2025-12-11 08:37:28.455104	2025-12-05 15:13:39.157079
1037	16	236	10	3	2	5	1	2025-12-05 14:43:51.668525	2025-12-05 14:43:49.558994
1064	16	264	10	5	1	6	-3	2025-12-05 14:43:51.672522	2025-12-05 14:43:49.6975
1046	16	245	10	4	2	6	0	2025-12-05 14:43:51.68831	2025-12-05 14:43:49.605221
1270	18	255	10	0	1	1	2	2025-12-06 15:52:21.996354	2025-12-06 15:52:21.986918
1272	18	231	10	1	0	1	-1	2025-12-06 15:52:34.007057	2025-12-06 15:52:33.997688
1041	16	240	10	4	1	5	-2	2025-12-05 14:43:51.711424	2025-12-05 14:43:49.580165
1052	16	251	10	5	1	6	-3	2025-12-05 14:43:51.724926	2025-12-05 14:43:49.635674
1080	2	46	8	2	1	3	0	2025-12-11 08:38:27.460163	2025-12-05 15:16:06.677094
1057	16	256	10	4	3	7	2	2025-12-05 14:43:51.767162	2025-12-05 14:43:49.661818
1059	16	259	10	5	0	5	-5	2025-12-05 14:43:51.769682	2025-12-05 14:43:49.671976
1063	16	263	10	4	1	5	-2	2025-12-05 14:43:51.778258	2025-12-05 14:43:49.69216
1275	18	204	10	1	0	1	-1	2025-12-06 15:53:21.491901	2025-12-06 15:53:21.484989
1044	16	243	10	5	0	5	-5	2025-12-05 14:43:51.780831	2025-12-05 14:43:49.595997
1277	18	236	10	1	0	1	-1	2025-12-06 15:53:33.019131	2025-12-06 15:53:33.010113
1043	16	242	10	4	1	5	-2	2025-12-05 14:43:51.800188	2025-12-05 14:43:49.590398
1060	16	260	10	5	1	6	-3	2025-12-05 14:43:51.80636	2025-12-05 14:43:49.676876
1071	2	12	8	2	0	2	-2	2025-12-11 08:37:02.912777	2025-12-05 15:13:50.802502
1066	16	266	10	3	2	5	1	2025-12-05 14:43:51.076156	2025-12-05 14:43:49.707067
1279	18	251	10	1	0	1	-1	2025-12-06 15:53:45.107243	2025-12-06 15:53:45.099472
1281	18	263	10	1	0	1	-1	2025-12-06 15:54:00.580018	2025-12-06 15:54:00.57215
1065	16	265	10	4	1	5	-2	2025-12-05 14:43:51.085767	2025-12-05 14:43:49.70242
1070	2	23	8	2	0	2	-2	2025-12-06 12:47:34.343535	2025-12-05 15:13:45.818463
1283	18	197	10	1	0	1	-1	2025-12-06 15:54:11.42886	2025-12-06 15:54:11.412285
1078	2	28	8	2	1	3	0	2025-12-06 12:47:53.38954	2025-12-05 15:15:52.165718
1073	2	17	8	2	0	2	-2	2025-12-11 08:39:19.640745	2025-12-05 15:15:05.512415
1055	16	254	10	4	2	6	0	2025-12-05 14:43:51.104196	2025-12-05 14:43:49.651066
1284	18	256	10	1	0	1	-1	2025-12-06 15:54:44.12969	2025-12-06 15:54:44.121771
1074	2	13	8	2	1	3	0	2025-12-11 08:40:24.481629	2025-12-05 15:15:13.678353
1249	2	18	8	2	3	5	4	2025-12-11 08:40:07.186017	2025-12-06 09:02:08.849257
1079	2	42	8	4	0	4	-4	2025-12-06 14:09:36.041262	2025-12-05 15:15:59.233524
1077	2	43	8	3	3	6	3	2025-12-11 08:35:54.9858	2025-12-05 15:15:40.083049
1254	18	266	10	1	0	1	-1	2025-12-06 15:47:38.595149	2025-12-06 15:47:38.579022
1256	18	205	10	1	0	1	-1	2025-12-06 15:47:53.105377	2025-12-06 15:47:53.09663
1050	16	249	10	5	0	5	-5	2025-12-05 14:43:51.809357	2025-12-05 14:43:49.624214
1258	18	170	10	1	0	1	-1	2025-12-06 15:48:05.070165	2025-12-06 15:48:05.062151
1260	18	184	10	1	0	1	-1	2025-12-06 15:48:13.557877	2025-12-06 15:48:13.548348
1033	16	232	10	4	2	6	0	2025-12-05 14:43:51.815511	2025-12-05 14:43:49.53819
1262	18	200	10	1	0	1	-1	2025-12-06 15:48:26.093731	2025-12-06 15:48:26.08508
1054	16	253	10	2	1	3	0	2025-12-05 14:43:51.124728	2025-12-05 14:43:49.645762
1264	18	185	10	0	1	1	2	2025-12-06 15:51:39.715337	2025-12-06 15:51:39.703897
1266	18	219	10	1	0	1	-1	2025-12-06 15:51:57.618645	2025-12-06 15:51:57.609145
1286	18	226	10	0	1	1	2	2025-12-06 15:55:07.39659	2025-12-06 15:55:07.389443
1034	16	233	10	4	2	6	0	2025-12-05 14:43:51.826626	2025-12-05 14:43:49.543895
1288	18	264	10	1	0	1	-1	2025-12-06 15:55:20.744209	2025-12-06 15:55:20.737357
1290	18	237	10	0	1	1	2	2025-12-06 15:55:36.980673	2025-12-06 15:55:36.973671
1056	16	255	10	3	2	5	1	2025-12-05 14:43:51.156209	2025-12-05 14:43:49.656335
1045	16	244	10	3	2	5	1	2025-12-05 14:43:51.82941	2025-12-05 14:43:49.600469
1035	16	234	10	4	0	4	-4	2025-12-05 14:43:51.164323	2025-12-05 14:43:49.54887
1292	18	233	10	0	1	1	2	2025-12-06 15:55:52.148269	2025-12-06 15:55:52.140345
1040	16	239	10	3	1	4	-1	2025-12-05 14:43:51.190031	2025-12-05 14:43:49.57473
1042	16	241	10	3	1	4	-1	2025-12-05 14:43:51.192889	2025-12-05 14:43:49.585402
1295	18	169	10	1	0	1	-1	2025-12-06 15:56:27.488804	2025-12-06 15:56:27.481083
1058	16	258	10	4	0	4	-4	2025-12-05 14:43:51.218275	2025-12-05 14:43:49.667399
1297	18	192	10	1	0	1	-1	2025-12-06 15:56:43.414047	2025-12-06 15:56:43.406522
1039	16	238	10	3	1	4	-1	2025-12-05 14:43:51.222551	2025-12-05 14:43:49.569144
1053	16	252	10	4	0	4	-4	2025-12-05 14:43:51.239471	2025-12-05 14:43:49.640103
1299	18	181	10	1	0	1	-1	2025-12-06 15:56:52.991831	2025-12-06 15:56:52.983801
1061	16	261	10	5	0	5	-5	2025-12-05 14:43:51.832053	2025-12-05 14:43:49.682035
1047	16	246	10	5	0	5	-5	2025-12-05 14:43:51.837303	2025-12-05 14:43:49.609984
1301	18	227	10	1	0	1	-1	2025-12-06 15:57:02.910317	2025-12-06 15:57:02.896305
1062	16	262	10	6	0	6	-6	2025-12-05 14:43:51.967679	2025-12-05 14:43:49.686857
1303	18	244	10	1	0	1	-1	2025-12-06 15:57:11.256362	2025-12-06 15:57:11.24936
1304	18	249	10	1	0	1	-1	2025-12-06 15:57:42.409584	2025-12-06 15:57:42.399915
1306	18	241	10	1	0	1	-1	2025-12-06 15:57:53.77084	2025-12-06 15:57:53.763243
1308	18	193	10	1	0	1	-1	2025-12-06 15:58:04.97539	2025-12-06 15:58:04.966499
1310	18	235	10	0	1	1	2	2025-12-06 15:58:21.709561	2025-12-06 15:58:21.702114
1312	18	218	10	0	1	1	2	2025-12-06 15:58:34.207451	2025-12-06 15:58:34.19961
1315	18	221	10	0	1	1	2	2025-12-06 15:59:27.055929	2025-12-06 15:59:27.048342
1049	16	248	10	4	1	5	-2	2025-12-05 14:43:51.261264	2025-12-05 14:43:49.619714
1317	18	253	10	0	1	1	2	2025-12-06 15:59:42.334777	2025-12-06 15:59:42.328477
1038	16	237	10	4	1	5	-2	2025-12-05 14:43:51.283518	2025-12-05 14:43:49.564217
1319	18	248	10	1	0	1	-1	2025-12-06 15:59:51.55845	2025-12-06 15:59:51.550536
1321	18	176	10	1	0	1	-1	2025-12-06 16:00:00.175131	2025-12-06 16:00:00.16634
1323	18	254	10	0	1	1	2	2025-12-06 16:00:13.462996	2025-12-06 16:00:13.455474
1324	18	212	10	1	0	1	-1	2025-12-06 16:00:50.584144	2025-12-06 16:00:50.576421
1326	18	257	10	0	1	1	2	2025-12-06 16:01:00.068332	2025-12-06 16:01:00.061725
1328	18	206	10	1	0	1	-1	2025-12-06 16:01:14.462862	2025-12-06 16:01:14.454313
1333	2	114	9	1	0	1	-1	2025-12-07 06:58:05.858948	2025-12-07 06:58:05.844566
1334	2	87	9	1	0	1	-1	2025-12-07 07:00:54.671137	2025-12-07 07:00:54.662864
1335	2	165	9	1	0	1	-1	2025-12-07 07:01:00.210017	2025-12-07 07:01:00.200921
1336	2	96	9	0	1	1	2	2025-12-07 07:01:07.038931	2025-12-07 07:01:07.03023
1076	2	36	8	2	0	2	-2	2025-12-11 08:37:22.264742	2025-12-05 15:15:30.397661
1381	2	338	12	0	3	3	6	2026-01-03 15:36:10.254221	2025-12-09 12:52:06.121588
1255	18	201	10	0	1	1	2	2025-12-06 15:47:46.556545	2025-12-06 15:47:46.546351
1441	2	372	12	1	1	2	1	2026-01-03 15:46:26.970914	2025-12-09 13:01:14.758813
1259	18	173	10	1	0	1	-1	2025-12-06 15:48:09.039421	2025-12-06 15:48:09.030265
1261	18	171	10	1	0	1	-1	2025-12-06 15:48:19.387263	2025-12-06 15:48:19.38004
1263	18	196	10	1	0	1	-1	2025-12-06 15:48:31.89472	2025-12-06 15:48:31.886047
1265	18	223	10	0	1	1	2	2025-12-06 15:51:48.016257	2025-12-06 15:51:48.008428
1267	18	224	10	0	1	1	2	2025-12-06 15:52:06.004928	2025-12-06 15:52:05.99776
1269	18	191	10	1	0	1	-1	2025-12-06 15:52:15.957267	2025-12-06 15:52:15.947102
1271	18	189	10	1	0	1	-1	2025-12-06 15:52:26.989189	2025-12-06 15:52:26.978069
1273	18	243	10	0	1	1	2	2025-12-06 15:52:45.091783	2025-12-06 15:52:45.083847
1274	18	225	10	1	0	1	-1	2025-12-06 15:53:15.633023	2025-12-06 15:53:15.625338
1257	18	220	10	0	2	2	4	2025-12-06 16:01:09.516	2025-12-06 15:48:00.679172
1329	18	262	10	0	1	1	2	2025-12-06 16:01:26.237945	2025-12-06 16:01:26.22676
1331	18	172	10	1	0	1	-1	2025-12-06 16:01:38.558364	2025-12-06 16:01:38.550113
1337	2	64	9	1	0	1	-1	2025-12-07 07:01:10.926717	2025-12-07 07:01:10.917676
1338	2	65	9	1	0	1	-1	2025-12-07 07:01:17.688099	2025-12-07 07:01:17.6774
1339	2	123	9	0	1	1	2	2025-12-07 07:01:22.559563	2025-12-07 07:01:22.550314
1340	2	153	9	1	0	1	-1	2025-12-07 07:01:28.347818	2025-12-07 07:01:28.340693
1341	2	86	9	1	0	1	-1	2025-12-07 07:01:35.414305	2025-12-07 07:01:35.405463
1342	2	133	9	1	0	1	-1	2025-12-07 07:01:39.830024	2025-12-07 07:01:39.820709
1343	2	92	9	0	1	1	2	2025-12-07 07:03:13.783976	2025-12-07 07:03:13.774744
1344	2	80	9	1	0	1	-1	2025-12-07 07:03:19.176563	2025-12-07 07:03:19.167711
1345	2	149	9	1	0	1	-1	2025-12-07 07:03:23.395178	2025-12-07 07:03:23.385406
1346	2	93	9	1	0	1	-1	2025-12-07 07:03:28.832422	2025-12-07 07:03:28.824268
1347	2	141	9	1	0	1	-1	2025-12-07 07:03:37.860514	2025-12-07 07:03:37.850982
1348	2	108	9	1	0	1	-1	2025-12-07 07:03:42.288587	2025-12-07 07:03:42.27838
1349	2	124	9	1	0	1	-1	2025-12-07 07:03:46.647408	2025-12-07 07:03:46.637659
1350	2	126	9	1	0	1	-1	2025-12-07 07:03:51.733876	2025-12-07 07:03:51.724262
1351	2	107	9	1	0	1	-1	2025-12-07 07:03:56.621157	2025-12-07 07:03:56.613648
1352	2	140	9	1	0	1	-1	2025-12-07 07:04:03.27127	2025-12-07 07:04:03.263816
1353	2	116	9	1	0	1	-1	2025-12-07 07:05:09.148688	2025-12-07 07:05:09.138739
1354	2	150	9	1	0	1	-1	2025-12-07 07:05:15.396538	2025-12-07 07:05:15.387992
1355	2	145	9	1	0	1	-1	2025-12-07 07:05:21.118813	2025-12-07 07:05:21.107194
1356	2	90	9	1	0	1	-1	2025-12-07 07:05:26.850279	2025-12-07 07:05:26.842196
1357	2	148	9	1	0	1	-1	2025-12-07 07:05:31.927204	2025-12-07 07:05:31.917244
1358	2	75	9	0	1	1	2	2025-12-07 07:05:38.393473	2025-12-07 07:05:38.384808
1359	2	112	9	1	0	1	-1	2025-12-07 07:05:45.939359	2025-12-07 07:05:45.931684
1360	2	55	9	1	0	1	-1	2025-12-07 07:06:07.326934	2025-12-07 07:06:07.319209
1361	2	151	9	1	0	1	-1	2025-12-07 07:06:12.820248	2025-12-07 07:06:12.810336
1362	2	129	9	0	1	1	2	2025-12-07 07:06:21.242989	2025-12-07 07:06:21.23481
1365	2	696	20	2	0	2	-2	2025-12-10 07:48:55.969322	2025-12-07 07:17:34.727076
1366	2	712	20	0	4	4	8	2025-12-11 08:28:44.853548	2025-12-07 07:17:42.666417
1363	2	699	20	2	1	3	0	2025-12-11 08:28:51.795791	2025-12-07 07:17:23.438569
1067	2	19	8	2	1	3	0	2025-12-11 08:35:33.484426	2025-12-05 15:13:26.589163
1364	2	689	20	2	0	2	-2	2025-12-10 07:47:14.140333	2025-12-07 07:17:29.944963
1394	2	363	12	2	1	3	0	2026-01-03 15:38:55.943429	2025-12-09 12:54:18.155033
1409	2	305	12	2	0	2	-2	2026-01-03 15:37:38.557004	2025-12-09 12:56:13.158787
1446	2	356	12	1	2	3	3	2026-01-07 16:27:33.37339	2025-12-09 13:01:44.383989
1447	2	374	12	1	1	2	1	2026-01-03 15:45:22.291191	2025-12-09 13:01:49.574122
1382	2	310	12	1	0	1	-1	2025-12-09 12:52:50.543141	2025-12-09 12:52:50.501686
1415	2	362	12	0	4	4	8	2026-01-07 16:28:08.07299	2025-12-09 12:57:31.316077
1433	2	314	12	2	0	2	-2	2026-01-03 15:49:32.723574	2025-12-09 13:00:16.118229
1378	2	321	12	2	0	2	-2	2026-01-03 15:45:41.675409	2025-12-09 12:51:46.680533
1425	2	289	12	2	0	2	-2	2026-01-03 15:36:46.346204	2025-12-09 12:59:00.69573
1384	2	295	12	2	0	2	-2	2026-01-03 15:38:02.951652	2025-12-09 12:53:01.644837
1444	2	301	12	2	0	2	-2	2026-01-03 15:47:37.432047	2025-12-09 13:01:31.770255
1396	2	303	12	2	1	3	0	2026-01-03 15:43:20.282853	2025-12-09 12:54:28.467731
1388	2	287	12	2	0	2	-2	2026-01-03 15:45:36.491393	2025-12-09 12:53:27.239236
1374	2	337	12	2	1	3	0	2026-01-03 15:45:17.251745	2025-12-09 12:51:21.264662
1435	2	318	12	0	2	2	4	2026-01-03 15:43:27.429355	2025-12-09 13:00:31.42161
1442	2	312	12	2	1	3	0	2026-01-07 16:33:22.170778	2025-12-09 13:01:19.604866
1407	2	309	12	1	0	1	-1	2025-12-09 12:56:01.461957	2025-12-09 12:56:01.453013
1417	2	381	12	0	4	4	8	2026-01-07 16:27:06.910861	2025-12-09 12:57:54.647419
1419	2	379	12	0	4	4	8	2026-01-07 16:28:21.030964	2025-12-09 12:58:06.78035
1413	2	324	12	1	0	1	-1	2025-12-09 12:57:17.604953	2025-12-09 12:57:17.593
1376	2	325	12	2	0	2	-2	2026-01-03 15:44:44.532704	2025-12-09 12:51:31.562362
1377	2	364	12	0	4	4	8	2026-01-07 16:33:02.391284	2025-12-09 12:51:40.851123
1431	2	375	12	2	1	3	0	2026-01-07 16:27:51.370829	2025-12-09 12:59:53.014586
1423	2	330	12	1	2	3	3	2026-01-03 15:37:52.647035	2025-12-09 12:58:50.545954
1443	2	326	12	2	0	2	-2	2026-01-03 15:37:00.520614	2025-12-09 13:01:27.254465
1367	2	692	20	3	4	7	5	2025-12-11 08:30:26.514398	2025-12-07 07:17:52.811205
1392	2	292	12	2	0	2	-2	2026-01-03 15:37:57.153294	2025-12-09 12:54:06.445326
1445	2	316	12	2	0	2	-2	2026-01-03 15:38:21.15138	2025-12-09 13:01:37.259061
1427	2	328	12	2	2	4	2	2026-01-07 16:27:02.176021	2025-12-09 12:59:13.413183
1372	2	302	12	2	0	2	-2	2026-01-03 15:43:31.975452	2025-12-09 12:51:10.846516
1439	2	311	12	2	0	2	-2	2026-01-03 15:49:03.448003	2025-12-09 13:00:54.143386
1403	2	354	12	2	1	3	0	2026-01-07 16:32:51.057458	2025-12-09 12:55:35.265377
1390	2	351	12	2	1	3	0	2026-01-03 15:46:42.180715	2025-12-09 12:53:43.306339
1375	2	339	12	2	0	2	-2	2026-01-03 15:37:30.170567	2025-12-09 12:51:28.316977
1400	2	371	12	1	2	3	3	2026-01-03 15:38:32.494726	2025-12-09 12:54:52.552627
1398	2	319	12	2	0	2	-2	2026-01-03 15:45:26.955407	2025-12-09 12:54:39.273689
1373	2	291	12	2	0	2	-2	2026-01-03 15:38:37.417629	2025-12-09 12:51:16.635592
1250	2	32	8	2	0	2	-2	2025-12-11 08:36:16.912908	2025-12-06 09:08:49.58952
1448	2	327	12	2	0	2	-2	2026-01-03 15:39:15.654215	2025-12-09 13:01:55.887085
1421	2	331	12	1	1	2	1	2026-01-07 16:33:41.103531	2025-12-09 12:58:19.822667
1411	2	323	12	2	0	2	-2	2026-01-03 15:39:29.062894	2025-12-09 12:56:24.720498
1380	2	344	12	2	0	2	-2	2026-01-03 15:44:23.846239	2025-12-09 12:51:58.066309
1429	2	367	12	2	1	3	0	2026-01-03 15:44:34.443689	2025-12-09 12:59:39.638976
1405	2	370	12	2	1	3	0	2026-01-03 15:45:12.684907	2025-12-09 12:55:50.327163
1379	2	290	12	2	0	2	-2	2026-01-03 15:45:50.064147	2025-12-09 12:51:50.463101
1437	2	283	12	0	2	2	4	2026-01-03 15:47:41.115332	2025-12-09 13:00:45.146728
1234	2	11	8	2	0	2	-2	2025-12-11 08:35:39.422952	2025-12-05 15:36:35.502763
1224	2	37	8	2	3	5	4	2025-12-11 08:39:36.176185	2025-12-05 15:35:04.761094
1302	18	222	10	1	0	1	-1	2025-12-06 15:57:06.553066	2025-12-06 15:57:06.544489
1237	2	14	8	2	1	3	0	2025-12-11 08:35:27.176586	2025-12-05 15:36:53.018054
1233	2	47	8	3	3	6	3	2025-12-11 08:40:37.65022	2025-12-05 15:36:30.380482
1305	18	177	10	1	0	1	-1	2025-12-06 15:57:47.807405	2025-12-06 15:57:47.798557
1406	2	297	12	1	1	2	1	2026-01-03 15:36:15.210275	2025-12-09 12:55:57.29715
1241	2	30	8	2	0	2	-2	2025-12-06 09:01:48.583167	2025-12-05 15:37:49.460868
1238	2	10	8	3	0	3	-3	2025-12-11 08:40:30.415861	2025-12-05 15:36:59.57939
1307	18	260	10	0	1	1	2	2025-12-06 15:57:57.83316	2025-12-06 15:57:57.82486
1309	18	186	10	0	1	1	2	2025-12-06 15:58:13.133861	2025-12-06 15:58:13.118295
1311	18	182	10	1	0	1	-1	2025-12-06 15:58:27.315981	2025-12-06 15:58:27.30947
1230	2	22	8	2	0	2	-2	2025-12-11 08:36:01.874357	2025-12-05 15:36:11.151005
1313	18	198	10	1	0	1	-1	2025-12-06 15:58:38.637565	2025-12-06 15:58:38.629721
1240	2	15	8	1	2	3	3	2025-12-11 08:38:57.586009	2025-12-05 15:37:40.512324
1253	2	29	8	2	0	2	-2	2025-12-11 08:36:36.090067	2025-12-06 13:44:55.652843
1223	2	40	8	1	3	4	5	2025-12-11 08:38:21.153267	2025-12-05 15:34:59.310916
1314	18	214	10	0	1	1	2	2025-12-06 15:59:21.942102	2025-12-06 15:59:21.932871
1226	2	20	8	2	0	2	-2	2025-12-11 08:35:44.528849	2025-12-05 15:35:19.961744
1316	18	252	10	0	1	1	2	2025-12-06 15:59:33.487515	2025-12-06 15:59:33.478949
1318	18	183	10	1	0	1	-1	2025-12-06 15:59:46.103142	2025-12-06 15:59:46.095962
1320	18	188	10	1	0	1	-1	2025-12-06 15:59:55.815724	2025-12-06 15:59:55.807646
1242	17	10	8	1	0	1	-1	2025-12-05 16:03:52.443747	2025-12-05 16:03:52.43758
1243	17	25	8	1	0	1	-1	2025-12-05 16:03:52.452381	2025-12-05 16:03:52.450055
1244	17	43	8	1	0	1	-1	2025-12-05 16:03:52.46007	2025-12-05 16:03:52.457092
1245	17	12	8	1	0	1	-1	2025-12-05 16:03:52.467747	2025-12-05 16:03:52.464793
1246	17	22	8	1	0	1	-1	2025-12-05 16:03:52.47445	2025-12-05 16:03:52.47195
1247	17	24	8	0	1	1	2	2025-12-05 16:03:52.482869	2025-12-05 16:03:52.479114
1248	17	42	8	1	0	1	-1	2025-12-05 16:03:52.491253	2025-12-05 16:03:52.488409
1322	18	168	10	1	0	1	-1	2025-12-06 16:00:06.02569	2025-12-06 16:00:06.010596
1252	2	31	8	2	1	3	0	2025-12-11 08:37:34.567204	2025-12-06 13:44:36.180261
1325	18	208	10	1	0	1	-1	2025-12-06 16:00:56.704871	2025-12-06 16:00:56.68997
1327	18	239	10	0	1	1	2	2025-12-06 16:01:04.928284	2025-12-06 16:01:04.919808
1232	2	24	8	2	0	2	-2	2025-12-11 08:38:08.015818	2025-12-05 15:36:23.37742
1330	18	199	10	1	0	1	-1	2025-12-06 16:01:33.230226	2025-12-06 16:01:33.222006
1229	2	21	8	2	0	2	-2	2025-12-11 08:38:33.111882	2025-12-05 15:35:42.179869
1228	2	39	8	1	3	4	5	2025-12-11 08:36:43.624927	2025-12-05 15:35:36.760066
1227	2	26	8	2	1	3	0	2025-12-11 08:39:14.899603	2025-12-05 15:35:28.75367
1239	2	38	8	2	1	3	0	2025-12-11 08:36:58.238402	2025-12-05 15:37:29.490787
1251	2	41	8	1	2	3	3	2025-12-11 08:36:51.166649	2025-12-06 13:44:14.342978
1235	2	44	8	2	2	4	2	2025-12-06 14:10:07.324641	2025-12-05 15:36:41.844696
1225	2	45	8	0	6	6	12	2025-12-11 08:40:16.052215	2025-12-05 15:35:15.110392
1236	2	49	8	3	3	6	3	2025-12-11 08:38:03.418648	2025-12-05 15:36:48.504309
1276	18	216	10	1	0	1	-1	2025-12-06 15:53:26.211336	2025-12-06 15:53:26.19867
1278	18	238	10	1	0	1	-1	2025-12-06 15:53:37.608326	2025-12-06 15:53:37.601386
1280	18	210	10	0	1	1	2	2025-12-06 15:53:54.042178	2025-12-06 15:53:54.032854
1282	18	234	10	0	1	1	2	2025-12-06 15:54:05.993853	2025-12-06 15:54:05.985973
1285	18	213	10	0	1	1	2	2025-12-06 15:54:52.40488	2025-12-06 15:54:52.396438
1287	18	209	10	1	0	1	-1	2025-12-06 15:55:11.741384	2025-12-06 15:55:11.732693
1289	18	240	10	1	0	1	-1	2025-12-06 15:55:30.319868	2025-12-06 15:55:30.31194
1291	18	174	10	1	0	1	-1	2025-12-06 15:55:42.608037	2025-12-06 15:55:42.593302
1293	18	229	10	1	0	1	-1	2025-12-06 15:55:57.927731	2025-12-06 15:55:57.919736
1294	18	179	10	1	0	1	-1	2025-12-06 15:56:21.953806	2025-12-06 15:56:21.945479
1296	18	258	10	1	0	1	-1	2025-12-06 15:56:34.183728	2025-12-06 15:56:34.175192
1298	18	167	10	1	0	1	-1	2025-12-06 15:56:48.736099	2025-12-06 15:56:48.727889
1300	18	250	10	0	1	1	2	2025-12-06 15:56:57.068369	2025-12-06 15:56:57.058808
1332	18	207	10	1	0	1	-1	2025-12-06 16:01:44.866881	2025-12-06 16:01:44.85963
1368	2	704	20	3	2	5	1	2025-12-11 08:31:00.983393	2025-12-07 07:18:02.453903
1231	2	16	8	2	1	3	0	2025-12-11 08:35:20.833437	2025-12-05 15:36:16.091708
1370	2	711	20	1	5	6	9	2025-12-11 08:30:40.761973	2025-12-07 07:18:14.574588
1426	2	365	12	1	3	4	5	2026-01-07 16:26:49.334808	2025-12-09 12:59:06.224844
1428	2	358	12	0	3	3	6	2026-01-03 15:43:40.786793	2025-12-09 12:59:29.908381
1387	2	347	12	1	0	1	-1	2025-12-09 12:53:23.402156	2025-12-09 12:53:23.369373
1436	2	336	12	0	2	2	4	2026-01-03 15:48:52.316147	2025-12-09 13:00:40.589353
1393	2	308	12	2	0	2	-2	2026-01-07 16:33:33.521397	2025-12-09 12:54:10.279998
1385	2	334	12	1	1	2	1	2026-01-03 15:37:17.526814	2025-12-09 12:53:08.755034
1414	2	378	12	0	3	3	6	2026-01-03 15:46:31.985662	2025-12-09 12:57:24.98207
1401	2	377	12	2	0	2	-2	2026-01-03 15:47:28.730401	2025-12-09 12:55:00.558427
1418	2	285	12	2	0	2	-2	2026-01-03 15:47:53.916431	2025-12-09 12:57:59.423085
1402	2	376	12	1	0	1	-1	2025-12-09 12:55:29.330084	2025-12-09 12:55:29.322946
1408	2	369	12	1	2	3	3	2026-01-07 16:32:46.162368	2025-12-09 12:56:08.133996
1434	2	366	12	2	0	2	-2	2026-01-03 15:36:20.778281	2025-12-09 13:00:21.607996
1440	2	343	12	1	1	2	1	2026-01-03 15:44:40.539162	2025-12-09 13:01:08.216209
1397	2	296	12	1	2	3	3	2026-01-07 16:28:13.103515	2025-12-09 12:54:34.439191
1432	2	346	12	1	1	2	1	2026-01-03 15:46:55.380238	2025-12-09 13:00:10.579759
1410	2	341	12	2	0	2	-2	2026-01-03 15:45:57.979175	2025-12-09 12:56:19.810852
1449	2	286	12	2	0	2	-2	2026-01-03 15:43:54.093179	2025-12-09 13:02:00.797254
1404	2	361	12	0	3	3	6	2026-01-03 15:48:01.137082	2025-12-09 12:55:42.502117
1420	2	300	12	1	0	1	-1	2025-12-09 12:58:13.327622	2025-12-09 12:58:13.259592
1416	2	335	12	2	0	2	-2	2026-01-03 15:43:47.574796	2025-12-09 12:57:47.234365
1424	2	284	12	3	0	3	-3	2026-01-07 16:27:18.302332	2025-12-09 12:58:56.214774
1395	2	315	12	2	0	2	-2	2026-01-03 15:37:06.065524	2025-12-09 12:54:23.979882
1371	2	709	20	2	0	2	-2	2025-12-10 07:47:34.300345	2025-12-07 07:18:19.495756
1412	2	349	12	0	4	4	8	2026-01-07 16:26:56.169729	2025-12-09 12:57:13.609116
1399	2	368	12	1	1	2	1	2026-01-03 15:47:02.193512	2025-12-09 12:54:45.101039
1422	2	357	12	0	3	3	6	2026-01-03 15:36:33.885	2025-12-09 12:58:39.924681
1438	2	320	12	2	0	2	-2	2026-01-03 15:48:57.772924	2025-12-09 13:00:50.622026
1383	2	345	12	2	0	2	-2	2026-01-03 15:49:11.726089	2025-12-09 12:52:56.207747
1430	2	352	12	2	0	2	-2	2026-01-03 15:44:51.868411	2025-12-09 12:59:47.347738
1391	2	306	12	2	0	2	-2	2026-01-07 16:32:55.129742	2025-12-09 12:53:47.591377
1453	2	373	12	1	1	2	1	2026-01-03 15:48:44.648161	2025-12-09 13:05:03.861052
1516	2	1381	35	1	0	1	-1	2026-01-13 14:24:41.284034	2026-01-13 14:24:41.275606
1526	2	1370	35	0	1	1	2	2026-02-01 15:16:09.4471	2026-02-01 15:16:09.438402
1464	2	282	12	3	0	3	-3	2026-01-07 16:26:38.593443	2025-12-09 13:06:14.61378
1451	2	317	12	1	2	3	3	2026-01-07 16:27:12.01357	2025-12-09 13:02:16.019878
1458	2	298	12	0	1	1	2	2025-12-09 13:05:33.536561	2025-12-09 13:05:33.526259
1452	2	332	12	2	0	2	-2	2026-01-07 16:27:26.772032	2025-12-09 13:04:22.416286
1462	2	359	12	0	3	3	6	2026-01-07 16:27:45.760096	2025-12-09 13:06:04.952338
1463	2	299	12	0	3	3	6	2026-01-07 16:27:57.243933	2025-12-09 13:06:09.724845
1465	2	348	12	1	1	2	1	2026-01-07 16:33:17.062919	2025-12-09 13:06:34.46103
1389	2	294	12	0	4	4	8	2026-01-07 16:33:29.680972	2025-12-09 12:53:34.217848
1455	2	360	12	2	0	2	-2	2026-01-07 16:33:45.78912	2025-12-09 13:05:16.177659
1528	2	1366	35	1	0	1	-1	2026-02-01 15:16:46.098455	2026-02-01 15:16:46.089662
1471	2	340	12	0	1	1	2	2025-12-09 13:10:26.742023	2025-12-09 13:10:26.733897
1490	2	860	23	4	1	5	-2	2025-12-10 14:20:59.737373	2025-12-10 08:45:32.212471
1082	2	48	8	1	6	7	11	2025-12-11 08:39:50.842212	2025-12-05 15:16:22.864533
1068	2	33	8	2	0	2	-2	2025-12-11 08:40:00.376687	2025-12-05 15:13:33.12366
1484	2	691	20	2	0	2	-2	2025-12-11 08:29:58.205181	2025-12-10 07:49:55.323928
1482	2	703	20	2	1	3	0	2025-12-11 08:30:07.053854	2025-12-10 07:49:14.14559
1499	2	864	23	5	1	6	-3	2025-12-10 15:15:13.013635	2025-12-10 08:54:54.647432
1469	2	313	12	2	0	2	-2	2026-01-03 15:36:28.364329	2025-12-09 13:07:49.731386
1466	2	329	12	1	1	2	1	2026-01-03 15:36:52.47319	2025-12-09 13:06:38.873702
1525	2	1375	35	1	0	1	-1	2026-02-01 15:15:48.785429	2026-02-01 15:15:48.774347
1460	2	322	12	2	0	2	-2	2026-01-03 15:39:10.333192	2025-12-09 13:05:50.204716
1476	2	698	20	1	4	5	7	2025-12-11 08:30:34.220287	2025-12-10 07:47:53.057714
1480	2	701	20	0	4	4	8	2025-12-11 08:30:49.096355	2025-12-10 07:49:03.47124
1510	2	866	23	1	0	1	-1	2025-12-10 13:59:32.215225	2025-12-10 13:59:32.204185
1454	2	304	12	2	0	2	-2	2026-01-03 15:43:58.150783	2025-12-09 13:05:11.20284
1483	2	708	20	1	3	4	5	2025-12-11 08:30:55.336843	2025-12-10 07:49:45.995621
1472	2	695	20	1	1	2	1	2025-12-10 14:00:09.322388	2025-12-10 07:47:03.168867
1386	2	333	12	1	2	3	3	2026-01-03 15:44:17.515899	2025-12-09 12:53:15.670655
1481	2	707	20	1	1	2	1	2025-12-10 14:00:42.901975	2025-12-10 07:49:08.474173
1477	2	690	20	1	1	2	1	2025-12-10 14:00:55.007285	2025-12-10 07:48:12.381195
1498	2	843	23	1	0	1	-1	2025-12-10 08:54:04.558776	2025-12-10 08:54:04.548167
1459	2	307	12	2	0	2	-2	2026-01-03 15:44:27.918623	2025-12-09 13:05:37.293473
1473	2	697	20	1	4	5	7	2025-12-11 08:31:10.776092	2025-12-10 07:47:20.387815
1509	2	841	23	1	3	4	5	2025-12-11 08:32:15.760393	2025-12-10 09:02:38.419477
1470	2	293	12	2	0	2	-2	2026-01-03 15:45:07.380635	2025-12-09 13:09:01.452413
1500	2	850	23	4	0	4	-4	2025-12-10 14:08:49.288625	2025-12-10 08:55:07.923733
1507	2	863	23	3	1	4	-1	2025-12-11 08:32:32.360445	2025-12-10 09:02:30.597284
1497	2	853	23	4	2	6	0	2025-12-11 08:32:45.152522	2025-12-10 08:48:35.305819
1492	2	842	23	5	2	7	-1	2025-12-11 08:32:53.11327	2025-12-10 08:46:27.698773
1501	2	856	23	4	4	8	4	2025-12-11 08:33:19.710451	2025-12-10 08:56:26.301594
1494	2	852	23	2	1	3	0	2025-12-10 08:56:29.058679	2025-12-10 08:47:28.286169
1468	2	288	12	2	0	2	-2	2026-01-03 15:45:32.9672	2025-12-09 13:07:41.9804
1487	2	859	23	2	1	3	0	2025-12-10 09:02:00.019618	2025-12-10 08:44:33.658106
1511	2	848	23	0	4	4	8	2025-12-11 08:33:35.657755	2025-12-10 14:09:47.274416
1461	2	380	12	2	1	3	0	2026-01-03 15:46:49.918109	2025-12-09 13:05:57.010806
1457	2	342	12	1	1	2	1	2026-01-03 15:47:10.621453	2025-12-09 13:05:28.934776
1502	2	861	23	3	3	6	3	2025-12-10 15:17:23.381195	2025-12-10 08:56:37.977239
1504	2	854	23	2	1	3	0	2025-12-10 13:51:45.60095	2025-12-10 08:58:47.660218
1495	2	851	23	2	1	3	0	2025-12-10 08:57:58.957435	2025-12-10 08:47:54.507891
1491	2	865	23	2	2	4	2	2025-12-11 08:33:56.272829	2025-12-10 08:46:07.261512
1489	2	862	23	5	3	8	1	2025-12-11 08:34:02.958974	2025-12-10 08:45:04.066133
1450	2	350	12	1	1	2	1	2026-01-03 15:47:18.564815	2025-12-09 13:02:08.493295
1508	2	847	23	2	1	3	0	2025-12-10 15:18:18.342568	2025-12-10 09:02:35.522621
1488	2	849	23	3	1	4	-1	2025-12-10 09:02:39.63963	2025-12-10 08:44:44.772753
1503	2	857	23	4	1	5	-2	2025-12-10 14:11:03.84201	2025-12-10 08:58:20.316327
1493	2	846	23	5	4	9	3	2025-12-10 15:18:48.949106	2025-12-10 08:46:46.4303
1505	2	855	23	3	1	4	-1	2025-12-10 14:11:31.530542	2025-12-10 09:00:13.783484
1512	2	858	23	0	2	2	4	2025-12-11 08:34:28.721779	2025-12-10 15:16:56.839508
1456	2	355	12	1	1	2	1	2026-01-03 15:48:13.82059	2025-12-09 13:05:22.083951
1486	2	702	20	2	0	2	-2	2025-12-11 08:28:21.55981	2025-12-10 07:50:18.252583
1478	2	693	20	2	1	3	0	2025-12-11 08:28:34.184755	2025-12-10 07:48:18.288872
1496	2	845	23	5	1	6	-3	2025-12-10 13:58:30.709597	2025-12-10 08:48:24.841416
1475	2	705	20	2	0	2	-2	2025-12-11 08:28:57.195908	2025-12-10 07:47:42.916061
1467	2	353	12	0	2	2	4	2026-01-03 15:48:24.847462	2025-12-09 13:06:46.567236
1521	2	1386	35	1	0	1	-1	2026-01-13 14:31:44.347638	2026-01-13 14:31:44.335392
1485	2	694	20	2	0	2	-2	2025-12-11 08:29:33.18911	2025-12-10 07:50:07.194726
1506	2	844	23	1	4	5	7	2025-12-11 08:34:51.311818	2025-12-10 09:02:10.341202
1514	2	1367	35	0	1	1	2	2026-01-13 14:24:24.963246	2026-01-13 14:24:24.949626
1513	2	1368	35	3	0	3	-3	2026-02-01 15:14:51.749593	2026-01-13 14:24:18.984851
1522	2	1372	35	1	1	2	1	2026-02-01 15:15:10.943585	2026-01-13 14:31:52.786997
1524	2	1369	35	0	1	1	2	2026-02-01 15:15:30.091369	2026-02-01 15:15:30.078808
1520	2	1383	35	2	0	2	-2	2026-02-01 15:15:40.434365	2026-01-13 14:25:14.891868
1517	2	1376	35	3	0	3	-3	2026-02-01 15:16:00.681868	2026-01-13 14:24:50.011647
1527	2	1373	35	1	0	1	-1	2026-02-01 15:16:16.349998	2026-02-01 15:16:16.340951
1519	2	1387	35	2	0	2	-2	2026-02-01 15:16:26.216379	2026-01-13 14:25:06.517446
1518	2	1371	35	2	0	2	-2	2026-02-01 15:16:39.280977	2026-01-13 14:24:58.228165
1529	2	1384	35	1	0	1	-1	2026-02-01 15:16:54.380446	2026-02-01 15:16:54.371219
1530	2	1374	35	1	0	1	-1	2026-02-01 15:18:38.590938	2026-02-01 15:18:38.582318
1531	2	1385	35	1	0	1	-1	2026-02-01 15:18:49.81717	2026-02-01 15:18:49.807182
1515	2	1380	35	2	0	2	-2	2026-02-01 15:18:58.158465	2026-01-13 14:24:32.916151
1532	2	1379	35	1	0	1	-1	2026-02-01 15:19:09.394697	2026-02-01 15:19:09.385019
1533	2	1378	35	1	0	1	-1	2026-02-01 15:19:16.334286	2026-02-01 15:19:16.326342
1534	2	1377	35	1	0	1	-1	2026-02-01 15:19:24.51172	2026-02-01 15:19:24.503866
1535	2	1382	35	2	0	2	-2	2026-02-01 15:19:34.540499	2026-02-01 15:19:34.102342
1536	2	1147	28	1	0	1	-1	2026-02-01 15:20:20.837148	2026-02-01 15:20:20.827392
1539	2	1137	28	1	0	1	-1	2026-02-01 15:20:41.23088	2026-02-01 15:20:41.224275
1540	2	1036	28	1	0	1	-1	2026-02-01 15:20:45.776779	2026-02-01 15:20:45.764547
1541	2	1087	28	1	0	1	-1	2026-02-01 15:20:51.37096	2026-02-01 15:20:51.359326
1542	2	1139	28	1	0	1	-1	2026-02-01 15:20:58.095982	2026-02-01 15:20:58.085101
1543	2	1086	28	1	0	1	-1	2026-02-01 15:21:04.053227	2026-02-01 15:21:04.041034
1545	2	1063	28	1	0	1	-1	2026-02-01 15:21:18.09822	2026-02-01 15:21:18.087147
1547	2	1138	28	1	0	1	-1	2026-02-01 15:21:52.27976	2026-02-01 15:21:52.271875
1548	2	1093	28	1	0	1	-1	2026-02-01 15:21:58.04318	2026-02-01 15:21:58.03102
1549	2	1108	28	1	0	1	-1	2026-02-01 15:22:05.17497	2026-02-01 15:22:05.165802
1550	2	1095	28	1	0	1	-1	2026-02-01 15:22:10.355079	2026-02-01 15:22:10.345164
1552	2	1128	28	1	0	1	-1	2026-02-01 15:22:21.874451	2026-02-01 15:22:21.861833
1553	2	1082	28	1	0	1	-1	2026-02-01 15:22:27.27612	2026-02-01 15:22:27.266533
1554	2	1114	28	1	0	1	-1	2026-02-01 15:22:32.762694	2026-02-01 15:22:32.751743
1555	2	1051	28	1	0	1	-1	2026-02-01 15:22:36.662148	2026-02-01 15:22:36.650937
1556	2	1116	28	1	0	1	-1	2026-02-01 15:22:41.671066	2026-02-01 15:22:41.65587
1557	2	1037	28	0	1	1	2	2026-02-01 15:22:46.408913	2026-02-01 15:22:46.400049
1558	2	1106	28	1	0	1	-1	2026-02-01 15:22:55.570851	2026-02-01 15:22:55.561057
1559	2	1038	28	1	0	1	-1	2026-02-01 15:23:01.218081	2026-02-01 15:23:01.208599
1560	2	1140	28	1	0	1	-1	2026-02-01 15:23:07.335877	2026-02-01 15:23:07.327384
1561	2	1053	28	1	0	1	-1	2026-02-01 15:23:18.978612	2026-02-01 15:23:18.965173
1562	2	1071	28	1	0	1	-1	2026-02-01 15:23:23.454398	2026-02-01 15:23:23.445823
1567	2	1136	28	1	0	1	-1	2026-02-01 15:24:01.538133	2026-02-01 15:24:01.528506
1568	2	1143	28	1	0	1	-1	2026-02-01 15:24:08.961262	2026-02-01 15:24:08.951304
1569	2	1076	28	1	0	1	-1	2026-02-01 15:24:15.052494	2026-02-01 15:24:15.042975
1571	2	1096	28	1	0	1	-1	2026-02-01 15:24:29.14804	2026-02-01 15:24:29.136701
1572	2	1109	28	0	1	1	2	2026-02-01 15:24:35.2953	2026-02-01 15:24:35.28417
1573	2	1123	28	0	1	1	2	2026-02-01 15:24:48.066151	2026-02-01 15:24:48.055169
1575	2	1134	28	1	0	1	-1	2026-02-01 15:25:01.100834	2026-02-01 15:25:01.092318
1576	2	1144	28	1	0	1	-1	2026-02-01 15:25:06.308236	2026-02-01 15:25:06.298919
1578	2	1146	28	0	1	1	2	2026-02-01 15:25:22.532506	2026-02-01 15:25:22.523542
1582	2	1121	28	1	0	1	-1	2026-02-01 15:26:04.000254	2026-02-01 15:26:03.991051
1584	2	1113	28	1	0	1	-1	2026-02-01 15:26:17.489093	2026-02-01 15:26:17.480153
1586	2	1072	28	1	0	1	-1	2026-02-01 15:26:32.266685	2026-02-01 15:26:32.256634
1544	2	1081	28	1	1	2	1	2026-02-01 15:32:36.034083	2026-02-01 15:21:12.247063
1564	2	1107	28	0	2	2	4	2026-02-01 15:34:24.308912	2026-02-01 15:23:36.399155
1565	2	1066	28	0	2	2	4	2026-02-01 15:36:21.165554	2026-02-01 15:23:45.716904
1566	2	1119	28	0	2	2	4	2026-02-01 15:38:24.861762	2026-02-01 15:23:55.713019
1546	2	1065	28	0	2	2	4	2026-02-01 15:39:01.935242	2026-02-01 15:21:37.897345
1580	2	1049	28	1	1	2	1	2026-02-01 15:39:19.652078	2026-02-01 15:25:47.47369
1656	2	1889	41	0	1	1	2	2026-02-13 08:06:31.313915	2026-02-13 08:06:31.303958
1583	2	1080	28	1	0	1	-1	2026-02-01 15:26:10.448192	2026-02-01 15:26:10.438832
1585	2	1127	28	1	0	1	-1	2026-02-01 15:26:26.625793	2026-02-01 15:26:26.612345
1588	2	1133	28	1	0	1	-1	2026-02-01 15:26:50.696198	2026-02-01 15:26:50.682771
1589	2	1045	28	1	0	1	-1	2026-02-01 15:26:56.646136	2026-02-01 15:26:56.634795
1590	2	1102	28	1	0	1	-1	2026-02-01 15:27:02.880025	2026-02-01 15:27:02.871663
1591	2	1059	28	1	0	1	-1	2026-02-01 15:27:27.705415	2026-02-01 15:27:27.695514
1657	2	1851	41	1	0	1	-1	2026-02-13 08:06:37.838637	2026-02-13 08:06:37.830458
1594	2	1125	28	0	1	1	2	2026-02-01 15:27:49.674724	2026-02-01 15:27:49.666132
1596	2	1067	28	1	0	1	-1	2026-02-01 15:28:00.535521	2026-02-01 15:28:00.525224
1597	2	1129	28	1	0	1	-1	2026-02-01 15:28:32.899763	2026-02-01 15:28:32.8901
1598	2	1078	28	0	1	1	2	2026-02-01 15:28:39.273541	2026-02-01 15:28:39.264036
1599	2	1120	28	1	0	1	-1	2026-02-01 15:28:47.281995	2026-02-01 15:28:47.272506
1600	2	1055	28	1	0	1	-1	2026-02-01 15:28:51.602763	2026-02-01 15:28:51.593018
1601	2	1122	28	1	0	1	-1	2026-02-01 15:29:02.24719	2026-02-01 15:29:02.236377
1602	2	1148	28	0	1	1	2	2026-02-01 15:29:09.303953	2026-02-01 15:29:09.29272
1603	2	1069	28	1	0	1	-1	2026-02-01 15:29:13.380082	2026-02-01 15:29:13.370267
1604	2	1052	28	1	0	1	-1	2026-02-01 15:29:18.436371	2026-02-01 15:29:18.42575
1605	2	1089	28	1	0	1	-1	2026-02-01 15:29:24.69258	2026-02-01 15:29:24.681871
1606	2	1124	28	1	0	1	-1	2026-02-01 15:29:29.060396	2026-02-01 15:29:29.051557
1607	2	1091	28	0	1	1	2	2026-02-01 15:29:41.124757	2026-02-01 15:29:41.115333
1608	2	1042	28	1	0	1	-1	2026-02-01 15:29:52.203014	2026-02-01 15:29:52.192861
1609	2	1084	28	1	0	1	-1	2026-02-01 15:29:58.528926	2026-02-01 15:29:58.521243
1610	2	1111	28	0	1	1	2	2026-02-01 15:30:37.659701	2026-02-01 15:30:37.650546
1611	2	1044	28	0	1	1	2	2026-02-01 15:30:51.11065	2026-02-01 15:30:51.103966
1612	2	1103	28	0	1	1	2	2026-02-01 15:31:20.756145	2026-02-01 15:31:20.74675
1613	2	1098	28	1	0	1	-1	2026-02-01 15:31:27.271229	2026-02-01 15:31:27.26148
1614	2	1101	28	0	1	1	2	2026-02-01 15:31:34.339013	2026-02-01 15:31:34.330637
1615	2	1132	28	0	1	1	2	2026-02-01 15:31:44.43308	2026-02-01 15:31:44.425341
1616	2	1126	28	1	0	1	-1	2026-02-01 15:31:49.651761	2026-02-01 15:31:49.642604
1617	2	1085	28	1	0	1	-1	2026-02-01 15:31:55.919672	2026-02-01 15:31:55.912263
1618	2	1046	28	1	0	1	-1	2026-02-01 15:31:59.399362	2026-02-01 15:31:59.321847
1619	2	1070	28	0	1	1	2	2026-02-01 15:32:08.514478	2026-02-01 15:32:08.505613
1620	2	1099	28	1	0	1	-1	2026-02-01 15:32:13.445043	2026-02-01 15:32:13.435175
1624	2	1040	28	1	0	1	-1	2026-02-01 15:32:46.724687	2026-02-01 15:32:46.714609
1625	2	1077	28	1	0	1	-1	2026-02-01 15:32:53.288946	2026-02-01 15:32:53.279624
1626	2	1039	28	1	0	1	-1	2026-02-01 15:32:58.090084	2026-02-01 15:32:58.081756
1627	2	1035	28	1	0	1	-1	2026-02-01 15:33:05.010878	2026-02-01 15:33:05.002636
1628	2	1130	28	1	0	1	-1	2026-02-01 15:33:12.217339	2026-02-01 15:33:12.206326
1631	2	1142	28	0	1	1	2	2026-02-01 15:34:28.973138	2026-02-01 15:34:28.957809
1632	2	1056	28	1	0	1	-1	2026-02-01 15:34:33.65239	2026-02-01 15:34:33.642028
1633	2	1131	28	0	1	1	2	2026-02-01 15:34:41.975187	2026-02-01 15:34:41.964144
1634	2	1097	28	1	0	1	-1	2026-02-01 15:34:49.143107	2026-02-01 15:34:49.130607
1635	2	1041	28	1	0	1	-1	2026-02-01 15:34:54.363939	2026-02-01 15:34:54.355454
1636	2	1079	28	1	0	1	-1	2026-02-01 15:35:01.127831	2026-02-01 15:35:01.120935
1637	2	1094	28	1	0	1	-1	2026-02-01 15:35:05.18989	2026-02-01 15:35:05.176931
1638	2	1149	28	1	0	1	-1	2026-02-01 15:35:12.45851	2026-02-01 15:35:12.448584
1639	2	1092	28	0	1	1	2	2026-02-01 15:35:25.307235	2026-02-01 15:35:25.298159
1640	2	1062	28	1	0	1	-1	2026-02-01 15:35:30.682106	2026-02-01 15:35:30.673966
1641	2	1141	28	0	1	1	2	2026-02-01 15:35:40.530535	2026-02-01 15:35:40.521886
1642	2	1118	28	1	0	1	-1	2026-02-01 15:35:46.861598	2026-02-01 15:35:46.852426
1643	2	1145	28	1	0	1	-1	2026-02-01 15:35:52.026511	2026-02-01 15:35:52.018193
1644	2	1064	28	1	0	1	-1	2026-02-01 15:35:57.814648	2026-02-01 15:35:57.805511
1645	2	1117	28	1	0	1	-1	2026-02-01 15:36:06.438856	2026-02-01 15:36:06.429586
1646	2	1135	28	1	0	1	-1	2026-02-01 15:36:11.262731	2026-02-01 15:36:11.25534
1647	2	1043	28	1	0	1	-1	2026-02-01 15:37:58.969995	2026-02-01 15:37:58.962231
1581	2	1110	28	0	2	2	4	2026-02-01 15:38:14.998922	2026-02-01 15:25:59.04589
1592	2	1068	28	0	2	2	4	2026-02-01 15:38:36.764726	2026-02-01 15:27:37.97373
1648	2	1088	28	1	0	1	-1	2026-02-01 15:38:43.2057	2026-02-01 15:38:43.19837
1649	2	1050	28	1	0	1	-1	2026-02-01 15:38:48.247162	2026-02-01 15:38:48.239712
1587	2	1104	28	1	1	2	1	2026-02-01 15:39:08.207591	2026-02-01 15:26:40.244296
1651	2	1862	41	0	1	1	2	2026-02-13 08:05:50.203237	2026-02-13 08:05:50.158874
1658	2	1898	41	0	2	2	4	2026-02-14 15:54:05.556405	2026-02-13 08:06:49.296072
1653	2	1904	41	1	0	1	-1	2026-02-13 08:06:09.288778	2026-02-13 08:06:09.278075
1654	2	1921	41	0	1	1	2	2026-02-13 08:06:17.503099	2026-02-13 08:06:17.491972
1655	2	1850	41	1	0	1	-1	2026-02-13 08:06:23.53932	2026-02-13 08:06:23.530747
1664	2	1911	41	0	2	2	4	2026-02-14 15:54:20.533255	2026-02-13 08:07:26.994282
1659	2	1912	41	1	0	1	-1	2026-02-13 08:06:53.979203	2026-02-13 08:06:53.969663
1652	2	1893	41	0	2	2	4	2026-02-14 15:53:52.562896	2026-02-13 08:06:02.479698
1661	2	1896	41	0	1	1	2	2026-02-13 08:07:06.371043	2026-02-13 08:07:06.359535
1662	2	1925	41	0	1	1	2	2026-02-13 08:07:13.613136	2026-02-13 08:07:13.604199
1663	2	1890	41	0	1	1	2	2026-02-13 08:07:21.261721	2026-02-13 08:07:21.253295
1665	2	1874	41	0	1	1	2	2026-02-13 08:07:34.360264	2026-02-13 08:07:34.350664
1666	2	1828	41	1	0	1	-1	2026-02-13 08:07:45.130792	2026-02-13 08:07:45.121814
1667	2	1831	41	1	0	1	-1	2026-02-13 08:07:51.630417	2026-02-13 08:07:51.621692
1668	2	1906	41	0	1	1	2	2026-02-13 08:08:00.507993	2026-02-13 08:08:00.498484
1669	2	1884	41	0	1	1	2	2026-02-13 08:08:06.982419	2026-02-13 08:08:06.973075
1670	2	1864	41	0	1	1	2	2026-02-13 08:08:18.817244	2026-02-13 08:08:18.808858
1671	2	1910	41	1	0	1	-1	2026-02-13 08:08:26.708855	2026-02-13 08:08:26.698487
1672	2	1845	41	1	0	1	-1	2026-02-13 08:08:33.040236	2026-02-13 08:08:33.032015
1673	2	1929	41	0	1	1	2	2026-02-13 08:08:40.128765	2026-02-13 08:08:40.12024
1660	2	1879	41	0	2	2	4	2026-02-14 15:53:37.789004	2026-02-13 08:07:01.296291
1674	2	1934	41	1	0	1	-1	2026-02-13 08:08:50.423979	2026-02-13 08:08:50.405269
1675	2	1827	41	1	0	1	-1	2026-02-13 08:08:56.011774	2026-02-13 08:08:56.001017
1676	2	1867	41	1	0	1	-1	2026-02-13 08:09:03.174416	2026-02-13 08:09:03.166142
1677	2	1924	41	0	1	1	2	2026-02-13 08:09:11.912575	2026-02-13 08:09:11.902403
1678	2	1894	41	0	1	1	2	2026-02-13 08:09:19.853972	2026-02-13 08:09:19.845437
1679	2	1838	41	2	0	2	-2	2026-02-13 08:09:28.903103	2026-02-13 08:09:28.344515
1680	2	1888	41	0	1	1	2	2026-02-13 08:09:38.021022	2026-02-13 08:09:38.011009
1681	2	1840	41	1	0	1	-1	2026-02-13 08:09:43.740253	2026-02-13 08:09:43.730308
1682	2	1846	41	0	1	1	2	2026-02-13 08:09:49.44556	2026-02-13 08:09:49.437582
1683	2	1830	41	2	0	2	-2	2026-02-14 15:53:16.919149	2026-02-14 15:53:16.280032
1684	2	1843	41	0	1	1	2	2026-02-14 15:53:21.783285	2026-02-14 15:53:21.771223
1685	2	1901	41	0	1	1	2	2026-02-14 15:53:27.644081	2026-02-14 15:53:27.635022
1686	2	1834	41	1	0	1	-1	2026-02-14 15:53:32.667602	2026-02-14 15:53:32.657933
1687	2	1860	41	1	0	1	-1	2026-02-14 15:53:56.56267	2026-02-14 15:53:56.54648
1688	2	1920	41	1	0	1	-1	2026-02-14 15:54:15.035694	2026-02-14 15:54:15.024647
\.


--
-- Data for Name: cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.cards (card_pk, id_json, deck_pk, front, back, pronunciation, image, created_at, box, next_review, tags, easiness, "interval", consecutive_correct, last_reviewed_at, definition, explanation_it, translation_en, translation_de, translation_mg, example) FROM stdin;
255	dd3f45e	10	Silencieux	Silenzioso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f507.svg	2025-12-03 13:40:51.049143	0	2025-12-06 16:02:21.998588	{adjectif,italien,fréquent,bruit}	2.3	0	0	\N	\N	\N	Silent	Still	Mangina	\N
256	2aecdb5	10	Large	Largo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2194.svg	2025-12-03 13:40:51.068398	1	2025-12-07 15:54:44.131558	{adjectif,italien,fréquent,taille}	2.6	1	1	\N	\N	\N	Wide	Breit	MANERAN-	\N
258	e1bde29	10	Profond	Profondo		\N	2025-12-03 13:40:51.110067	1	2025-12-07 15:56:34.186981	{adjectif,italien,fréquent,taille}	2.6	1	1	\N	\N	\N	Deep	Tief	lalina	\N
13	2a832a4	8	Se réveiller	Svegliarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23f0.svg	2025-12-03 13:28:05.876803	2	2025-12-17 08:40:24.484057	{verbe,italien,pronominal,quotidien}	2.7	6	2	2025-12-06 08:43:27.303033+03	\N	Uscire dal sonno.	To wake up	Aufwachen	Mifoha	Mi sveglio sempre alle 7:00.
18	a7c5c5e	8	Se souvenir	Ricordarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-03 13:28:05.976974	2	2025-12-17 08:40:07.190964	{verbe,italien,pronominal,mémoire}	2.1	6	2	2025-12-06 08:43:27.304739+03	\N	Tenere a mente qualcosa.	To remember	Sich erinnern	Mahatsiaro	Ti ricordi di chiudere la porta?
627	5b1d47e	18	Livreur	Corriere		\N	2025-12-07 06:20:59.133895	0	2025-12-08 06:20:59.133895	{métier,italien}	2.5	0	0	\N	\N	Chi trasporta e consegna pacchi o posta.	Courier	Kurier	Mpitondra entana	Il corriere ha appena consegnato il pacco.
628	59c3265	18	Électricien	Elettricista		\N	2025-12-07 06:20:59.152579	0	2025-12-08 06:20:59.152579	{métier,italien}	2.5	0	0	\N	\N	Tecnico che installa e ripara impianti elettrici.	Electrician	Elektriker	Elektrisianina	Abbiamo chiamato l'elettricista per il guasto.
629	391df6d	18	Plombier	Idraulico		\N	2025-12-07 06:20:59.171088	0	2025-12-08 06:20:59.171088	{métier,italien}	2.5	0	0	\N	\N	Tecnico che ripara tubature e impianti sanitari.	Plumber	Klempner / Installateur	Plombier	L'idraulico ha riparato il rubinetto che perdeva.
1076	9c1c757	28	Gaz	Gas		\N	2026-01-08 15:19:18.797155	1	2026-02-02 15:24:15.055551	{nom,italien,énergie}	2.6	1	1	\N	\N	Stato della materia, combustibile.	Gas	Gas	Entona / Gaz	Cuciniamo con il fornello a gas.
1078	7cdc424	28	Réduire	Ridurre		\N	2026-01-08 15:19:18.845164	0	2026-02-01 15:38:39.277721	{verbe,italien,action}	2.3	0	0	\N	\N	Rendere minore in quantità o dimensione.	To reduce	Reduzieren	Mampihena	Dobbiamo ridurre gli sprechi.
1080	e5456e8	28	Protéger	Proteggere		\N	2026-01-08 15:19:19.737376	1	2026-02-02 15:26:10.451355	{verbe,italien,conservation}	2.6	1	1	\N	\N	Difendere da un pericolo o danno.	To protect	Schützen	Miaro	Bisogna proteggere l'ambiente.
1077	9d4c23c	28	Émissions	Emissioni		\N	2026-01-08 15:19:18.822103	1	2026-02-02 15:32:53.291722	{nom,italien,climat}	2.6	1	1	\N	\N	\N	Emissions	Emissionen	famokarana entona	\N
1079	2992bbf	28	Économiser	Risparmiare		\N	2026-01-08 15:19:19.711338	1	2026-02-02 15:35:01.129783	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Save	Speichern	afa-tsy	\N
263	26d8915	10	Désert	Deserto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3dc.svg	2025-12-03 13:40:51.215181	1	2025-12-07 15:54:00.582074	{adjectif,italien,fréquent,fréquence}	2.6	1	1	\N	\N	\N	Desert	Wüste	EFITRA	\N
264	878c701	10	Chaotique	Caotico		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f300.svg	2025-12-03 13:40:51.235833	1	2025-12-07 15:55:20.746116	{adjectif,italien,fréquent,organisation}	2.6	1	1	\N	\N	\N	Chaotic	Chaotisch	mikorontana	\N
265	f0c91ed	10	Organisé	Organizzato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c1.svg	2025-12-03 13:40:51.25741	0	2025-12-04 13:40:51.25741	{adjectif,italien,fréquent,organisation}	2.5	0	0	\N	\N	\N	Organized	Organisiert	VOALAMINA	\N
266	349dc21	10	Ordinaire	Ordinario		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c4.svg	2025-12-03 13:40:51.281302	1	2025-12-07 15:47:38.60081	{adjectif,italien,fréquent,qualité}	2.6	1	1	\N	\N	\N	Ordinary	Normal	tsotra	\N
32	befe61d	8	Se relaxer	Rilassarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9d8.svg	2025-12-03 13:28:06.265428	2	2025-12-17 08:36:16.915056	{verbe,italien,pronominal,repos}	2.7	6	2	2025-12-06 08:43:27.304934+03	\N	Riposarsi, sciogliere la tensione.	To relax	Sich entspannen	Miala sasatra	Nel weekend mi piace rilassarmi leggendo un libro.
37	f162833	8	Se raser	Radersi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fa92.svg	2025-12-03 13:28:06.361647	2	2025-12-17 08:39:36.178612	{verbe,italien,pronominal,hygiène}	2.5	6	2	2025-12-06 08:43:27.304977+03	\N	Tagliare la barba o i peli.	To shave	Sich rasieren	Miharatra	Si rade ogni mattina prima di andare al lavoro.
38	602a9f1	8	Se sécher	Asciugarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9f9.svg	2025-12-03 13:28:06.380698	2	2025-12-17 08:36:58.256403	{verbe,italien,pronominal,hygiène}	2.7	6	2	2025-12-06 08:43:27.305019+03	\N	Togliere l'acqua o l'umidità dal corpo.	To dry oneself	Sich abtrocknen	Hamaina	Usa l'asciugamano per asciugarti.
15	7fdea89	8	Se coucher	Coricarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6cc.svg	2025-12-03 13:28:05.916027	0	2025-12-11 08:48:57.590621	{verbe,italien,pronominal,quotidien}	2.4	0	0	2025-12-06 08:43:27.304609+03	\N	Andare a letto, sdraiarsi.	To go to bed	Zu Bett gehen	Mandry / Matory	È tardi, vado a coricarmi.
19	e66b73c	8	Se préparer	Prepararsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f45c.svg	2025-12-03 13:28:05.996414	2	2025-12-17 08:35:33.487487	{verbe,italien,pronominal,quotidien}	2.7	6	2	2025-12-06 08:43:27.304788+03	\N	Mettersi pronto per fare qualcosa.	To get ready	Sich vorbereiten	Miomana	Devo prepararmi per uscire.
29	412fcbb	8	Se peigner	Pettinarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9d1-200d-1f9b0.svg	2025-12-03 13:28:06.203815	2	2025-12-17 08:36:36.092748	{verbe,italien,pronominal,hygiène}	2.7	6	2	2025-12-06 08:43:27.304842+03	\N	Ordinare i capelli con il pettine.	To comb one's hair	Sich kämmen	Mibango volo	Si pettina davanti allo specchio.
31	a981595	8	Se fâcher	Arrabbiarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f621.svg	2025-12-03 13:28:06.246305	2	2025-12-17 08:37:34.570502	{verbe,italien,pronominal,émotion}	2.5	6	2	2025-12-06 08:43:27.30489+03	\N	Diventare furioso o irritato.	To get angry	Wütend werden	Tezitra	Non arrabbiarti per queste sciocchezze.
558	ea7a627	17	L’oncle	Lo zio		\N	2025-12-07 06:08:35.243468	0	2025-12-08 06:08:35.243468	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The uncle	Der Onkel	Ny dadatoa	\N
11	b9206cc	8	S'appeler	Chiamarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4db.svg	2025-12-03 13:28:05.837499	1	2025-12-17 08:35:39.427386	{verbe,italien,pronominal,identité}	2.7	6	2	\N	\N	\N	Call yourself	Rufen Sie sich selbst an	Miantso ny tenanao	\N
14	e255084	8	Se laver	Lavarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6bf.svg	2025-12-03 13:28:05.896092	1	2025-12-17 08:35:27.179	{verbe,italien,pronominal,hygiène}	2.7	6	2	\N	\N	\N	Wash	Waschen	sasao madio	\N
43	b932961	8	S'effrayer	Spaventarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f628.svg	2025-12-03 13:28:06.478482	2	2025-12-17 08:35:54.988256	{verbe,italien,pronominal,émotion}	2.6	6	2	\N	\N	\N	Get scared	Hab Angst	Matahotra	\N
44	32f9a93	8	Se repentir	Pentirsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f614.svg	2025-12-03 13:28:06.496927	2	2025-12-12 14:10:07.328595	{verbe,italien,pronominal,émotion}	2.5	6	2	\N	\N	\N	Repent	Bereuen	Mibebaha	\N
47	506ffec	8	Se déconnecter	Scollegarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6ab.svg	2025-12-03 13:28:06.553646	3	2025-12-29 08:40:37.652235	{verbe,italien,pronominal,technologie}	2.4	18	3	\N	\N	\N	Disconnect	Trennen	elektrônika	\N
49	32ebaa1	8	Se nourrir	Nutrirsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f374.svg	2025-12-03 13:28:06.790716	2	2025-12-17 08:38:03.421733	{verbe,italien,pronominal,vie}	2.6	6	2	\N	\N	\N	Feeding	Füttern	sakafo	\N
55	f3448ea	9	Venir	Venire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6b6.svg	2025-12-03 13:33:22.608966	1	2025-12-08 07:06:07.328716	{verbe,italien,fréquent,mouvement}	2.6	1	1	\N	\N	\N	Come	Kommen	AVY	\N
58	4f5f3d3	9	Parler	Parlare		\N	2025-12-03 13:33:22.662312	0	2025-12-04 13:33:22.662312	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Speak	Sprechen	Mitenena	\N
66	57aa075	9	Laisser	Lasciare		\N	2025-12-03 13:33:22.827916	0	2025-12-04 13:33:22.827916	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Leave	Verlassen	fialan-tsasatra	\N
644	b654d47	19	Chat	Gatto		\N	2025-12-07 06:26:42.526961	0	2025-12-08 06:26:42.526961	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Cat	Katze	Cat	\N
40	5e424fe	8	Se blesser	Ferirsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fa78.svg	2025-12-03 13:28:06.420948	0	2025-12-11 08:48:21.156226	{verbe,italien,pronominal,santé}	2.1999999999999997	0	0	\N	\N	\N	Getting hurt	Sich verletzen	Maratra	\N
41	93baa18	8	Se cacher	Nascondersi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f978.svg	2025-12-03 13:28:06.440111	1	2025-12-12 08:36:51.16973	{verbe,italien,pronominal,mouvement}	2.2	1	1	\N	\N	\N	Hide	Verstecken	afeno ny	\N
45	873abb0	8	Se rendre compte	Accorgersi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4a1.svg	2025-12-03 13:28:06.516344	0	2025-12-11 08:50:16.054576	{verbe,italien,pronominal,réflexion}	1.6999999999999997	0	0	\N	\N	\N	Notice	Beachten	Mariho	\N
46	c4e2d2c	8	Se connecter	Collegarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f50c.svg	2025-12-03 13:28:06.534968	2	2025-12-17 08:38:27.462643	{verbe,italien,pronominal,technologie}	2.7	6	2	\N	\N	\N	Connect	Verbinden	Connect	\N
48	c174d14	8	S'embarrasser	Imbarazzarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f633.svg	2025-12-03 13:28:06.732734	1	2025-12-12 08:39:50.845218	{verbe,italien,pronominal,émotion}	1.6	1	1	\N	\N	\N	Get embarrassed	Lass dich verlegen	Menatra	\N
57	fb15b2a	9	Trouver	Trovare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f50d.svg	2025-12-03 13:33:22.642988	0	2025-12-04 13:33:22.642988	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Find	Finden	hitady	\N
59	c91fd06	9	Demander	Chiedere		\N	2025-12-03 13:33:22.680849	0	2025-12-04 13:33:22.680849	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Ask	Fragen	Anontanio	\N
63	99ababe	9	Comprendre	Capire		\N	2025-12-03 13:33:22.766288	0	2025-12-04 13:33:22.766288	{verbe,italien,fréquent,cognition}	2.5	0	0	\N	\N	\N	Understand	Verstehen	Fantaro	\N
65	15604c3	9	Prendre	Prendere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/270b.svg	2025-12-03 13:33:22.806076	1	2025-12-08 07:01:17.690942	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	Take	Nehmen	Raiso	\N
67	6e33145	9	Entrer	Entrare		\N	2025-12-03 13:33:22.848005	0	2025-12-04 13:33:22.848005	{verbe,italien,fréquent,mouvement}	2.5	0	0	\N	\N	\N	Enter	Eingeben	Ampidiro	\N
16	dc6e905	8	S'habiller	Vestirsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f455.svg	2025-12-03 13:28:05.935635	1	2025-12-17 08:35:20.836599	{verbe,italien,pronominal,quotidien}	2.7	6	2	\N	\N	\N	Get dressed	Zieh dich an	Miakanjo	\N
20	c0c8d7d	8	S'asseoir	Sedersi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fa91.svg	2025-12-03 13:28:06.016041	1	2025-12-17 08:35:44.531647	{verbe,italien,pronominal,mouvement}	2.7	6	2	\N	\N	\N	Sit	Sitzen	fitorevahana	\N
574	f0deb6c	17	La belle-sœur	La cognata		\N	2025-12-07 06:08:35.729006	0	2025-12-08 06:08:35.729006	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The sister-in-law	Die Schwägerin	Ny zaodahiny	\N
808	4b93545	22	Muovere	Mosso		\N	2025-12-08 16:20:08.21588	0	2025-12-09 16:20:08.21588	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Moved	Verschoben	nafindra	\N
2270	e3f1c38	61	Massage	Massaggio		\N	2026-02-24 15:13:49.721869	0	2026-02-25 15:13:49.721869	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Manipolazione dei tessuti per favorire il recupero.	Massage	Massage	Massage	Il massaggio scioglie i muscoli contratti.
1932	8831a37	41	être arrogant	tirarsela		\N	2026-02-08 07:05:08.544212	0	2026-02-09 07:05:08.544212	{}	2.5	0	0	\N	\N	Darsi un tono di superiorità	to show off / to act superior	angeben	miezaka miavonavona	Da quando è direttore se la tira tantissimo.
2271	93bfa3b	61	Étirement	Allungamento		\N	2026-02-24 15:13:56.629416	0	2026-02-25 15:13:56.629416	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Esercizio per allungare i muscoli dopo l'attività.	Stretching	Dehnen	Fanitarana	L'allungamento finale è obbligatorio.
1903	6d5abc4	41	y faire attention	badarci		\N	2026-02-06 15:39:14.101049	0	2026-02-07 15:39:14.101049	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Prestare attenzione a qualcosa	to pay attention to it	darauf achten	mitandrina amin'izany	Non ci bado alle critiche negative.
2272	8f43c98	61	Détente	Distensione		\N	2026-02-24 15:14:03.410594	0	2026-02-25 15:14:03.410594	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Stato di riduzione della tensione.	Relaxation	Entspannung	Fandrenesana	La distensione aiuta il sonno profondo.
89	db6eec8	9	Espérer	Sperare		\N	2025-12-03 13:33:23.512234	0	2025-12-04 13:33:23.512234	{verbe,italien,fréquent,émotion}	2.5	0	0	\N	\N	\N	Hope	Hoffnung	FANANTENANA	\N
97	2daef22	9	Choisir	Scegliere		\N	2025-12-03 13:33:23.683229	0	2025-12-04 13:33:23.683229	{verbe,italien,fréquent,décision}	2.5	0	0	\N	\N	\N	Choose	Wählen	Mifidiana	\N
77	0156dec	9	Ouvrir	Aprire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f513.svg	2025-12-03 13:33:23.096734	0	2025-12-04 13:33:23.096734	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Open	Offen	Misokatra	\N
78	c93f5ca	9	Fermer	Chiudere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f512.svg	2025-12-03 13:33:23.119069	0	2025-12-04 13:33:23.119069	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Close	Schließen	AKAIKY	\N
81	cd75da6	9	Acheter	Comprare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6d2.svg	2025-12-03 13:33:23.351733	0	2025-12-04 13:33:23.351733	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Buy	Kaufen	Buy	\N
82	5296859	9	Vendre	Vendere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4b0.svg	2025-12-03 13:33:23.372661	0	2025-12-04 13:33:23.372661	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Sell	Verkaufen	mivarotra	\N
83	5b222fb	9	Conduire	Guidare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f697.svg	2025-12-03 13:33:23.392598	0	2025-12-04 13:33:23.392598	{verbe,italien,fréquent,mouvement}	2.5	0	0	\N	\N	\N	Guide	Führung	Torolalana	\N
84	598cf72	9	Étudier	Studiare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4d6.svg	2025-12-03 13:33:23.411888	0	2025-12-04 13:33:23.411888	{verbe,italien,fréquent,éducation}	2.5	0	0	\N	\N	\N	Study	Studie	FIANARANA	\N
88	c9c5639	9	Aider	Aiutare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f91d.svg	2025-12-03 13:33:23.492903	0	2025-12-04 13:33:23.492903	{verbe,italien,fréquent,social}	2.5	0	0	\N	\N	\N	Help	Helfen	Vonjeo	\N
68	242f781	9	Sortir	Uscire		\N	2025-12-03 13:33:22.867599	0	2025-12-04 13:33:22.867599	{verbe,italien,fréquent,mouvement}	2.5	0	0	\N	\N	\N	Go out	Hinausgehen	Mivoaka	\N
75	ab508c2	9	Écrire	Scrivere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/270d.svg	2025-12-03 13:33:23.045147	0	2025-12-07 07:15:38.39602	{verbe,italien,fréquent,communication}	2.3	0	0	\N	\N	\N	Write	Schreiben	soraty	\N
79	85ed653	9	Courir	Correre		\N	2025-12-03 13:33:23.285135	0	2025-12-04 13:33:23.285135	{verbe,italien,fréquent,mouvement}	2.5	0	0	\N	\N	\N	Run	Laufen	mihazakazaka	\N
80	bc0545b	9	Marcher	Camminare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6b6.svg	2025-12-03 13:33:23.329765	1	2025-12-08 07:03:19.178718	{verbe,italien,fréquent,mouvement}	2.6	1	1	\N	\N	\N	Walk	Gehen	MANDEHANA	\N
86	48a55bf	9	Se souvenir	Ricordare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-03 13:33:23.452352	1	2025-12-08 07:01:35.416994	{verbe,italien,fréquent,cognition}	2.6	1	1	\N	\N	\N	Remember	Erinnern	Tsarovy	\N
90	f12950d	9	Rester	Restare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3e0.svg	2025-12-03 13:33:23.536056	1	2025-12-08 07:05:26.852507	{verbe,italien,fréquent,mouvement}	2.6	1	1	\N	\N	\N	Remain	Bleiben	Mitoera	\N
92	17ed5be	9	Passer	Passare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23e9.svg	2025-12-03 13:33:23.581009	0	2025-12-07 07:13:13.786329	{verbe,italien,fréquent,mouvement}	2.3	0	0	\N	\N	\N	Pass	Passieren	nitranga	\N
93	1c23813	9	Attendre	Aspettare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23f3.svg	2025-12-03 13:33:23.605148	1	2025-12-08 07:03:28.834647	{verbe,italien,fréquent,vie}	2.6	1	1	\N	\N	\N	Wait	Warten	miandry	\N
95	0764b41	9	Mourir	Morire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/26b0.svg	2025-12-03 13:33:23.646696	0	2025-12-04 13:33:23.646696	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Die	Sterben	maty	\N
697	69dfc3a	20	Griller	Grigliare		\N	2025-12-07 06:31:34.329663	1	2025-12-12 08:31:10.778656	{cuisine,italien}	1.8	1	1	\N	\N	\N	Grilling	Grillen	Grilling	\N
2433	969b41a	63	Numérisation	Digitalizzazione		\N	2026-02-24 15:50:57.67745	0	2026-02-25 15:50:57.67745	{science,numérique,information}	2.5	0	0	\N	\N	Conversione di informazioni analogiche in formato digitale.	Digitization	Digitalisierung	Numérisation	La digitalizzazione ha reso i documenti accessibili.
2434	bd8bf84	63	Intelligence artificielle	Intelligenza artificiale		\N	2026-02-24 15:51:04.064595	0	2026-02-25 15:51:04.064595	{science,numérique,information}	2.5	0	0	\N	\N	Capacità di una macchina di simulare l'intelligenza umana.	Artificial intelligence	Künstliche Intelligenz	Intelligence artificielle	L'intelligenza artificiale sta cambiando il mondo.
112	0bc9622	9	Réparer	Riparare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6e0.svg	2025-12-03 13:33:23.967935	1	2025-12-08 07:05:45.941353	{verbe,italien,fréquent,maison}	2.6	1	1	\N	\N	\N	Repair	Reparieren	FANAMBOARANA NY SIMBA	\N
116	d34cd15	9	Photographier	Fotografare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4f7.svg	2025-12-03 13:33:24.048096	1	2025-12-08 07:05:09.1512	{verbe,italien,fréquent,loisir}	2.6	1	1	\N	\N	\N	Photographing	Fotografieren	sary	\N
121	e3f0e86	9	Organiser	Organizzare		\N	2025-12-03 13:33:24.147722	0	2025-12-04 13:33:24.147722	{verbe,italien,fréquent,travail}	2.5	0	0	\N	\N	\N	Organize	Organisieren	Mandamina	\N
98	544be1e	9	Préférer	Preferire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44d.svg	2025-12-03 13:33:23.70222	0	2025-12-04 13:33:23.70222	{verbe,italien,fréquent,décision}	2.5	0	0	\N	\N	\N	Prefer	Bevorzugen	kokoa	\N
104	eada5f0	9	Pleurer	Piangere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f622.svg	2025-12-03 13:33:23.8165	0	2025-12-04 13:33:23.8165	{verbe,italien,fréquent,émotion}	2.5	0	0	\N	\N	\N	Cry	Weinen	Miantsoa	\N
105	ff48fdc	9	Jouer	Giocare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3ae.svg	2025-12-03 13:33:23.834992	0	2025-12-04 13:33:23.834992	{verbe,italien,fréquent,loisir}	2.5	0	0	\N	\N	\N	Play	Spielen	Play	\N
106	eaf1fcf	9	Chanter	Cantare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3a4.svg	2025-12-03 13:33:23.853159	0	2025-12-04 13:33:23.853159	{verbe,italien,fréquent,loisir}	2.5	0	0	\N	\N	\N	Sing	Singen	Mihirà	\N
109	ddd4452	9	Cuisiner	Cucinare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f373.svg	2025-12-03 13:33:23.909874	0	2025-12-04 13:33:23.909874	{verbe,italien,fréquent,maison}	2.5	0	0	\N	\N	\N	Cooked	Gekocht	masaka	\N
110	c310e36	9	Couper	Tagliare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2702.svg	2025-12-03 13:33:23.929398	0	2025-12-04 13:33:23.929398	{verbe,italien,fréquent,maison}	2.5	0	0	\N	\N	\N	Cut	Schneiden	Hetezo	\N
107	9329dc8	9	Danser	Ballare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f483.svg	2025-12-03 13:33:23.871735	1	2025-12-08 07:03:56.624645	{verbe,italien,fréquent,loisir}	2.6	1	1	\N	\N	\N	Dance	Tanzen	mandihy	\N
108	d08c9e3	9	Nettoyer	Pulire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9f9.svg	2025-12-03 13:33:23.890458	1	2025-12-08 07:03:42.291845	{verbe,italien,fréquent,maison}	2.6	1	1	\N	\N	\N	Clean	Sauber	MADIO	\N
119	35fe2f7	9	Répondre	Rispondere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e2.svg	2025-12-03 13:33:24.106139	0	2025-12-04 13:33:24.106139	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Answer	Antwort	Valio	\N
120	a2d0a00	9	Inviter	Invitare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f39f.svg	2025-12-03 13:33:24.128782	0	2025-12-04 13:33:24.128782	{verbe,italien,fréquent,social}	2.5	0	0	\N	\N	\N	Invite	Einladen	Asao	\N
122	4e9b03d	9	Planifier	Pianificare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5d3.svg	2025-12-03 13:33:24.167312	0	2025-12-04 13:33:24.167312	{verbe,italien,fréquent,travail}	2.5	0	0	\N	\N	\N	Plan	Planen	ALAMINO MIALOHA	\N
123	8435d26	9	Commencer	Iniziare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/25b6.svg	2025-12-03 13:33:24.187323	0	2025-12-07 07:11:22.56276	{verbe,italien,fréquent,action}	2.3	0	0	\N	\N	\N	Start	Start	fanombohana	\N
124	ab62b8f	9	Finir	Finire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23f9.svg	2025-12-03 13:33:24.206643	1	2025-12-08 07:03:46.649573	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	Finish	Beenden	farany	\N
125	e0a93d6	9	Continuer	Continuare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/27a1.svg	2025-12-03 13:33:24.226601	0	2025-12-04 13:33:24.226601	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Continue	Weitermachen	FOANA	\N
126	d5d9e16	9	Arrêter	Fermare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/26d4.svg	2025-12-03 13:33:24.246	1	2025-12-08 07:03:51.736514	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	Stop	Stoppen	Mijanòna	\N
847	cf713fb	23	Che lavoro faceva sua madre?	Sua madre lavorava in una fabbrica di tessuti.		\N	2025-12-10 08:41:45.248852	1	2025-12-11 15:18:18.344919	{italien,A2,métiers,"Roberto Benigni"}	2.5	1	1	\N	\N	\N	His mother worked in a textile factory.	Seine Mutter arbeitete in einer Textilfabrik.	Niasa tao amin’ny orinasa lamba ny reniny.	\N
28	835c5be	8	Se brosser	Spazzolarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1faa5.svg	2025-12-03 13:28:06.181933	1	2025-12-12 12:47:53.392228	{verbe,italien,pronominal,hygiène}	2.7	6	2	\N	\N	\N	Brushing	Bürsten	miborosy	\N
30	8acc49d	8	Se tromper	Sbagliarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/274c.svg	2025-12-03 13:28:06.226763	1	2025-12-12 09:01:48.585778	{verbe,italien,pronominal,erreur}	2.7	6	2	\N	\N	\N	Be wrong	Liegen Sie falsch	Aoka ho diso	\N
137	993cd9c	9	Partager	Condividere		\N	2025-12-03 13:33:24.459526	0	2025-12-04 13:33:24.459526	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Share	Aktie	anjara	\N
1035	5d77310	28	Substituer	Sostituire		\N	2026-01-08 15:19:17.628889	1	2026-02-02 15:33:05.01384	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Substitute	Ersatz	mpisolo toerana	\N
1101	5825059	28	Surchauffe	Surriscaldamento		\N	2026-01-08 15:19:20.357437	0	2026-02-01 15:41:34.342294	{nom,italien,climat}	2.3	0	0	\N	\N	\N	Overheating	Überhitzung	Mihoatra ny hafanana	\N
138	e5ee519	9	Connecter	Collegare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f50c.svg	2025-12-03 13:33:24.48136	0	2025-12-04 13:33:24.48136	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Connect	Verbinden	Connect	\N
139	6e0de21	9	Déconnecter	Scollegare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6ab.svg	2025-12-03 13:33:24.507632	0	2025-12-04 13:33:24.507632	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Disconnect	Trennen	elektrônika	\N
142	e707080	9	Installer	Installare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e6.svg	2025-12-03 13:33:24.574791	0	2025-12-04 13:33:24.574791	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Install	Installieren	hametraka	\N
143	74db742	9	Mettre à jour	Aggiornare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f504.svg	2025-12-03 13:33:24.595256	0	2025-12-04 13:33:24.595256	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Update	Aktualisieren	vaovao farany	\N
144	eec4371	9	Configurer	Configurare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2699.svg	2025-12-03 13:33:24.616897	0	2025-12-04 13:33:24.616897	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Configure	Konfigurieren	Tefeo	\N
146	95f42b9	9	Vérifier	Verificare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2714.svg	2025-12-03 13:33:24.658248	0	2025-12-04 13:33:24.658248	{verbe,italien,fréquent,travail}	2.5	0	0	\N	\N	\N	Check	Überprüfen	Jereo	\N
133	65ebf2c	9	Chercher	Cercare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f50e.svg	2025-12-03 13:33:24.377844	1	2025-12-08 07:01:39.832238	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	Look for	Suchen	Mitady	\N
134	c4028bb	9	Découvrir	Scoprire		\N	2025-12-03 13:33:24.397568	0	2025-12-04 13:33:24.397568	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Discover	Entdecken	Fantaro	\N
140	f9c3865	9	Allumer	Accendere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4a1.svg	2025-12-03 13:33:24.532092	1	2025-12-08 07:04:03.273251	{verbe,italien,fréquent,maison}	2.6	1	1	\N	\N	\N	Turn on	Einschalten	Alefaso	\N
141	8614223	9	Éteindre	Spegnere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4a1.svg	2025-12-03 13:33:24.554222	1	2025-12-08 07:03:37.863328	{verbe,italien,fréquent,maison}	2.6	1	1	\N	\N	\N	Turn off	Ausschalten	Vonoy	\N
145	d21d2cc	9	Tester	Testare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2705.svg	2025-12-03 13:33:24.636979	1	2025-12-08 07:05:21.12145	{verbe,italien,fréquent,travail}	2.6	1	1	\N	\N	\N	Test	Prüfen	Test	\N
148	eb7f574	9	Connaître	Conoscere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4ca.svg	2025-12-03 13:33:24.701649	1	2025-12-08 07:05:31.929325	{verbe,italien,fréquent,cognition}	2.6	1	1	\N	\N	\N	Know	Wissen	Aoka ho fantatrao	\N
149	497d063	9	Suivre	Seguire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f449.svg	2025-12-03 13:33:24.724016	1	2025-12-08 07:03:23.397978	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	Follow	Folgen	Araho	\N
150	f32713a	9	Partir	Partire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2708.svg	2025-12-03 13:33:24.744637	1	2025-12-08 07:05:15.398774	{verbe,italien,fréquent,mouvement}	2.6	1	1	\N	\N	\N	Start	Start	fanombohana	\N
151	6694253	9	Arriver	Arrivare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6ec.svg	2025-12-03 13:33:24.766198	1	2025-12-08 07:06:12.82334	{verbe,italien,fréquent,mouvement}	2.6	1	1	\N	\N	\N	Arrive	Ankommen	TONGA	\N
648	8368fe0	19	Cheval	Cavallo		\N	2025-12-07 06:26:42.614938	0	2025-12-08 06:26:42.614938	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Horse	Pferd	soavaly	\N
33	e2281e4	8	S'endormir	Addormentarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f634.svg	2025-12-03 13:28:06.284505	1	2025-12-17 08:40:00.380331	{verbe,italien,pronominal,sommeil}	2.7	6	2	\N	\N	\N	Fall asleep	Einschlafen	Matory	\N
34	75fc543	8	S'entraîner	Allenarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-03 13:28:06.30374	1	2025-12-17 08:37:16.740587	{verbe,italien,pronominal,sport}	2.7	6	2	\N	\N	\N	Train	Zug	fiaran-dalamby	\N
283	9a23439	12	Non	Non		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/274c.svg	2025-12-06 14:05:16.29163	0	2026-01-03 15:57:41.118713	{adverbe,italien,fréquent,négation}	2.0999999999999996	0	0	\N	\N	\N	Not	Nicht	tsy	\N
288	63052a7	12	Toujours	Sempre		\N	2025-12-06 14:05:16.422784	2	2026-01-09 15:45:32.970486	{adverbe,italien,fréquent,fréquence}	2.7	6	2	\N	\N	\N	Always	Stets	foana	\N
290	7a55a12	12	Déjà	Già		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23f1.svg	2025-12-06 14:05:16.468395	2	2026-01-09 15:45:50.066206	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Already	Bereits	EFA	\N
295	041fe49	12	Peut-être	Forse		\N	2025-12-06 14:05:16.601668	2	2026-01-09 15:38:02.954766	{adverbe,italien,fréquent,incertitude}	2.7	6	2	\N	\N	\N	Perhaps	Vielleicht	angamba	\N
297	ada2e2e	12	Presque	Quasi		\N	2025-12-06 14:05:16.653457	0	2026-01-03 15:46:15.213706	{adverbe,italien,fréquent,degré}	2.4	0	0	\N	\N	\N	Almost	Fast	efa ho	\N
165	4e1c57a	9	Préparer	Preparare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f45c.svg	2025-12-03 13:33:25.04015	1	2025-12-08 07:01:00.212369	{verbe,italien,fréquent,vie}	2.6	1	1	\N	\N	\N	Prepare	Vorbereiten	Miomana	\N
296	0a3efd4	12	Vraiment	Davvero		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4a1.svg	2025-12-06 14:05:16.628938	0	2026-01-07 16:38:13.106139	{adverbe,italien,fréquent,confirmation}	2.1999999999999997	0	0	\N	\N	\N	Really	Wirklich	Marina	\N
168	ee89a47	10	Petit	Piccolo		\N	2025-12-03 13:40:49.334337	1	2025-12-07 16:00:06.029853	{adjectif,italien,fréquent,taille}	2.6	1	1	\N	\N	\N	Small	Klein	KELY	\N
169	7c626cd	10	Bon	Buono		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44d.svg	2025-12-03 13:40:49.353268	1	2025-12-07 15:56:27.4907	{adjectif,italien,fréquent,qualité}	2.6	1	1	\N	\N	\N	Good	Gut	Tsara	\N
172	0ae67b9	10	Vieux	Vecchio		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9d3.svg	2025-12-03 13:40:49.414589	1	2025-12-07 16:01:38.56044	{adjectif,italien,fréquent,temps}	2.6	1	1	\N	\N	\N	Old	Alt	Antitra	\N
176	2a8a6ee	10	Bas	Basso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c9.svg	2025-12-03 13:40:49.496779	1	2025-12-07 16:00:00.17769	{adjectif,italien,fréquent,taille}	2.6	1	1	\N	\N	\N	Bass	Bass	basse	\N
177	ee52f42	10	Long	Lungo		\N	2025-12-03 13:40:49.516317	1	2025-12-07 15:57:47.810847	{adjectif,italien,fréquent,taille}	2.6	1	1	\N	\N	\N	Long	Lang	ELA	\N
178	b1a3288	10	Court	Corto		\N	2025-12-03 13:40:49.536247	0	2025-12-04 13:40:49.536247	{adjectif,italien,fréquent,taille}	2.5	0	0	\N	\N	\N	Short	Kurz	Fohy	\N
179	56694c5	10	Facile	Facile		\N	2025-12-03 13:40:49.561391	1	2025-12-07 15:56:21.957044	{adjectif,italien,fréquent,difficulté}	2.6	1	1	\N	\N	\N	Easy	Einfach	Mora	\N
180	8435f06	10	Difficile	Difficile		\N	2025-12-03 13:40:49.582156	0	2025-12-04 13:40:49.582156	{adjectif,italien,fréquent,difficulté}	2.5	0	0	\N	\N	\N	Difficult	Schwierig	sarotra	\N
1036	751dd57	28	Creuser	Scavare		\N	2026-01-08 15:19:17.678353	1	2026-02-02 15:20:45.780027	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Dig	Graben	mihady	\N
163	b62d538	9	Expliquer	Spiegare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4ac.svg	2025-12-03 13:33:25.003876	0	2025-12-04 13:33:25.003876	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Explain	Erklären	Hazavao	\N
164	000965e	9	Écouter	Ascoltare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3a7.svg	2025-12-03 13:33:25.021693	0	2025-12-04 13:33:25.021693	{verbe,italien,fréquent,perception}	2.5	0	0	\N	\N	\N	Listen	Hören	Henoy	\N
166	5990eaa	9	Laver	Lavare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6bf.svg	2025-12-03 13:33:25.057956	0	2025-12-04 13:33:25.057956	{verbe,italien,fréquent,maison}	2.5	0	0	\N	\N	\N	Wash	Waschen	sasao madio	\N
167	c01c57e	10	Grand	Grande		\N	2025-12-03 13:40:49.313676	1	2025-12-07 15:56:48.738849	{adjectif,italien,fréquent,taille}	2.6	1	1	\N	\N	\N	Great	Großartig	LEHIBE	\N
171	4e8bd60	10	Nouveau	Nuovo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f195.svg	2025-12-03 13:40:49.392123	1	2025-12-07 15:48:19.389136	{adjectif,italien,fréquent,temps}	2.6	1	1	\N	\N	\N	New	Neu	Vaovao	\N
173	138f9dc	10	Beau	Bello		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f60d.svg	2025-12-03 13:40:49.436063	1	2025-12-07 15:48:09.042924	{adjectif,italien,fréquent,esthétique}	2.6	1	1	\N	\N	\N	Handsome	Gutaussehend	tsara tarehy	\N
174	d5e7d56	10	Laid	Brutto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f922.svg	2025-12-03 13:40:49.45579	1	2025-12-07 15:55:42.614679	{adjectif,italien,fréquent,esthétique}	2.6	1	1	\N	\N	\N	Bad	Schlecht	Ratsy	\N
181	4d45896	10	Rapide	Veloce		\N	2025-12-03 13:40:49.602616	1	2025-12-07 15:56:52.994869	{adjectif,italien,fréquent,vitesse}	2.6	1	1	\N	\N	\N	Fast	Schnell	fifadian-kanina	\N
182	0296ce8	10	Lent	Lento		\N	2025-12-03 13:40:49.623642	1	2025-12-07 15:58:27.318477	{adjectif,italien,fréquent,vitesse}	2.6	1	1	\N	\N	\N	Slow	Langsam	MORA	\N
183	13ca943	10	Chaud	Caldo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f525.svg	2025-12-03 13:40:49.643764	1	2025-12-07 15:59:46.105092	{adjectif,italien,fréquent,température}	2.6	1	1	\N	\N	\N	Heat	Hitze	hafanana	\N
302	b40bd19	12	Donc	Quindi		\N	2025-12-06 14:05:16.771952	2	2026-01-09 15:43:31.978465	{adverbe,italien,fréquent,logique}	2.7	6	2	\N	\N	\N	So	Also	Noho izany	\N
189	eb98ca9	10	Riche	Ricco		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4b8.svg	2025-12-03 13:40:49.765704	1	2025-12-07 15:52:26.991213	{adjectif,italien,fréquent,richesse}	2.6	1	1	\N	\N	\N	Rich	Reich	MPANANKARENA	\N
348	8b3f0ce	12	Malheureusement	Purtroppo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f622.svg	2025-12-06 14:05:17.800007	0	2026-01-07 16:43:17.065241	{adverbe,italien,fréquent,émotion}	2.4	0	0	\N	\N	\N	Unfortunately	Bedauerlicherweise	Indrisy	\N
191	dbf4503	10	Plein	Pieno		\N	2025-12-03 13:40:49.805146	1	2025-12-07 15:52:15.959897	{adjectif,italien,fréquent,quantité}	2.6	1	1	\N	\N	\N	Full	Voll	Feno	\N
372	266ce5e	12	Presque jamais	Quasi mai		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/26d4.svg	2025-12-06 14:05:18.350153	0	2026-01-03 15:56:26.972831	{adverbe,italien,fréquent,fréquence}	2.4	0	0	\N	\N	\N	Almonst never	Fast nie	Almonst na oviana na oviana	\N
381	33b79fc	12	Quand même	Comunque		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f937.svg	2025-12-06 14:05:18.556572	0	2026-01-07 16:37:06.913389	{adverbe,italien,fréquent,contraste}	1.6999999999999997	0	0	\N	\N	\N	Anyway	Ohnehin	ihany	\N
1921	3fc481c	41	en sentir le manque	sentirne la mancanza		\N	2026-02-06 15:39:14.483312	0	2026-02-13 08:16:17.509634	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Sentire la mancanza di qualcuno o qualcosa	to miss it	es vermissen	malahelo ny tsy fisian'izany	Ne sento la mancanza ogni giorno.
1934	0612651	41	se chercher des ennuis	cercarsela		\N	2026-02-08 07:10:23.0433	1	2026-02-14 08:08:50.4275	{}	2.6	1	1	\N	\N	Provocare problemi con il proprio comportamento	to ask for trouble	Ärger suchen	mitady olana	Se la cerca con quel modo di parlare.
197	9323318	10	Heureux	Felice		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f600.svg	2025-12-03 13:40:49.928908	1	2025-12-07 15:54:11.433667	{adjectif,italien,fréquent,émotion}	2.6	1	1	\N	\N	Persona che prova o esprime contentezza e soddisfazione.	Happy	Glücklich	Falifaly	Sembra sempre felice della sua vita.
198	cc587c9	10	Triste	Triste		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f622.svg	2025-12-03 13:40:49.948595	1	2025-12-07 15:58:38.640198	{adjectif,italien,fréquent,émotion}	2.6	1	1	\N	\N	Persona che prova o mostra malinconia.	Sad	Traurig	Malahelo	Sembra triste dopo la notizia.
2273	0eb248a	61	Repos	Riposo		\N	2026-02-24 15:14:10.386619	0	2026-02-25 15:14:10.386619	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Periodo senza attività fisica intensa.	Rest	Ruhe	Fialan-tsasatra	Il riposo è parte integrante dell'allenamento.
188	edb7af1	10	Faible	Debole		\N	2025-12-03 13:40:49.745441	1	2025-12-07 15:59:55.817832	{adjectif,italien,fréquent,force}	2.6	1	1	\N	\N	\N	Weak	Schwach	MALEMY	\N
193	c592dca	10	Clair	Chiaro		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2600.svg	2025-12-03 13:40:49.84659	1	2025-12-07 15:58:04.97929	{adjectif,italien,fréquent,lumière}	2.6	1	1	\N	\N	\N	Clear	Klar	Mazava	\N
195	85db423	10	Propre	Pulito		\N	2025-12-03 13:40:49.886698	0	2025-12-04 13:40:49.886698	{adjectif,italien,fréquent,propreté}	2.5	0	0	\N	\N	\N	Clean	Sauber	MADIO	\N
205	89ce3b7	10	Nécessaire	Necessario		\N	2025-12-03 13:40:50.092473	1	2025-12-07 15:47:53.107696	{adjectif,italien,fréquent,importance}	2.6	1	1	\N	\N	\N	Necessary	Notwendig	ilaina	\N
207	65ebc6a	10	Impossible	Impossibile		\N	2025-12-03 13:40:50.133111	1	2025-12-07 16:01:44.868637	{adjectif,italien,fréquent,possibilité}	2.6	1	1	\N	\N	\N	Impossible	Unmöglich	azo atao	\N
208	85b515b	10	Prêt	Pronto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23f1.svg	2025-12-03 13:40:50.151425	1	2025-12-07 16:00:56.706981	{adjectif,italien,fréquent,état}	2.6	1	1	\N	\N	\N	Ready	Bereit	Vonona	\N
202	f8babca	10	Intéressant	Interessante		\N	2025-12-03 13:40:50.034576	0	2025-12-04 13:40:50.034576	{adjectif,italien,fréquent,qualité}	2.5	0	0	\N	\N	\N	Interesting	Interessant	TENA	\N
204	db690e4	10	Important	Importante		\N	2025-12-03 13:40:50.073386	1	2025-12-07 15:53:21.493899	{adjectif,italien,fréquent,importance}	2.6	1	1	\N	\N	\N	Important	Wichtig	ZAVA-DEHIBE	\N
210	dae5833	10	Sain	Sano		\N	2025-12-03 13:40:50.192862	0	2025-12-06 16:03:54.044291	{adjectif,italien,fréquent,santé}	2.3	0	0	\N	\N	\N	Healthy	Gesund	ara-pahasalamana	\N
1110	d9e6d5a	28	Engrais	Fertilizzante		\N	2026-01-08 15:19:20.575195	0	2026-02-01 15:48:15.00247	{nom,italien,agriculture}	2.0999999999999996	0	0	\N	\N	\N	Fertilizer	Dünger	zezika	\N
187	48a25ee	10	Fort	Forte		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-03 13:40:49.722527	0	2025-12-04 13:40:49.722527	{adjectif,italien,fréquent,force}	2.5	0	0	\N	\N	\N	Strong	Stark	mahery	\N
190	d195c13	10	Pauvre	Povero		\N	2025-12-03 13:40:49.785121	0	2025-12-04 13:40:49.785121	{adjectif,italien,fréquent,richesse}	2.5	0	0	\N	\N	\N	Poor	Arm	MAHANTRA	\N
194	13a1b62	10	Sombre	Scuro		\N	2025-12-03 13:40:49.867057	0	2025-12-04 13:40:49.867057	{adjectif,italien,fréquent,lumière}	2.5	0	0	\N	\N	\N	Dark	Dunkel	Maizina	\N
192	d0d317e	10	Vide	Vuoto		\N	2025-12-03 13:40:49.826423	1	2025-12-07 15:56:43.416251	{adjectif,italien,fréquent,quantité}	2.6	1	1	\N	\N	\N	Empty	Leer	foana	\N
196	cad9936	10	Sale	Sporco		\N	2025-12-03 13:40:49.907458	1	2025-12-07 15:48:31.897426	{adjectif,italien,fréquent,propreté}	2.6	1	1	\N	\N	\N	Dirty	Schmutzig	Maloto	\N
223	e8a99a5	10	Tiède	Tiepido		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f321.svg	2025-12-03 13:40:50.440579	0	2025-12-06 16:01:48.018428	{adjectif,italien,fréquent,température}	2.3	0	0	\N	\N	\N	Warm	Warm	mafana	\N
324	2ffa8a6	12	Bien	Bene		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44d.svg	2025-12-06 14:05:17.256061	1	2025-12-10 12:57:17.610479	{adverbe,italien,fréquent,qualité}	2.6	1	1	\N	\N	\N	Well	Also	TSARA	\N
333	4191f49	12	Habituellement	Abitualmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f58b.svg	2025-12-06 14:05:17.456169	0	2026-01-03 15:54:17.518418	{adverbe,italien,fréquent,habitude}	2.1999999999999997	0	0	\N	\N	\N	Usually	Normalerweise	matetika	\N
342	aa7260f	12	Partiellement	Parzialmente		\N	2025-12-06 14:05:17.660317	1	2026-01-04 15:47:10.6249	{adverbe,italien,fréquent,degré}	2.4	1	1	\N	\N	\N	Partially	Teilweise	amin'ny ampahany	\N
366	7d7a705	12	Finalement	Finalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3c1.svg	2025-12-06 14:05:18.216225	2	2026-01-09 15:36:20.781266	{adverbe,italien,fréquent,ordre}	2.7	6	2	\N	\N	\N	Finally	Endlich	Farany	\N
369	56e9b61	12	Longuement	Lungamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4d6.svg	2025-12-06 14:05:18.28186	0	2026-01-07 16:42:46.165158	{adverbe,italien,fréquent,manière}	2.1999999999999997	0	0	\N	\N	\N	Long	Lang	ELA	\N
375	6c9f8a7	12	Pas encore	Non ancora		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/274c.svg	2025-12-06 14:05:18.420474	1	2026-01-08 16:27:51.373661	{adverbe,italien,fréquent,temps}	2.5	1	1	\N	\N	\N	Not yet	Noch nicht	Tsy mbola	\N
363	7a793ba	12	Prochainement	Prossimamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c6.svg	2025-12-06 14:05:18.149889	2	2026-01-09 15:38:55.946013	{adverbe,italien,fréquent,temps}	2.5	6	2	\N	\N	\N	Soon	Bald	Tsy ho ela	\N
346	629c196	12	Évidemment	Ovviamente		\N	2025-12-06 14:05:17.753276	1	2026-01-04 15:46:55.383758	{adverbe,italien,fréquent,certitude}	2.4	1	1	\N	\N	\N	Obviously	Offensichtlich	Mazava ho	\N
218	cff2c25	10	Mouillé	Bagnato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4a7.svg	2025-12-03 13:40:50.358121	0	2025-12-06 16:08:34.209748	{adjectif,italien,fréquent,humidité}	2.3	0	0	\N	\N	\N	Wet	Nass	fahavaratra	\N
219	e069cca	10	Lourd	Pesante		\N	2025-12-03 13:40:50.37351	1	2025-12-07 15:51:57.621731	{adjectif,italien,fréquent,poids}	2.6	1	1	\N	\N	\N	Heavy	Schwer	mavesatra	\N
221	40c8446	10	Moelleux	Morbido		\N	2025-12-03 13:40:50.405726	0	2025-12-06 16:09:27.05843	{adjectif,italien,fréquent,texture}	2.3	0	0	\N	\N	\N	Soft	Weich	Malefaka	\N
222	40df218	10	Dur	Duro		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9f1.svg	2025-12-03 13:40:50.422601	1	2025-12-07 15:57:06.555236	{adjectif,italien,fréquent,texture}	2.6	1	1	\N	\N	\N	Hard	Hart	Sarotra	\N
235	e613443	10	Malhonnête	Disonesto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f575.svg	2025-12-03 13:40:50.655531	0	2025-12-06 16:08:21.711837	{adjectif,italien,fréquent,morale}	2.3	0	0	\N	\N	\N	Dishonest	Unehrlich	Manao ny marina	\N
237	3ac376a	10	Faux	Falso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/274c.svg	2025-12-03 13:40:50.694497	0	2025-12-06 16:05:36.982652	{adjectif,italien,fréquent,morale}	2.3	0	0	\N	\N	\N	False	FALSCH	DISO	\N
240	8f986a4	10	Rare	Raro		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2728.svg	2025-12-03 13:40:50.74975	1	2025-12-07 15:55:30.321913	{adjectif,italien,fréquent,fréquence}	2.6	1	1	\N	\N	\N	Rare	Selten	tsy fahita firy	\N
224	96d9174	10	Poli	Cortese		\N	2025-12-03 13:40:50.458332	0	2025-12-06 16:02:06.00783	{adjectif,italien,fréquent,politesse}	2.3	0	0	\N	\N	\N	Courteous	Höflich	mahalala	\N
232	610f177	10	Stupide	Stupido		\N	2025-12-03 13:40:50.598998	0	2025-12-04 13:40:50.598998	{adjectif,italien,fréquent,intelligence}	2.5	0	0	\N	\N	\N	Stupid	Dumm	VENDRANA	\N
239	3a77cc7	10	Commun	Comune		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c2.svg	2025-12-03 13:40:50.7296	0	2025-12-06 16:11:04.930566	{adjectif,italien,fréquent,fréquence}	2.3	0	0	\N	\N	\N	Common	Gemeinsam	Mahazatra	\N
1132	f19e419	28	Zéro émission	Zero emissioni		\N	2026-01-08 15:19:21.176563	0	2026-02-01 15:41:44.436759	{expression,italien,climat}	2.3	0	0	\N	\N	\N	Zero emissions	Null Emissionen	Zero emissions	\N
1137	3c384ba	28	Responsabilité	Responsabilità		\N	2026-01-08 15:19:21.294691	1	2026-02-02 15:20:41.232842	{nom,italien,social}	2.6	1	1	\N	\N	\N	Responsibility	Verantwortung	Andraikitra	\N
1186	6855008	30	Descendre	Scendere giù		\N	2026-01-09 16:10:11.550747	0	2026-01-10 16:10:11.550747	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go down	Gehen	Midina	\N
217	ad47e22	10	Sec	Secco		\N	2025-12-03 13:40:50.339482	0	2025-12-04 13:40:50.339482	{adjectif,italien,fréquent,humidité}	2.5	0	0	\N	\N	\N	Dry	Trocken	MAINA	\N
226	e043719	10	Malpoli	Scortese		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f620.svg	2025-12-03 13:40:50.495354	0	2025-12-06 16:05:07.398917	{adjectif,italien,fréquent,politesse}	2.3	0	0	\N	\N	\N	Rude	Unhöflich	tsy mahalala fomba	\N
2274	bf938f0	61	Calme	Calma		\N	2026-02-24 15:14:16.581346	0	2026-02-25 15:14:16.581346	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Stato di tranquillità fisica e mentale.	Calm	Ruhe	Miadana	Mantieni la calma durante la gara.
2275	42d0538	61	Énergie positive	Energia positiva		\N	2026-02-24 15:14:22.560534	0	2026-02-25 15:14:22.560534	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Atteggiamento mentale ottimista e vitale.	Positive energy	Positive Energie	Angovo tsara	L'energia positiva aumenta la motivazione.
206	b622bbe	10	Possible	Possibile		\N	2025-12-03 13:40:50.113412	1	2025-12-07 16:01:14.464944	{adjectif,italien,fréquent,possibilité}	2.6	1	1	\N	\N	\N	Possible	Möglich	possible	\N
248	870f618	10	Simple	Semplice		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4d1.svg	2025-12-03 13:40:50.905588	1	2025-12-07 15:59:51.56028	{adjectif,italien,fréquent,difficulté}	2.6	1	1	\N	\N	\N	Simple	Einfach	TSOTRA	\N
249	0940c27	10	Compliqué	Complicato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4cc.svg	2025-12-03 13:40:50.92624	1	2025-12-07 15:57:42.411883	{adjectif,italien,fréquent,difficulté}	2.6	1	1	\N	\N	\N	Complicated	Kompliziert	sarotra ny	\N
251	19947e4	10	Bon marché	Economico		\N	2025-12-03 13:40:50.966353	1	2025-12-07 15:53:45.10988	{adjectif,italien,fréquent,prix}	2.6	1	1	\N	\N	\N	Economic	Wirtschaftlich	ARA-	\N
252	35a0d1a	10	Correct	Giusto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2705.svg	2025-12-03 13:40:50.987756	0	2025-12-06 16:09:33.490106	{adjectif,italien,fréquent,exactitude}	2.3	0	0	\N	\N	\N	Right	Rechts	TSARA	\N
253	02f0023	10	Incorrect	Sbagliato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/274c.svg	2025-12-03 13:40:51.007532	0	2025-12-06 16:09:42.337079	{adjectif,italien,fréquent,exactitude}	2.3	0	0	\N	\N	\N	Wrong	Falsch	DISO	\N
254	8662cd0	10	Bruyant	Rumoroso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f50a.svg	2025-12-03 13:40:51.026965	0	2025-12-06 16:10:13.465038	{adjectif,italien,fréquent,bruit}	2.3	0	0	\N	\N	\N	Noisy	Laut	tabataba	\N
257	b780f93	10	Étroit	Stretto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/21a9.svg	2025-12-03 13:40:51.088513	0	2025-12-06 16:11:00.070403	{adjectif,italien,fréquent,taille}	2.3	0	0	\N	\N	\N	Strict	Strikt	Henjana	\N
260	6212852	10	Élevé	Elevato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c8.svg	2025-12-03 13:40:51.152799	0	2025-12-06 16:07:57.836243	{adjectif,italien,fréquent,niveau}	2.3	0	0	\N	\N	\N	High	Hoch	Avo	\N
1052	dcf5be8	28	Flore	Flora		\N	2026-01-08 15:19:18.192606	1	2026-02-02 15:29:18.43976	{nom,italien,biodiversité}	2.6	1	1	\N	\N	\N	Flora	Flora	zavamaniry	\N
1133	afdee8c	28	Transition énergétique	Transizione energetica		\N	2026-01-08 15:19:21.201511	1	2026-02-02 15:26:50.699626	{expression,italien,énergie}	2.6	1	1	\N	\N	\N	Energy transition	Energiewende	Tetezamita angovo	\N
361	55298b1	12	Séparément	Separatamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5c3.svg	2025-12-06 14:05:18.105085	0	2026-01-03 15:58:01.140267	{adverbe,italien,fréquent,manière}	1.8999999999999997	0	0	\N	\N	\N	Separately	Separat	manokana	\N
370	54d8dde	12	Faiblement	Debolmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-06 14:05:18.304072	2	2026-01-09 15:45:12.687379	{adverbe,italien,fréquent,degré}	2.5	6	2	\N	\N	\N	Weakly	Schwach	natahotra	\N
373	925110c	12	Presque toujours	Quasi sempre		\N	2025-12-06 14:05:18.377359	0	2026-01-03 15:58:44.650702	{adverbe,italien,fréquent,fréquence}	2.4	0	0	\N	\N	\N	Almost always	Fast immer	Saika foana	\N
319	b6a5b8d	12	Tôt	Presto		\N	2025-12-06 14:05:17.150371	2	2026-01-09 15:45:26.957702	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Soon	Bald	Tsy ho ela	\N
322	ede210c	12	Lentement	Lentamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23ea.svg	2025-12-06 14:05:17.208781	2	2026-01-09 15:39:10.336374	{adverbe,italien,fréquent,manière}	2.7	6	2	\N	\N	\N	Slowly	Langsam	tsikelikely	\N
331	422c840	12	Généralement	Generalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c8.svg	2025-12-06 14:05:17.41307	0	2026-01-07 16:43:41.107095	{adverbe,italien,fréquent,fréquence}	2.4	0	0	\N	\N	\N	Generally	Allgemein	ankapobeny	\N
334	145d7b4	12	Spécialement	Specialmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f31f.svg	2025-12-06 14:05:17.478196	0	2026-01-03 15:47:17.529545	{adverbe,italien,fréquent,manière}	2.4	0	0	\N	\N	\N	Especially	Besonders	indrindra	\N
247	1ef12cd	10	Lointain	Lontano		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fa94.svg	2025-12-03 13:40:50.885936	0	2025-12-04 13:40:50.885936	{adjectif,italien,fréquent,distance}	2.5	0	0	\N	\N	\N	Distant	Entfernt	lavitra	\N
250	89e54ae	10	Cher	Caro		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4b5.svg	2025-12-03 13:40:50.947115	0	2025-12-06 16:06:57.071129	{adjectif,italien,fréquent,prix}	2.3	0	0	\N	\N	\N	Dear	Liebling	Ry	\N
262	9b95796	10	Bondé	Affollato		\N	2025-12-03 13:40:51.194212	0	2025-12-06 16:11:26.240574	{adjectif,italien,fréquent,fréquence}	2.3	0	0	\N	\N	\N	Crowded	Überfüllt	be olona	\N
340	bd6cdb2	12	Exactement	Esattamente		\N	2025-12-06 14:05:17.611381	0	2025-12-09 13:20:26.744273	{adverbe,italien,fréquent,exactitude}	2.3	0	0	\N	\N	\N	Exactly	genau	Izay indrindra	\N
364	5a00e21	12	Récemment	Recentemente		\N	2025-12-06 14:05:18.170995	0	2026-01-07 16:43:02.394751	{adverbe,italien,fréquent,temps}	1.6999999999999997	0	0	\N	\N	\N	Lately	In letzter Zeit	tato ho ato	\N
376	ec586ec	12	Plus tard	Più tardi		\N	2025-12-06 14:05:18.443894	1	2025-12-10 12:55:29.33239	{adverbe,italien,fréquent,temps}	2.6	1	1	\N	\N	\N	Later	Später	TATỲ AORIANA	\N
42	76bccf8	8	S'ennuyer	Annoiarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f971.svg	2025-12-03 13:28:06.458929	3	2026-02-20 14:09:36.044211	{verbe,italien,pronominal,émotion}	2.9	76	4	\N	\N	\N	Getting bored	Langeweile	Lasa leo	\N
326	14825f8	12	Mieux	Meglio		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-06 14:05:17.301926	2	2026-01-09 15:37:00.52387	{adverbe,italien,fréquent,comparaison}	2.7	6	2	\N	\N	\N	Better	Besser	TSARA	\N
809	0e4ff26	22	Piangere	Pianto		\N	2025-12-08 16:20:08.236736	0	2025-12-09 16:20:08.236736	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Crying	Weinen	mitomany	\N
810	e9f6f4f	22	Rompere	Rotto		\N	2025-12-08 16:20:08.25638	0	2025-12-09 16:20:08.25638	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Broken	Gebrochen	tapaka	\N
811	3d4f208	22	Cuocere	Cotto		\N	2025-12-08 16:20:08.277652	0	2025-12-09 16:20:08.277652	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Cooked	Gekocht	masaka	\N
813	99a5a30	22	Ridere	Riso		\N	2025-12-08 16:20:08.315353	0	2025-12-09 16:20:08.315353	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Rice	Reis	-BARY	\N
815	c747c08	22	Friggere	Fritto		\N	2025-12-08 16:20:08.353907	0	2025-12-09 16:20:08.353907	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Fried	Gebraten	nendasina	\N
10	8c497aa	8	Se lever	Alzarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6cf.svg	2025-12-03 13:28:05.805554	1	2025-12-17 08:40:30.418491	{verbe,italien,pronominal,quotidien}	2.7	6	2	\N	\N	\N	Get up	Aufstehen	Mifohaza	\N
12	b58763a	8	Se sentir	Sentirsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f60a.svg	2025-12-03 13:28:05.856813	1	2025-12-17 08:37:02.9158	{verbe,italien,pronominal,émotion}	2.7	6	2	\N	\N	\N	Feel	Fühlen	hahatsapa	\N
2276	a1ab2be	61	Vitalité	Vitalità		\N	2026-02-24 15:14:28.723209	0	2026-02-25 15:14:28.723209	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Sensazione di forza e benessere generale.	Vitality	Vitalität	Vitalité	Lo sport dona vitalità quotidiana.
17	2e02588	8	Se trouver	Trovarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4cd.svg	2025-12-03 13:28:05.954635	1	2025-12-17 08:39:19.643724	{verbe,italien,pronominal,localisation}	2.7	6	2	\N	\N	\N	Be	Sei	ho	\N
21	8f4d4ca	8	Se demander	Chiedersi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f914.svg	2025-12-03 13:28:06.035827	1	2025-12-17 08:38:33.115588	{verbe,italien,pronominal,réflexion}	2.7	6	2	\N	\N	\N	Ask yourself	Fragen Sie sich	Manontania tena	\N
22	b16fb80	8	S'amuser	Divertirsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f973.svg	2025-12-03 13:28:06.05503	1	2025-12-17 08:36:01.876714	{verbe,italien,pronominal,loisir}	2.7	6	2	\N	\N	\N	Have fun	Viel Spaß	Maka fahafinaretana	\N
23	1794cca	8	Se dépêcher	Sbrigarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3c3.svg	2025-12-03 13:28:06.076793	1	2025-12-12 12:47:34.345342	{verbe,italien,pronominal,mouvement}	2.7	6	2	\N	\N	\N	Hurry up	Beeil dich	Haingana	\N
186	1621f09	10	Âgé	Anziano		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9d3.svg	2025-12-03 13:40:49.700386	0	2025-12-06 16:08:13.138909	{adjectif,italien,fréquent,âge}	2.3	0	0	\N	\N	Persona di età avanzata.	Elderly	Älter / Senior	Zokiolona	Bisogna portare rispetto alle persone anziane.
543	8143963	17	La famille	La famiglia		\N	2025-12-07 06:08:34.921192	0	2025-12-08 06:08:34.921192	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The family	Die Familie	Ny fianakaviana	\N
299	9650471	12	Seulement	Solo		\N	2025-12-06 14:05:16.706562	0	2026-01-07 16:37:57.247663	{adverbe,italien,fréquent,restriction}	1.8999999999999997	0	0	\N	\N	\N	Alone	Allein	irery	\N
1037	082b3bb	28	Arriver	Succedere		\N	2026-01-08 15:19:17.701649	0	2026-02-01 15:32:46.411506	{verbe,italien,événement}	2.3	0	0	\N	\N	\N	Happen	Passieren	Ela!	\N
1194	bb4e3bb	30	Surgir	Saltare fuori		\N	2026-01-09 16:10:11.705485	0	2026-01-10 16:10:11.705485	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Jump out	Spring raus	Mitsambikina mivoaka	\N
822	b6af1da	22	Accorgersi	Accorto		\N	2025-12-08 16:20:08.491468	0	2025-12-09 16:20:08.491468	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Cautious	Zurückhaltend	MALINA	\N
825	76689e3	22	Soffrire	Sofferito		\N	2025-12-08 16:20:08.716105	0	2025-12-09 16:20:08.716105	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Suffered	Gelitten	nijaly	\N
1497	b86fd5d	37	orangeade	aranciata		\N	2026-01-21 14:50:00.675627	0	2026-01-22 14:50:00.675627	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	orange soda	Orangenlimonade	orange soda	\N
287	2276ce6	12	Peu	Poco		\N	2025-12-06 14:05:16.398972	2	2026-01-09 15:45:36.493911	{adverbe,italien,fréquent,degré}	2.7	6	2	\N	\N	\N	Not much	Nicht viel	Tsy betsaka	\N
36	42f0bd2	8	Se maquiller	Truccarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f484.svg	2025-12-03 13:28:06.342425	1	2025-12-17 08:37:22.266985	{verbe,italien,pronominal,hygiène}	2.7	6	2	\N	\N	\N	Put on makeup	Tragen Sie Make-up auf	Manaova makiazy	\N
39	2f8ffbc	8	Se protéger	Proteggersi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6e1.svg	2025-12-03 13:28:06.399855	0	2025-12-11 08:46:43.62936	{verbe,italien,pronominal,sécurité}	2.1999999999999997	0	0	2025-12-06 08:43:27.305061+03	\N	\N	Protect yourself	Schützen Sie sich	Arovy ny tenanao	\N
282	3820f3a	12	Oui	Sì		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2705.svg	2025-12-06 14:05:16.247535	3	2026-01-27 16:26:38.596229	{adverbe,italien,fréquent,affirmation}	2.8	20	3	\N	\N	\N	Yes	Ja	ENY	\N
284	fc1839d	12	Plus	Più		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2795.svg	2025-12-06 14:05:16.32242	3	2026-01-29 16:27:18.305269	{adverbe,italien,fréquent,quantité}	2.8	22	3	\N	\N	\N	More	Mehr	Bebe kokoa	\N
285	5416629	12	Moins	Meno		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2796.svg	2025-12-06 14:05:16.351814	2	2026-01-09 15:47:53.918699	{adverbe,italien,fréquent,quantité}	2.7	6	2	\N	\N	\N	Less	Weniger	Kely kokoa	\N
289	0af84b4	12	Jamais	Mai		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/26d4.svg	2025-12-06 14:05:16.446627	2	2026-01-09 15:36:46.349528	{adverbe,italien,fréquent,fréquence}	2.7	6	2	\N	\N	\N	Never	Niemals	tsy	\N
292	60a348d	12	Souvent	Spesso		\N	2025-12-06 14:05:16.516096	2	2026-01-09 15:37:57.157019	{adverbe,italien,fréquent,fréquence}	2.7	6	2	\N	\N	\N	Often	Oft	Matetika	\N
294	616a473	12	Parfois	Talvolta		\N	2025-12-06 14:05:16.568096	0	2026-01-07 16:43:29.683758	{adverbe,italien,fréquent,fréquence}	1.6999999999999997	0	0	\N	\N	\N	Sometimes	Manchmal	indraindray	\N
24	3db4588	8	S'arrêter	Fermarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6d1.svg	2025-12-03 13:28:06.096733	1	2025-12-17 08:38:08.018617	{verbe,italien,pronominal,mouvement}	2.7	6	2	\N	\N	\N	Stop	Stoppen	Mijanòna	\N
25	783b955	8	Se reposer	Riposarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6cc.svg	2025-12-03 13:28:06.118258	1	2025-12-12 08:39:43.090069	{verbe,italien,pronominal,repos}	2.5	1	1	\N	\N	\N	Rest	Ausruhen	HAFA	\N
26	725db9e	8	Se rencontrer	Incontrarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f91d.svg	2025-12-03 13:28:06.140344	1	2025-12-17 08:39:14.902382	{verbe,italien,pronominal,social}	2.7	6	2	\N	\N	\N	Meet	Treffen	Mihaona	\N
27	4ada209	8	Se marier	Sposarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f492.svg	2025-12-03 13:28:06.162265	1	2025-12-17 08:37:28.461861	{verbe,italien,pronominal,vie}	2.7	6	2	\N	\N	\N	Getting married	Heiraten	Manambady	\N
35	c5468b0	8	Se calmer	Calmarsi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f60c.svg	2025-12-03 13:28:06.323411	1	2025-12-17 08:37:57.495319	{verbe,italien,pronominal,émotion}	2.7	6	2	\N	\N	\N	Calm down	Beruhige dich	Tonio fotsiny	\N
293	6183007	12	Rarement	Raramente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2728.svg	2025-12-06 14:05:16.542966	2	2026-01-09 15:45:07.383723	{adverbe,italien,fréquent,fréquence}	2.7	6	2	\N	\N	\N	Rarely	Selten	zara raha	\N
298	299a7ed	12	Environ	Circa		\N	2025-12-06 14:05:16.67907	0	2025-12-09 13:15:33.540245	{adverbe,italien,fréquent,quantité}	2.3	0	0	\N	\N	\N	About	Um	About	\N
220	eda4eb3	10	Léger	Leggero		\N	2025-12-03 13:40:50.38913	0	2025-12-06 16:11:09.518063	{adjectif,italien,fréquent,poids}	2.0999999999999996	0	0	\N	\N	Che ha poco peso, non pesante.	Light	Leicht	Maivana	Questa valigia è molto leggera.
291	149f045	12	Encore	Ancora		\N	2025-12-06 14:05:16.490688	2	2026-01-09 15:38:37.42126	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Still	Trotzdem	Na izany aza	\N
1498	917e3e0	37	boisson	bibita		\N	2026-01-21 14:50:00.708338	0	2026-01-22 14:50:00.708338	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	drink	trinken	zava-pisotro	\N
1499	74f002c	37	vin pétillant	spumante		\N	2026-01-21 14:50:00.741514	0	2026-01-22 14:50:00.741514	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	bubbly wine	sprudelnder Wein	divay miboiboika	\N
286	e280f54	12	Très	Molto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2b50.svg	2025-12-06 14:05:16.376813	2	2026-01-09 15:43:54.095951	{adverbe,italien,fréquent,degré}	2.7	6	2	\N	\N	\N	Very	Sehr	TENA	\N
826	7f10a50	22	Nascondere	Nascosto		\N	2025-12-08 16:20:08.73592	0	2025-12-09 16:20:08.73592	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Hidden	Versteckt	Zavatra tsy	\N
2277	112ae93	62	Athlétisme	Atletica		\N	2026-02-24 15:24:30.458336	0	2026-02-25 15:24:30.458336	{sport,entraînement,performance}	2.5	0	0	\N	\N	Insieme di discipline sportive che comprendono corsa, salti e lanci.	Athletics	Leichtathletik	Fanatanjahan-tsaina	L'atletica è la regina delle Olimpiadi.
303	6cdf1cc	12	Alors	Allora		\N	2025-12-06 14:05:16.797745	0	2026-01-03 15:53:20.285229	{adverbe,italien,fréquent,temps}	2.5	0	0	\N	\N	\N	At that time	Damals	Tamin'izany fotoana izany	\N
309	6b5a9f8	12	Demain	Domani		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5d2.svg	2025-12-06 14:05:16.928751	1	2025-12-10 12:56:01.464262	{adverbe,italien,fréquent,temps}	2.6	1	1	\N	\N	\N	Tomorrow	Morgen	rahampitso	\N
315	c98d202	12	Dedans	Dentro		\N	2025-12-06 14:05:17.065686	2	2026-01-09 15:37:06.068541	{adverbe,italien,fréquent,lieu}	2.7	6	2	\N	\N	\N	In	In	In	\N
1144	7e8d889	28	Opinion	Opinione		\N	2026-01-08 15:19:21.460432	1	2026-02-02 15:25:06.312185	{nom,italien,communication}	2.6	1	1	\N	\N	Idea o giudizio personale su qualcosa.	Opinion	Meinung	Hevitra	Rispetto la tua opinione, anche se non sono d'accordo.
300	ff6a637	12	Aussi	Anche		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2797.svg	2025-12-06 14:05:16.727795	1	2025-12-10 12:58:13.34643	{adverbe,italien,fréquent,addition}	2.6	1	1	\N	\N	\N	Also	Auch	KOA	\N
306	bbe7381	12	Après	Dopo		\N	2025-12-06 14:05:16.863797	2	2026-01-13 16:32:55.133662	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	After	Nach	rehefa	\N
318	fcaf8b7	12	En arrière	Indietro		\N	2025-12-06 14:05:17.129526	0	2026-01-03 15:53:27.432453	{adverbe,italien,fréquent,direction}	2.0999999999999996	0	0	\N	\N	\N	Backwards	Rückwärts	backwards	\N
330	d3d58b1	12	Probablement	Probabilmente		\N	2025-12-06 14:05:17.389132	1	2026-01-04 15:37:52.650086	{adverbe,italien,fréquent,incertitude}	2.2	1	1	\N	\N	\N	Probably	Wahrscheinlich	angamba	\N
336	f4e1dd1	12	Surtout	Soprattutto		\N	2025-12-06 14:05:17.521121	0	2026-01-03 15:58:52.319716	{adverbe,italien,fréquent,importance}	2.0999999999999996	0	0	\N	\N	\N	Above all	Vor allem	Ambonin'ny zava-drehetra	\N
345	efa939b	12	Naturellement	Naturalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f33f.svg	2025-12-06 14:05:17.731412	2	2026-01-09 15:49:11.729001	{adverbe,italien,fréquent,manière}	2.7	6	2	\N	\N	\N	Naturally	Natürlich	mazava ho	\N
354	eb78286	12	Toutefois	Tuttavia		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6ab.svg	2025-12-06 14:05:17.9364	2	2026-01-13 16:32:51.059986	{adverbe,italien,fréquent,contraste}	2.5	6	2	\N	\N	\N	However	Jedoch	na izany aza	\N
357	425fd5b	12	Autrement	Altrimenti		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f504.svg	2025-12-06 14:05:18.013995	0	2026-01-03 15:46:33.887522	{adverbe,italien,fréquent,condition}	1.8999999999999997	0	0	\N	\N	\N	Otherwise	Ansonsten	raha tsy izany	\N
378	54f41b5	12	À peu près	Pressappoco		\N	2025-12-06 14:05:18.486832	0	2026-01-03 15:56:31.989297	{adverbe,italien,fréquent,approximation}	1.8999999999999997	0	0	\N	\N	\N	Approximately	\N	\N	\N
312	830dfdd	12	Là-bas	Laggiù		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3d4.svg	2025-12-06 14:05:16.999556	2	2026-01-13 16:33:22.173413	{adverbe,italien,fréquent,lieu}	2.5	6	2	\N	\N	\N	Over there	Da drüben	Iry e	\N
321	8003b22	12	Tout de suite	Subito		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/26a1.svg	2025-12-06 14:05:17.192116	2	2026-01-09 15:45:41.678175	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Right away	Sofort	Tsy misy hatak'andro	\N
327	649f970	12	Pire	Peggio		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4a9.svg	2025-12-06 14:05:17.32509	2	2026-01-09 15:39:15.657182	{adverbe,italien,fréquent,comparaison}	2.7	6	2	\N	\N	\N	Worse	Schlechter	Mbola ratsy kokoa	\N
351	7fac92e	12	Franchement	Francamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4ac.svg	2025-12-06 14:05:17.868092	2	2026-01-09 15:46:42.18319	{adverbe,italien,fréquent,manière}	2.5	6	2	\N	\N	\N	Frankly	Ehrlich gesagt	amim-pahatsorana	\N
360	d3f651a	12	Ensemble	Insieme		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f91d.svg	2025-12-06 14:05:18.082562	2	2026-01-13 16:33:45.791365	{adverbe,italien,fréquent,manière}	2.7	6	2	\N	\N	\N	Together	Zusammen	miara-	\N
1392	68dbf08	36	Être extrêmement heureux	Essere al settimo cielo		\N	2026-01-20 14:49:12.157256	0	2026-01-21 14:49:12.157256	{expression,idiomatique,italien,fréquent,émotion}	2.5	0	0	\N	\N	Essere estremamente felici.	To be over the moon	Im siebten Himmel sein	Faly be / Any an-danitra fahafito	Quando ha vinto, era al settimo cielo.
339	4b628c3	12	Précisément	Precisamente		\N	2025-12-06 14:05:17.588937	2	2026-01-09 15:37:30.17465	{adverbe,italien,fréquent,exactitude}	2.7	6	2	\N	\N	\N	Precisely	Genau	indrindra	\N
827	c8868f9	22	Confondere	Confuso		\N	2025-12-08 16:20:08.757581	0	2025-12-09 16:20:08.757581	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Confused	Verwirrt	very hevitra	\N
2278	79fc2c1	62	Préparation	Preparazione		\N	2026-02-24 15:24:37.550936	0	2026-02-25 15:24:37.550936	{sport,entraînement,performance}	2.5	0	0	\N	\N	Fase di organizzazione fisica e mentale prima di una gara o di un allenamento.	Preparation	Vorbereitung	Fanamboarana	La preparazione atletica è fondamentale per evitare infortuni.
2279	d606f47	62	Conditionnement	Condizionamento		\N	2026-02-24 15:24:45.324877	0	2026-02-25 15:24:45.324877	{sport,entraînement,performance}	2.5	0	0	\N	\N	Allenamento mirato a migliorare la resistenza fisica generale.	Conditioning	Konditionierung	Fanamafisana	Il condizionamento aerobico aumenta la capacità polmonare.
301	3e945f0	12	Au lieu	Invece		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f504.svg	2025-12-06 14:05:16.750454	2	2026-01-09 15:47:37.435274	{adverbe,italien,fréquent,contraste}	2.7	6	2	\N	\N	\N	Instead	Stattdessen	fa tsy	\N
304	824b91d	12	Ensuite	Poi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/27a1.svg	2025-12-06 14:05:16.819582	2	2026-01-09 15:43:58.155113	{adverbe,italien,fréquent,ordre}	2.7	6	2	\N	\N	\N	Then	Dann	dia	\N
310	c701e73	12	Ici	Qui		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4cd.svg	2025-12-06 14:05:16.952025	1	2025-12-10 12:52:50.545681	{adverbe,italien,fréquent,lieu}	2.6	1	1	\N	\N	\N	Here	Hier	Eto	\N
313	3b519b1	12	En haut	Sopra		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2b06.svg	2025-12-06 14:05:17.022035	2	2026-01-09 15:36:28.367834	{adverbe,italien,fréquent,lieu}	2.7	6	2	\N	\N	\N	Above	Über	AMBONY	\N
307	51f128d	12	Aujourd’hui	Oggi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c6.svg	2025-12-06 14:05:16.886988	2	2026-01-09 15:44:27.921717	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Today	Heute	ankehitriny	\N
316	aceb9bb	12	Dehors	Fuori		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3e3.svg	2025-12-06 14:05:17.086411	2	2026-01-09 15:38:21.154109	{adverbe,italien,fréquent,lieu}	2.7	6	2	\N	\N	\N	Out	Aus	avy	\N
325	29ec0a0	12	Mal	Male		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44e.svg	2025-12-06 14:05:17.28209	2	2026-01-09 15:44:44.535839	{adverbe,italien,fréquent,qualité}	2.7	6	2	\N	\N	\N	Bad	Schlecht	Ratsy	\N
337	2380c6f	12	Au moins	Almeno		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4b0.svg	2025-12-06 14:05:17.543065	2	2026-01-09 15:45:17.254395	{adverbe,italien,fréquent,quantité}	2.5	6	2	\N	\N	\N	At least	Mindestens	Farafaharatsiny	\N
343	3f07927	12	Totalement	Totalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c8.svg	2025-12-06 14:05:17.687073	0	2026-01-03 15:54:40.542321	{adverbe,italien,fréquent,degré}	2.4	0	0	\N	\N	\N	Totally	Völlig	tanteraka	\N
349	4e0d4b2	12	Heureusement	Fortunatamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f389.svg	2025-12-06 14:05:17.825316	0	2026-01-07 16:36:56.174343	{adverbe,italien,fréquent,émotion}	1.6999999999999997	0	0	\N	\N	\N	Luckily	Glücklicherweise	Soa ihany	\N
355	aad40c1	12	Cependant	Però		\N	2025-12-06 14:05:17.967146	1	2026-01-04 15:48:13.824041	{adverbe,italien,fréquent,contraste}	2.4	1	1	\N	\N	\N	But	Aber	SAINGY	\N
358	ed9a740	12	Aussi bien	Ugualmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f39f.svg	2025-12-06 14:05:18.03677	0	2026-01-03 15:53:40.788856	{adverbe,italien,fréquent,comparaison}	1.8999999999999997	0	0	\N	\N	\N	Likewise	Ebenfalls	Toy izany koa	\N
367	2d26e79	12	Globalement	Globalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f310.svg	2025-12-06 14:05:18.238306	2	2026-01-09 15:44:34.446198	{adverbe,italien,fréquent,manière}	2.5	6	2	\N	\N	\N	Globally	Global	maneran-	\N
50	9b7f2ca	9	Aller	Andare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6b6.svg	2025-12-03 13:33:22.520647	0	2025-12-04 13:33:22.520647	{verbe,italien,fréquent,mouvement}	2.5	0	0	\N	\N	\N	Go	Gehen	Mandehana	\N
352	fd09893	12	En réalité	In realtà		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f914.svg	2025-12-06 14:05:17.891334	2	2026-01-09 15:44:51.87106	{adverbe,italien,fréquent,logique}	2.7	6	2	\N	\N	\N	Actually	Eigentlich	Raha ny marina	\N
51	7ce5918	9	Dire	Dire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5e3.svg	2025-12-03 13:33:22.538117	0	2025-12-04 13:33:22.538117	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Say	Sagen	LAZAIN'NY	\N
379	ff60019	12	Approximativement	Approssimativamente		\N	2025-12-06 14:05:18.513105	0	2026-01-07 16:38:21.034375	{adverbe,italien,fréquent,approximation}	1.6999999999999997	0	0	\N	\N	\N	Approximately	Etwa	eo ho eo	\N
52	c25cda0	9	Voir	Vedere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f440.svg	2025-12-03 13:33:22.555906	0	2025-12-04 13:33:22.555906	{verbe,italien,fréquent,perception}	2.5	0	0	\N	\N	\N	See	Sehen	JEREO NY	\N
328	49d6856	12	Claiement	Chiaramente		\N	2025-12-06 14:05:17.344735	2	2026-01-13 16:27:02.179861	{adverbe,italien,fréquent,manière}	2.3	6	2	\N	\N	\N	Clearly	Deutlich	HITA àry fa	\N
314	d6dbbcf	12	En bas	Sotto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2b07.svg	2025-12-06 14:05:17.045838	2	2026-01-09 15:49:32.726513	{adverbe,italien,fréquent,lieu}	2.7	6	2	\N	\N	\N	Under	Unter	Under	\N
828	39c39e4	22	Convincere	Convinto		\N	2025-12-08 16:20:08.778724	0	2025-12-09 16:20:08.778724	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Convinced	Überzeugt	resy lahatra	\N
2281	5cdd510	62	Réactivité	Reattività		\N	2026-02-24 15:24:59.622573	0	2026-02-25 15:24:59.622573	{sport,capacités,physique}	2.5	0	0	\N	\N	Capacità di rispondere rapidamente a uno stimolo.	Reactivity	Reaktionsfähigkeit	Fahafahana mamaly haingana	La reattività è essenziale negli sport di combattimento.
323	40a0024	12	Rapidement	Velocemente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/23e9.svg	2025-12-06 14:05:17.227837	2	2026-01-09 15:39:29.065599	{adverbe,italien,fréquent,manière}	2.7	6	2	\N	\N	\N	Quickly	Schnell	haingana	\N
329	95e4b9e	12	Certainement	Certamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f91d.svg	2025-12-06 14:05:17.366034	1	2026-01-04 15:36:52.475492	{adverbe,italien,fréquent,certitude}	2.4	1	1	\N	\N	\N	Certainly	Sicherlich	Azo antoka	\N
332	14fffac	12	Normalement	Normalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4d1.svg	2025-12-06 14:05:17.434523	2	2026-01-13 16:27:26.775726	{adverbe,italien,fréquent,habitude}	2.7	6	2	\N	\N	\N	Normally	Normalerweise	Raha ny mahazatra	\N
335	3cae6fb	12	Principalement	Principalmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3c6.svg	2025-12-06 14:05:17.5002	2	2026-01-09 15:43:47.57802	{adverbe,italien,fréquent,importance}	2.7	6	2	\N	\N	\N	Mainly	Hauptsächlich	indrindra	\N
338	fd05144	12	Absolument	Assolutamente		\N	2025-12-06 14:05:17.56599	0	2026-01-03 15:46:10.259536	{adverbe,italien,fréquent,degré}	1.8999999999999997	0	0	\N	\N	\N	Absolutely	Absolut	tanteraka	\N
362	11104dd	12	Autrefois	Una volta		\N	2025-12-06 14:05:18.127667	0	2026-01-07 16:38:08.075127	{adverbe,italien,fréquent,temps}	1.6999999999999997	0	0	\N	\N	\N	Once	Einmal	, indray mandeha	\N
305	1c8b95a	12	Avant	Prima		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/25c0.svg	2025-12-06 14:05:16.841912	2	2026-01-09 15:37:38.559579	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Before	Vor	Talohan'ny	\N
308	89a1294	12	Hier	Ieri		\N	2025-12-06 14:05:16.909007	2	2026-01-13 16:33:33.52484	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Yesterday	Gestern	Omaly	\N
311	48d24d5	12	Là	Lì		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4cc.svg	2025-12-06 14:05:16.97749	2	2026-01-09 15:49:03.452279	{adverbe,italien,fréquent,lieu}	2.7	6	2	\N	\N	\N	There	Dort	Ery	\N
320	6190f03	12	Tard	Tardi		\N	2025-12-06 14:05:17.170458	2	2026-01-09 15:48:57.775786	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Late	Spät	tara	\N
53	dc7d551	9	Savoir	Sapere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-03 13:33:22.5741	0	2025-12-04 13:33:22.5741	{verbe,italien,fréquent,cognition}	2.5	0	0	\N	\N	\N	Know	Wissen	Aoka ho fantatrao	\N
344	658b793	12	Littéralement	Letteralmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4d6.svg	2025-12-06 14:05:17.708464	2	2026-01-09 15:44:23.849206	{adverbe,italien,fréquent,manière}	2.7	6	2	\N	\N	\N	Literally	Buchstäblich	ara-bakiteny	\N
350	16f554c	12	Sincèrement	Sinceramente		\N	2025-12-06 14:05:17.847274	1	2026-01-04 15:47:18.567358	{adverbe,italien,fréquent,manière}	2.4	1	1	\N	\N	\N	Sincerely	Aufrichtig	amin-kitsimpo	\N
356	81b84a5	12	Néanmoins	Nondimeno		\N	2025-12-06 14:05:17.992545	1	2026-01-08 16:27:33.375512	{adverbe,italien,fréquent,contraste}	2.2	1	1	\N	\N	\N	Nonetheless	Dennoch	Na izany aza	\N
359	2eb5e4a	12	Autant	Altrettanto		\N	2025-12-06 14:05:18.059383	0	2026-01-07 16:37:45.762284	{adverbe,italien,fréquent,comparaison}	1.8999999999999997	0	0	\N	\N	\N	Likewise	Ebenfalls	Toy izany koa	\N
365	fe6285c	12	Actuellement	Attualmente		\N	2025-12-06 14:05:18.192582	1	2026-01-08 16:26:49.337175	{adverbe,italien,fréquent,temps}	2	1	1	\N	\N	\N	Currently	Momentan	Amin'izao fotoana izao	\N
54	341d9a2	9	Penser	Pensare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4ad.svg	2025-12-03 13:33:22.591924	0	2025-12-04 13:33:22.591924	{verbe,italien,fréquent,cognition}	2.5	0	0	\N	\N	\N	Think	Denken	Eritrereto	\N
56	630525c	9	Donner	Dare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f381.svg	2025-12-03 13:33:22.626541	0	2025-12-04 13:33:22.626541	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Give	Geben	Omeo	\N
317	2609ae0	12	En avant	Avanti		\N	2025-12-06 14:05:17.108961	1	2026-01-08 16:27:12.01725	{adverbe,italien,fréquent,direction}	2.2	1	1	\N	\N	\N	After you	\N	\N	\N
829	e9a799d	22	Risolvere	Risolto		\N	2025-12-08 16:20:08.798748	0	2025-12-09 16:20:08.798748	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Solved	Gelöst	voavaha	\N
398	f025dfd	13	Pouls	Polso		\N	2025-12-06 14:15:35.747937	0	2025-12-07 14:15:35.747937	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	Frequenza delle contrazioni cardiache percepita all'arteria.	Pulse	Puls	Pouls	Controlla il polso dopo l'allenamento.
407	3632851	13	Jambe	Gamba		\N	2025-12-06 14:15:36.001658	0	2025-12-07 14:15:36.001658	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Leg	Bein	tongotra	\N
408	d3f6010	13	Genou	Ginocchio		\N	2025-12-06 14:15:36.024976	0	2025-12-07 14:15:36.024976	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Knee	Knie	lohalika	\N
410	04359f3	13	Pied	Piede		\N	2025-12-06 14:15:36.065159	0	2025-12-07 14:15:36.065159	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Foot	Fuß	tongotra	\N
411	d58df01	13	Orteil	Dito del piede		\N	2025-12-06 14:15:36.086065	0	2025-12-07 14:15:36.086065	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Toe	Zehe	rantsan-tongony	\N
414	c460bad	13	Foie	Fegato		\N	2025-12-06 14:15:36.174079	0	2025-12-07 14:15:36.174079	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Liver	Leber	aty	\N
416	2af814a	13	Peau	Pelle		\N	2025-12-06 14:15:36.227848	0	2025-12-07 14:15:36.227848	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Skin	Haut	Hoditra	\N
1081	417c160	28	Préserver	Preservare		\N	2026-01-08 15:19:19.762241	1	2026-02-02 15:32:36.038356	{verbe,italien,conservation}	2.4	1	1	\N	\N	\N	Preserve	Bewahren	Arovy	\N
1082	06c3a16	28	Conserver	Conservare		\N	2026-01-08 15:19:19.783881	1	2026-02-02 15:22:27.279422	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Keep	Halten	Ataovy	\N
341	7ac26af	12	Complètement	Completamente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5dc.svg	2025-12-06 14:05:17.636712	2	2026-01-09 15:45:57.982364	{adverbe,italien,fréquent,degré}	2.7	6	2	\N	\N	\N	Completely	Vollständig	tanteraka	\N
347	d380ae3	12	Éventuellement	Eventualmente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2753.svg	2025-12-06 14:05:17.776789	1	2025-12-10 12:53:23.405708	{adverbe,italien,fréquent,possibilité}	2.6	1	1	\N	\N	\N	Possibly	Möglicherweise	Mety	\N
353	4e8d0b9	12	D’ailleurs	Inoltre		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2797.svg	2025-12-06 14:05:17.913746	0	2026-01-03 15:58:24.849817	{adverbe,italien,fréquent,addition}	2.0999999999999996	0	0	\N	\N	\N	Furthermore	Außerdem	koa	\N
377	de9f7be	12	Plus tôt	Più presto		\N	2025-12-06 14:05:18.465642	2	2026-01-09 15:47:28.73312	{adverbe,italien,fréquent,temps}	2.7	6	2	\N	\N	\N	Sooner	Früher	haingana	\N
382	4f5dcc7	13	Tête	Testa		\N	2025-12-06 14:15:35.121505	0	2025-12-07 14:15:35.121505	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Head	Kopf	LOHA	\N
383	ece98d0	13	Cheveux	Capelli		\N	2025-12-06 14:15:35.157899	0	2025-12-07 14:15:35.157899	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Hair	Haar	dia singam-bolo	\N
384	10b419f	13	Front	Fronte		\N	2025-12-06 14:15:35.208923	0	2025-12-07 14:15:35.208923	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Forehead	Stirn	Handrina	\N
386	1de4fc9	13	Œil	Occhio		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f441.svg	2025-12-06 14:15:35.303475	0	2025-12-07 14:15:35.303475	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Eye	Auge	maso	\N
395	c5f157c	13	Épaule	Spalla		\N	2025-12-06 14:15:35.634172	0	2025-12-07 14:15:35.634172	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Shoulder	Schulter	-tsorony	\N
396	049580d	13	Bras	Braccio		\N	2025-12-06 14:15:35.68441	0	2025-12-07 14:15:35.68441	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Arm	Arm	hiomana	\N
402	ee266cb	13	Poitrine	Petto		\N	2025-12-06 14:15:35.877086	0	2025-12-07 14:15:35.877086	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Chest	Brust	tratra	\N
404	638de66	13	Ventre	Pancia		\N	2025-12-06 14:15:35.93156	0	2025-12-07 14:15:35.93156	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Belly	Bauch	kibo	\N
405	c94beaf	13	Abdomen	Addome		\N	2025-12-06 14:15:35.954524	0	2025-12-07 14:15:35.954524	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Abdomen	Abdomen	kibony	\N
965	8b52841	25	Manique	Presina		\N	2025-12-11 15:25:46.959143	0	2025-12-12 15:25:46.959143	{cuisine,italien}	2.5	0	0	\N	\N	\N	Potholder	Topflappen	Potholder	\N
1696	c22f519	39	frontière	confine		\N	2026-01-30 16:23:23.733233	0	2026-01-31 16:23:23.733233	{nom,italien,transport}	2.5	0	0	\N	\N	\N	confine	beschränken	velively	\N
831	66ad49b	22	Mordere	Morso		\N	2025-12-08 16:20:08.848056	0	2025-12-09 16:20:08.848056	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Bite	Beißen	manaikitra	\N
832	0e998d2	22	Dipingere	Dipinto		\N	2025-12-08 16:20:08.866429	0	2025-12-09 16:20:08.866429	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Painting	Malerei	mandoko	\N
406	16db8d1	13	Hanche	Anca		\N	2025-12-06 14:15:35.976522	0	2025-12-07 14:15:35.976522	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Hip	Hüfte	valahana	\N
409	8149b97	13	Cheville	Caviglia		\N	2025-12-06 14:15:36.044802	0	2025-12-07 14:15:36.044802	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Ankle	Knöchel	dia fehin	\N
415	b0a0b57	13	Estomac	Stomaco		\N	2025-12-06 14:15:36.202193	0	2025-12-07 14:15:36.202193	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Stomach	Magen	vavony	\N
1367	ac0e46a	35	Donner un coup de main	Dare un mano		\N	2026-01-12 13:20:11.458334	0	2026-01-13 14:34:24.973891	{expression,italien,aide,coopération}	2.3	0	0	\N	\N	\N	Lend a hand	Helfen	\N	\N
1369	2fdc653	35	Surveiller	Tenere d’occhio		\N	2026-01-12 13:20:14.313747	0	2026-02-01 15:25:30.095348	{expression,italien,attention,vigilance}	2.3	0	0	\N	\N	\N	Keep an eye out	Halten Sie Ausschau	Araho maso	\N
1370	9852c5d	35	Ne pas dormir	Non chiudere occhio		\N	2026-01-12 13:20:15.990192	0	2026-02-01 15:26:09.449874	{expression,italien,sommeil,insomnie}	2.3	0	0	\N	\N	\N	Don't close your eyes	Schließe nicht deine Augen	Aza manakimpy ny masonao	\N
1372	72c7de7	35	Ne rien faire	Stare con le mani in mano		\N	2026-01-12 13:20:18.809062	1	2026-02-02 15:15:10.946041	{expression,italien,paresse,inactivité}	2.4	1	1	\N	\N	\N	Stand on your hands	Stehen Sie auf Ihren Händen	Mijoroa amin'ny tananao	\N
385	538baac	13	Visage	Viso		\N	2025-12-06 14:15:35.275987	0	2025-12-07 14:15:35.275987	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Face	Gesicht	Face	\N
388	73b5667	13	Oreille	Orecchio		\N	2025-12-06 14:15:35.359135	0	2025-12-07 14:15:35.359135	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Ear	Ohr	sofina	\N
1373	31f71e8	35	Se mêler de tout	Mettere il naso dappertutto		\N	2026-01-12 13:20:20.018754	1	2026-02-02 15:16:16.35208	{expression,italien,curiosité,intrusion}	2.6	1	1	\N	\N	\N	Sticking your nose everywhere	Steck deine Nase überall hin	Mampiraikitra ny oronao eny rehetra eny	\N
1374	f1ca6e1	35	Être dans la lune	Avere la testa tra le nuvole		\N	2026-01-12 13:20:21.96522	1	2026-02-02 15:18:38.594694	{expression,italien,rêverie,distraction}	2.6	1	1	\N	\N	\N	Having your head in the clouds	Mit dem Kopf in den Wolken	Manana ny lohanao eny amin'ny rahona	\N
1375	3953e3d	35	Se creuser la tête	Spremersi il cervello		\N	2026-01-12 13:20:23.143466	1	2026-02-02 15:15:48.788855	{expression,italien,réflexion,problème}	2.6	1	1	\N	\N	\N	Racking your brain	Zermartere dir den Kopf	Manimba ny atidohanao	\N
1734	23a6781	40	Créatif	creativo		\N	2026-01-31 15:19:21.560904	0	2026-02-01 15:19:21.560904	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona capace di produrre idee originali e soluzioni innovative.	Creative	Kreativ	Mamorina	Il suo approccio creativo ha salvato il progetto.
2282	82a2820	62	Élasticité	Elasticità		\N	2026-02-24 15:25:05.656417	0	2026-02-25 15:25:05.656417	{sport,capacités,physique}	2.5	0	0	\N	\N	Capacità dei muscoli di allungarsi e tornare alla posizione iniziale.	Elasticity	Elastizität	Fahafahana miolana	L'elasticità muscolare previene gli stiramenti.
2283	09f804e	62	Rapidité	Rapidità		\N	2026-02-24 15:25:13.159852	0	2026-02-25 15:25:13.159852	{sport,capacités,physique}	2.5	0	0	\N	\N	Capacità di compiere movimenti veloci.	Speed	Schnelligkeit	Hafaingana	La rapidità di esecuzione distingue i grandi campioni.
2284	32cbffc	62	Technique	Tecnica		\N	2026-02-24 15:25:17.864852	0	2026-02-25 15:25:17.864852	{sport,performance}	2.5	0	0	\N	\N	Insieme di gesti corretti ed efficienti di uno sport.	Technique	Technik	Teknika	Una buona tecnica riduce il rischio di infortuni.
1046	e0d0b07	28	Air	Aria		\N	2026-01-08 15:19:18.029126	1	2026-02-02 15:31:59.402439	{nom,italien,air}	2.6	1	1	\N	\N	\N	Air	Luft	Air	\N
1376	b8b618b	35	Réfléchir	Usare il cervello		\N	2026-01-12 13:20:24.655311	3	2026-02-23 15:16:00.683865	{expression,italien,réflexion,logique}	2.8	22	3	\N	\N	\N	Use your brain	Benutze dein Gehirn	Ampiasao ny atidohanao	\N
2285	cb0fb6b	62	Tactique	Tattica		\N	2026-02-24 15:25:25.318983	0	2026-02-25 15:25:25.318983	{sport,performance}	2.5	0	0	\N	\N	Strategia di gioco per superare l'avversario.	Tactics	Taktik	Taktika	La tattica difensiva ha portato alla vittoria.
2286	715580c	62	Préparateur	Preparatore		\N	2026-02-24 15:25:32.363321	0	2026-02-25 15:25:32.363321	{sport,entraînement}	2.5	0	0	\N	\N	Esperto che si occupa della preparazione fisica specifica.	Trainer	Vorbereiter	Mpampiofana	Il preparatore atletico ha creato un programma personalizzato.
2287	41ebb47	62	Défi	Sfida		\N	2026-02-24 15:25:38.365727	0	2026-02-25 15:25:38.365727	{sport,mental}	2.5	0	0	\N	\N	Prova che stimola a superare i propri limiti.	Challenge	Herausforderung	Fanamby	Ogni gara è una sfida personale.
1377	a819e9a	35	Avoir le cerveau en bouillie	Avere il cervello in pappa		\N	2026-01-12 13:20:25.974045	1	2026-02-02 15:19:24.514749	{expression,italien,fatigue,confusion}	2.6	1	1	\N	\N	\N	Having your brains in mush	Dein Gehirn im Brei haben	Manana ny atidohanao amin'ny mush	\N
1378	b7c110d	35	Se faire du souci	Farsi il sangue amaro		\N	2026-01-12 13:20:27.81413	1	2026-02-02 15:19:16.336918	{expression,italien,inquiétude,stress}	2.6	1	1	\N	\N	\N	Getting bitter	Wird bitter	Lasa mangidy	\N
60	8536b9f	9	Utiliser	Usare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f6e0.svg	2025-12-03 13:33:22.70008	0	2025-12-04 13:33:22.70008	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Use	Verwenden	Ampiasao	\N
1381	e365f76	35	Être sur toutes les lèvres	Essere sulla bocca di tutti		\N	2026-01-12 13:20:32.592291	1	2026-01-14 14:24:41.286295	{expression,italien,communication,buzz}	2.6	1	1	\N	\N	\N	Be on everyone's lips	Seien Sie in aller Munde	Aoka ho eo am-bavan'ny tsirairay	\N
1382	d76b105	35	Tourner le dos	Voltare le spalle		\N	2026-01-12 13:20:34.693168	2	2026-02-07 15:19:34.545398	{expression,italien,attitude,rejet}	2.7	6	2	\N	\N	\N	Turn your back	Dreh dir den Rücken zu	Mihodina ny lamosinao	\N
1379	035ed92	35	Avoir le cœur qui bat très fort	Avere il cuore in gola		\N	2026-01-12 13:20:29.620133	1	2026-02-02 15:19:09.398416	{expression,italien,émotion,peur}	2.6	1	1	\N	\N	\N	Having your heart in your mouth	Das Herz im Mund haben	Manana ny fonao eo am-bavanao	\N
1380	59dc24b	35	Porter sur le cœur	Avere qualcosa sul cuore		\N	2026-01-12 13:20:30.844123	2	2026-02-07 15:18:58.161054	{expression,italien,émotion,confession}	2.7	6	2	\N	\N	\N	Have something on your heart	Habe etwas auf deinem Herzen	Manàna zavatra ao am-ponao	\N
1383	0d320a8	35	Se donner à fond	Farsi in quattro		\N	2026-01-12 13:20:35.898689	2	2026-02-07 15:15:40.436703	{expression,italien,effort,détermination}	2.7	6	2	\N	\N	\N	Go out of your way	Geh dir aus dem Weg	Mialà amin'ny lalanao	\N
1385	c2dc92b	35	Être à portée de main	Essere a portata di mano		\N	2026-01-12 13:20:38.365857	1	2026-02-02 15:18:49.820447	{expression,italien,accessibilité,proximité}	2.6	1	1	\N	\N	\N	Be within reach	Seien Sie in Reichweite	Aoka ho azo antoka	\N
1387	d7137e4	35	Avoir très faim	Avere un buco nello stomaco		\N	2026-01-12 13:20:40.643444	2	2026-02-07 15:16:26.243983	{expression,italien,faim,estomac}	2.7	6	2	\N	\N	\N	Having a hole in your stomach	Ein Loch im Bauch haben	Misy loaka ny kibonao	\N
1384	3f079b1	35	Mettre le doigt sur le problème	Mettere il dito nella piaga		\N	2026-01-12 13:20:37.077091	1	2026-02-02 15:16:54.382704	{expression,italien,problème,blessure}	2.6	1	1	\N	\N	\N	Putting your finger on the wound	Legen Sie Ihren Finger auf die Wunde	Mametraka ny rantsantanana eo amin'ny fery	\N
1386	bba731d	35	Avoir quelque chose sur la conscience	Avere un peso sullo stomaco		\N	2026-01-12 13:20:39.536565	1	2026-01-14 14:31:44.351248	{expression,italien,émotion,culpabilité}	2.6	1	1	\N	\N	\N	Having a weight on your stomach	Ein Gewicht auf dem Bauch haben	Manana lanja eo amin'ny vavony	\N
833	8e9a8d7	22	Distinguere	Distinto		\N	2025-12-08 16:20:08.885615	0	2025-12-09 16:20:08.885615	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Distinct	Unterscheidbar	Miavaka	\N
1395	c5dbd5b	36	Être dans les problèmes	Essere nei guai		\N	2026-01-20 14:49:12.258771	0	2026-01-21 14:49:12.258771	{expression,idiomatique,italien,fréquent,situation}	2.5	0	0	\N	\N	\N	Being in trouble	In Schwierigkeiten sein	Tojo olana	\N
1396	66e26ce	36	Avoir les idées claires	Avere le idee chiare		\N	2026-01-20 14:49:12.284378	0	2026-01-21 14:49:12.284378	{expression,idiomatique,italien,fréquent,mental}	2.5	0	0	\N	\N	\N	Have clear ideas	Haben Sie klare Vorstellungen	Manàna hevitra mazava	\N
1397	7c9d533	36	Perdre patience	Perdere la pazienza		\N	2026-01-20 14:49:12.310055	0	2026-01-21 14:49:12.310055	{expression,idiomatique,italien,fréquent,émotion}	2.5	0	0	\N	\N	\N	Losing patience	Die Geduld verlieren	Very faharetana	\N
61	859fdd6	9	Travailler	Lavorare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4bc.svg	2025-12-03 13:33:22.722596	0	2025-12-04 13:33:22.722596	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Work	Arbeiten	ASA	\N
62	46f38a2	9	Entendre	Sentire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f442.svg	2025-12-03 13:33:22.747366	0	2025-12-04 13:33:22.747366	{verbe,italien,fréquent,perception}	2.5	0	0	\N	\N	\N	Feel	Fühlen	hahatsapa	\N
64	4b12e39	9	Tenir	Tenere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/270a.svg	2025-12-03 13:33:22.786061	1	2025-12-08 07:01:10.929421	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	Hold	Halten	MANOHANA	\N
69	3ecc72b	9	Mettre	Mettere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e6.svg	2025-12-03 13:33:22.896711	0	2025-12-04 13:33:22.896711	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Put	Setzen	Nampiditra	\N
70	475678f	9	Porter	Portare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f392.svg	2025-12-03 13:33:22.92425	0	2025-12-04 13:33:22.92425	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Bring	Bringen	Mitondrà	\N
71	e5ba241	9	Regarder	Guardare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f440.svg	2025-12-03 13:33:22.948436	0	2025-12-04 13:33:22.948436	{verbe,italien,fréquent,perception}	2.5	0	0	\N	\N	\N	Watch	Betrachten	Jereo	\N
72	be77469	9	Manger	Mangiare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f37d.svg	2025-12-03 13:33:22.971854	0	2025-12-04 13:33:22.971854	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Eat	Essen	Hanina	\N
73	761e997	9	Boire	Bere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f964.svg	2025-12-03 13:33:22.995682	0	2025-12-04 13:33:22.995682	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Drink	Trinken	zava-pisotro	\N
74	e94e388	9	Dormir	Dormire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f634.svg	2025-12-03 13:33:23.021181	0	2025-12-04 13:33:23.021181	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Sleep	Schlafen	torimaso	\N
76	e33b782	9	Lire	Leggere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4d6.svg	2025-12-03 13:33:23.075797	0	2025-12-04 13:33:23.075797	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Light	Licht	fahazavana	\N
368	ba5ea94	12	Brièvement	Brevemente		\N	2025-12-06 14:05:18.260584	0	2026-01-03 15:57:02.19583	{adverbe,italien,fréquent,manière}	2.4	0	0	\N	\N	\N	Briefly	Knapp	fohifohy	\N
371	3aae504	12	Fortement	Fortemente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-06 14:05:18.326853	0	2026-01-03 15:48:32.49746	{adverbe,italien,fréquent,degré}	2.1999999999999997	0	0	\N	\N	\N	Strongly	Stark	mafy	\N
374	c9ef42f	12	À peine	Appena		\N	2025-12-06 14:05:18.40066	1	2026-01-04 15:45:22.293557	{adverbe,italien,fréquent,temps}	2.4	1	1	\N	\N	\N	As soon as	Sobald	Vantany vao	\N
1398	aae01f6	36	Être fauché	Essere a corto di soldi		\N	2026-01-20 14:49:12.339744	0	2026-01-21 14:49:12.339744	{expression,idiomatique,italien,fréquent,argent}	2.5	0	0	\N	\N	\N	Being short of money	Mangel an Geld	Tsy ampy vola	\N
1399	3bbfeaf	36	Bien s’entendre	Andare d’accordo		\N	2026-01-20 14:49:12.368882	0	2026-01-21 14:49:12.368882	{expression,idiomatique,italien,fréquent,relation}	2.5	0	0	\N	\N	\N	Get along	Komm zurecht	Mifanaraka	\N
1400	ef9f98a	36	Faire comme si de rien n’était	Fare finta di niente		\N	2026-01-20 14:49:12.391245	0	2026-01-21 14:49:12.391245	{expression,idiomatique,italien,fréquent,attitude}	2.5	0	0	\N	\N	\N	Pretend nothing happened	Stellen Sie sich vor, es wäre nichts passiert	Mody tsy nisy nitranga	\N
1401	52ad172	36	Tourner la page	Metterci una pietra sopra		\N	2026-01-20 14:49:12.418823	0	2026-01-21 14:49:12.418823	{expression,idiomatique,italien,fréquent,émotion}	2.5	0	0	\N	\N	\N	Put a stone on it	Legen Sie einen Stein darauf	Asio vato eo amboniny	\N
834	52d62bb	22	Appendere	Appeso		\N	2025-12-08 16:20:08.904795	0	2025-12-09 16:20:08.904795	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Hanging	Hängend	mihantona	\N
837	446fb31	22	Piacere	Piaciuto		\N	2025-12-08 16:20:08.972533	0	2025-12-09 16:20:08.972533	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Liked it	Hat mir gefallen	Tia azy	\N
838	f46a238	22	Produrre	Prodotto		\N	2025-12-08 16:20:09.000678	0	2025-12-09 16:20:09.000678	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Product	Produkt	vokatra	\N
839	891e9bc	22	Redigere	Redatto		\N	2025-12-08 16:20:09.025184	0	2025-12-09 16:20:09.025184	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Redacted	Redigiert	Redacted	\N
2288	fadaebe	62	Compétition	Competizione		\N	2026-02-24 15:25:44.500133	0	2026-02-25 15:25:44.500133	{sport,performance}	2.5	0	0	\N	\N	Evento in cui gli atleti si confrontano per vincere.	Competition	Wettkampf	Fifaninanana	La competizione porta il meglio di ogni sportivo.
2435	0adc4ca	63	Base de données	Database		\N	2026-02-24 15:51:10.945	0	2026-02-25 15:51:10.945	{science,numérique,information}	2.5	0	0	\N	\N	Raccolta organizzata di dati strutturati.	Database	Datenbank	Base de données	Il database è stato aggiornato.
380	0576875	12	De plus	Per di più		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2797.svg	2025-12-06 14:05:18.535537	0	2026-01-03 15:56:49.924705	{adverbe,italien,fréquent,addition}	2.5	0	0	\N	\N	\N	What's more	Was mehr ist	Inona koa	\N
387	29931a9	13	Yeux	Occhi		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f440.svg	2025-12-06 14:15:35.329126	0	2025-12-07 14:15:35.329126	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Eyes	Augen	maso	\N
389	0f8a23b	13	Nez	Naso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f443.svg	2025-12-06 14:15:35.388899	0	2025-12-07 14:15:35.388899	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Nose	Nase	orona	\N
883	accac8e	24	Livre	Libro		\N	2025-12-10 15:39:05.916988	0	2025-12-11 15:39:05.916988	{maison,italien}	2.5	0	0	\N	\N	\N	Book	Buch	Boky	\N
1366	a62574d	35	En un clin d’œil	In un batter d’occhio		\N	2026-01-12 13:20:10.344999	1	2026-02-02 15:16:46.100966	{expression,italien,temps,rapide}	2.6	1	1	\N	\N	\N	In the blink of an eye	Im Handumdrehen	Amin'ny indray mipi-maso	\N
1402	581d155	36	Être occupé	Avere da fare		\N	2026-01-20 14:49:12.44433	0	2026-01-21 14:49:12.44433	{expression,idiomatique,italien,fréquent,quotidien}	2.5	0	0	\N	\N	\N	Have to do	Muss tun	Tsy maintsy atao	\N
1403	9e861ee	36	Ne plus en pouvoir	Non farcela più		\N	2026-01-20 14:49:12.47004	0	2026-01-21 14:49:12.47004	{expression,idiomatique,italien,fréquent,fatigue}	2.5	0	0	\N	\N	\N	Don't do it anymore	Tu es nicht mehr	Aza manao izany intsony	\N
1404	510f1b8	36	Être sur le point de	Essere sul punto di		\N	2026-01-20 14:49:12.492939	0	2026-01-21 14:49:12.492939	{expression,idiomatique,italien,fréquent,temps}	2.5	0	0	\N	\N	\N	Be on the verge of	\N	\N	\N
2436	16c634b	63	Serveur	Server		\N	2026-02-24 15:51:17.840121	0	2026-02-25 15:51:17.840121	{science,numérique,information}	2.5	0	0	\N	\N	Computer che fornisce servizi ad altri dispositivi.	Server	Server	Serveur	Il server è sempre attivo.
2437	59e5f45	63	Cryptographie	Crittografia		\N	2026-02-24 15:51:25.40999	0	2026-02-25 15:51:25.40999	{science,numérique,information}	2.5	0	0	\N	\N	Scienza della protezione delle informazioni.	Cryptography	Kryptographie	Cryptographie	La crittografia garantisce la sicurezza dei dati.
2438	1ce6d9d	63	Flux	Flusso		\N	2026-02-24 15:51:37.556202	0	2026-02-25 15:51:37.556202	{science,numérique,information}	2.5	0	0	\N	\N	Movimento continuo di dati o informazioni.	Flow	Fluss	Flux	Il flusso di dati è costante.
2439	e039ba6	63	Matériel	Hardware		\N	2026-02-24 15:51:44.113014	0	2026-02-25 15:51:44.113014	{science,numérique,information}	2.5	0	0	\N	\N	Componenti fisici di un computer.	Hardware	Hardware	Matériel	L'hardware è stato aggiornato.
2440	0b4c1ef	63	Virtuel	Virtuale		\N	2026-02-24 15:51:50.887083	0	2026-02-25 15:51:50.887083	{science,numérique,information}	2.5	0	0	\N	\N	Simulato da un computer, non fisico.	Virtual	Virtuell	Virtuel	La realtà virtuale è molto immersiva.
890	e1e766a	24	Évier	Lavello		\N	2025-12-10 15:39:06.054349	0	2025-12-11 15:39:06.054349	{maison,italien}	2.5	0	0	\N	\N	\N	Sink	Waschbecken	hilentika	\N
1405	ac27d8f	36	Prendre une décision	Prendere una decisione		\N	2026-01-20 14:49:12.517541	0	2026-01-21 14:49:12.517541	{expression,idiomatique,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Make a decision	Treffen Sie eine Entscheidung	Manaova fanapahan-kevitra	\N
1406	dd21cda	36	Trouver le temps	Trovare il tempo		\N	2026-01-20 14:49:12.544206	0	2026-01-21 14:49:12.544206	{expression,idiomatique,italien,fréquent,temps}	2.5	0	0	\N	\N	\N	Find the time	Finden Sie die Zeit	Tadiavo ny fotoana	\N
85	8f4a5a9	9	Apprendre	Imparare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-03 13:33:23.431504	0	2025-12-04 13:33:23.431504	{verbe,italien,fréquent,éducation}	2.5	0	0	\N	\N	\N	Learn	Lernen	-PANAZAVANA	\N
91	ef1a0fb	9	Revenir	Tornare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f501.svg	2025-12-03 13:33:23.558792	0	2025-12-04 13:33:23.558792	{verbe,italien,fréquent,mouvement}	2.5	0	0	\N	\N	\N	Return	Zurückkehren	Miverena	\N
94	0c4af02	9	Vivre	Vivere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f331.svg	2025-12-03 13:33:23.627063	0	2025-12-04 13:33:23.627063	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Live	Live	velona	\N
96	e70f5d2	9	Naître	Nascere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f476.svg	2025-12-03 13:33:23.66462	0	2025-12-07 07:11:07.041073	{verbe,italien,fréquent,vie}	2.3	0	0	\N	\N	\N	Be born	Geboren werden	Teraka	\N
99	7a9b37e	9	Payer	Pagare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4b3.svg	2025-12-03 13:33:23.721252	0	2025-12-04 13:33:23.721252	{verbe,italien,fréquent,vie}	2.5	0	0	\N	\N	\N	Pay	Zahlen	KARAMANY	\N
100	006adb4	9	Envoyer	Inviare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e7.svg	2025-12-03 13:33:23.740125	0	2025-12-04 13:33:23.740125	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Send	Schicken	Alefaso	\N
101	fa95939	9	Recevoir	Ricevere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e9.svg	2025-12-03 13:33:23.759047	0	2025-12-04 13:33:23.759047	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Receive	Erhalten	Raiso	\N
102	d01f87d	9	Rire	Ridere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f602.svg	2025-12-03 13:33:23.779565	0	2025-12-04 13:33:23.779565	{verbe,italien,fréquent,émotion}	2.5	0	0	\N	\N	\N	LAUGH	LACHEN	ihomehezana	\N
103	22d83d8	9	Sourire	Sorridere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f60a.svg	2025-12-03 13:33:23.798557	0	2025-12-04 13:33:23.798557	{verbe,italien,fréquent,émotion}	2.5	0	0	\N	\N	\N	Smile	Lächeln	tsiky	\N
390	86f40a0	13	Bouche	Bocca		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f444.svg	2025-12-06 14:15:35.414737	0	2025-12-07 14:15:35.414737	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Mouth	Mund	vava	\N
392	adf469b	13	Langue	Lingua		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f445.svg	2025-12-06 14:15:35.483755	0	2025-12-07 14:15:35.483755	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Tongue	Zunge	Tongue	\N
399	43e55a1	13	Main	Mano		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/270b.svg	2025-12-06 14:15:35.776271	0	2025-12-07 14:15:35.776271	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Hand	Hand	TANAN'ILAY	\N
401	bdbeb28	13	Pouce	Pollice		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44d.svg	2025-12-06 14:15:35.846913	0	2025-12-07 14:15:35.846913	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Thumb	Daumen	ankihibe	\N
413	5b68915	13	Poumon	Polmone		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fac1.svg	2025-12-06 14:15:36.14426	0	2025-12-07 14:15:36.14426	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Lung	Lunge	avokavoka	\N
417	364cd46	13	Os	Osso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9b4.svg	2025-12-06 14:15:36.252046	0	2025-12-07 14:15:36.252046	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Bone	Knochen	taolana	\N
419	31ecc42	13	Cerveau	Cervello		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-06 14:15:36.294365	0	2025-12-07 14:15:36.294365	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Brain	Gehirn	atidoha	\N
1407	364baec	36	Faire de son mieux	Fare del proprio meglio		\N	2026-01-20 14:49:12.569621	0	2026-01-21 14:49:12.569621	{expression,idiomatique,italien,fréquent,effort}	2.5	0	0	\N	\N	\N	Do your best	Gib dein Bestes	Ataovy izay fara herinao	\N
1408	35fc09d	36	Avoir besoin de	Avere bisogno di		\N	2026-01-20 14:49:12.59194	0	2026-01-21 14:49:12.59194	{expression,idiomatique,italien,fréquent,nécessité}	2.5	0	0	\N	\N	\N	Need	Brauchen	NILA	\N
1409	7dac015	36	Dire la vérité	Dire la verità		\N	2026-01-20 14:49:12.617539	0	2026-01-21 14:49:12.617539	{expression,idiomatique,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Tell the truth	Sag die Wahrheit	Lazao ny marina	\N
856	5eb11a2	23	Quando è diventato famoso in televisione?	È diventato famoso negli anni dopo gli spettacoli teatrali.		\N	2025-12-10 08:41:45.478833	0	2025-12-11 08:43:19.713643	{italien,A2,télévision,"Roberto Benigni"}	2.0999999999999996	0	0	\N	\N	\N	He became famous in the years after the stage shows.	Berühmt wurde er in den Jahren nach den Bühnenshows.	Nalaza izy tamin'ny taona taorian'ny seho an-tsehatra.	\N
859	4b5c457	23	Con quali registi famosi ha lavorato?	Ha lavorato con Costa-Gavras, Marco Ferreri e Jim Jarmusch.		\N	2025-12-10 08:41:45.544006	2	2025-12-16 09:02:00.027826	{italien,A2,cinéma,"Roberto Benigni"}	2.5	6	2	\N	\N	\N	He worked with Costa-Gavras, Marco Ferreri and Jim Jarmusch.	Er arbeitete mit Costa-Gavras, Marco Ferreri und Jim Jarmusch.	Niara-niasa tamin'i Costa-Gavras, Marco Ferreri ary Jim Jarmusch izy.	\N
967	6dee179	25	Tamis	Setaccio		\N	2025-12-11 15:25:47.002313	0	2025-12-12 15:25:47.002313	{cuisine,italien}	2.5	0	0	\N	\N	\N	Sieve	Sieb	sivana	\N
1501	7e988c0	37	sandwich	panini		\N	2026-01-21 14:50:00.795427	0	2026-01-22 14:50:00.795427	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	sandwiches	Sandwiches	mofo voasesika	\N
546	f86985a	17	Les parents	I genitori		\N	2025-12-07 06:08:34.989668	0	2025-12-08 06:08:34.989668	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The parents	Die Eltern	Ny ray aman-dreny	\N
548	bacacd0	17	La fille	La figlia		\N	2025-12-07 06:08:35.031557	0	2025-12-08 06:08:35.031557	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The daughter	Die Tochter	Ny zanakavavy	\N
549	7c630b1	17	Le frère	Il fratello		\N	2025-12-07 06:08:35.052288	0	2025-12-08 06:08:35.052288	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The brother	Der Bruder	Ny rahalahy	\N
550	d7a0fad	17	La sœur	La sorella		\N	2025-12-07 06:08:35.075121	0	2025-12-08 06:08:35.075121	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The sister	Die Schwester	Ny anabavy	\N
551	c735708	17	Les frères et sœurs	I fratelli		\N	2025-12-07 06:08:35.096109	0	2025-12-08 06:08:35.096109	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The brothers	Die Brüder	Ireo rahalahy	\N
552	5f886b1	17	Le grand-père	Il nonno		\N	2025-12-07 06:08:35.118679	0	2025-12-08 06:08:35.118679	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The grandfather	Der Großvater	Ny dadabe	\N
1389	431dd09	35	Faire la sourde oreille	Fare orecchie da mercante		\N	2026-01-13 14:35:38.05674	0	2026-01-14 14:35:38.05674	{expression,ignorance}	2.5	0	0	\N	\N	\N	Turn a deaf ear	Ein taubes Ohr für jdn. haben	Mody manao be marenina	\N
843	a44bc2a	23	Dove è nato Benigni?	È nato in Toscana, vicino alla città di Arezzo.		\N	2025-12-10 08:41:45.132205	1	2025-12-11 08:54:04.560935	{italien,A2,géographie,"Roberto Benigni"}	2.6	1	1	\N	\N	\N	He was born in Tuscany, near the city of Arezzo.	Er wurde in der Toskana, in der Nähe der Stadt Arezzo, geboren.	Teraka tany Tuscany, akaikin’ny tanànan’i Arezzo izy.	\N
844	95f956b	23	Com'era la sua infanzia?	La sua infanzia è stata tranquilla e molto serena.		\N	2025-12-10 08:41:45.164178	0	2025-12-11 08:44:51.314181	{italien,A2,infanzia,"Roberto Benigni"}	1.7999999999999998	0	0	\N	\N	\N	His childhood was calm and very peaceful.	Seine Kindheit war ruhig und sehr friedlich.	Tony sy tena nilamina ny fahazazany.	\N
845	684cf5b	23	Com'era la sua famiglia?	Era una famiglia semplice e lavoratrice.		\N	2025-12-10 08:41:45.188681	2	2025-12-16 13:58:30.711677	{italien,A2,famille,"Roberto Benigni"}	2.8	6	2	\N	\N	\N	It was a simple, working family.	Es war eine einfache, arbeitende Familie.	Fianakaviana tsotra sy miasa izy io.	\N
846	1f3c57f	23	Che lavoro faceva suo padre?	Suo padre lavorava come contadino e falegname.		\N	2025-12-10 08:41:45.220281	2	2025-12-16 15:18:48.951958	{italien,A2,métiers,"Roberto Benigni"}	2.2	6	2	\N	\N	\N	His father worked as a farmer and carpenter.	Sein Vater arbeitete als Landwirt und Zimmermann.	Mpamboly sy mpandrafitra ny rainy.	\N
968	2bf68b9	25	Presse-agrumes	Spremiagrumi		\N	2025-12-11 15:25:47.022922	0	2025-12-12 15:25:47.022922	{cuisine,italien}	2.5	0	0	\N	\N	\N	Juicer	Entsafter	Juicer	\N
111	825a997	9	Coller	Incollare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4ce.svg	2025-12-03 13:33:23.94909	0	2025-12-04 13:33:23.94909	{verbe,italien,fréquent,maison}	2.5	0	0	\N	\N	\N	Paste	Paste	Mametaka	\N
113	5e473fd	9	Construire	Costruire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9f1.svg	2025-12-03 13:33:23.987052	0	2025-12-04 13:33:23.987052	{verbe,italien,fréquent,travail}	2.5	0	0	\N	\N	\N	Build	Bauen	manaova	\N
557	df7a173	17	Les petits-enfants	I nipoti		\N	2025-12-07 06:08:35.222903	0	2025-12-08 06:08:35.222903	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The grandchildren	Die Enkel	Ny zafikely	\N
593	41c808e	18	Hôtesse de l’air	Assistente di volo		\N	2025-12-07 06:20:58.279979	0	2025-12-08 06:20:58.279979	{métier,italien}	2.5	0	0	\N	\N	\N	Flight attendant	Flugbegleiterin	Hotesy	\N
1300	253a369	32	Bonne chance	In bocca al lupo		\N	2026-01-12 12:49:14.348706	0	2026-01-13 12:49:14.348706	{expression,italien,animal,chance}	2.5	0	0	\N	\N	\N	Good luck	Viel Glück	Mirary anao ho tsara vintana	\N
1303	850b2bc	32	Faire d’une pierre deux coups	Prendere due piccioni con una fava		\N	2026-01-12 12:49:14.433743	0	2026-01-13 12:49:14.433743	{expression,italien,animal,action}	2.5	0	0	\N	\N	\N	Kill two birds with one stone	Schlagen Sie zwei Fliegen mit einer Klappe	Vonoy ny vorona roa amin'ny vato iray	\N
1502	26c5f85	37	yaourt	yogurt		\N	2026-01-21 14:50:00.818305	0	2026-01-22 14:50:00.818305	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	yogurt	Joghurt	yaorta	\N
1503	c5971d0	37	ricotta	ricotta		\N	2026-01-21 14:50:00.843671	0	2026-01-22 14:50:00.843671	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	ricotta	Ricotta	ricotta	\N
1504	e92418c	37	mozzarella	mozzarella		\N	2026-01-21 14:50:00.861215	0	2026-01-22 14:50:00.861215	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	Mozzarella	Mozzarella	Mozzarella	\N
1505	eed31a5	37	croissant	cornetto		\N	2026-01-21 14:50:00.878512	0	2026-01-22 14:50:00.878512	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	croissant	Croissant	croissant	\N
1506	d25afeb	37	basilic	basilico		\N	2026-01-21 14:50:00.896087	0	2026-01-22 14:50:00.896087	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	basil	Basilikum	basilika	\N
848	70ccf49	23	Quante sorelle aveva?	Aveva tre sorelle.		\N	2025-12-10 08:41:45.301956	0	2025-12-11 08:43:35.659996	{italien,A2,famille,"Roberto Benigni"}	1.6999999999999997	0	0	\N	\N	\N	He had three sisters.	Er hatte drei Schwestern.	Nanana rahavavy telo izy.	\N
561	84e5b13	17	La cousine	La cugina		\N	2025-12-07 06:08:35.311963	0	2025-12-08 06:08:35.311963	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The cousin	Der Cousin	Ny cousin	\N
850	0a152a6	23	Che lavoro ha fatto durante gli studi?	Ha lavorato come apprendista mago.		\N	2025-12-10 08:41:45.345974	4	2026-03-04 14:08:49.291214	{italien,A2,métiers,"Roberto Benigni"}	2.9	84	4	\N	\N	\N	He worked as a magician's apprentice.	Er arbeitete als Zauberlehrling.	Niasa ho mpiofana mpanao ody izy.	\N
420	4320ec7	13	Sang	Sangue		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fa78.svg	2025-12-06 14:15:36.319458	0	2025-12-07 14:15:36.319458	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Blood	Blut	ra	\N
391	b1c3f2b	13	Dent	Dente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9b7.svg	2025-12-06 14:15:35.452574	0	2025-12-07 14:15:35.452574	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Tooth	Zahn	Nify	\N
400	03e25dc	13	Doigt	Dito		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/261d.svg	2025-12-06 14:15:35.810479	0	2025-12-07 14:15:35.810479	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Finger	Finger	rantsan-	\N
851	f56d00d	23	Cosa gli piaceva fare da giovane?	Gli piaceva divertire le persone e farle ridere.		\N	2025-12-10 08:41:45.369176	2	2025-12-16 08:57:58.959821	{italien,A2,loisirs,"Roberto Benigni"}	2.5	6	2	\N	\N	\N	He liked to entertain people and make them laugh.	Er liebte es, Menschen zu unterhalten und zum Lachen zu bringen.	Tia mampiala voly sy mampihomehezan’ny olona izy.	\N
852	4eb7578	23	Chi lo ha scoperto a vent’anni?	Un regista di Roma lo ha visto durante uno spettacolo.		\N	2025-12-10 08:41:45.389449	2	2025-12-16 08:56:29.062016	{italien,A2,cinéma,"Roberto Benigni"}	2.5	6	2	\N	\N	\N	A director from Rome saw him during a show.	Ein Regisseur aus Rom sah ihn während einer Show.	Nisy tale avy any Roma nahita azy nandritra ny fampisehoana.	\N
970	42774e1	25	Couvert	Coperto		\N	2025-12-11 15:25:47.086308	0	2025-12-12 15:25:47.086308	{cuisine,italien}	2.5	0	0	\N	\N	\N	Covered	Bedeckt	Voaresaka	\N
971	0a52920	25	Planche à découper	Tagliere		\N	2025-12-11 15:25:47.11448	0	2025-12-12 15:25:47.11448	{cuisine,italien}	2.5	0	0	\N	\N	\N	Cutting board	Schneidebrett	Tapa-kazo	\N
972	e18ddba	25	Tasse	Tazza		\N	2025-12-11 15:25:47.150158	0	2025-12-12 15:25:47.150158	{cuisine,italien}	2.5	0	0	\N	\N	\N	Cup	Tasse	kapoaka	\N
1508	8e2489a	37	farine	farina		\N	2026-01-21 14:50:00.930666	0	2026-01-22 14:50:00.930666	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	Flour	Mehl	koba tsara toto	\N
1509	83fc3ac	37	céréales	cereali		\N	2026-01-21 14:50:00.948249	0	2026-01-22 14:50:00.948249	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cereals	Getreide	voamadinika	\N
855	08b7e0d	23	Cosa ha imparato a teatro?	Ha imparato a parlare davanti al pubblico e a muoversi sul palco.		\N	2025-12-10 08:41:45.456932	1	2025-12-11 14:11:31.532989	{italien,A2,théâtre,"Roberto Benigni"}	2.6	1	1	\N	\N	\N	He learned to speak in front of the audience and to move on stage.	Er lernte, vor Publikum zu sprechen und sich auf der Bühne zu bewegen.	Nianatra niteny teo anatrehan’ny mpanatrika sy nifindra toerana izy.	\N
858	67b3af8	23	Quando inizia la sua carriera nel cinema?	Inizia nel 1976 con il film 'Berlinguer ti voglio bene'.		\N	2025-12-10 08:41:45.522204	0	2025-12-11 08:44:28.726638	{italien,A2,cinéma,"Roberto Benigni"}	2.0999999999999996	0	0	\N	\N	\N	It began in 1976 with the film 'Berlinguer I love you'.	Es begann 1976 mit dem Film „Berlinguer, ich liebe dich“.	Nanomboka tamin'ny 1976 tamin'ny sarimihetsika 'Berlinguer tiako ianao'.	\N
976	5e1a0e6	25	Cuisinière à gaz	Fornello a gas		\N	2025-12-11 15:25:47.285445	0	2025-12-12 15:25:47.285445	{cuisine,italien}	2.5	0	0	\N	\N	\N	Gas stove	Gasherd	Fatana entona	\N
860	7313566	23	Quale film importante ha girato con Jarmusch?	Ha girato 'Down by Law'.		\N	2025-12-10 08:41:45.564155	4	2026-02-24 14:20:59.741332	{italien,A2,cinéma,"Roberto Benigni"}	2.7	76	4	\N	\N	\N	He filmed 'Down by Law'.	Er hat „Down by Law“ gedreht.	Nanao horonantsary 'Down by Law' izy.	\N
862	0ecaea4	23	Chi ha conosciuto durante il film 'Tu mi turbi'?	Ha conosciuto Nicoletta Braschi.		\N	2025-12-10 08:41:45.602462	3	2025-12-28 08:34:02.961253	{italien,A2,personnes,"Roberto Benigni"}	2.4	17	3	\N	\N	\N	He met Nicoletta Braschi.	Er lernte Nicoletta Braschi kennen.	Nihaona tamin'i Nicoletta Braschi izy.	\N
863	583b845	23	Qual è il suo più grande successo?	Il suo più grande successo è 'La vita è bella'.		\N	2025-12-10 08:41:45.621603	2	2025-12-17 08:32:32.36371	{italien,A2,cinéma,"Roberto Benigni"}	2.6	6	2	\N	\N	\N	His biggest hit is 'Life is Beautiful'.	Sein größter Hit ist „Life is Beautiful“.	Ny malaza indrindra dia ny 'Life is Beautiful'.	\N
865	c77de1c	23	In quali film ha lavorato negli anni seguenti?	Ha fatto 'Pinocchio' e 'La tigre e la neve'.		\N	2025-12-10 08:41:45.669155	0	2025-12-11 08:43:56.275362	{italien,A2,cinéma,"Roberto Benigni"}	2.3	0	0	\N	\N	\N	He did 'Pinocchio' and 'Crouching Tiger and Snow'.	Er hat „Pinocchio“ und „Crouching Tiger and Snow“ gemacht.	Nanao 'Pinocchio' sy 'Crouching Tiger and Snow' izy.	\N
1513	b306739	37	risotto	risotto		\N	2026-01-21 14:50:01.019314	0	2026-01-22 14:50:01.019314	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	risotto	Risotto	risotto	\N
1700	a8c8eec	39	escalator	scala mobile		\N	2026-01-30 16:23:23.838848	0	2026-01-31 16:23:23.838848	{nom,italien,transport}	2.5	0	0	\N	\N	\N	escalator	Rolltreppe	escalator	\N
1701	f622bb0	39	téléphérique	funivia		\N	2026-01-30 16:23:35.038412	0	2026-01-31 16:23:35.038412	{nom,italien,transport}	2.5	0	0	\N	\N	\N	cable car	Seilbahn	fiara tariby	\N
1702	5a35541	39	tracteur	trattore		\N	2026-01-30 16:23:35.061162	0	2026-01-31 16:23:35.061162	{nom,italien,transport}	2.5	0	0	\N	\N	\N	tractor	Traktor	traktera	\N
854	03e7ca4	23	Dove ha iniziato a recitare?	Ha iniziato a recitare a teatro.		\N	2025-12-10 08:41:45.434531	1	2025-12-11 13:51:45.603611	{italien,A2,théâtre,"Roberto Benigni"}	2.5	1	1	\N	\N	\N	He started acting in the theater.	Er begann im Theater zu spielen.	Nanomboka nitendry teatra izy.	\N
2441	23ccc0d	63	Invention	Invenzione		\N	2026-02-24 15:52:01.52574	0	2026-02-25 15:52:01.52574	{science,innovation,recherche}	2.5	0	0	\N	\N	Creazione di un nuovo oggetto o processo.	Invention	Erfindung	Invention	L'invenzione della ruota ha cambiato la storia.
866	5bc62d6	23	Con quale regista americano ha collaborato?	Ha collaborato con Woody Allen nel film 'To Rome with Love'.		\N	2025-12-10 08:41:45.694128	1	2025-12-11 13:59:32.218274	{italien,A2,cinéma,"Roberto Benigni"}	2.6	1	1	\N	\N	\N	He collaborated with Woody Allen in the film 'To Rome with Love'.	Er arbeitete mit Woody Allen im Film „To Rome with Love“ zusammen.	Niara-niasa tamin'i Woody Allen tao amin'ny sarimihetsika 'To Rome with Love' izy.	\N
1444	2b58fc7	37	poisson	pesce		\N	2026-01-21 14:49:58.59195	0	2026-01-22 14:49:58.59195	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	fish	Fisch	TRONDRO	\N
1703	57d72c5	39	caravane	roulotte		\N	2026-01-30 16:23:35.088488	0	2026-01-31 16:23:35.088488	{nom,italien,transport}	2.5	0	0	\N	\N	\N	caravan	Wohnwagen	valalamanjohy	\N
1704	723677e	39	camping-car	camper		\N	2026-01-30 16:23:35.112837	0	2026-01-31 16:23:35.112837	{nom,italien,transport}	2.5	0	0	\N	\N	\N	camper	Camper	mpilasy	\N
857	9b5c9dc	23	Come si chiamava il programma televisivo famoso?	Il programma si chiamava 'The Other Sunday'.		\N	2025-12-10 08:41:45.500923	3	2025-12-31 14:11:03.845398	{italien,A2,télévision,"Roberto Benigni"}	2.7	21	3	\N	\N	\N	The program was called 'The Other Sunday'.	Die Sendung hieß „Der andere Sonntag“.	Nantsoina hoe 'The Other Sunday' ilay fandaharana.	\N
1005	67d4fd6	25	Sucre	Zucchero		\N	2025-12-11 15:25:47.932397	0	2025-12-12 15:25:47.932397	{cuisine,italien}	2.5	0	0	\N	\N	\N	Sugar	Zucker	siramamy	\N
1006	afa886f	25	Épice	Spezia		\N	2025-12-11 15:25:47.951673	0	2025-12-12 15:25:47.951673	{cuisine,italien}	2.5	0	0	\N	\N	\N	Spice	Würzen	zava-manitra	\N
1007	29d7ffe	25	Vinaigre	Aceto		\N	2025-12-11 15:25:47.976486	0	2025-12-12 15:25:47.976486	{cuisine,italien}	2.5	0	0	\N	\N	\N	Vinegar	Essig	vinaingitra	\N
1008	5584cc5	25	Tasse à mesurer	Misurino		\N	2025-12-11 15:25:48.005542	0	2025-12-12 15:25:48.005542	{cuisine,italien}	2.5	0	0	\N	\N	\N	Measuring cup	Messbecher	Kaopy fandrefesana	\N
1009	3500735	25	Verre à vin	Bicchiere da vino		\N	2025-12-11 15:25:48.031518	0	2025-12-12 15:25:48.031518	{cuisine,italien}	2.5	0	0	\N	\N	\N	Wine glass	Weinglas	vera divay	\N
1528	b6309ae	38	costume (homme)	abito		\N	2026-01-25 06:44:09.40432	0	2026-01-26 06:44:09.40432	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	suit	Anzug	fitoriana	\N
1524	7a7489d	38	manteau	cappotto		\N	2026-01-25 06:44:09.323284	0	2026-01-26 06:44:09.323284	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	coat	Mantel	akanjo	\N
1525	9d4ad43	38	veste	giacca		\N	2026-01-25 06:44:09.347905	0	2026-01-26 06:44:09.347905	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	jacket	Jacke	palitao	\N
1526	8bf1d85	38	pull	maglione		\N	2026-01-25 06:44:09.366674	0	2026-01-26 06:44:09.366674	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	Sweater	Pullover	akanjo ba	\N
1527	3ae5d23	38	sweat à capuche	felpa		\N	2026-01-25 06:44:09.385098	0	2026-01-26 06:44:09.385098	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	Sweatshirt	Sweatshirt	sweatshirt	\N
1529	64d1217	38	smoking	smoking		\N	2026-01-25 06:44:09.423575	0	2026-01-26 06:44:09.423575	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	tuxedo	Smoking	tuxedo	\N
1535	2e727f4	38	bottes (femme)	stivali alti		\N	2026-01-25 06:44:09.540258	0	2026-01-26 06:44:09.540258	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	high boots	hohe Stiefel	kiraro avo	\N
1536	ecca25d	38	sandales	sandali		\N	2026-01-25 06:44:09.557116	0	2026-01-26 06:44:09.557116	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	sandals	Sandalen	kapa	\N
1537	b9706ea	38	tongs	infradito		\N	2026-01-25 06:44:09.577276	0	2026-01-26 06:44:09.577276	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	flip flops	Flip-Flops	kapa	\N
1538	40e175f	38	talons hauts	tacchi alti		\N	2026-01-25 06:44:09.598739	0	2026-01-26 06:44:09.598739	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	high heels	High Heels	kiraro avo	\N
1040	c3e1d8c	28	Environnement	Ambiente		\N	2026-01-08 15:19:17.776699	1	2026-02-02 15:32:46.72681	{nom,italien,général}	2.6	1	1	\N	\N	\N	Environment	Umfeld	TONTOLO IAINANA	\N
394	5791df6	13	Cou	Collo		\N	2025-12-06 14:15:35.558032	0	2025-12-07 14:15:35.558032	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Neck	Nacken	vozony	\N
1197	6122eed	30	Penser à ça	Pensarci su		\N	2026-01-09 16:10:11.773681	0	2026-01-10 16:10:11.773681	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Think about it	Denken Sie darüber nach	Eritrereto izany	\N
1198	7a0252b	30	Manger dehors	Mangiare fuori		\N	2026-01-09 16:10:11.797241	0	2026-01-10 16:10:11.797241	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Eating out	Auswärts essen	Misakafo any ivelany	\N
1209	d04a346	31	Espèce en danger	Specie in pericolo		\N	2026-01-11 15:36:49.103303	0	2026-01-12 15:36:49.103303	{expression,italien,biodiversité}	2.5	0	0	\N	\N	\N	Endangered species	Gefährdete Arten	Karazana atahorana ho lany tamingana	\N
1044	31b37cd	28	Gaz à effet de serre	Gas serra		\N	2026-01-08 15:19:17.88244	0	2026-02-01 15:40:51.114114	{nom,italien,climat}	2.3	0	0	\N	\N	\N	Greenhouse gases	Treibhausgase	Entona maitso	\N
1547	971a8d4	38	cravate	cravatta		\N	2026-01-25 06:44:09.782995	0	2026-01-26 06:44:09.782995	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	necktie	Krawatte	karavato	\N
1548	1e19ce3	38	nœud papillon	papillon		\N	2026-01-25 06:44:09.804736	0	2026-01-26 06:44:09.804736	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	bow tie	Fliege	fatotra Lolo	\N
397	bcce9b1	13	Coude	Gomito		\N	2025-12-06 14:15:35.717627	0	2025-12-07 14:15:35.717627	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Elbow	Ellbogen	kiho	\N
412	4c87434	13	Cœur	Cuore		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1fac0.svg	2025-12-06 14:15:36.109668	0	2025-12-07 14:15:36.109668	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	\N	Heart	Herz	FO	\N
570	853a682	17	Le mari	Il marito		\N	2025-12-07 06:08:35.518032	0	2025-12-08 06:08:35.518032	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The husband	Der Ehemann	Ny lehilahy	\N
583	4ced160	18	Médecin	Medico		\N	2025-12-07 06:20:58.066	0	2025-12-08 06:20:58.066	{métier,italien}	2.5	0	0	\N	\N	\N	Doctor	Arzt	Doctor	\N
584	de857d0	18	Infirmier	Infermiere		\N	2025-12-07 06:20:58.092615	0	2025-12-08 06:20:58.092615	{métier,italien}	2.5	0	0	\N	\N	\N	Nurse	Krankenschwester	Mpitsabo	\N
585	3a77b39	18	Ingénieur	Ingegnere		\N	2025-12-07 06:20:58.113709	0	2025-12-08 06:20:58.113709	{métier,italien}	2.5	0	0	\N	\N	\N	Engineer	Ingenieur	injeniera	\N
586	dee8ff9	18	Professeur	Insegnante		\N	2025-12-07 06:20:58.133688	0	2025-12-08 06:20:58.133688	{métier,italien}	2.5	0	0	\N	\N	\N	Teacher	Lehrer	MPAMPIANATRA	\N
587	8a84f85	18	Développeur	Sviluppatore		\N	2025-12-07 06:20:58.15653	0	2025-12-08 06:20:58.15653	{métier,italien}	2.5	0	0	\N	\N	\N	Developer	Entwickler	Developer	\N
588	d3d03e0	18	Avocat	Avvocato		\N	2025-12-07 06:20:58.177596	0	2025-12-08 06:20:58.177596	{métier,italien}	2.5	0	0	\N	\N	\N	Lawyer	Rechtsanwalt	Mpisolo vava	\N
589	1a82244	18	Juge	Giudice		\N	2025-12-07 06:20:58.196816	0	2025-12-08 06:20:58.196816	{métier,italien}	2.5	0	0	\N	\N	\N	Judge	Richter	Mpitsara	\N
590	804eb95	18	Policier	Poliziotto		\N	2025-12-07 06:20:58.217424	0	2025-12-08 06:20:58.217424	{métier,italien}	2.5	0	0	\N	\N	\N	Police officer	Polizist	Polisy	\N
592	8262352	18	Pilote	Pilota		\N	2025-12-07 06:20:58.260103	0	2025-12-08 06:20:58.260103	{métier,italien}	2.5	0	0	\N	\N	\N	Pilot	Pilot	Pilot	\N
1196	e0595da	30	Exclure	Tagliare fuori		\N	2026-01-09 16:10:11.747019	0	2026-01-10 16:10:11.747019	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Cut out	Ausgeschnitten	Manapaka	\N
1549	11a56d8	38	ceinture	cintura		\N	2026-01-25 06:44:09.826375	0	2026-01-26 06:44:09.826375	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	belt	Gürtel	fehin-kibo	\N
1550	de71ef6	38	maillot de bain	costume da bagno		\N	2026-01-25 06:44:09.848009	0	2026-01-26 06:44:09.848009	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	swimming suit	Badeanzug	akanjo milomano	\N
1552	63664b1	38	sous-vêtements	biancheria intima		\N	2026-01-25 06:44:09.893173	0	2026-01-26 06:44:09.893173	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	underwear	Unterwäsche	atin'akanjo	\N
1553	ece464e	38	débardeur	canottiera		\N	2026-01-25 06:44:09.914811	0	2026-01-26 06:44:09.914811	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	tanktop	Tanktop	tanktop	\N
1555	cbed8dd	38	boxer	boxer		\N	2026-01-25 06:44:09.956152	0	2026-01-26 06:44:09.956152	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	boxers	Boxer	mpanao ady totohondry	\N
1556	750d290	38	soutien-gorge	reggiseno		\N	2026-01-25 06:44:09.97654	0	2026-01-26 06:44:09.97654	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	bra	BH	bra	\N
1557	9ebf4b0	38	pyjama	pigiama		\N	2026-01-25 06:44:09.996632	0	2026-01-26 06:44:09.996632	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	pajamas	Pyjama	hitafy ny akanjo mandry	\N
403	8994b19	13	Dos	Schiena		\N	2025-12-06 14:15:35.904075	0	2025-12-07 14:15:35.904075	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	Parte posteriore del tronco.	Back	Rücken	Lamosina	Un dorso forte protegge la colonna vertebrale.
1062	340af4e	28	Plastique	Plastica		\N	2026-01-08 15:19:18.438433	1	2026-02-02 15:35:30.685025	{nom,italien,déchets}	2.6	1	1	\N	\N	\N	Plastic	Plastik	plastika	\N
1554	79c5c44	38	slip	mutande		\N	2026-01-25 06:44:09.935494	0	2026-01-26 06:44:09.935494	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	underwear	Unterwäsche	atin'akanjo	\N
1558	828e73c	38	peignoir	accappatoio		\N	2026-01-25 06:44:10.021024	0	2026-01-26 06:44:10.021024	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	bathrobe	Bademantel	akanjo fandroana	\N
1391	9f0b75e	36	Se vendre très vite	Andare a ruba		\N	2026-01-20 14:49:12.093033	0	2026-01-21 14:49:12.093033	{expression,idiomatique,italien,fréquent,commerce}	2.5	0	0	\N	\N	\N	Going like hot cakes	Geht wie warme Semmeln	Mandeha toy ny mofomamy mafana	\N
1393	309d46e	36	Avoir très hâte	Non vedere l’ora		\N	2026-01-20 14:49:12.189065	0	2026-01-21 14:49:12.189065	{expression,idiomatique,italien,fréquent,temps}	2.5	0	0	\N	\N	\N	Don't look forward to it	Freuen Sie sich nicht darauf	Aza miandrandra izany	\N
1410	4b2401f	36	Pas du tout	Non essere affatto		\N	2026-01-20 14:49:12.639815	0	2026-01-21 14:49:12.639815	{expression,idiomatique,italien,fréquent,négation}	2.5	0	0	\N	\N	\N	Don't be at all	Sei es überhaupt nicht	Aza manao izany mihitsy	\N
1695	f0ed0fe	39	douane	dogana		\N	2026-01-30 16:23:23.708827	0	2026-01-31 16:23:23.708827	{nom,italien,transport}	2.5	0	0	\N	\N	\N	customs	Zoll	Doany	\N
2442	f023c3d	63	Découverte	Scoperta		\N	2026-02-24 15:52:08.099552	0	2026-02-25 15:52:08.099552	{science,innovation,recherche}	2.5	0	0	\N	\N	Rivelazione di qualcosa che già esisteva.	Discovery	Entdeckung	Découverte	La scoperta della penicillina ha salvato milioni di vite.
2443	c3fd78f	63	Brevet	Brevetto		\N	2026-02-24 15:52:14.46501	0	2026-02-25 15:52:14.46501	{science,innovation,recherche}	2.5	0	0	\N	\N	Diritto esclusivo su un'invenzione.	Patent	Patent	Brevet	Il brevetto protegge l'invenzione per 20 anni.
2444	cdef65d	63	Laboratoire	Laboratorio		\N	2026-02-24 15:52:21.834929	0	2026-02-25 15:52:21.834929	{science,innovation,recherche}	2.5	0	0	\N	\N	Luogo attrezzato per ricerche scientifiche.	Laboratory	Labor	Laboratoire	Il laboratorio è dotato di strumenti moderni.
2445	7b44e96	63	Développement R&D	Sviluppo R&S		\N	2026-02-24 15:52:27.41167	0	2026-02-25 15:52:27.41167	{science,innovation,recherche}	2.5	0	0	\N	\N	Attività di ricerca e sviluppo di nuovi prodotti.	R&D	Forschung und Entwicklung	Développement R&D	Il reparto R&S lavora su nuovi materiali.
2446	08d023a	63	Optimisation	Ottimizzazione		\N	2026-02-24 15:52:34.552667	0	2026-02-25 15:52:34.552667	{science,innovation,recherche}	2.5	0	0	\N	\N	Miglioramento di un processo per aumentarne l'efficienza.	Optimization	Optimierung	Optimisation	L'ottimizzazione ha ridotto i costi del 30%.
2447	15064c9	63	Complexité	Complessità		\N	2026-02-24 15:52:41.624753	0	2026-02-25 15:52:41.624753	{science,innovation,recherche}	2.5	0	0	\N	\N	Caratteristica di sistemi con molte interazioni.	Complexity	Komplexität	Complexité	La complessità del problema richiede nuovi approcci.
2182	6c9a349	61	Performance	Prestazione		\N	2026-02-24 15:03:58.030607	0	2026-02-25 15:03:58.030607	{sport,performance,suivi}	2.5	0	0	\N	\N	Livello di efficienza e risultati ottenuti.	Performance	Leistung	Performance	La prestazione del nuovo sistema è eccellente.
2448	4fc7fa5	63	Fiabilité	Affidabilità		\N	2026-02-24 15:52:47.914225	0	2026-02-25 15:52:47.914225	{science,innovation,recherche}	2.5	0	0	\N	\N	Capacità di funzionare correttamente per lungo tempo.	Reliability	Zuverlässigkeit	Fiabilité	L'affidabilità del dispositivo è garantita.
2449	d6d0ee0	63	Miniaturisation	Miniaturizzazione		\N	2026-02-24 15:52:54.454329	0	2026-02-25 15:52:54.454329	{science,innovation,recherche}	2.5	0	0	\N	\N	Riduzione delle dimensioni di dispositivi mantenendone le funzioni.	Miniaturization	Miniaturisierung	Miniaturisation	La miniaturizzazione ha permesso gli smartphone.
2450	f9f0d21	63	Rupture technologique	Rottura tecnologica		\N	2026-02-24 15:53:00.745355	0	2026-02-25 15:53:00.745355	{science,innovation,recherche}	2.5	0	0	\N	\N	Innovazione che cambia radicalmente un settore.	Technological breakthrough	Technologischer Durchbruch	Rupture technologique	Internet è stata una rottura tecnologica.
1067	90b6d12	28	Compost	Compost		\N	2026-01-08 15:19:18.560165	1	2026-02-02 15:28:00.538377	{nom,italien,déchets}	2.6	1	1	\N	\N	\N	Compost	Kompost	zezika	\N
1070	7fc7de8	28	Énergie renouvelable	Energia rinnovabile		\N	2026-01-08 15:19:18.629761	0	2026-02-01 15:42:08.518059	{expression,italien,énergie}	2.3	0	0	\N	\N	\N	Renewable energy	Erneuerbare Energie	Angovo azo havaozina	\N
1560	b5780c4	38	lunettes de soleil	occhiali da sole		\N	2026-01-25 06:44:10.065556	0	2026-01-26 06:44:10.065556	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	sunglasses	Sonnenbrille	solomaso	\N
1561	acd413c	38	sac à main	borsa		\N	2026-01-25 06:44:10.085694	0	2026-01-26 06:44:10.085694	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	bag	Tasche	kitapo	\N
604	f4452a0	18	Serveur	Cameriere		\N	2025-12-07 06:20:58.616273	0	2025-12-08 06:20:58.616273	{métier,italien}	2.5	0	0	\N	\N	\N	Waiter	Kellner	Servera	\N
621	1336966	18	Fleuriste	Fiorista		\N	2025-12-07 06:20:59.001546	0	2025-12-08 06:20:59.001546	{métier,italien}	2.5	0	0	\N	\N	\N	Florist	Florist	Florist	\N
1201	e9cc0bd	31	Ozone	Ozono		\N	2026-01-11 15:36:48.939018	0	2026-01-12 15:36:48.939018	{nom,italien,air}	2.5	0	0	\N	\N	\N	Ozone	Ozon	Ozone	\N
1390	df165e5	31	Absorber	Assorbire		\N	2026-01-15 15:09:25.137369	0	2026-01-16 15:09:25.137369	{}	2.5	0	0	\N	\N	\N	Absorb	Absorbieren	mandray	\N
1415	308d372	37	pâtes	pasta		\N	2026-01-21 14:49:57.728376	0	2026-01-22 14:49:57.728376	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pasta	Pasta	paty	\N
1416	afe4f0c	37	pizza	pizza		\N	2026-01-21 14:49:57.767248	0	2026-01-22 14:49:57.767248	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pizza	Pizza	ny pizza	\N
1562	5008707	38	sac à dos	zaino		\N	2026-01-25 06:44:10.109941	0	2026-01-26 06:44:10.109941	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	Backpack	Rucksack	Kitapo	\N
1563	1043a1a	38	sac de courses	sacchetto		\N	2026-01-25 06:44:10.136007	0	2026-01-26 06:44:10.136007	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	bag	Tasche	kitapo	\N
1564	2aec9ad	38	portefeuille	portafoglio		\N	2026-01-25 06:44:10.158011	0	2026-01-26 06:44:10.158011	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	wallet	Geldbörse	kitapom-batsy	\N
1417	5bff6ca	37	riz	riso		\N	2026-01-21 14:49:57.795532	0	2026-01-22 14:49:57.795532	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	rice	Reis	-BARY	\N
1753	c09f7c5	40	nerveux	nervoso		\N	2026-01-31 15:19:21.982142	0	2026-02-01 15:19:21.982142	{adjectif,italien,émotion}	2.5	0	0	\N	\N	\N	nervous	nervös	natahotra	\N
1568	ae4b144	38	bague	anello		\N	2026-01-25 06:44:10.32987	0	2026-01-26 06:44:10.32987	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	ring	Ring	peratra	\N
1569	f0ae251	38	diamant	diamante		\N	2026-01-25 06:44:10.352638	0	2026-01-26 06:44:10.352638	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	diamond	Diamant	Diamond	\N
1570	24522a0	38	collier	collana		\N	2026-01-25 06:44:10.37473	0	2026-01-26 06:44:10.37473	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	necklace	Halskette	rojo	\N
1572	3bed233	38	bracelet	braccialetto		\N	2026-01-25 06:44:10.425709	0	2026-01-26 06:44:10.425709	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	bracelet	Armband	fehin-tanana	\N
1239	e243d85	31	Gestion des déchets	Gestione dei rifiuti		\N	2026-01-11 15:36:49.864238	0	2026-01-12 15:36:49.864238	{expression,italien,déchets}	2.5	0	0	\N	\N	\N	Waste management	Abfallmanagement	Fitantanana fako	\N
1241	2591d1f	31	Incinération	Incenerimento		\N	2026-01-11 15:36:49.905875	0	2026-01-12 15:36:49.905875	{nom,italien,déchets}	2.5	0	0	\N	\N	\N	Incineration	Verbrennung	fandoroana	\N
1573	3820989	38	montre	orologio		\N	2026-01-25 06:44:10.444246	0	2026-01-26 06:44:10.444246	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	clock	Uhr	famantaranandro	\N
1242	675f579	31	Réutiliser	Riutilizzare		\N	2026-01-11 15:36:49.930707	0	2026-01-12 15:36:49.930707	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Reuse	Wiederverwendung	ampiasaina	\N
1243	fdb5454	31	Surcyclage	Upcycling		\N	2026-01-11 15:36:49.954151	0	2026-01-12 15:36:49.954151	{nom,italien,recyclage}	2.5	0	0	\N	\N	\N	Upcycling	Upcycling	Upcycling	\N
1244	4634876	31	Économie circulaire	Economia circolare		\N	2026-01-11 15:36:49.976108	0	2026-01-12 15:36:49.976108	{expression,italien,économie}	2.5	0	0	\N	\N	\N	Circular economy	Kreislaufwirtschaft	Toe-karena boribory	\N
115	afe5784	9	Dessiner	Disegnare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3a8.svg	2025-12-03 13:33:24.0268	0	2025-12-04 13:33:24.0268	{verbe,italien,fréquent,travail}	2.5	0	0	\N	\N	\N	Draw	Ziehen	Manaova	\N
1574	cd1d503	38	parapluie	ombrello		\N	2026-01-25 06:44:10.463754	0	2026-01-26 06:44:10.463754	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	umbrella	Regenschirm	elo	\N
1576	9083d4f	38	valise	valigia		\N	2026-01-25 06:44:10.502036	0	2026-01-26 06:44:10.502036	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	suitcase	Koffer	valizy	\N
1069	51c4ce3	28	Énergie	Energia		\N	2026-01-08 15:19:18.605646	1	2026-02-02 15:29:13.383728	{nom,italien,énergie}	2.6	1	1	\N	\N	Capacità di produrre lavoro o calore.	Energy	Energie	Angovo	L'energia si conserva in un sistema isolato.
612	50fcab4	18	Graphiste	Grafico		\N	2025-12-07 06:20:58.777073	0	2025-12-08 06:20:58.777073	{métier,italien}	2.5	0	0	\N	\N	\N	Graphic	Grafik	SARY	\N
1419	b7c50aa	37	thé	tè		\N	2026-01-21 14:49:57.851918	0	2026-01-22 14:49:57.851918	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	tea	Tee	dite	\N
1418	992efd8	37	café	caffè		\N	2026-01-21 14:49:57.828216	0	2026-01-22 14:49:57.828216	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	coffee	Kaffee	kafe	\N
1577	26c328d	38	coton	cotone		\N	2026-01-25 06:44:10.522913	0	2026-01-26 06:44:10.522913	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	cotton	Baumwolle	landihazo	\N
1578	232da69	38	laine	lana		\N	2026-01-25 06:44:10.544689	0	2026-01-26 06:44:10.544689	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	wool	Wolle	volonondry	\N
1579	2b5c258	38	pelote de laine	gomitolo		\N	2026-01-25 06:44:10.563717	0	2026-01-26 06:44:10.563717	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	ball	Ball	baolina	\N
1587	37c7ecd	38	sari	sari		\N	2026-01-25 06:44:10.771058	0	2026-01-26 06:44:10.771058	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	sari	Sari	sari	\N
1588	89da2ff	38	foulard	foulard		\N	2026-01-25 06:44:10.801378	0	2026-01-26 06:44:10.801378	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	scarf	Schal	fehy	\N
1589	4d2dca4	38	gilet de sécurité	gilet di sicurezza		\N	2026-01-25 06:44:10.819472	0	2026-01-26 06:44:10.819472	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	safety vest	Sicherheitsweste	akanjo fiarovana	\N
1590	3e0aaec	38	blouse	camice		\N	2026-01-25 06:44:10.849406	0	2026-01-26 06:44:10.849406	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	shirt	Hemd	AKANJONAO	\N
1591	13e2f0d	38	uniforme	uniforme		\N	2026-01-25 06:44:10.87209	0	2026-01-26 06:44:10.87209	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	uniform	Uniform	fanamiana	\N
853	b16578a	23	Cosa ha fatto dopo l’invito del regista?	È entrato nella sua compagnia teatrale.		\N	2025-12-10 08:41:45.412908	2	2025-12-17 08:32:45.155276	{italien,A2,théâtre,"Roberto Benigni"}	2.5	6	2	\N	\N	\N	He joined her theater company.	Er schloss sich ihrer Theatergruppe an.	Niditra tao amin'ny orinasa teatrany izy.	\N
867	e817fcf	24	Maison	Casa		\N	2025-12-10 15:39:05.610701	0	2025-12-11 15:39:05.610701	{maison,italien}	2.5	0	0	\N	\N	\N	House	Haus	Trano	\N
1368	a6352a0	35	Fermer les yeux	Chiudere un occhio		\N	2026-01-12 13:20:13.223171	3	2026-02-21 15:14:51.752807	{expression,italien,tolérance,laisser-passer}	2.8	20	3	\N	\N	\N	Close one eye	Schließe ein Auge	Akimpio ny maso iray	\N
605	d7ac9b1	18	Boulanger	Panettiere		\N	2025-12-07 06:20:58.636933	0	2025-12-08 06:20:58.636933	{métier,italien}	2.5	0	0	\N	\N	\N	Baker	Bäcker	Baker	\N
606	2dff8de	18	Pâtissier	Pasticciere		\N	2025-12-07 06:20:58.657566	0	2025-12-08 06:20:58.657566	{métier,italien}	2.5	0	0	\N	\N	\N	Pastry chef	Konditor	Chef pastry	\N
607	81f2d12	18	Boucher	Macellaio		\N	2025-12-07 06:20:58.677446	0	2025-12-08 06:20:58.677446	{métier,italien}	2.5	0	0	\N	\N	\N	Butcher	Metzger	mpivaro-kena	\N
608	f9d0881	18	Journaliste	Giornalista		\N	2025-12-07 06:20:58.69641	0	2025-12-08 06:20:58.69641	{métier,italien}	2.5	0	0	\N	\N	\N	Journalist	Journalist	Mpanao gazety	\N
609	5e233e9	18	Écrivain	Scrittore		\N	2025-12-07 06:20:58.717502	0	2025-12-08 06:20:58.717502	{métier,italien}	2.5	0	0	\N	\N	\N	Writer	Schriftsteller	ANY	\N
610	9556aa1	18	Photographe	Fotografo		\N	2025-12-07 06:20:58.737436	0	2025-12-08 06:20:58.737436	{métier,italien}	2.5	0	0	\N	\N	\N	I photograph	Ich fotografiere	maka sary aho	\N
611	e6d4471	18	Designer	Designer		\N	2025-12-07 06:20:58.757592	0	2025-12-08 06:20:58.757592	{métier,italien}	2.5	0	0	\N	\N	\N	Designer	Designer	endrika	\N
1420	0e72c59	37	lait	latte		\N	2026-01-21 14:49:57.874424	0	2026-01-22 14:49:57.874424	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	milk	Milch	ronono	\N
1422	0b385d0	37	vin	vino		\N	2026-01-21 14:49:57.933713	0	2026-01-22 14:49:57.933713	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	wine	Wein	divay	\N
1427	3b8bb32	37	beurre	burro		\N	2026-01-21 14:49:58.056607	0	2026-01-22 14:49:58.056607	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	butter	Butter	dibera	\N
1428	ddf358a	37	miel	miele		\N	2026-01-21 14:49:58.085489	0	2026-01-22 14:49:58.085489	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	honey	Honig	Honey	\N
1429	18742bc	37	sucre	zucchero		\N	2026-01-21 14:49:58.121467	0	2026-01-22 14:49:58.121467	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	sugar	Zucker	siramamy	\N
1049	2692817	28	Biodiversité	Biodiversità		\N	2026-01-08 15:19:18.116718	1	2026-02-02 15:39:19.655514	{nom,italien,biodiversité}	2.4	1	1	\N	\N	Varietà di forme di vita su un territorio.	Biodiversity	Biodiversität	Biodiversité	La biodiversità è minacciata dal cambiamento climatico.
1599	dc4e3b6	38	aiguille	ago		\N	2026-01-25 06:44:11.014371	0	2026-01-26 06:44:11.014371	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	Aug	Aug	Aog	\N
1600	e18208a	38	fil	filo		\N	2026-01-25 06:44:11.034809	0	2026-01-26 06:44:11.034809	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	row	Reihe	toerana	\N
1601	db4b10e	38	ciseaux	forbici		\N	2026-01-25 06:44:11.055777	0	2026-01-26 06:44:11.055777	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	scissors	Schere	hety	\N
1602	fdf7a05	38	épingle à nourrice	spilla da balia		\N	2026-01-25 06:44:11.073452	0	2026-01-26 06:44:11.073452	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	safety pin	Sicherheitsnadel	pin fiarovana	\N
1142	cf146cc	28	Informer	Informare		\N	2026-01-08 15:19:21.413301	0	2026-02-01 15:44:28.976573	{verbe,italien,communication}	2.3	0	0	\N	\N	\N	Inform	Informieren	Ampahafantaro	\N
1603	3884e4c	38	ruban	nastro		\N	2026-01-25 06:44:11.093052	0	2026-01-26 06:44:11.093052	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	tape	Band	scotch	\N
117	1041e72	9	Filmer	Filmare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3a5.svg	2025-12-03 13:33:24.066708	0	2025-12-04 13:33:24.066708	{verbe,italien,fréquent,loisir}	2.5	0	0	\N	\N	\N	Film	Film	horonan-tsary	\N
118	b9532d2	9	Appeler	Chiamare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4de.svg	2025-12-03 13:33:24.085823	0	2025-12-04 13:33:24.085823	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Call	Anruf	ANTSO	\N
645	940cc5e	19	Oiseau	Uccello		\N	2025-12-07 06:26:42.551351	0	2025-12-08 06:26:42.551351	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Bird	Vogel	vorona	\N
868	786c15c	24	Toit	Tetto		\N	2025-12-10 15:39:05.636642	0	2025-12-11 15:39:05.636642	{maison,italien}	2.5	0	0	\N	\N	\N	Roof	Dach	TAFOTRANO	\N
869	c6ed4d7	24	Chambre	Camera da letto		\N	2025-12-10 15:39:05.654901	0	2025-12-11 15:39:05.654901	{maison,italien}	2.5	0	0	\N	\N	\N	Bedroom	Schlafzimmer	efi-trano	\N
871	1e8ac74	24	Oreiller	Cuscino		\N	2025-12-10 15:39:05.69181	0	2025-12-11 15:39:05.69181	{maison,italien}	2.5	0	0	\N	\N	\N	Cushion	Kissen	lafika	\N
872	011726b	24	Couverture	Coperta		\N	2025-12-10 15:39:05.712886	0	2025-12-11 15:39:05.712886	{maison,italien}	2.5	0	0	\N	\N	\N	Cover	Abdeckung	\N	\N
873	bd92f17	24	Armoire	Armadio		\N	2025-12-10 15:39:05.730617	0	2025-12-11 15:39:05.730617	{maison,italien}	2.5	0	0	\N	\N	\N	Wardrobe	Kleiderschrank	fitafiana	\N
1051	e39174b	28	Faune	Fauna		\N	2026-01-08 15:19:18.166788	1	2026-02-02 15:22:36.664602	{nom,italien,biodiversité}	2.6	1	1	\N	\N	\N	Fauna	Fauna	biby	\N
615	a8997c5	18	Économiste	Economista		\N	2025-12-07 06:20:58.837728	0	2025-12-08 06:20:58.837728	{métier,italien}	2.5	0	0	\N	\N	\N	Economist	Ökonom	mpahay toekarena	\N
616	c439df4	18	Entrepreneur	Imprenditore		\N	2025-12-07 06:20:58.857455	0	2025-12-08 06:20:58.857455	{métier,italien}	2.5	0	0	\N	\N	\N	Entrepreneur	Unternehmer	Entrepreneur	\N
618	2bb80e5	18	Agriculteur	Agricoltore		\N	2025-12-07 06:20:58.897691	0	2025-12-08 06:20:58.897691	{métier,italien}	2.5	0	0	\N	\N	\N	Farmer	Bauer	MPAMBOLY	\N
619	bd5707f	18	Pêcheur	Pescatore		\N	2025-12-07 06:20:58.919982	0	2025-12-08 06:20:58.919982	{métier,italien}	2.5	0	0	\N	\N	\N	Fisherman	Fischer	mpanjono	\N
620	48b4bc5	18	Jardinier	Giardiniere		\N	2025-12-07 06:20:58.954027	0	2025-12-08 06:20:58.954027	{métier,italien}	2.5	0	0	\N	\N	\N	Gardener	Gärtner	mpiandry saha	\N
1423	f59c185	37	bière	birra		\N	2026-01-21 14:49:57.957446	0	2026-01-22 14:49:57.957446	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	beer	Bier	labiera	\N
1424	22e71c7	37	jus	succo		\N	2026-01-21 14:49:57.982948	0	2026-01-22 14:49:57.982948	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	juice	Saft	ranom-boankazo	\N
1425	3fa4cc4	37	huile	olio		\N	2026-01-21 14:49:58.00896	0	2026-01-22 14:49:58.00896	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	oil	Öl	SOLIKA	\N
1604	04b7a76	38	mètre ruban	metro		\N	2026-01-25 06:44:11.144191	0	2026-01-26 06:44:11.144191	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	meter	Meter	metatra	\N
1605	4e44e11	38	règle	righello		\N	2026-01-25 06:44:11.173347	0	2026-01-26 06:44:11.173347	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	ruler	Herrscher	MPANAPAKA	\N
1432	2483152	37	vinaigre	aceto		\N	2026-01-21 14:49:58.259759	0	2026-01-22 14:49:58.259759	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	vinegar	Essig	vinaingitra	\N
1433	3596cc9	37	tomate	pomodoro		\N	2026-01-21 14:49:58.291944	0	2026-01-22 14:49:58.291944	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	tomato	Tomate	voatabia	\N
1434	7a741b7	37	pomme de terre	patata		\N	2026-01-21 14:49:58.322025	0	2026-01-22 14:49:58.322025	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	potato	Kartoffel	ovy	\N
1435	06cd73c	37	carotte	carota		\N	2026-01-21 14:49:58.351371	0	2026-01-22 14:49:58.351371	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	carrot	Karotte	karaoty	\N
1606	5e58cb2	38	miroir	specchio		\N	2026-01-25 06:44:11.194238	0	2026-01-26 06:44:11.194238	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	mirror	Spiegel	fitaratra	\N
1607	c8ef9ee	38	rouge à lèvres	rossetto		\N	2026-01-25 06:44:11.213406	0	2026-01-26 06:44:11.213406	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	lipstick	Lippenstift	lokomena	\N
1613	a44acaa	38	maquillage	trucco		\N	2026-01-25 06:44:11.339046	0	2026-01-26 06:44:11.339046	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	trick	Trick	fitaka	\N
1436	5753bc3	37	oignon	cipolla		\N	2026-01-21 14:49:58.382829	0	2026-01-22 14:49:58.382829	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	onion	Zwiebel	tongolo	\N
1614	e7f4d14	38	déodorant	deodorante		\N	2026-01-25 06:44:11.358383	0	2026-01-26 06:44:11.358383	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	deodorant	Deodorant	deodorant	\N
127	609563e	9	Changer	Cambiare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f501.svg	2025-12-03 13:33:24.264602	0	2025-12-04 13:33:24.264602	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Change	Ändern	FIOVANA	\N
128	5020f52	9	Supprimer	Eliminare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5d1.svg	2025-12-03 13:33:24.283157	0	2025-12-04 13:33:24.283157	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Eliminate	Beseitigen	manafoana	\N
130	494227f	9	Télécharger	Scaricare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2b07.svg	2025-12-03 13:33:24.320759	0	2025-12-04 13:33:24.320759	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Download	Herunterladen	DOWNLOAD	\N
131	153cb66	9	Charger	Caricare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2b06.svg	2025-12-03 13:33:24.340373	0	2025-12-04 13:33:24.340373	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Load	Laden	entana	\N
132	f8eee68	9	Naviguer	Navigare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f310.svg	2025-12-03 13:33:24.358818	0	2025-12-04 13:33:24.358818	{verbe,italien,fréquent,technologie}	2.5	0	0	\N	\N	\N	Navigate	Navigieren	hitety	\N
135	51d42fe	9	Montrer	Mostrare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f446.svg	2025-12-03 13:33:24.417087	0	2025-12-04 13:33:24.417087	{verbe,italien,fréquent,communication}	2.5	0	0	\N	\N	\N	Show	Zeigen	FAMPISEHOANA	\N
136	2ae0390	9	Cacher	Nascondere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f648.svg	2025-12-03 13:33:24.438547	0	2025-12-04 13:33:24.438547	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	HIDE	VERSTECKEN	afeno ny	\N
147	63a35ff	9	Croire	Credere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f64f.svg	2025-12-03 13:33:24.679977	0	2025-12-04 13:33:24.679977	{verbe,italien,fréquent,cognition}	2.5	0	0	\N	\N	\N	Believe	Glauben	INOAN'NY	\N
152	83f164e	9	Rendre	Restituire		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e4.svg	2025-12-03 13:33:24.786969	0	2025-12-04 13:33:24.786969	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Return	Zurückkehren	Miverena	\N
154	ab2e3bc	9	Gagner	Vincere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3c6.svg	2025-12-03 13:33:24.827917	0	2025-12-04 13:33:24.827917	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	WIN	GEWINNEN	MANANDRESY	\N
155	652df15	9	Obtenir	Ottenere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4e5.svg	2025-12-03 13:33:24.851997	0	2025-12-04 13:33:24.851997	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Obtain	Erhalten	hahazo	\N
156	186d547	9	Maintenir	Mantenere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-03 13:33:24.873888	0	2025-12-04 13:33:24.873888	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Maintain	Pflegen	foana	\N
157	551840a	9	Ajouter	Aggiungere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2795.svg	2025-12-03 13:33:24.894181	0	2025-12-04 13:33:24.894181	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Add	Hinzufügen	hametraka	\N
158	82e3711	9	Retirer	Togliere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2796.svg	2025-12-03 13:33:24.915039	0	2025-12-04 13:33:24.915039	{verbe,italien,fréquent,action}	2.5	0	0	\N	\N	\N	Remove	Entfernen	esory	\N
159	21476df	9	Saluer	Salutare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44b.svg	2025-12-03 13:33:24.931754	0	2025-12-04 13:33:24.931754	{verbe,italien,fréquent,social}	2.5	0	0	\N	\N	\N	Greet	Begrüßen	Miarahaba	\N
160	6a2ebc4	9	Visiter	Visitare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f3db.svg	2025-12-03 13:33:24.948224	0	2025-12-04 13:33:24.948224	{verbe,italien,fréquent,loisir}	2.5	0	0	\N	\N	\N	Visit	Besuchen	FITSIDIHANA	\N
623	1274b2c	18	Mécanicien	Meccanico		\N	2025-12-07 06:20:59.054388	0	2025-12-08 06:20:59.054388	{métier,italien}	2.5	0	0	\N	\N	\N	Mechanical	Mechanisch	Mekanika	\N
624	4fd475a	18	Chauffeur	Autista		\N	2025-12-07 06:20:59.074667	0	2025-12-08 06:20:59.074667	{métier,italien}	2.5	0	0	\N	\N	\N	Driver	Treiber	Driver	\N
625	a67fc31	18	Conducteur de train	Macchinista		\N	2025-12-07 06:20:59.095806	0	2025-12-08 06:20:59.095806	{métier,italien}	2.5	0	0	\N	\N	\N	Machinist	Maschinist	milina	\N
1148	05900aa	28	Indicateur	Indicatore		\N	2026-01-08 15:19:21.567984	0	2026-02-01 15:39:09.307703	{nom,italien,data}	2.3	0	0	\N	\N	\N	Indicator	Indikator	famantarana	\N
1615	72ed152	38	savon	sapone		\N	2026-01-25 06:44:11.377677	0	2026-01-26 06:44:11.377677	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	soap	Seife	savony	\N
632	6e1530d	18	Peintre bâtiment	Imbianchino		\N	2025-12-07 06:20:59.228294	0	2025-12-08 06:20:59.228294	{métier,italien}	2.5	0	0	\N	\N	\N	House painter	Anstreicher	Mpanao hosodoko trano	\N
634	6c897aa	18	Secrétaire	Segretario		\N	2025-12-07 06:20:59.267786	0	2025-12-08 06:20:59.267786	{métier,italien}	2.5	0	0	\N	\N	\N	Secretary	Sekretär	mpitan-tsoratra	\N
1616	052a99e	38	éponge	spugna		\N	2026-01-25 06:44:11.397533	0	2026-01-26 06:44:11.397533	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	sponge	Schwamm	sponjy	\N
1719	75acf85	39	garage	officina		\N	2026-01-30 16:23:35.465226	0	2026-01-31 16:23:35.465226	{nom,italien,transport}	2.5	0	0	\N	\N	\N	garage	Garage	atrikasa	\N
1720	d941c21	39	mécanicien	meccanico		\N	2026-01-30 16:23:35.488586	0	2026-01-31 16:23:35.488586	{nom,italien,transport}	2.5	0	0	\N	\N	\N	mechanical	mechanisch	mekanika	\N
200	78a3ef8	10	Calme	Calmo		\N	2025-12-03 13:40:49.987395	1	2025-12-07 15:48:26.095622	{adjectif,italien,fréquent,émotion}	2.6	1	1	\N	\N	Persona che mantiene la serenità anche nelle situazioni difficili.	Calm	Ruhig	Miadana	Resta sempre calmo durante le emergenze.
161	d29231d	9	Voyager	Viaggiare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f5fa.svg	2025-12-03 13:33:24.96619	0	2025-12-04 13:33:24.96619	{verbe,italien,fréquent,loisir}	2.5	0	0	\N	\N	\N	Travel	Reisen	Tsangatsangana	\N
175	907eefa	10	Haut	Alto		\N	2025-12-03 13:40:49.475905	0	2025-12-04 13:40:49.475905	{adjectif,italien,fréquent,taille}	2.5	0	0	\N	\N	\N	High	Hoch	Avo	\N
184	cb57137	10	Froid	Freddo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2744.svg	2025-12-03 13:40:49.662	1	2025-12-07 15:48:13.56071	{adjectif,italien,fréquent,température}	2.6	1	1	\N	\N	\N	Cold	Kalt	Mangatsiaka	\N
185	252d01b	10	Jeune	Giovane		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f466.svg	2025-12-03 13:40:49.680856	0	2025-12-06 16:01:39.717912	{adjectif,italien,fréquent,âge}	2.3	0	0	\N	\N	\N	Young	Jung	tANORA	\N
203	df816de	10	Ennuyeux	Noioso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f614.svg	2025-12-03 13:40:50.053629	0	2025-12-04 13:40:50.053629	{adjectif,italien,fréquent,qualité}	2.5	0	0	\N	\N	\N	Boring	Langweilig	mahasorena	\N
211	a7a946f	10	Malade	Malato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f912.svg	2025-12-03 13:40:50.212151	0	2025-12-04 13:40:50.212151	{adjectif,italien,fréquent,santé}	2.5	0	0	\N	\N	\N	Sick	Krank	marary	\N
874	84168bf	24	Commode	Comò		\N	2025-12-10 15:39:05.748988	0	2025-12-11 15:39:05.748988	{maison,italien}	2.5	0	0	\N	\N	\N	Dresser	Kommode	Dresser	\N
876	e13f8be	24	Canapé	Divano		\N	2025-12-10 15:39:05.783959	0	2025-12-11 15:39:05.783959	{maison,italien}	2.5	0	0	\N	\N	\N	Sofa	Sofa	ambony seza	\N
878	42c3bd7	24	Tapis	Tappeto		\N	2025-12-10 15:39:05.818816	0	2025-12-11 15:39:05.818816	{maison,italien}	2.5	0	0	\N	\N	\N	Rug	Teppich	lamba firakotra	\N
1394	4cc0ddb	36	Se ridiculiser	Fare una figuraccia		\N	2026-01-20 14:49:12.227693	0	2026-01-21 14:49:12.227693	{expression,idiomatique,italien,fréquent,social}	2.5	0	0	\N	\N	\N	Make a fool of yourself	Machen Sie sich lächerlich	Manaova adala	\N
630	a4116b7	18	Menuisier	Falegname		\N	2025-12-07 06:20:59.189527	0	2025-12-08 06:20:59.189527	{métier,italien}	2.5	0	0	\N	\N	\N	Carpenter	Tischler	mpandrafitra	\N
1439	4fa4001	37	aubergine	melanzana		\N	2026-01-21 14:49:58.4637	0	2026-01-22 14:49:58.4637	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	eggplant	Aubergine	baranjely	\N
1440	331f674	37	poivron	peperone		\N	2026-01-21 14:49:58.490803	0	2026-01-22 14:49:58.490803	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pepper	Pfeffer	sakay	\N
1441	221f049	37	salade	insalata		\N	2026-01-21 14:49:58.517056	0	2026-01-22 14:49:58.517056	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	salad	Salat	salady	\N
1442	7e8e19f	37	champignon	fungo		\N	2026-01-21 14:49:58.541812	0	2026-01-22 14:49:58.541812	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	fungus	Pilz	holatra	\N
1443	6198c19	37	poulet	pollo		\N	2026-01-21 14:49:58.565491	0	2026-01-22 14:49:58.565491	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	chicken	Huhn	akoho	\N
1722	0e6271e	39	essuie-glace	tergicristallo		\N	2026-01-30 16:23:35.539103	0	2026-01-31 16:23:35.539103	{nom,italien,transport}	2.5	0	0	\N	\N	\N	windshield wiper	Scheibenwischer	wiper ny fitaratra	\N
879	b324268	24	Télévision	Televisione		\N	2025-12-10 15:39:05.836033	0	2025-12-11 15:39:05.836033	{maison,italien}	2.5	0	0	\N	\N	\N	Television	Fernsehen	Televiziona	\N
1723	ab0beb0	39	coffre (voiture)	bagagliaio		\N	2026-01-30 16:23:35.562837	0	2026-01-31 16:23:35.562837	{nom,italien,transport}	2.5	0	0	\N	\N	\N	trunk	Stamm	vatany	\N
637	6ca6217	18	Vendeur	Commesso		\N	2025-12-07 06:20:59.329529	0	2025-12-08 06:20:59.329529	{métier,italien}	2.5	0	0	\N	\N	\N	Clerk	Sachbearbeiter	mpiasa	\N
1153	fcfa483	30	Être fou	Essere fuori di testa		\N	2026-01-09 16:10:10.895934	0	2026-01-10 16:10:10.895934	{verbe,italien,émotion}	2.5	0	0	\N	\N	\N	Being out of your mind	Verrückt sein	Lasa very saina ianao	\N
638	42ef24d	18	Entraîneur	Allenatore		\N	2025-12-07 06:20:59.349732	0	2025-12-08 06:20:59.349732	{métier,italien}	2.5	0	0	\N	\N	Professionista che guida e prepara gli atleti.	Coach	Trainer	Mpampiofana	L'allenatore ha motivato tutta la squadra.
2459	2fbbd10	41	partir très vite	darsela a gambe		\N	2026-03-03 13:55:58.924846	0	2026-03-04 13:55:58.924846	{}	2.5	0	0	\N	\N	scappare velocemente	to run away	weglaufen	mandositra haingana	Quando il ladro ha visto la polizia, se l’è data a gambe.
881	2391e19	24	Lampe	Lampada		\N	2025-12-10 15:39:05.874211	0	2025-12-11 15:39:05.874211	{maison,italien}	2.5	0	0	\N	\N	\N	Lamp	Lampe	jiro	\N
882	0a11d2d	24	Bibliothèque	Libreria		\N	2025-12-10 15:39:05.894774	0	2025-12-11 15:39:05.894774	{maison,italien}	2.5	0	0	\N	\N	\N	Bookshelf	Bücherregal	fitoeram-boky	\N
885	613292f	24	Frigo	Frigorifero		\N	2025-12-10 15:39:05.953255	0	2025-12-11 15:39:05.953255	{maison,italien}	2.5	0	0	\N	\N	\N	Refrigerator	Kühlschrank	vata fampangatsiahana	\N
640	7df4d74	18	Psychologue	Psicologo		\N	2025-12-07 06:20:59.392327	0	2025-12-08 06:20:59.392327	{métier,italien}	2.5	0	0	\N	\N	\N	Psychologist	Psychologe	psikology	\N
1446	8fe191e	37	bœuf	manzo		\N	2026-01-21 14:49:58.641199	0	2026-01-22 14:49:58.641199	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	beef	Rindfleisch	omby	\N
1154	6a64dc1	30	Éliminer	Fare fuori		\N	2026-01-09 16:10:10.917503	0	2026-01-10 16:10:10.917503	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Making out	Ausfertigung	Mamorona	\N
1155	2fb448d	30	Mettre dedans	Mettere dentro		\N	2026-01-09 16:10:10.938029	0	2026-01-10 16:10:10.938029	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Put inside	Hineinlegen	Ataovy ao anatiny	\N
1156	606b136	30	Renverser avec voiture	Mettere sotto		\N	2026-01-09 16:10:10.960864	0	2026-01-10 16:10:10.960864	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Put underneath	Unterlegen	Apetraho eo ambany	\N
1747	b159c98	40	sincère	sincero		\N	2026-01-31 15:19:21.898269	0	2026-02-01 15:19:21.898269	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	\N	sincere	aufrichtig	olona tia	\N
1833	62548dd	41	filer à l'anglaise	svignarsela		\N	2026-02-06 15:39:12.221757	0	2026-02-07 15:39:12.221757	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Andarsene di nascosto senza salutare	to slip away quietly	sich heimlich davonstehlen	miala tsy misy mahita	Alla festa si è svignata prima che qualcuno se ne accorgesse.
886	429fa47	24	Four	Forno		\N	2025-12-10 15:39:05.970565	0	2025-12-11 15:39:05.970565	{maison,italien}	2.5	0	0	\N	\N	\N	Oven	Ofen	lafaoro	\N
887	0ea2c80	24	Micro-ondes	Microonde		\N	2025-12-10 15:39:05.992745	0	2025-12-11 15:39:05.992745	{maison,italien}	2.5	0	0	\N	\N	\N	Microwave	Mikrowelle	Microwave	\N
891	d52c456	24	Casserole	Pentola		\N	2025-12-10 15:39:06.079599	0	2025-12-11 15:39:06.079599	{maison,italien}	2.5	0	0	\N	\N	\N	Pot	Pot	vilany	\N
892	ec5377b	24	Poêle	Padella		\N	2025-12-10 15:39:06.100398	0	2025-12-11 15:39:06.100398	{maison,italien}	2.5	0	0	\N	\N	\N	Pan	Pfanne	fanendasana	\N
649	174dba6	19	Mouton	Pecora		\N	2025-12-07 06:26:42.634635	0	2025-12-08 06:26:42.634635	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Sheep	Schaf	ONDRIN'I	\N
667	6fb9129	19	Kangourou	Canguro		\N	2025-12-07 06:26:43.077998	0	2025-12-08 06:26:43.077998	{animaux,italien}	2.5	0	0	\N	\N	\N	Kangaroo	Känguru	Kangaroo	\N
670	2b6424f	19	Zèbre	Zebra		\N	2025-12-07 06:26:43.147433	0	2025-12-08 06:26:43.147433	{animaux,italien}	2.5	0	0	\N	\N	\N	Zebra	Zebra	Zebra	\N
673	9a685b5	19	Serpent	Serpente		\N	2025-12-07 06:26:43.212493	0	2025-12-08 06:26:43.212493	{animaux,italien}	2.5	0	0	\N	\N	\N	Snake	Schlange	MENARANA	\N
1160	963c1ae	30	Attaquer verbalement	Dare addosso		\N	2026-01-09 16:10:11.034355	0	2026-01-10 16:10:11.034355	{verbe,italien,relation}	2.5	0	0	\N	\N	\N	To give on	Weitergeben	To give on	\N
1161	9e8a418	30	Travailler dur	Darci dentro		\N	2026-01-09 16:10:11.056578	0	2026-01-10 16:10:11.056578	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Go for it	Tue es	Ataovy	\N
209	38d9507	10	Fatigué	Stanco		\N	2025-12-03 13:40:50.169918	1	2025-12-07 15:55:11.744802	{adjectif,italien,fréquent,état}	2.6	1	1	\N	\N	\N	Tired	Müde	RERAKA	\N
213	c3ddac0	10	Amer	Amaro		\N	2025-12-03 13:40:50.263042	0	2025-12-06 16:04:52.406836	{adjectif,italien,fréquent,goût}	2.3	0	0	\N	\N	\N	Bitter	Bitter	mangidy	\N
215	ff486c9	10	Acide	Acido		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f34b.svg	2025-12-03 13:40:50.297396	0	2025-12-04 13:40:50.297396	{adjectif,italien,fréquent,goût}	2.5	0	0	\N	\N	\N	Acid	Säure	asidra	\N
1162	5e92941	30	Donner gratuitement	Dare via		\N	2026-01-09 16:10:11.077613	0	2026-01-10 16:10:11.077613	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Give it away	Verschenkt es	Omeo azy	\N
1163	b984db0	30	Noter rapidement	Buttare giù		\N	2026-01-09 16:10:11.096657	0	2026-01-10 16:10:11.096657	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Throw it down	Wirf es weg	Atsipazo midina	\N
1164	fad3c69	30	Jeter	Buttare via		\N	2026-01-09 16:10:11.116229	0	2026-01-10 16:10:11.116229	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Throw away	Wegwerfen	Ario	\N
1165	1b6feaf	30	Ejecter	Buttare fuori		\N	2026-01-09 16:10:11.135066	0	2026-01-10 16:10:11.135066	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Throw out	Wegwerfen	ario mivoaka	\N
1167	57fa66a	30	S'en sortir	Tirare avanti		\N	2026-01-09 16:10:11.17304	0	2026-01-10 16:10:11.17304	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Move forward	Gehen Sie vorwärts	Mandrosoa	\N
216	365cee1	10	Frais	Fresco		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/2744.svg	2025-12-03 13:40:50.315834	1	2025-12-07 15:53:26.213633	{adjectif,italien,fréquent,température}	2.6	1	1	\N	\N	\N	Fresh	Frisch	Fresh	\N
212	52ce824	10	Doux	Dolce		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f36c.svg	2025-12-03 13:40:50.238974	1	2025-12-07 16:00:50.586906	{adjectif,italien,fréquent,goût}	2.6	1	1	\N	\N	\N	Sweet	Süß	hanitra	\N
214	2d8ad78	10	Salé	Salato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9c2.svg	2025-12-03 13:40:50.280745	0	2025-12-06 16:09:21.945354	{adjectif,italien,fréquent,goût}	2.3	0	0	\N	\N	\N	Savory	Bohnenkraut	hanim-py	\N
654	a91269b	19	Canard	Anatra		\N	2025-12-07 06:26:42.743682	0	2025-12-08 06:26:42.743682	{animaux,italien}	2.5	0	0	\N	\N	\N	Duck	Ente	Gana	\N
657	f660f29	19	Aigle	Aquila		\N	2025-12-07 06:26:42.825098	0	2025-12-08 06:26:42.825098	{animaux,italien}	2.5	0	0	\N	\N	\N	Eagle	Adler	Eagle	\N
1168	c3e50c6	30	Tirer dehors	Tirare fuori		\N	2026-01-09 16:10:11.192879	0	2026-01-10 16:10:11.192879	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Take out	Mitnahme	Mamoaka	\N
1169	9f70b43	30	Remonter le moral	Tirare su		\N	2026-01-09 16:10:11.212575	0	2026-01-10 16:10:11.212575	{verbe,italien,émotion}	2.5	0	0	\N	\N	\N	Pull up	Hochziehen	Misintona miakatra	\N
1170	bc50e65	30	S'en aller	Andare via		\N	2026-01-09 16:10:11.232556	0	2026-01-10 16:10:11.232556	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go away	Geh weg	Andehana mandeha	\N
1171	9d6a266	30	Entrer dans	Entrare in		\N	2026-01-09 16:10:11.252424	0	2026-01-10 16:10:11.252424	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Enter	Eingeben	Ampidiro	\N
1172	6283aad	30	Se manifester	Farsi avanti		\N	2026-01-09 16:10:11.272651	0	2026-01-10 16:10:11.272651	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Come forward	Komm nach vorne	Mandrosoa	\N
1176	f3c59ee	30	Faire attention à	Stare attento a		\N	2026-01-09 16:10:11.353129	0	2026-01-10 16:10:11.353129	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Be careful	Seien Sie vorsichtig	Mitandrema	\N
1177	6e8935f	30	Retourner	Tornare indietro		\N	2026-01-09 16:10:11.373896	0	2026-01-10 16:10:11.373896	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go back	Geh zurück	Hiverina	\N
1178	5bf655a	30	Sortir	Venire fuori		\N	2026-01-09 16:10:11.392624	0	2026-01-10 16:10:11.392624	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Come out	Herauskommen	Niseho	\N
1179	56285f4	30	Aller dedans	Andare dentro		\N	2026-01-09 16:10:11.411316	0	2026-01-10 16:10:11.411316	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go inside	Geh hinein	Midira ao anatiny	\N
1180	78ca237	30	Aller en haut	Andare su		\N	2026-01-09 16:10:11.430848	0	2026-01-10 16:10:11.430848	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go up	Steigen	Miakara	\N
1181	6609918	30	Venir vers le haut	Venire su		\N	2026-01-09 16:10:11.450132	0	2026-01-10 16:10:11.450132	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Come up	Aufkommen	Miakara	\N
230	cc3758e	10	Sérieux	Serio		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f610.svg	2025-12-03 13:40:50.5662	0	2025-12-04 13:40:50.5662	{adjectif,italien,fréquent,personnalité}	2.5	0	0	\N	\N	Persona responsabile e concentrata.	Serious	Ernst	Miaraka	È serio e prende tutto sul serio.
228	d9e57ed	10	Antipathique	Antipatico		\N	2025-12-03 13:40:50.53146	0	2025-12-04 13:40:50.53146	{adjectif,italien,fréquent,personnalité}	2.5	0	0	\N	\N	\N	Unfriendly	Unfreundlich	ninamana	\N
245	afef8b9	10	Fermé	Chiuso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f512.svg	2025-12-03 13:40:50.843664	0	2025-12-04 13:40:50.843664	{adjectif,italien,fréquent,état}	2.5	0	0	\N	\N	\N	Closed	Geschlossen	mihidy	\N
544	ff262b1	17	Le père	Il padre		\N	2025-12-07 06:08:34.946224	0	2025-12-08 06:08:34.946224	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The father	Der Vater	Ny ray	\N
679	7ed084b	19	Requin	Squalo		\N	2025-12-07 06:26:43.333195	0	2025-12-08 06:26:43.333195	{animaux,italien}	2.5	0	0	\N	\N	\N	Shark	Hai	Antsantsa	\N
1187	9931fdd	30	Être en désavantage	Essere sotto		\N	2026-01-09 16:10:11.569169	0	2026-01-10 16:10:11.569169	{verbe,italien,état}	2.5	0	0	\N	\N	\N	Being underneath	Darunter sein	Eo ambany	\N
1188	5979d59	30	Rester derrière	Stare dietro		\N	2026-01-09 16:10:11.587922	0	2026-01-10 16:10:11.587922	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Stay behind	Bleiben Sie zurück	Mijanòna any aoriana	\N
1190	458a4d7	30	Parler dans le dos	Parlare alle spalle		\N	2026-01-09 16:10:11.626404	0	2026-01-10 16:10:11.626404	{verbe,italien,relation}	2.5	0	0	\N	\N	\N	Talking behind your back	Hinter deinem Rücken reden	Miresaka ao ambadika	\N
1191	ea5dbd2	30	Aller à la rencontre	Andare incontro		\N	2026-01-09 16:10:11.645438	0	2026-01-10 16:10:11.645438	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Go towards each other	Gehen Sie aufeinander zu	Mandehana mifanatrika	\N
1150	1a63b8f	30	Enlever	Portare via		\N	2026-01-09 16:10:10.827449	0	2026-01-10 16:10:10.827449	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Take away	Wegbringen	Entina	\N
1151	c4d3f59	30	Continuer	Portare avanti		\N	2026-01-09 16:10:10.855657	0	2026-01-10 16:10:10.855657	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Carry on	Weitermachen	Tohizo hatrany	\N
129	0e8ea33	9	Sauvegarder	Salvare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4be.svg	2025-12-03 13:33:24.302119	0	2025-12-07 07:16:21.245076	{verbe,italien,fréquent,technologie}	2.3	0	0	\N	\N	\N	Save	Speichern	afa-tsy	\N
684	031d306	19	Papillon	Farfalla		\N	2025-12-07 06:26:43.432576	0	2025-12-08 06:26:43.432576	{animaux,italien}	2.5	0	0	\N	\N	\N	Butterfly	Schmetterling	lolo	\N
687	cb29519	19	Fourmi	Formica		\N	2025-12-07 06:26:43.495433	0	2025-12-08 06:26:43.495433	{animaux,italien}	2.5	0	0	\N	\N	\N	Ant	Ameise	vitsika	\N
691	f75faff	20	Mélanger	Mescolare		\N	2025-12-07 06:31:34.087699	2	2025-12-17 08:29:58.208484	{cuisine,italien}	2.7	6	2	\N	\N	\N	Mix	Mischen	Mix	\N
694	96eabeb	20	Cuire	Cuocere		\N	2025-12-07 06:31:34.154796	2	2025-12-17 08:29:33.191847	{cuisine,italien}	2.7	6	2	\N	\N	\N	Cook	Kochen	Cook	\N
1825	4fc767e	40	sérieux	serio			2026-01-31 15:20:42.380202	0	2026-02-01 15:20:42.380202	{}	2.5	0	0	\N	\N	\N	serious	ernst	matotra	\N
1826	e21a9db	40	joyeux	allegro			2026-01-31 15:20:55.100737	0	2026-02-01 15:20:55.100737	{}	2.5	0	0	\N	\N	\N	cheerful	heiter	Amim-pifaliana	\N
695	a50c713	20	Bouillir	Bollire		\N	2025-12-07 06:31:34.254936	1	2025-12-11 14:00:09.325442	{cuisine,italien}	2.4	1	1	\N	\N	\N	Boil	Kochen	vay	\N
1192	0a93723	30	Être à côté	Stare accanto		\N	2026-01-09 16:10:11.66491	0	2026-01-10 16:10:11.66491	{verbe,italien,relation}	2.5	0	0	\N	\N	\N	Stay close	Bleiben Sie nah dran	Mijanòna akaiky	\N
1095	efc1927	28	Politique	Politica		\N	2026-01-08 15:19:20.125128	1	2026-02-02 15:22:10.359298	{nom,italien,politique}	2.6	1	1	\N	\N	\N	Politics	Politik	Politika	\N
1149	1a5c073	28	Source d'énegie	Fonte di Energia		\N	2026-01-08 15:25:50.658033	1	2026-02-02 15:35:12.461036	{Environnement}	2.6	1	1	\N	\N	\N	Source of Energy	Energiequelle	Loharanon'ny angovo	\N
1193	5f826b2	30	Tourner autour	Girare attorno		\N	2026-01-09 16:10:11.683899	0	2026-01-10 16:10:11.683899	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go around	Gehen Sie herum	Mandehana manodidina	\N
1207	768e628	31	Panneau solaire	Pannello solare		\N	2026-01-11 15:36:49.066816	0	2026-01-12 15:36:49.066816	{nom,italien,énergie}	2.5	0	0	\N	\N	\N	Solar panel	Solarpanel	Paneau solaire	\N
1208	be847b0	31	Voiture électrique	Auto elettrica		\N	2026-01-11 15:36:49.084805	0	2026-01-12 15:36:49.084805	{nom,italien,transport}	2.5	0	0	\N	\N	\N	Electric car	Elektroauto	Fiara elektrika	\N
1271	d93807b	31	Chaîne alimentaire	Catena alimentare		\N	2026-01-11 15:36:50.549851	0	2026-01-12 15:36:50.549851	{expression,italien,écologie}	2.5	0	0	\N	\N	\N	Food chain	Nahrungskette	Rojo sakafo	\N
1212	de394f5	31	Récif corallien	Barriera corallina		\N	2026-01-11 15:36:49.166162	0	2026-01-12 15:36:49.166162	{nom,italien,eau}	2.5	0	0	\N	\N	\N	Coral reef	Korallenriff	haran-dranomasina	\N
1213	fcbccf7	31	Niveau de la mer	Livello del mare		\N	2026-01-11 15:36:49.184505	0	2026-01-12 15:36:49.184505	{expression,italien,climat}	2.5	0	0	\N	\N	\N	Sea level	Meeresspiegel	haavon'ny ranomasina	\N
233	cefc4e5	10	Rusé	Furbo		\N	2025-12-03 13:40:50.618411	0	2025-12-06 16:05:52.15087	{adjectif,italien,fréquent,personnalité}	2.3	0	0	\N	\N	\N	Cunning	Listig	mahay	\N
234	bbc8ddb	10	Honnête	Onesto		\N	2025-12-03 13:40:50.63799	0	2025-12-06 16:04:05.997244	{adjectif,italien,fréquent,morale}	2.3	0	0	\N	\N	\N	Honest	Ehrlich	marina	\N
238	75d5f0a	10	Célèbre	Famoso		\N	2025-12-03 13:40:50.711404	1	2025-12-07 15:53:37.610806	{adjectif,italien,fréquent,notoriété}	2.6	1	1	\N	\N	\N	Famous	Berühmt	olo-malaza	\N
242	80f2058	10	Différent	Diverso		\N	2025-12-03 13:40:50.786624	0	2025-12-06 16:02:10.966222	{adjectif,italien,fréquent,comparaison}	2.3	0	0	\N	\N	\N	Different	Anders	SAMY HAFA	\N
243	7e0e767	10	Identique	Uguale		\N	2025-12-03 13:40:50.803287	0	2025-12-06 16:02:45.093897	{adjectif,italien,fréquent,comparaison}	2.3	0	0	\N	\N	\N	The same	Das gleiche	Mitovy	\N
690	32632ff	20	Émincer	Affettare		\N	2025-12-07 06:31:34.062783	1	2025-12-11 14:00:55.009742	{cuisine,italien}	2.4	1	1	\N	\N	\N	Slice	Scheibe	silaka	\N
701	6334ff8	20	Rincer	Sciacquare		\N	2025-12-07 06:31:34.41063	0	2025-12-11 08:40:49.09834	{cuisine,italien}	1.6999999999999997	0	0	\N	\N	\N	Rinse	Spülen	hosasany	\N
704	6953cf1	20	Assaisonner	Condire		\N	2025-12-07 06:31:34.472561	3	2025-12-30 08:31:00.985609	{cuisine,italien}	2.4	19	3	\N	\N	\N	Season	Jahreszeit	vanim-potoana	\N
897	0390717	24	Table	Tavolo		\N	2025-12-10 15:39:06.203769	0	2025-12-11 15:39:06.203769	{maison,italien}	2.5	0	0	\N	\N	\N	Table	Tisch	LOHA	\N
1371	15e001d	35	Dépenser sans compter	Avere le mani bucate		\N	2026-01-12 13:20:17.665582	2	2026-02-07 15:16:39.284981	{expression,italien,argent,dépenses}	2.7	6	2	\N	\N	\N	Having your hands full	Sie haben alle Hände voll zu tun	Feno ny tananao	\N
1449	e2693b9	37	saucisse	salsiccia		\N	2026-01-21 14:49:58.737981	0	2026-01-22 14:49:58.737981	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	sausage	Wurst	saosisy	\N
1450	b0d352a	37	œuf	uovo		\N	2026-01-21 14:49:58.766473	0	2026-01-22 14:49:58.766473	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	egg	Ei	atody	\N
1214	0ee7813	31	Fonte des glaces	Scioglimento dei ghiacci		\N	2026-01-11 15:36:49.20295	0	2026-01-12 15:36:49.20295	{expression,italien,climat}	2.5	0	0	\N	\N	\N	Melting of ice	Schmelzendes Eis	Mitsonika ny ranomandry	\N
708	dc5f099	20	Goûter	Assaggiare		\N	2025-12-07 06:31:34.5534	1	2025-12-12 08:30:55.339893	{cuisine,italien}	2	1	1	\N	\N	\N	Taste	Schmecken	tsiro	\N
1618	3201821	39	automobile	auto		\N	2026-01-30 16:23:21.871607	0	2026-01-31 16:23:21.871607	{nom,italien,transport}	2.5	0	0	\N	\N	\N	car	Auto	fiara	\N
1285	f1276ba	31	Mer	Mare		\N	2026-01-11 15:36:50.949112	0	2026-01-12 15:36:50.949112	{nom,italien,eau}	2.5	0	0	\N	\N	Estensione d'acqua salata più piccola di un oceano, spesso parzialmente circondata da terre.	Sea	Meer	Ranomasina	Il mare Mediterraneo bagna le coste italiane.
1617	23e0cf8	39	Machine	macchina		\N	2026-01-30 16:23:21.810501	0	2026-01-31 16:23:21.810501	{nom,italien,transport}	2.5	0	0	\N	\N	Dispositivo meccanico che trasforma energia in lavoro utile.	Machine	Maschine	Milina	La macchina funziona con efficienza.
1221	1e01569	31	Durabilité	Sostenibilità		\N	2026-01-11 15:36:49.35443	0	2026-01-12 15:36:49.35443	{nom,italien,développement}	2.5	0	0	\N	\N	Capacità di durare nel tempo senza esaurire risorse.	Sustainability	Nachhaltigkeit	Durabilité	La sostenibilità è un obiettivo globale.
1216	1e12a95	31	Ouragan	Uragano		\N	2026-01-11 15:36:49.240727	0	2026-01-12 15:36:49.240727	{nom,italien,catastrophe}	2.5	0	0	\N	\N	\N	Hurricane	Hurrikan	Rivo-doza	\N
1301	cf8b594	32	Réponse à bonne chance	Crepi il lupo		\N	2026-01-12 12:49:14.384796	0	2026-01-13 12:49:14.384796	{expression,italien,animal,réponse}	2.5	0	0	\N	\N	\N	Die the wolf	Stirb der Wolf	Maty ny amboadia	\N
1302	26bf71d	32	Avoir très faim	Avere una fame da lupo		\N	2026-01-12 12:49:14.407411	0	2026-01-13 12:49:14.407411	{expression,italien,animal,faim}	2.5	0	0	\N	\N	\N	Be hungry like a wolf	Sei hungrig wie ein Wolf	Aoka ho noana toy ny amboadia	\N
1220	879d4f4	31	Tsunami	Tsunami		\N	2026-01-11 15:36:49.332034	0	2026-01-12 15:36:49.332034	{nom,italien,catastrophe}	2.5	0	0	\N	\N	\N	Tsunami	Tsunami	tsunami,	\N
1222	2da785b	31	Éco-responsable	Eco-responsabile		\N	2026-01-11 15:36:49.375782	0	2026-01-12 15:36:49.375782	{adjectif,italien,qualité}	2.5	0	0	\N	\N	\N	Eco-responsible	Umweltbewusst	Tompon'andraikitra amin'ny tontolo iainana	\N
545	727722c	17	La mère	La madre		\N	2025-12-07 06:08:34.967993	0	2025-12-08 06:08:34.967993	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The mother	Die Mutter	Ny reny	\N
1223	a1c6628	31	Biologique	Biologico		\N	2026-01-11 15:36:49.397529	0	2026-01-12 15:36:49.397529	{adjectif,italien,agriculture}	2.5	0	0	\N	\N	\N	Biological	Biologisch	niteraka	\N
705	fdcebe4	20	Verser	Versare		\N	2025-12-07 06:31:34.492752	2	2025-12-17 08:28:57.199141	{cuisine,italien}	2.7	6	2	\N	\N	\N	Deposit	Kaution	petra-bola	\N
1224	5eee808	31	Agriculture biologique	Agricoltura biologica		\N	2026-01-11 15:36:49.420014	0	2026-01-12 15:36:49.420014	{expression,italien,agriculture}	2.5	0	0	\N	\N	\N	Organic farming	Ökologischer Landbau	Fiompiana organika	\N
1225	4fa6251	31	Reboisement	Rimboschimento		\N	2026-01-11 15:36:49.439476	0	2026-01-12 15:36:49.439476	{nom,italien,nature}	2.5	0	0	\N	\N	\N	Reforestation	Wiederaufforstung	Fambolen-kazo	\N
246	1a44236	10	Proche	Vicino		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4cd.svg	2025-12-03 13:40:50.864371	0	2025-12-04 13:40:50.864371	{adjectif,italien,fréquent,distance}	2.5	0	0	\N	\N	\N	Near	Nahe	AKAIKY	\N
699	81f05a9	20	Éplucher	Sbucciare		\N	2025-12-07 06:31:34.370768	2	2025-12-17 08:28:51.798885	{cuisine,italien}	2.5	6	2	\N	\N	\N	Peel	Schälen	Peel	\N
711	7b07302	20	Pétrir	Impastare		\N	2025-12-07 06:31:34.615698	1	2025-12-12 08:30:40.764795	{cuisine,italien}	1.6	1	1	\N	\N	\N	Knead	Kneten	mametafeta	\N
899	a681650	24	Salle de bain	Bagno		\N	2025-12-10 15:39:06.242364	0	2025-12-11 15:39:06.242364	{maison,italien}	2.5	0	0	\N	\N	\N	Bath	Bad	Bath	\N
900	b98a3b2	24	Douche	Doccia		\N	2025-12-10 15:39:06.265933	0	2025-12-11 15:39:06.265933	{maison,italien}	2.5	0	0	\N	\N	\N	Shower	Dusche	fandroana	\N
1621	419ceb3	39	avion	aereo		\N	2026-01-30 16:23:21.944219	0	2026-01-31 16:23:21.944219	{nom,italien,transport}	2.5	0	0	\N	\N	\N	airplane	Flugzeug	fiaramanidina	\N
1305	3458064	32	Tourner autour du pot	Menare il can per l’aia		\N	2026-01-12 12:49:14.483891	0	2026-01-13 12:49:14.483891	{expression,italien,animal,discussion}	2.5	0	0	\N	\N	\N	Beat around the bush	Reden Sie um den heißen Brei herum	Kapohy manodidina ny kirihitra	\N
1233	5f254c6	31	Réserve naturelle	Riserva naturale		\N	2026-01-11 15:36:49.727844	0	2026-01-12 15:36:49.727844	{expression,italien,conservation}	2.5	0	0	\N	\N	\N	Nature reserve	Naturschutzgebiet	Toerana voajanahary	\N
1234	105362e	31	Énergie verte	Energia verde		\N	2026-01-11 15:36:49.748856	0	2026-01-12 15:36:49.748856	{expression,italien,énergie}	2.5	0	0	\N	\N	\N	Green energy	Grüne Energie	Angovo maitso	\N
1235	22e7b4f	31	Hydroélectrique	Idroelettrico		\N	2026-01-11 15:36:49.771826	0	2026-01-12 15:36:49.771826	{adjectif,italien,énergie}	2.5	0	0	\N	\N	\N	Hydroelectric	Wasserkraft	herinaratra	\N
1237	0744267	31	Géothermique	Geotermico		\N	2026-01-11 15:36:49.817936	0	2026-01-12 15:36:49.817936	{adjectif,italien,énergie}	2.5	0	0	\N	\N	\N	Geothermal	Geothermie	hafanana avy ao anaty	\N
1626	4a2bf03	39	métro	metropolitana		\N	2026-01-30 16:23:22.14099	0	2026-01-31 16:23:22.14099	{nom,italien,transport}	2.5	0	0	\N	\N	\N	subway	U-Bahn	metro	\N
1250	acbfc0c	31	Technologie propre	Tecnologia pulita		\N	2026-01-11 15:36:50.106172	0	2026-01-12 15:36:50.106172	{expression,italien,tech}	2.5	0	0	\N	\N	\N	Clean technology	Saubere Technologie	Teknolojia madio	\N
703	2f9549e	20	Poivrer	Pepare		\N	2025-12-07 06:31:34.452765	2	2025-12-17 08:30:07.058392	{cuisine,italien}	2.5	6	2	\N	\N	\N	Pepper	Pfeffer	Sakay	\N
905	2c5ddfa	24	Serviette	Asciugamano		\N	2025-12-10 15:39:06.35255	0	2025-12-11 15:39:06.35255	{maison,italien}	2.5	0	0	\N	\N	\N	Towel	Handtuch	lamba famaohana	\N
1251	38a7931	31	Batterie	Batteria		\N	2026-01-11 15:36:50.126969	0	2026-01-12 15:36:50.126969	{nom,italien,énergie}	2.5	0	0	\N	\N	\N	Drums	Schlagzeug	amponga	\N
1252	b4ae5ec	31	Électrique	Elettrico		\N	2026-01-11 15:36:50.15124	0	2026-01-12 15:36:50.15124	{adjectif,italien,énergie}	2.5	0	0	\N	\N	\N	Electric	Elektrisch	elektrika	\N
1253	a2619d7	31	Hybride	Ibrido		\N	2026-01-11 15:36:50.176237	0	2026-01-12 15:36:50.176237	{adjectif,italien,transport}	2.5	0	0	\N	\N	\N	Hybrid	Hybrid	mifangaro	\N
547	168d463	17	Le fils	Il figlio		\N	2025-12-07 06:08:35.01388	0	2025-12-08 06:08:35.01388	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The son	Der Sohn	Ny zanaka	\N
1254	0488c95	31	Biocarburant	Biocarburante		\N	2026-01-11 15:36:50.197262	0	2026-01-12 15:36:50.197262	{nom,italien,énergie}	2.5	0	0	\N	\N	\N	Biofuel	Biokraftstoff	Biofuel	\N
87	4a52de4	9	Oublier	Dimenticare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-03 13:33:23.473232	1	2025-12-08 07:00:54.67309	{verbe,italien,fréquent,cognition}	2.6	1	1	\N	\N	\N	Forget	Vergessen	Adinoy	\N
1454	bae9c27	37	crème	panna		\N	2026-01-21 14:49:58.982126	0	2026-01-22 14:49:58.982126	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cream	Creme	fanosotra	\N
1307	7d0aa77	32	Être malin	Essere furbo come una volpe		\N	2026-01-12 12:49:14.537599	0	2026-01-13 12:49:14.537599	{expression,italien,animal,caractère}	2.5	0	0	\N	\N	\N	Be as smart as a fox	Sei so schlau wie ein Fuchs	Aoka ho hendry tahaka ny amboahaolo	\N
1308	5036f93	32	Être épuisé	Essere stanco come un cane		\N	2026-01-12 12:49:14.564084	0	2026-01-13 12:49:14.564084	{expression,italien,animal,fatigue}	2.5	0	0	\N	\N	\N	Being tired as a dog	Als Hund müde sein	Reraka toy ny alika	\N
1867	4735246	41	mettre	metterci		\N	2026-02-06 15:39:12.958072	1	2026-02-14 08:09:03.177363	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Impiegare tempo per fare qualcosa	to take (time)	dauern / brauchen	mandany fotoana	Ci metto cinque minuti ad arrivare.
553	167e2f9	17	La grand-mère	La nonna		\N	2025-12-07 06:08:35.139401	0	2025-12-08 06:08:35.139401	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The grandmother	Die Großmutter	Ny renibe	\N
1027	78c0450	18	Ouvrier	Operaio		\N	2025-12-17 15:19:53.332258	0	2025-12-18 15:19:53.332258	{}	2.5	0	0	\N	\N	\N	Worker	Arbeitnehmer	MPIASA	\N
1029	63b3464	18	Facteur	Postino		\N	2025-12-17 15:21:26.610618	0	2025-12-18 15:21:26.610618	{}	2.5	0	0	\N	\N	\N	Postman	\N	\N	\N
1031	9b6a43a	18	Traducteur	Traduttore		\N	2025-12-17 15:22:32.582984	0	2025-12-18 15:22:32.582984	{}	2.5	0	0	\N	\N	\N	Translator	Übersetzer	MPANDIKA TENY	\N
1033	d2bf716	18	Ambulancier	Ambulanziata		\N	2025-12-17 15:24:39.352311	0	2025-12-18 15:24:39.352311	{}	2.5	0	0	\N	\N	\N	Ambulance	Krankenwagen	fiara mpitondra marary	\N
591	84eb2a9	18	Pompier	Pompiere		\N	2025-12-07 06:20:58.238954	0	2025-12-08 06:20:58.238954	{métier,italien}	2.5	0	0	\N	\N	\N	Firemen	Feuerwehrleute	mpamono afo	\N
614	8087e61	18	Banquier	Banchiere		\N	2025-12-07 06:20:58.817719	0	2025-12-08 06:20:58.817719	{métier,italien}	2.5	0	0	\N	\N	\N	Banker	Banker	mpiasan'ny banky	\N
906	e106017	24	Machine à laver	Lavatrice		\N	2025-12-10 15:39:06.368338	0	2025-12-11 15:39:06.368338	{maison,italien}	2.5	0	0	\N	\N	\N	Washing machine	Waschmaschine	milina fanasan-damba	\N
1053	eb0b1bd	28	Forêt	Foresta		\N	2026-01-08 15:19:18.215363	1	2026-02-02 15:23:18.98172	{nom,italien,nature}	2.6	1	1	\N	\N	Vasta estensione di terreno coperta da alberi ad alto fusto.	Forest	Wald	Ala	La foresta amazzonica è il polmone verde del pianeta.
1055	07e41ef	28	Plan	Pianta		\N	2026-01-08 15:19:18.262808	1	2026-02-02 15:28:51.606149	{nom,italien,nature}	2.6	1	1	\N	\N	Rappresentazione orizzontale dettagliata di un'area urbana o di un edificio.	Plan	Plan	Plan	Il piano della città mostra tutte le strade principali.
907	67b1c91	24	Panier à linge	Cesto della biancheria		\N	2025-12-10 15:39:06.384366	0	2025-12-11 15:39:06.384366	{maison,italien}	2.5	0	0	\N	\N	\N	Laundry basket	Wäschekorb	Sobika fanasan-damba	\N
908	c9ebc87	24	Bureau	Scrivania		\N	2025-12-10 15:39:06.401675	0	2025-12-11 15:39:06.401675	{maison,italien}	2.5	0	0	\N	\N	\N	Desk	Schreibtisch	Birao	\N
1025	b6bc542	18	Employé de bureau	Impiegato		\N	2025-12-17 15:18:09.806859	0	2025-12-18 15:18:09.806859	{}	2.5	0	0	\N	\N	\N	Employee	Mitarbeiter	mpiasa	\N
1456	14d27d1	37	hamburger	hamburger		\N	2026-01-21 14:49:59.140173	0	2026-01-22 14:49:59.140173	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	burgers	Burger	burgers	\N
1457	8ea2eaa	37	fruit	frutta		\N	2026-01-21 14:49:59.259416	0	2026-01-22 14:49:59.259416	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	fruit	Obst	voankazo	\N
1459	11f4417	37	pomme	mela		\N	2026-01-21 14:49:59.466883	0	2026-01-22 14:49:59.466883	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	apple	Apfel	\N	\N
893	c268c42	24	Assiette	Piatto		\N	2025-12-10 15:39:06.121436	0	2025-12-11 15:39:06.121436	{maison,italien}	2.5	0	0	\N	\N	\N	Dish	Gericht	lovia	\N
940	a3ec0c3	25	Ouvre-bouteille	Apribottiglie		\N	2025-12-11 15:25:46.323863	0	2025-12-12 15:25:46.323863	{cuisine,italien}	2.5	0	0	\N	\N	\N	Bottle opener	Flaschenöffner	Mpamoaka tavoahangy	\N
1026	8f689b2	18	Coiffeur	Parucchiere		\N	2025-12-17 15:18:54.589173	0	2025-12-18 15:18:54.589173	{}	2.5	0	0	\N	\N	\N	Hairdresser	Friseur	mpanety	\N
241	75bb66a	10	Spécial	Speciale		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f31f.svg	2025-12-03 13:40:50.768177	1	2025-12-07 15:57:53.773194	{adjectif,italien,fréquent,qualité}	2.6	1	1	\N	\N	\N	Special	Besonders	Special	\N
244	ce5ff91	10	Ouvert	Aperto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f513.svg	2025-12-03 13:40:50.822955	1	2025-12-07 15:57:11.258164	{adjectif,italien,fréquent,état}	2.6	1	1	\N	\N	\N	Open	Offen	Misokatra	\N
259	924bab2	10	Superficiel	Superficiale		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c5.svg	2025-12-03 13:40:51.1327	0	2025-12-04 13:40:51.1327	{adjectif,italien,fréquent,taille}	2.5	0	0	\N	\N	\N	Superficial	Oberflächlich	endrika ivelany fotsiny	\N
261	3455290	10	Réduit	Ridotto		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4c9.svg	2025-12-03 13:40:51.173072	0	2025-12-04 13:40:51.173072	{adjectif,italien,fréquent,niveau}	2.5	0	0	\N	\N	\N	Reduced	Reduziert	mihena	\N
910	a7fd683	24	Chaise de bureau	Sedia da ufficio		\N	2025-12-10 15:39:06.438344	0	2025-12-11 15:39:06.438344	{maison,italien}	2.5	0	0	\N	\N	\N	Office chair	Bürostuhl	Seza birao	\N
912	e2bca2f	24	Rideau	Tenda		\N	2025-12-10 15:39:06.475691	0	2025-12-11 15:39:06.475691	{maison,italien}	2.5	0	0	\N	\N	\N	Tent	Zelt	TRANOLAIN'I	\N
914	413e4ad	24	Entrée	Ingresso		\N	2025-12-10 15:39:06.512035	0	2025-12-11 15:39:06.512035	{maison,italien}	2.5	0	0	\N	\N	\N	Entrance	Eingang	Fidirana	\N
1024	7b4f2cd	18	Paysan	Contadino		\N	2025-12-17 15:16:19.233241	0	2025-12-18 15:16:19.233241	{}	2.5	0	0	\N	\N	\N	Farmer	Bauer	MPAMBOLY	\N
1028	fc99059	18	Directeur	Direttore		\N	2025-12-17 15:20:45.892099	0	2025-12-18 15:20:45.892099	{}	2.5	0	0	\N	\N	\N	Director	Direktor	tale	\N
1030	565f2b8	18	Bibliothécaire	Bibliotecario		\N	2025-12-17 15:22:08.036873	0	2025-12-18 15:22:08.036873	{}	2.5	0	0	\N	\N	\N	Librarian	Bibliothekar	tranomboky	\N
1032	0fd74b1	18	Styliste	Stilista		\N	2025-12-17 15:23:07.498476	0	2025-12-18 15:23:07.498476	{}	2.5	0	0	\N	\N	\N	Stylist	Stylist	Stylist	\N
1460	d780300	37	banane	banana		\N	2026-01-21 14:49:59.508587	0	2026-01-22 14:49:59.508587	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	banana	Banane	akondro	\N
554	03e37b2	17	Les grands-parents	I nonni		\N	2025-12-07 06:08:35.161495	0	2025-12-08 06:08:35.161495	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The grandparents	Die Großeltern	Ny raibe sy renibe	\N
555	b89e26b	17	Le petit-fils	Il nipote		\N	2025-12-07 06:08:35.182396	0	2025-12-08 06:08:35.182396	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The nephew	Der Neffe	Ny zana-drahalahiny	\N
556	a12212e	17	La petite-fille	La nipote		\N	2025-12-07 06:08:35.202248	0	2025-12-08 06:08:35.202248	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The granddaughter	Die Enkelin	Ny zafikely	\N
921	8045f8a	24	Fleurs	Fiori		\N	2025-12-10 15:39:06.642474	0	2025-12-11 15:39:06.642474	{maison,italien}	2.5	0	0	\N	\N	\N	Flowers	Blumen	Voninkazo	\N
915	5b53fa9	24	Couloir	Corridoio		\N	2025-12-10 15:39:06.529527	0	2025-12-11 15:39:06.529527	{maison,italien}	2.5	0	0	\N	\N	\N	Hallway	Flur	lalantsara	\N
917	088a1dc	24	Garage	Garage		\N	2025-12-10 15:39:06.566005	0	2025-12-11 15:39:06.566005	{maison,italien}	2.5	0	0	\N	\N	\N	Garage	Garage	Garage	\N
919	82da3ba	24	Jardin	Giardino		\N	2025-12-10 15:39:06.600042	0	2025-12-11 15:39:06.600042	{maison,italien}	2.5	0	0	\N	\N	\N	Garden	Garten	ZARIDAINA	\N
920	4c13af0	24	Pelouse	Prato		\N	2025-12-10 15:39:06.619122	0	2025-12-11 15:39:06.619122	{maison,italien}	2.5	0	0	\N	\N	\N	Lawn	Rasen	bozaka	\N
984	7a1ef11	25	Grille-pain	Tostapane		\N	2025-12-11 15:25:47.502947	0	2025-12-12 15:25:47.502947	{cuisine,italien}	2.5	0	0	\N	\N	\N	Toaster	Toaster	Toaster	\N
1461	628205f	37	orange	arancia		\N	2026-01-21 14:49:59.555635	0	2026-01-22 14:49:59.555635	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	orange	orange	voasary	\N
1462	65948d0	37	citron	limone		\N	2026-01-21 14:49:59.591879	0	2026-01-22 14:49:59.591879	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	lemon	Zitrone	voasary makirana	\N
1463	e685b64	37	poire	pera		\N	2026-01-21 14:49:59.625232	0	2026-01-22 14:49:59.625232	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pear	Birne	poara	\N
928	c1f38be	24	Plafond	Soffitto		\N	2025-12-10 15:39:06.768542	0	2025-12-11 15:39:06.768542	{maison,italien}	2.5	0	0	\N	\N	\N	Ceiling	Decke	valindrihana	\N
1470	4b94fbf	37	pastèque	anguria		\N	2026-01-21 14:49:59.945618	0	2026-01-22 14:49:59.945618	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	watermelon	Wassermelone	voajabo	\N
1471	8e24328	37	kiwi	kiwi		\N	2026-01-21 14:49:59.995645	0	2026-01-22 14:49:59.995645	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	kiwi	Kiwi	kiwi	\N
1472	1f001d4	37	noix de coco	noce di cocco		\N	2026-01-21 14:50:00.037642	0	2026-01-22 14:50:00.037642	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	coconut	Kokosnuss	voanio	\N
1762	4945b71	40	méchant	cattivo		\N	2026-01-31 15:19:22.122343	0	2026-02-01 15:19:22.122343	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	\N	bad	schlecht	ratsy	\N
1464	9b93f95	37	Pêche	pesca		\N	2026-01-21 14:49:59.694646	0	2026-01-22 14:49:59.694646	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	Attività di cattura di pesci e altri organismi acquatici.	Fishing	Fischerei	Fihazana	La pesca industriale minaccia alcune specie marine.
1759	7a496a1	40	Pessimiste	pessimista		\N	2026-01-31 15:19:22.072495	0	2026-02-01 15:19:22.072495	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che vede sempre il lato negativo delle situazioni.	Pessimistic	Pessimistisch	Manantena ratsy	È pessimista e pensa che non funzionerà.
1763	9432f42	40	Cruel	crudele		\N	2026-01-31 15:19:22.141809	0	2026-02-01 15:19:22.141809	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che prova piacere nel far soffrire gli altri.	Cruel	Grausam	Masiaka	Il suo comportamento crudele è inaccettabile.
559	c9d80ca	17	La tante	La zia		\N	2025-12-07 06:08:35.265158	0	2025-12-08 06:08:35.265158	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The aunt	Die Tante	Ny nenitoa	\N
560	68e601f	17	Le cousin	Il cugino		\N	2025-12-07 06:08:35.289046	0	2025-12-08 06:08:35.289046	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The cousin	Der Cousin	Ny cousin	\N
924	ad936d3	24	Balcon	Balcone		\N	2025-12-10 15:39:06.694241	0	2025-12-11 15:39:06.694241	{maison,italien}	2.5	0	0	\N	\N	\N	Balcony	Balkon	lavarangana	\N
925	564fe90	24	Cave	Cantina		\N	2025-12-10 15:39:06.711419	0	2025-12-11 15:39:06.711419	{maison,italien}	2.5	0	0	\N	\N	\N	Cellar	Keller	lakaly	\N
926	a4ed369	24	Cheminée	Camino		\N	2025-12-10 15:39:06.73441	0	2025-12-11 15:39:06.73441	{maison,italien}	2.5	0	0	\N	\N	\N	Fireplace	Kamin	am-patana	\N
927	4336547	24	Mur	Muro		\N	2025-12-10 15:39:06.751556	0	2025-12-11 15:39:06.751556	{maison,italien}	2.5	0	0	\N	\N	\N	Wall	Wand	Rindrina	\N
1465	b31c80c	37	raisin	uva		\N	2026-01-21 14:49:59.7314	0	2026-01-22 14:49:59.7314	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	grape	Traube	\N	\N
1466	201a0fe	37	fraise	fragola		\N	2026-01-21 14:49:59.757413	0	2026-01-22 14:49:59.757413	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	strawberry	Erdbeere	frezy	\N
934	460120e	24	Ventilateur	Ventilatore		\N	2025-12-10 15:39:06.8727	0	2025-12-11 15:39:06.8727	{maison,italien}	2.5	0	0	\N	\N	\N	Fan	Lüfter	Fan	\N
997	0649f19	25	Cuillère à glace	Paletta da gelato		\N	2025-12-11 15:25:47.777945	0	2025-12-12 15:25:47.777945	{cuisine,italien}	2.5	0	0	\N	\N	\N	Ice cream scoop	Eisportionierer	Tavoahangy gilasy	\N
1004	b909483	25	Poivre	Pepe		\N	2025-12-11 15:25:47.911818	0	2025-12-12 15:25:47.911818	{cuisine,italien}	2.5	0	0	\N	\N	\N	Pepper	Pfeffer	Sakay	\N
1764	0dcaacc	40	Hypocrite	ipocrita		\N	2026-01-31 15:19:22.156387	0	2026-02-01 15:19:22.156387	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che finge sentimenti o opinioni che non ha.	Hypocritical	Heuchlerisch	Mivadika	È ipocrita e dice una cosa ma ne pensa un'altra.
564	3c6e3a9	17	Le beau-père	Il suocero		\N	2025-12-07 06:08:35.387595	0	2025-12-08 06:08:35.387595	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The father-in-law	Der Schwiegervater	Ny rafozana	\N
929	f00fe4a	24	Plancher	Pavimento		\N	2025-12-10 15:39:06.785765	0	2025-12-11 15:39:06.785765	{maison,italien}	2.5	0	0	\N	\N	\N	Flooring	Bodenbelag	Flooring	\N
930	c7a2a14	24	Étagère	Mensola		\N	2025-12-10 15:39:06.802368	0	2025-12-11 15:39:06.802368	{maison,italien}	2.5	0	0	\N	\N	\N	Shelf	Regal	talantalana	\N
931	dde43b4	24	Cadre	Quadro		\N	2025-12-10 15:39:06.820214	0	2025-12-11 15:39:06.820214	{maison,italien}	2.5	0	0	\N	\N	\N	Painting	Malerei	mandoko	\N
933	02b38c6	24	Interrupteur	Interruttore		\N	2025-12-10 15:39:06.855586	0	2025-12-11 15:39:06.855586	{maison,italien}	2.5	0	0	\N	\N	\N	Switch	Schalten	jiro	\N
1474	94a0df4	37	avocat	avocado		\N	2026-01-21 14:50:00.099151	0	2026-01-22 14:50:00.099151	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	avocado	Avocado	zavoka	\N
1478	8054281	37	épinard	spinacio		\N	2026-01-21 14:50:00.202367	0	2026-01-22 14:50:00.202367	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	spinach	Spinat	epinara	\N
1479	8169725	37	artichaut	carciofo		\N	2026-01-21 14:50:00.221732	0	2026-01-22 14:50:00.221732	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	artichoke	Artischocke	artichaut	\N
1480	d0fe0f2	37	asperge	asparago		\N	2026-01-21 14:50:00.242365	0	2026-01-22 14:50:00.242365	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	asparagus	Spargel	asperza	\N
1775	44848ae	40	Surpris	sorpreso		\N	2026-01-31 15:19:22.369967	0	2026-02-01 15:19:22.369967	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che mostra stupore per un evento imprevisto.	Surprised	Überrascht	Gaga	È sorpreso dal regalo inaspettato.
565	0a20bb9	17	La belle-mère	La suocera		\N	2025-12-07 06:08:35.410392	0	2025-12-08 06:08:35.410392	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The mother-in-law	Die Schwiegermutter	Ny rafozambaviny	\N
1475	fddc45f	37	chou	cavolo		\N	2026-01-21 14:50:00.122541	0	2026-01-22 14:50:00.122541	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cabbage	Kohl	laisoa	\N
1476	76cf286	37	brocoli	broccolo		\N	2026-01-21 14:50:00.145295	0	2026-01-22 14:50:00.145295	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	broccoli	Brokkoli	broccoli	\N
1477	c8d0a33	37	concombre	cetriolo		\N	2026-01-21 14:50:00.172751	0	2026-01-22 14:50:00.172751	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cucumber	Gurke	kaokaombira	\N
1481	3d0a100	37	haricot	fagiolo		\N	2026-01-21 14:50:00.26087	0	2026-01-22 14:50:00.26087	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	bean	Bohne	tsaramaso	\N
1482	9731bb3	37	dinde	tacchino		\N	2026-01-21 14:50:00.280301	0	2026-01-22 14:50:00.280301	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	turkey	Truthahn	vorontsiloza	\N
941	e73fbd9	25	Ouvre-boîte	Apriscatole		\N	2025-12-11 15:25:46.36392	0	2025-12-12 15:25:46.36392	{cuisine,italien}	2.5	0	0	\N	\N	\N	Can opener	Dosenöffner	Afaka fanokafana	\N
942	db0a9e3	25	Bocal	Barattolo		\N	2025-12-11 15:25:46.385393	0	2025-12-12 15:25:46.385393	{cuisine,italien}	2.5	0	0	\N	\N	\N	Jar	Krug	siny	\N
566	25aec1c	17	Le beau-fils	Il figliastro		\N	2025-12-07 06:08:35.431957	0	2025-12-08 06:08:35.431957	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The stepson	Der Stiefsohn	Ny zananilahy	\N
946	2cf62ce	25	Bouteille	Bottiglia		\N	2025-12-11 15:25:46.482656	0	2025-12-12 15:25:46.482656	{cuisine,italien}	2.5	0	0	\N	\N	Contenitore per bere durante l'allenamento.	Bottle	Flasche	Bouteille	Porta sempre la bottiglia d'acqua.
1487	35c3b89	37	homard	aragosta		\N	2026-01-21 14:50:00.375274	0	2026-01-22 14:50:00.375274	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	lobster	Hummer	langosta	\N
945	4f07ca6	25	Bouilloire	Bollitore		\N	2025-12-11 15:25:46.455284	0	2025-12-12 15:25:46.455284	{cuisine,italien}	2.5	0	0	\N	\N	\N	Kettle	Wasserkocher	Kettle	\N
567	be515d9	17	La belle-fille	La figliastra		\N	2025-12-07 06:08:35.453308	0	2025-12-08 06:08:35.453308	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The stepdaughter	Die Stieftochter	Ny zananivavy	\N
568	289301c	17	Le gendre	Il genero		\N	2025-12-07 06:08:35.475267	0	2025-12-08 06:08:35.475267	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The son-in-law	Der Schwiegersohn	Ny vinanto	\N
875	952969d	24	Salon	Salotto		\N	2025-12-10 15:39:05.76615	0	2025-12-11 15:39:05.76615	{maison,italien}	2.5	0	0	\N	\N	\N	Living room	Wohnzimmer	Efitra fandraisam-bahiny	\N
877	437b4d4	24	Fauteuil	Poltrona		\N	2025-12-10 15:39:05.801511	0	2025-12-11 15:39:05.801511	{maison,italien}	2.5	0	0	\N	\N	\N	Armchair	Sessel	seza	\N
880	1b9e442	24	Télécommande	Telecomando		\N	2025-12-10 15:39:05.854602	0	2025-12-11 15:39:05.854602	{maison,italien}	2.5	0	0	\N	\N	\N	Remote control	Fernbedienung	Fanaraha-maso lavitra	\N
884	9635fa6	24	Cuisine	Cucina		\N	2025-12-10 15:39:05.935137	0	2025-12-11 15:39:05.935137	{maison,italien}	2.5	0	0	\N	\N	\N	Kitchen	Küche	LAKOZIA	\N
902	6d043d1	24	Lavabo	Lavandino		\N	2025-12-10 15:39:06.303477	0	2025-12-11 15:39:06.303477	{maison,italien}	2.5	0	0	\N	\N	\N	Sink	Waschbecken	hilentika	\N
943	c508822	25	Verre	Bicchiere		\N	2025-12-11 15:25:46.409022	0	2025-12-12 15:25:46.409022	{cuisine,italien}	2.5	0	0	\N	\N	\N	Glass	Glas	Glass	\N
944	23e0c0d	25	Balance de cuisine	Bilancia da cucina		\N	2025-12-11 15:25:46.432005	0	2025-12-12 15:25:46.432005	{cuisine,italien}	2.5	0	0	\N	\N	\N	Kitchen scale	Küchenwaage	Mizana lakozia	\N
1780	0fd45e3	40	Introverti	introverso		\N	2026-01-31 15:19:22.471571	0	2026-02-01 15:19:22.471571	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che trae energia dalla solitudine.	Introverted	Introvertiert	Tia irery	È introverso e preferisce leggere a casa.
1492	d427f98	37	bonbon	caramella		\N	2026-01-21 14:50:00.563509	0	2026-01-22 14:50:00.563509	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	candy	Süßigkeiten	vatomamy	\N
1493	5d7250f	37	pudding	budino		\N	2026-01-21 14:50:00.587439	0	2026-01-22 14:50:00.587439	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pudding	Pudding	pudding	\N
1489	41bb7b7	37	huître	ostrica		\N	2026-01-21 14:50:00.50399	0	2026-01-22 14:50:00.50399	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	oyster	Auster	oitira	\N
569	64f6f9f	17	La bru	La nuora		\N	2025-12-07 06:08:35.496827	0	2025-12-08 06:08:35.496827	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The daughter-in-law	Die Schwiegertochter	Ny vinantovavy	\N
571	f04aae0	17	La femme	La moglie		\N	2025-12-07 06:08:35.53861	0	2025-12-08 06:08:35.53861	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The wife	Die Frau	Ny vady	\N
572	2b3a581	17	Les époux	I coniugi		\N	2025-12-07 06:08:35.560706	0	2025-12-08 06:08:35.560706	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The spouses	Die Ehegatten	Ny mpivady	\N
573	dfdf784	17	Le beau-frère	Il cognato		\N	2025-12-07 06:08:35.686676	0	2025-12-08 06:08:35.686676	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The brother-in-law	Der Schwager	Ny zaodahiko	\N
1205	c371ff0	31	Méthane	Metano		\N	2026-01-11 15:36:49.027032	0	2026-01-12 15:36:49.027032	{nom,italien,climat}	2.5	0	0	\N	\N	\N	Methane	Methan	metanina	\N
1306	50fbecd	32	Se sentir mal à l’aise	Essere come un pesce fuor d’acqua		\N	2026-01-12 12:49:14.50751	0	2026-01-13 12:49:14.50751	{expression,italien,animal,émotion}	2.5	0	0	\N	\N	\N	Being like a fish out of water	Wie ein Fisch ohne Wasser sein	Toy ny trondro tsy misy rano	\N
575	f0f36d3	17	Le parrain	Il padrino		\N	2025-12-07 06:08:35.751619	0	2025-12-08 06:08:35.751619	{nom,italien,religion}	2.5	0	0	\N	\N	\N	The godfather	Der Pate	Ny raim-pianakaviana	\N
778	a0882ee	22	Accendere	Acceso		\N	2025-12-08 16:20:07.621626	0	2025-12-09 16:20:07.621626	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	On	An	On	\N
1791	25dcac9	40	Maladroit	maldestro		\N	2026-01-31 15:19:22.654255	0	2026-02-01 15:19:22.654255	{adjectif,italien,comportement}	2.5	0	0	\N	\N	Persona che compie gesti goffi.	Clumsy	Ungeschickt	Tsara tsy tsara	È maldestro e rompe spesso i bicchieri.
841	98e8779	23	Chi è Roberto Benigni?	È un attore, regista e sceneggiatore italiano molto famoso.		\N	2025-12-10 08:41:45.060673	0	2025-12-11 08:42:15.766252	{italien,A2,biografia,"Roberto Benigni"}	1.9999999999999998	0	0	\N	\N	\N	He is a very famous Italian actor, director and screenwriter.	Er ist ein sehr berühmter italienischer Schauspieler, Regisseur und Drehbuchautor.	Mpilalao sarimihetsika malaza italiana izy, talen-koronantsary ary mpanoratra tantara an-tsary.	\N
951	836a2cb	25	Couvercle	Coperchio		\N	2025-12-11 15:25:46.616746	0	2025-12-12 15:25:46.616746	{cuisine,italien}	2.5	0	0	\N	\N	\N	Cover	Abdeckung	MATOAN-DAHATSORATRA	\N
952	86aa370	25	Cuillère en bois	Cucchiaio di legno		\N	2025-12-11 15:25:46.641159	0	2025-12-12 15:25:46.641159	{cuisine,italien}	2.5	0	0	\N	\N	\N	Wooden spoon	Holzlöffel	sotro hazo	\N
784	8255ce5	22	Rendere	Reso		\N	2025-12-08 16:20:07.746664	0	2025-12-09 16:20:07.746664	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Made	Gemacht	VOAVOATRA	\N
782	1dd05b3	22	Prendere	Preso		\N	2025-12-08 16:20:07.701631	0	2025-12-09 16:20:07.701631	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Taken	Genommen	nalaina	\N
783	d2acd5d	22	Promettere	Promesso		\N	2025-12-08 16:20:07.72328	0	2025-12-09 16:20:07.72328	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Promise	Versprechen	FAMPANANTENANA	\N
785	8f9ef5a	22	Scendere	Sceso		\N	2025-12-08 16:20:07.768212	0	2025-12-09 16:20:07.768212	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Got out	Rausgekommen	Nivoaka	\N
787	deba454	22	Correre	Corso		\N	2025-12-08 16:20:07.80705	0	2025-12-09 16:20:07.80705	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Course	Kurs	Mazava ho azy	\N
1798	bc8f389	40	Violent	violento		\N	2026-01-31 15:19:22.817989	0	2026-02-01 15:19:22.817989	{adjectif,italien,comportement}	2.5	0	0	\N	\N	Persona che usa o minaccia la violenza.	Violent	Gewalttätig	Masiaka	Il suo comportamento violento è inaccettabile.
576	c9e058e	17	La marraine	La madrina		\N	2025-12-07 06:08:35.774376	0	2025-12-08 06:08:35.774376	{nom,italien,religion}	2.5	0	0	\N	\N	\N	The godmother	Die Patin	Ny renibeny	\N
793	cf8015b	22	Scegliere	Scelto		\N	2025-12-08 16:20:07.92809	0	2025-12-09 16:20:07.92809	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Choice	Auswahl	SAFIDY	\N
798	5e06f38	22	Chiedere	Chiesto		\N	2025-12-08 16:20:08.023118	0	2025-12-09 16:20:08.023118	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Asked	Gefragt	nanontaniana	\N
800	e55570c	22	Rimanere	Rimasto		\N	2025-12-08 16:20:08.057458	0	2025-12-09 16:20:08.057458	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Left	Links	ANKA	\N
803	a06b997	22	Vivere	Vissuto		\N	2025-12-08 16:20:08.106736	0	2025-12-09 16:20:08.106736	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Lived	Gelebt	Teto An-tany	\N
955	1a278ca	25	Fouet	Frusta		\N	2025-12-11 15:25:46.72637	0	2025-12-12 15:25:46.72637	{cuisine,italien}	2.5	0	0	\N	\N	\N	Whip	Peitsche	karavasy	\N
799	e0e6831	22	Rispondere	Risposto		\N	2025-12-08 16:20:08.040457	0	2025-12-09 16:20:08.040457	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Answered	Beantwortet	Valin'ireo	\N
802	45e5c39	22	Bere	Bevuto		\N	2025-12-08 16:20:08.089204	0	2025-12-09 16:20:08.089204	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Drank	Getrunken	nisotro	\N
812	7d71290	22	Togliere	Tolto		\N	2025-12-08 16:20:08.297116	0	2025-12-09 16:20:08.297116	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Removed	ENTFERNT	nesorina	\N
577	72d7ab6	17	Le filleul	Il figlioccio		\N	2025-12-07 06:08:35.796386	0	2025-12-08 06:08:35.796386	{nom,italien,religion}	2.5	0	0	\N	\N	\N	The godson	Der Patensohn	Ilay andriamanitra	\N
578	e12ab5c	17	La filleule	La figlioccia		\N	2025-12-07 06:08:35.819574	0	2025-12-08 06:08:35.819574	{nom,italien,religion}	2.5	0	0	\N	\N	\N	The goddaughter	Die Patentochter	Ny zanakavavin'ny andriamanitra	\N
579	155c386	17	Le compagnon	Il compagno		\N	2025-12-07 06:08:35.842871	0	2025-12-08 06:08:35.842871	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The companion	Der Begleiter	Ny namana	\N
580	54a0cf5	17	La compagne	La compagna		\N	2025-12-07 06:08:35.866005	0	2025-12-08 06:08:35.866005	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The companion	Der Begleiter	Ny namana	\N
814	61d61cc	22	Volgere	Volto		\N	2025-12-08 16:20:08.335996	0	2025-12-09 16:20:08.335996	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Face	Gesicht	Face	\N
956	3aa70e5	25	Râpe	Grattugia		\N	2025-12-11 15:25:46.75178	0	2025-12-12 15:25:46.75178	{cuisine,italien}	2.5	0	0	\N	\N	\N	Grater	Reibe	Grater	\N
957	2f655c8	25	Gants de four	Guanti da forno		\N	2025-12-11 15:25:46.781199	0	2025-12-12 15:25:46.781199	{cuisine,italien}	2.5	0	0	\N	\N	\N	Oven gloves	Ofenhandschuhe	fonon-tanana lafaoro	\N
958	091962c	25	Saladier	Insalatiera		\N	2025-12-11 15:25:46.806666	0	2025-12-12 15:25:46.806666	{cuisine,italien}	2.5	0	0	\N	\N	\N	Salad bowl	Salatschüssel	Lovia salady	\N
959	b600043	25	Rouleau à pâtisserie	Mattarello		\N	2025-12-11 15:25:46.831436	0	2025-12-12 15:25:46.831436	{cuisine,italien}	2.5	0	0	\N	\N	\N	Rolling pin	Nudelholz	Rolling pin	\N
1495	9a0fad7	37	alcool	alcol		\N	2026-01-21 14:50:00.630355	0	2026-01-22 14:50:00.630355	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	alcohol	Alkohol	TOAKA	\N
1496	6c56cb4	37	limonade	limonata		\N	2026-01-21 14:50:00.654099	0	2026-01-22 14:50:00.654099	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	lemonade	Limonade	limonady	\N
2607	1e0edf9	65	hydrocarbure	idrocarburo		https://upload.wikimedia.org/wikipedia/commons/0/03/StratigraphicTrap.png	2026-03-30 16:30:02.299361	0	2026-03-31 16:30:02.299361	{ressources,géochimie}	2.5	0	0	\N	\N	Composto organico costituito unicamente da molecole di carbonio e idrogeno tipicamente trovato nel sottosuolo.	hydrocarbon	Kohlenwasserstoff	hidrôkarbiora	Il bacino sedimentario è stato esplorato per la potenziale presenza di un importante giacimento di idrocarburo.
2608	71dc316	65	pétrole	petrolio		https://upload.wikimedia.org/wikipedia/commons/c/c2/Petroleum_sample.jpg	2026-03-30 16:30:08.732312	0	2026-03-31 16:30:08.732312	{ressources,énergie}	2.5	0	0	\N	\N	Miscela liquida naturale e scura di idrocarburi ospitata in specifiche trappole geologiche.	petroleum	Erdöl	solitany	La raffinazione del grezzo estratto converte il petrolio in vari combustibili usati mondialmente.
2609	58ca802	65	charbon	carbone		https://upload.wikimedia.org/wikipedia/commons/a/a0/Piece_of_coal_in_front_of_a_coal_firing_power_plant.jpg	2026-03-30 16:30:14.884131	0	2026-03-31 16:30:14.884131	{ressources,énergie,roche_sédimentaire}	2.5	0	0	\N	\N	Combustibile fossile nero e solido formatosi dal seppellimento e dall'indurimento di resti vegetali in paludi.	coal	Kohle	arintany	Molti bacini in Europa si sono arricchiti economicamente grazie all'estrazione storica del carbone.
2610	1df043f	65	gaz naturel	gas naturale		https://upload.wikimedia.org/wikipedia/commons/b/bc/Darvasa_gas_crater_panorama_crop.jpg	2026-03-30 16:30:21.875025	0	2026-03-31 16:30:21.875025	{ressources,énergie}	2.5	0	0	\N	\N	Massa gassosa combustibile, prevalentemente metano, prodotta dalla decomposizione termica della materia organica profonda.	natural gas	Erdgas	etona voajanahary	Spesso l'esplorazione petrolifera individua immense sacche sigillate di gas naturale sopra l'olio pesante.
2611	2eec416	65	minerai	minerale grezzo		https://upload.wikimedia.org/wikipedia/commons/3/31/Banded_iron_formation.png	2026-03-30 16:30:28.818475	0	2026-03-31 16:30:28.818475	{ressources,économie}	2.5	0	0	\N	\N	Ammasso solido estratto industrialmente per ricavare metalli preziosi o elementi utili con profitto.	ore	Erz	akora metaly	Hanno processato il materiale sbriciolato per estrarre l'oro dal minerale grezzo estratto ieri.
2612	7bec744	65	ressource	risorsa		https://upload.wikimedia.org/wikipedia/commons/3/31/Uniform_Resource_Locator_%28URL%29.jpg	2026-03-30 16:30:35.85655	0	2026-03-31 16:30:35.85655	{économie,environnement}	2.5	0	0	\N	\N	Qualsiasi concentrazione o deposito sotterraneo di materiale la cui estrazione è fattibile attualmente o in futuro.	resource	Ressource	harena voajanahary	Le nazioni competono spesso per l'accesso a una nuova risorsa energetica scoperta nell'Artico.
581	755cf13	17	Le beau-père (remariage)	Il patrigno		\N	2025-12-07 06:08:35.892358	0	2025-12-08 06:08:35.892358	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The stepfather	Der Stiefvater	Ny raikeliny	\N
819	61b5428	22	Dividere	Diviso		\N	2025-12-08 16:20:08.431373	0	2025-12-09 16:20:08.431373	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Divided	Geteilt	Nozaraina Roa	\N
818	70a5d98	22	Assumere	Assunto		\N	2025-12-08 16:20:08.413026	0	2025-12-09 16:20:08.413026	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Hired	Gemietet	nanakarama	\N
820	c0649d5	22	Esprimere	Espresso		\N	2025-12-08 16:20:08.451725	0	2025-12-09 16:20:08.451725	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Expressed	Ausgedrückt	Fitenenana	\N
821	19d0c51	22	Decidere	Deciso		\N	2025-12-08 16:20:08.47038	0	2025-12-09 16:20:08.47038	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Decided	Entschieden	Nanapa-kevitra	\N
823	ffe51f6	22	Sciogliere	Sciolto		\N	2025-12-08 16:20:08.51118	0	2025-12-09 16:20:08.51118	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Loose	Lose	mahamenatra	\N
960	d3e069c	25	Louche	Mestolo		\N	2025-12-11 15:25:46.855157	0	2025-12-12 15:25:46.855157	{cuisine,italien}	2.5	0	0	\N	\N	\N	Ladle	Schöpfkelle	lovia kely	\N
2613	31912c5	65	réserve	riserva		https://upload.wikimedia.org/wikipedia/commons/c/cf/Comercio_en_la_plaza_del_9_de_abril_de_1947%2C_T%C3%A1nger%2C_Marruecos%2C_2015-12-11%2C_DD_78.JPG	2026-03-30 16:30:44.713221	0	2026-03-31 16:30:44.713221	{économie,ressources}	2.5	0	0	\N	\N	La porzione di materiali utili già identificata che può essere recuperata legalmente ed economicamente con la tecnologia attuale.	reserve	Reserve	tahiry	La grande compagnia mineraria ha calcolato un aumento dell'enorme riserva di rame della sua miniera andina.
2614	2aaea90	65	mine	miniera		https://upload.wikimedia.org/wikipedia/commons/8/84/Oilshale_mine_01.jpg	2026-03-30 16:30:51.36183	0	2026-03-31 16:30:51.36183	{ressources,ingénierie}	2.5	0	0	\N	\N	L'impianto estrattivo superficiale o sotterraneo utilizzato per lo sfruttamento economico di depositi soliti utili.	mine	Mine	toeram-pitrandrahana	Il vecchio cunicolo rinforzato con il legno appartiene alla storica miniera d'argento del paese.
2615	4cbbc92	65	forage	perforazione		https://upload.wikimedia.org/wikipedia/commons/a/ae/PalmercarpenterA.jpg	2026-03-30 16:30:58.128335	0	2026-03-31 16:30:58.128335	{ingénierie,exploration}	2.5	0	0	\N	\N	La procedura tecnica con cui si scava un foro profondo con strumenti meccanici per indagare o estrarre materia.	drilling	Bohrung	fandavahana	La moderna perforazione offshore ha raggiunto livelli profondissimi nel fondale oceanico.
2616	d2edb88	65	géologue	geologo		https://upload.wikimedia.org/wikipedia/commons/4/4a/Geologists_1952_by_Adibek_Grigoryan.png	2026-03-30 16:31:04.976843	0	2026-03-31 16:31:04.976843	{profession,science_de_la_terre}	2.5	0	0	\N	\N	Lo studioso o il professionista che indaga l'evoluzione e l'architettura fisica del nostro pianeta.	geologist	Geologe	mpahay tany	Il capo cantiere ha richiesto l'opinione di un esperto geologo per garantire la stabilità della diga.
2617	d52f98f	65	géophysique	geofisica		https://upload.wikimedia.org/wikipedia/commons/1/19/Geophysics_is_a_piece_of_cake.jpg	2026-03-30 16:31:12.839296	0	2026-03-31 16:31:12.839296	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Ramo scientifico che applica principi fisici per comprendere la struttura invisibile sottostante alla superficie.	geophysics	Geophysik	geofizika	I metodi usati dalla geofisica consentono di studiare i serbatoi sepolti di idrocarburi con onde acustiche.
2618	43bb127	65	géochimie	geochimica		https://upload.wikimedia.org/wikipedia/commons/a/a0/Logotipo_INAGEQ.jpg	2026-03-30 16:31:20.03476	0	2026-03-31 16:31:20.03476	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Disciplina che studia l'abbondanza, i movimenti e i cicli degli elementi all'interno del sistema planetario.	geochemistry	Geochemie	geokimia	Attraverso sofisticate analisi, la geochimica spiega come interagiscono magma e acque sotterranee.
2619	1cb479a	65	sismologue	sismologo		https://upload.wikimedia.org/wikipedia/commons/4/45/Seismologist_with_air_gun_array.jpg	2026-03-30 16:31:26.53132	0	2026-03-31 16:31:26.53132	{profession,science_de_la_terre}	2.5	0	0	\N	\N	Lo scienziato specializzato nello studio e nel monitoraggio delle onde che attraversano la terra dopo scosse telluriche.	seismologist	Seismologe	mpandinika horohorontany	Il centro nazionale ha un sismologo sempre di guardia per analizzare i tremori registrati dai sensori remoti.
2620	ff0ea08	65	paléontologue	paleontologo		https://upload.wikimedia.org/wikipedia/commons/8/84/Un_corte_y_una_quebrada.jpg	2026-03-30 16:31:32.842741	0	2026-03-31 16:31:32.842741	{profession,science_de_la_terre}	2.5	0	0	\N	\N	Lo scienziato che ricerca e interpreta i resti fossilizzati per ricostruire l'evoluzione biologica estinta del passato.	paleontologist	Paläontologe	paleontôlôgy	Un abile paleontologo ha ricomposto meticolosamente lo scheletro completo del rettile giurassico ritrovato negli scavi.
582	cca0555	17	La belle-mère (remariage)	La matrigna		\N	2025-12-07 06:08:35.916637	0	2025-12-08 06:08:35.916637	{nom,italien,famille}	2.5	0	0	\N	\N	\N	The stepmother	Die Stiefmutter	Ny renikeliny	\N
824	12242c9	22	Tradurre	Tradotto		\N	2025-12-08 16:20:08.671193	0	2025-12-09 16:20:08.671193	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Translated	Übersetzt	nandika	\N
2621	d88fd08	65	stratigraphie	stratigrafia		https://upload.wikimedia.org/wikipedia/commons/2/20/Stratigraphy_of_the_Yixian_Formation.png	2026-03-30 16:31:39.026636	0	2026-03-31 16:31:39.026636	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Branca che analizza le sequenze temporali, la disposizione geometrica e le relazioni delle formazioni rocciose sovrapposte.	stratigraphy	Stratigraphie	stratigrafia	Il principio fondamentale usato nella moderna stratigrafia dice che i letti sedimentari più antichi si trovano in basso rispetto a quelli recenti.
2622	52955e0	65	minéralogie	mineralogia		https://upload.wikimedia.org/wikipedia/commons/b/b7/%D0%9C%D0%B8%D0%BD%D0%B5%D1%80%D0%B0%D0%BB%D1%8B%2C_%D0%B2%D1%85%D0%BE%D0%B4%D1%8F%D1%89%D0%B8%D0%B5_%D0%B2_%D1%81%D0%BE%D1%81%D1%82%D0%B0%D0%B2_%D0%B3%D1%80%D0%B0%D0%BD%D0%B8%D1%82%D0%B0.jpg	2026-03-30 16:31:45.138701	0	2026-03-31 16:31:45.138701	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Scienza dedicata allo studio chimico e strutturale dei materiali inorganici solidi formati naturalmente.	mineralogy	Mineralogie	mineralojia	L'analisi fatta in mineralogia richiede l'utilizzo sistematico della diffrattometria a raggi X sui campioni cristallini raccolti sul campo.
2623	3fae579	65	pétrologie	petrologia		https://upload.wikimedia.org/wikipedia/commons/3/30/X-ray_images_of_Igneous_rock_in_petrology_section.jpg	2026-03-30 16:31:52.137858	0	2026-03-31 16:31:52.137858	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Branca scientifica specializzata nell'osservare l'origine, l'evoluzione microscopica e macroscopica degli aggregati rocciosi litosferici.	petrology	Petrologie	petrolojia	La specializzazione avanzata in petrologia aiuta a capire le complesse temperature necessarie per trasformare sedimenti profondi in lamine metamorfiche stabili.
1914	131f49d	41	en passer par	passarne		\N	2026-02-06 15:39:14.326612	0	2026-02-07 15:39:14.326612	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Passare tante esperienze (spesso difficili)	to go through a lot	viel durchmachen	mandalo zavatra maro	Ne ha passate tante nella vita.
1195	bae0e3c	30	Garder dehors	Tenere fuori		\N	2026-01-09 16:10:11.724441	0	2026-01-10 16:10:11.724441	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Keep out	Bleiben Sie draußen	Tandremo	\N
830	540f8b5	22	Assolvere	Assolto		\N	2025-12-08 16:20:08.822293	0	2025-12-09 16:20:08.822293	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Acquitted	Freigesprochen	afaka madiodio	\N
1931	9977f98	41	y aller	andarci		\N	2026-02-08 06:54:51.965835	0	2026-02-09 06:54:51.965835	{}	2.5	0	0	\N	\N	Recarsi in un posto	to go there	dorthin gehen	mandehana any	Ci vado domani mattina presto.
1933	48ddef8	41	se débrouiller	farsela		\N	2026-02-08 07:08:44.699883	0	2026-02-09 07:08:44.699883	{}	2.5	0	0	\N	\N	Arrangiarsi da soli	to manage on one's own	sich durchschlagen	mizaka tena irery	Se la fa da solo senza chiedere aiuto a nessuno.
1769	39ab1fa	40	Émotif	emotivo		\N	2026-01-31 15:19:22.232404	0	2026-02-01 15:19:22.232404	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che esprime facilmente le emozioni.	Emotional	Emotional	Mora voakasika	È emotivo e piange ai film tristi.
1779	058b99e	40	Réservé	riservato		\N	2026-01-31 15:19:22.4531	0	2026-02-01 15:19:22.4531	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona discreta e poco espansiva.	Reserved	Zurückhaltend	Miadana	È riservato e parla solo quando necessario.
1781	ca81e89	40	Extraverti	estroverso		\N	2026-01-31 15:19:22.492174	0	2026-02-01 15:19:22.492174	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che trae energia dal contatto sociale.	Extraverted	Extravertiert	Tia olona	È estroverso e ama le feste.
594	57d2a04	18	Artiste	Artista		\N	2025-12-07 06:20:58.299948	0	2025-12-08 06:20:58.299948	{métier,italien}	2.5	0	0	\N	\N	\N	Artist	Künstler	Mpanakanto	\N
595	91d0811	18	Musicien	Musicista		\N	2025-12-07 06:20:58.320897	0	2025-12-08 06:20:58.320897	{métier,italien}	2.5	0	0	\N	\N	\N	Musician	Musiker	mozika	\N
596	0035414	18	Acteur	Attore		\N	2025-12-07 06:20:58.342655	0	2025-12-08 06:20:58.342655	{métier,italien}	2.5	0	0	\N	\N	\N	Actor	Schauspieler	Mpilalao sarimihetsika	\N
597	4794503	18	Chanteur	Cantante		\N	2025-12-07 06:20:58.406362	0	2025-12-08 06:20:58.406362	{métier,italien}	2.5	0	0	\N	\N	\N	Singer	Sänger	Mpihira	\N
598	3a01e0c	18	Architecte	Architetto		\N	2025-12-07 06:20:58.473804	0	2025-12-08 06:20:58.473804	{métier,italien}	2.5	0	0	\N	\N	\N	Architect	Architekt	mpanao mari-trano	\N
613	afe3282	18	Comptable	Contabile		\N	2025-12-07 06:20:58.797299	0	2025-12-08 06:20:58.797299	{métier,italien}	2.5	0	0	\N	\N	\N	Accountant	Buchhalter	kaonty	\N
835	eb927e2	22	Comporre	Composto		\N	2025-12-08 16:20:08.924358	0	2025-12-09 16:20:08.924358	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Compound	Verbindung	iombonana amin'ny	\N
840	76a6c45	22	Correggere	Corretto		\N	2025-12-08 16:20:09.046137	0	2025-12-09 16:20:09.046137	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Correct	Richtig	marina	\N
1500	22661b1	37	cocktail	cocktail		\N	2026-01-21 14:50:00.771176	0	2026-01-22 14:50:00.771176	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cocktail	Cocktail	molotov	\N
2528	0a4fbd1	65	roche	roccia		https://upload.wikimedia.org/wikipedia/commons/a/a8/Mealt_Waterfall_with_Kilt_Rock%2C_Isle_of_Skye.jpg	2026-03-30 16:20:55.395547	0	2026-03-31 16:20:55.395547	{pétrologie,matériaux}	2.5	0	0	\N	\N	Aggregato naturale di minerali che costituisce la massa solida del nostro pianeta.	rock	Gestein	vato	Il granito è una roccia ignea molto resistente.
1782	331a013	40	Responsable	responsabile		\N	2026-01-31 15:19:22.511799	0	2026-02-01 15:19:22.511799	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che assume i propri doveri con serietà.	Responsible	Verantwortungsvoll	Miaro	È responsabile e consegna sempre in tempo.
1783	e3d0cb1	40	Fiable	affidabile		\N	2026-01-31 15:19:22.530207	0	2026-02-01 15:19:22.530207	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona su cui si può contare.	Reliable	Zuverlässig	Azo itokisana	È affidabile e mantiene sempre le promesse.
1784	19fea32	40	Tolérant	tollerante		\N	2026-01-31 15:19:22.548464	0	2026-02-01 15:19:22.548464	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che accetta le differenze altrui.	Tolerant	Tolerant	Mora mandray	È tollerante verso tutte le culture.
2527	bd48877	65	terre	terra		\N	2026-03-30 16:20:47.896638	0	2026-03-31 16:20:47.896638	{géologie_générale,planétologie}	2.5	0	0	\N	\N	Il terzo pianeta del sistema solare, l'unico in cui è nota la presenza di vita.	earth	Erde	tany	La struttura interna della terra è divisa in crosta, mantello e nucleo.
2529	eb5d49b	65	minéral	minerale		https://upload.wikimedia.org/wikipedia/commons/1/10/Botryoidal_Purple_Grape_Agate_Chalcedony_from_Indonesia.jpg	2026-03-30 16:21:01.96641	0	2026-03-31 16:21:01.96641	{minéralogie,matériaux}	2.5	0	0	\N	\N	Sostanza solida naturale, inorganica, con una composizione chimica ben definita.	mineral	Mineral	mineraly	Il quarzo è un minerale molto comune nella crosta terrestre.
1199	447a24d	30	Aller chercher	Andare a prendere		\N	2026-01-09 16:10:11.821032	0	2026-01-10 16:10:11.821032	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Go get	Geh und hol	Mandehana mahazo	\N
2530	670b91d	65	sédiment	sedimento		https://upload.wikimedia.org/wikipedia/commons/6/63/Sediment_plume_at_sea.jpg	2026-03-30 16:21:08.705007	0	2026-03-31 16:21:08.705007	{sédimentologie,processus}	2.5	0	0	\N	\N	Materiale particellare solido che è stato trasportato e depositato da acqua, vento o ghiaccio.	sediment	Sediment	antsanga	Il fiume trasporta un grande carico di sedimento verso la foce.
698	db2e7a3	20	Rôtir	Arrostire		\N	2025-12-07 06:31:34.350331	1	2025-12-12 08:30:34.223116	{cuisine,italien}	1.8	1	1	\N	\N	\N	Roast	Braten	hena	\N
966	85c0120	25	Bol	Scodella		\N	2025-12-11 15:25:46.980691	0	2025-12-12 15:25:46.980691	{cuisine,italien}	2.5	0	0	\N	\N	\N	Bowl	Schüssel	vilia baolina	\N
2531	9038843	65	magma	magma		\N	2026-03-30 16:21:14.334734	0	2026-03-31 16:21:14.334734	{volcanologie,pétrologie}	2.5	0	0	\N	\N	Massa fusa ricca di gas e cristalli in sospensione, situata all'interno del pianeta.	magma	Magma	magma	Quando il magma si raffredda in profondità, forma rocce intrusive.
2532	6ec1e64	65	lave	lava		https://upload.wikimedia.org/wikipedia/commons/0/04/001_Volcano_eruption_of_Litli-Hr%C3%BAtur_in_Iceland_in_2023_Photo_by_Giles_Laurent.jpg	2026-03-30 16:21:20.883725	0	2026-03-31 16:21:20.883725	{volcanologie,pétrologie}	2.5	0	0	\N	\N	Il materiale fuso che viene eruttato in superficie da un apparato vulcanico.	lava	Lava	lava	La lava incandescente scorreva lungo i fianchi della montagna.
1507	f5f7017	37	épices	spezie		\N	2026-01-21 14:50:00.913199	0	2026-01-22 14:50:00.913199	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	spices	Gewürze	zava-manitra	\N
2534	9ee95bd	65	faille	faglia		https://upload.wikimedia.org/wikipedia/commons/1/1e/Fault_geology.jpg	2026-03-30 16:21:33.556538	0	2026-03-31 16:21:33.556538	{tectonique,structure}	2.5	0	0	\N	\N	Frattura della crosta terrestre lungo la quale è avvenuto uno spostamento dei blocchi rocciosi.	fault	Verwerfung	vakivaky	Il terremoto è stato generato dall'attivazione di una faglia sotterranea.
1785	faeb6b1	40	Compréhensif	comprensivo		\N	2026-01-31 15:19:22.56482	0	2026-02-01 15:19:22.56482	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che capisce e perdona facilmente.	Understanding	Verständnisvoll	Mifankahita	È comprensivo con i propri figli.
1788	981fc43	40	Éduqué	educato		\N	2026-01-31 15:19:22.611536	0	2026-02-01 15:19:22.611536	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che rispetta le regole del buon comportamento.	Polite	Höflich	Miaraka	È educato e dice sempre grazie.
2533	dcda672	65	volcan	vulcano		https://upload.wikimedia.org/wikipedia/commons/e/e6/Tavurvur_volcano_edit.jpg	2026-03-30 16:21:26.638177	0	2026-03-31 16:21:26.638177	{volcanologie,structure}	2.5	0	0	\N	\N	Rilievo formato dall'accumulo di materiali eruttati dall'interno del pianeta.	volcano	Vulkan	volokano	Il vulcano Etna è uno dei più attivi in Europa.
2535	12e682e	65	séisme	sisma		https://upload.wikimedia.org/wikipedia/commons/0/0d/Post-and-Grant-Avenue-Look.jpg	2026-03-30 16:21:40.238958	0	2026-03-31 16:21:40.238958	{sismologie,risque}	2.5	0	0	\N	\N	Rapida vibrazione della crosta terrestre causata dall'improvviso rilascio di energia.	earthquake	Erdbeben	horohorontany	Il sisma ha provocato gravi danni nella regione costiera.
2536	776b56f	65	croûte	crosta		https://upload.wikimedia.org/wikipedia/commons/7/7d/Alexander_von_Humboldt_-_Diagram_of_a_cross-section_of_the_earth%27s_crust_-_rectified.jpg	2026-03-30 16:21:47.908872	0	2026-03-31 16:21:47.908872	{structure_interne,géologie_générale}	2.5	0	0	\N	\N	L'involucro esterno e rigido del nostro pianeta.	crust	Kruste	hoditany	La crosta oceanica è più sottile di quella continentale.
1411	225c25a	36	Avoir affaire à	Avere a che fare con		\N	2026-01-20 14:49:12.662449	0	2026-01-21 14:49:12.662449	{expression,idiomatique,italien,fréquent,relation}	2.5	0	0	\N	\N	\N	Dealing with	Umgang mit	Fiaraha-miasa amin'ny	\N
1412	2f2932b	36	Valoir la peine	Valere la pena		\N	2026-01-20 14:49:12.684503	0	2026-01-21 14:49:12.684503	{expression,idiomatique,italien,fréquent,évaluation}	2.5	0	0	\N	\N	\N	Worth it	Es lohnt sich	Nahaleo ny sarany	\N
1413	1ee156d	36	Être d’accord	Essere d’accordo		\N	2026-01-20 14:49:12.707432	0	2026-01-21 14:49:12.707432	{expression,idiomatique,italien,fréquent,opinion}	2.5	0	0	\N	\N	\N	Agree	Zustimmen	manaiky	\N
1692	e31fa71	39	clé	chiave		\N	2026-01-30 16:23:23.638888	0	2026-01-31 16:23:23.638888	{nom,italien,transport}	2.5	0	0	\N	\N	\N	key	Schlüssel	ANDININ-	\N
1693	8ac505c	39	permis de conduire	patente		\N	2026-01-30 16:23:23.663138	0	2026-01-31 16:23:23.663138	{nom,italien,transport}	2.5	0	0	\N	\N	\N	license	Lizenz	Mombamomba ny mpanoratra	\N
1694	b85636b	39	location	noleggio		\N	2026-01-30 16:23:23.686855	0	2026-01-31 16:23:23.686855	{nom,italien,transport}	2.5	0	0	\N	\N	\N	rental	Vermietung	fanofana	\N
599	4fab73f	18	Scientifique	Scienziato		\N	2025-12-07 06:20:58.502454	0	2025-12-08 06:20:58.502454	{métier,italien}	2.5	0	0	\N	\N	\N	Scientist	Wissenschaftler	mpahay siansa	\N
600	04baa35	18	Pharmacien	Farmacista		\N	2025-12-07 06:20:58.535142	0	2025-12-08 06:20:58.535142	{métier,italien}	2.5	0	0	\N	\N	\N	Pharmacist	Apotheker	Pharmacist	\N
601	b110c15	18	Dentiste	Dentista		\N	2025-12-07 06:20:58.556326	0	2025-12-08 06:20:58.556326	{métier,italien}	2.5	0	0	\N	\N	\N	Dentist	Zahnarzt	mpitsabo nify	\N
602	60a2caf	18	Vétérinaire	Veterinario		\N	2025-12-07 06:20:58.576312	0	2025-12-08 06:20:58.576312	{métier,italien}	2.5	0	0	\N	\N	\N	Veterinarian	Tierarzt	mpitsabo biby	\N
603	75d4bba	18	Chef cuisinier	Cuoco		\N	2025-12-07 06:20:58.597003	0	2025-12-08 06:20:58.597003	{métier,italien}	2.5	0	0	\N	\N	\N	Cook	Kochen	Cook	\N
1510	a604221	37	confiture	marmellata		\N	2026-01-21 14:50:00.964932	0	2026-01-22 14:50:00.964932	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	jam	Marmelade	Jak	\N
1511	3bc0753	37	arachide	nocciolina		\N	2026-01-21 14:50:00.984719	0	2026-01-22 14:50:00.984719	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	peanut	Erdnuss	voanjo	\N
1837	3ced8cb	41	la faire longue	farla lunga		\N	2026-02-06 15:39:12.31198	0	2026-02-07 15:39:12.31198	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Prolungare inutilmente un discorso o una situazione	to drag it out	es in die Länge ziehen	manitatra tsy ilaina ny zavatra	Non farla lunga, dimmi subito sì o no!
1750	4f491e9	40	Timide	timido		\N	2026-01-31 15:19:21.939341	0	2026-02-01 15:19:21.939341	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona riservata che evita situazioni sociali.	Shy	Schüchtern	Mena mena	È timido e parla poco in gruppo.
1835	b1a6b94	41	arrêter	piantarla		\N	2026-02-06 15:39:12.270458	0	2026-02-07 15:39:12.270458	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Smettere un comportamento noioso o fastidioso	to stop it (colloquial)	damit aufhören	manatsahatra izany	Piantala di lamentarti sempre, mi stai stressando!
1836	a0dc922	41	réagir	prenderla		\N	2026-02-06 15:39:12.292913	0	2026-02-07 15:39:12.292913	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Reagire bene o male a qualcosa che viene detto o fatto	to take it (badly/well)	es aufnehmen	mandray izany (tsy tsara na tsara)	Non la prendere male, era solo uno scherzo tra amici.
1891	9ec08b8	41	s'en émerveiller	meravigliarsene		\N	2026-02-06 15:39:13.679702	0	2026-02-07 15:39:13.679702	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Meravigliarsi di qualcosa	to marvel at it	sich darüber wundern	gaga sy faly amin'izany	Se ne meraviglia ogni volta che lo vede.
1741	487ba7a	40	heureux	felice		\N	2026-01-31 15:19:21.793642	0	2026-02-01 15:19:21.793642	{adjectif,italien,émotion}	2.5	0	0	\N	\N	\N	happy	Glücklich	SAMBATRA	\N
1202	22dc59b	31	Couche d'ozone	Strato di ozono		\N	2026-01-11 15:36:48.962699	0	2026-01-12 15:36:48.962699	{expression,italien,air}	2.5	0	0	\N	\N	\N	Ozone layer	Ozonschicht	sosona ozone	\N
1203	a752c07	31	Pluie acide	Pioggia acida		\N	2026-01-11 15:36:48.984707	0	2026-01-12 15:36:48.984707	{expression,italien,pollution}	2.5	0	0	\N	\N	\N	Acid rain	Saurer Regen	orana asidra	\N
1204	789a069	31	Dioxyde de carbone	Anidride carbonica		\N	2026-01-11 15:36:49.006336	0	2026-01-12 15:36:49.006336	{nom,italien,climat}	2.5	0	0	\N	\N	\N	Carbon dioxide	Kohlendioxid	gazy karbonika	\N
979	8c8d0c5	25	Congélateur	Congelatore		\N	2025-12-11 15:25:47.40329	0	2025-12-12 15:25:47.40329	{cuisine,italien}	2.5	0	0	\N	\N	\N	Freezer	Gefrierschrank	vata fampangatsiahana	\N
980	5d4c26a	25	Lave-vaisselle	Lavastoviglie		\N	2025-12-11 15:25:47.426399	0	2025-12-12 15:25:47.426399	{cuisine,italien}	2.5	0	0	\N	\N	\N	Dishwasher	Spülmaschine	Fanasana vilia	\N
1071	f329490	28	Solaire	Solare		\N	2026-01-08 15:19:18.657027	1	2026-02-02 15:23:23.457095	{adjectif,italien,énergie}	2.6	1	1	\N	\N	\N	Solar	Solar	Masoandro	\N
1072	ef4695a	28	Éolien	Eolico		\N	2026-01-08 15:19:18.6883	1	2026-02-02 15:26:32.269916	{adjectif,italien,énergie}	2.6	1	1	\N	\N	\N	Wind power	Windkraft	herin'ny rivotra	\N
1754	feb8853	40	Anxieux	ansioso		\N	2026-01-31 15:19:21.998395	0	2026-02-01 15:19:21.998395	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona preoccupata e inquieta per il futuro.	Anxious	Ängstlich	Matahotra	È ansioso per il futuro del lavoro.
1512	f67053b	37	soupe	zuppa		\N	2026-01-21 14:50:01.001727	0	2026-01-22 14:50:01.001727	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	soup	Suppe	lasopy	\N
1238	aeeb6aa	31	Nucléaire	Nucleare		\N	2026-01-11 15:36:49.841075	0	2026-01-12 15:36:49.841075	{adjectif,italien,énergie}	2.5	0	0	\N	\N	\N	Nuclear	Nuklear	nokleary	\N
1414	4d2de84	37	pain	pane		\N	2026-01-21 14:49:57.680337	0	2026-01-22 14:49:57.680337	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	bread	brot	-kanina	\N
973	49294dc	25	Théière	Teiera		\N	2025-12-11 15:25:47.190753	0	2025-12-12 15:25:47.190753	{cuisine,italien}	2.5	0	0	\N	\N	\N	Teapot	Teekanne	Teapot	\N
974	54c8f7c	25	Plateau	Vassoio		\N	2025-12-11 15:25:47.220338	0	2025-12-12 15:25:47.220338	{cuisine,italien}	2.5	0	0	\N	\N	\N	Tray	Tablett	lovia	\N
975	4bb8590	25	Sucrier	Zuccheriera		\N	2025-12-11 15:25:47.258094	0	2025-12-12 15:25:47.258094	{cuisine,italien}	2.5	0	0	\N	\N	\N	Sugar bowl	Zuckerdose	Lovia siramamy	\N
1697	23727f1	39	entrée	entrata		\N	2026-01-30 16:23:23.759104	0	2026-01-31 16:23:23.759104	{nom,italien,transport}	2.5	0	0	\N	\N	\N	entrance	Eingang	Fidirana	\N
1698	ec93a1f	39	sortie	uscita		\N	2026-01-30 16:23:23.785147	0	2026-01-31 16:23:23.785147	{nom,italien,transport}	2.5	0	0	\N	\N	\N	exit	Ausfahrt	Fivoahana	\N
2537	3795c31	65	manteau	mantello		https://upload.wikimedia.org/wikipedia/commons/0/08/Mantle_cell_lymphoma_-_intermed_mag.jpg	2026-03-30 16:21:55.237499	0	2026-03-31 16:21:55.237499	{structure_interne,géologie_générale}	2.5	0	0	\N	\N	Lo strato intermedio tra il nucleo e la litosfera.	mantle	Mantel	akanjon-tany	Il mantello terrestre è costituito da peridotiti e rocce dense.
2538	e4222b9	65	noyau	nucleo		https://upload.wikimedia.org/wikipedia/commons/7/70/CivicCenterSquare.jpg	2026-03-30 16:22:02.866343	0	2026-03-31 16:22:02.866343	{structure_interne,géologie_générale}	2.5	0	0	\N	\N	La parte più interna e centrale del nostro pianeta.	core	Kern	vihy	Il nucleo esterno è allo stato liquido, composto principalmente da ferro e nichel.
2539	4fe8152	65	plaque	placca		https://upload.wikimedia.org/wikipedia/commons/e/ef/Piece_of_chocolate_cake_on_a_white_plate_decorated_with_chocolate_sauce.jpg	2026-03-30 16:22:12.161625	0	2026-03-31 16:22:12.161625	{tectonique,géologie_structurale}	2.5	0	0	\N	\N	Grande frammento rigido della litosfera in lento e costante movimento.	plate	Platte	takelaka	La placca pacifica è in costante subduzione sotto altre masse continentali.
2540	a64714c	65	tectonique	tettonica		https://upload.wikimedia.org/wikipedia/commons/b/b4/Plate_tectonics_map.gif	2026-03-30 16:22:20.928054	0	2026-03-31 16:22:20.928054	{tectonique,dynamique}	2.5	0	0	\N	\N	Ramo della geologia che studia i processi di deformazione delle rocce e la struttura della litosfera.	tectonics	Tektonik	tektonika	La teoria della tettonica a zolle ha rivoluzionato le scienze della terra.
2541	952f2cf	65	pli	piega		https://upload.wikimedia.org/wikipedia/commons/6/68/Painting_of_Characters_on_Eight-panel_Folding_Screen.jpg	2026-03-30 16:22:27.951471	0	2026-03-31 16:22:27.951471	{géologie_structurale,déformation}	2.5	0	0	\N	\N	Deformazione duttile degli strati rocciosi che si presentano ondulati senza essersi rotti.	fold	Falte	ketrona	La montagna è caratterizzata da una grande piega anticlinale.
2542	32010cd	65	érosion	erosione		https://upload.wikimedia.org/wikipedia/commons/6/64/Erosion_Yorkshire_Dales.jpg	2026-03-30 16:22:34.141293	0	2026-03-31 16:22:34.141293	{géomorphologie,processus}	2.5	0	0	\N	\N	L'usura e il trasporto dei materiali superficiali a opera di acqua, vento e ghiaccio.	erosion	Erosion	fikaohan-tany	Il vento causa una forte erosione del suolo nel deserto.
2543	10016b6	65	fossile	fossile		https://upload.wikimedia.org/wikipedia/commons/1/17/The_fossils_from_Cretaceous_age_found_in_Lebanon.jpg	2026-03-30 16:22:41.463884	0	2026-03-31 16:22:41.463884	{paléontologie,stratigraphie}	2.5	0	0	\N	\N	Resto o traccia di organismo del passato conservatosi nei sedimenti.	fossil	Fossil	fôsily	Hanno trovato un fossile di dinosauro molto ben conservato in questa zona.
2544	238a3c9	65	strate	strato		https://upload.wikimedia.org/wikipedia/commons/6/69/L%C3%BCdinghausen%2C_Berenbrock%2C_Dortmund-Ems-Kanal_%28an_der_Kreisstra%C3%9Fe_23%29_--_2015_--_4668-70.jpg	2026-03-30 16:22:48.358785	0	2026-03-31 16:22:48.358785	{stratigraphie,sédimentologie}	2.5	0	0	\N	\N	Corpo sedimentario tabulare distinto per composizione o colore dalle formazioni adiacenti.	stratum	Schicht	soson-tany	Ogni strato del deposito geologico rappresenta un'epoca diversa.
2545	c1cc6e4	65	cristal	cristallo		https://upload.wikimedia.org/wikipedia/commons/7/75/Bi-crystal.jpg	2026-03-30 16:22:54.911939	0	2026-03-31 16:22:54.911939	{minéralogie,matériaux}	2.5	0	0	\N	\N	Corpo solido omogeneo limitato da facce piane con una struttura interna ordinata.	crystal	Kristall	kristaly	Il cristallo di ametista trovato ha un colore viola molto intenso.
2546	9db7095	65	quartz	quarzo		https://upload.wikimedia.org/wikipedia/commons/1/14/Quartz%2C_Tibet.jpg	2026-03-30 16:23:01.689186	0	2026-03-31 16:23:01.689186	{minéralogie,silicates}	2.5	0	0	\N	\N	Uno dei minerali più abbondanti, composto da biossido di silicio.	quartz	Quarz	koartsa	Il quarzo puro è incolore e trasparente.
2547	8aac484	65	basalte	basalto		https://upload.wikimedia.org/wikipedia/commons/4/49/Reynisfjara%2C_Su%C3%B0urland%2C_Islandia%2C_2014-08-17%2C_DD_164.JPG	2026-03-30 16:23:09.289215	0	2026-03-31 16:23:09.289215	{pétrologie,roche_magmatique}	2.5	0	0	\N	\N	Una roccia effusiva molto scura e pesante, tipica dei fondali oceanici.	basalt	Basalt	bazalta	Le colonne esagonali si sono formate per il rapido raffreddamento del basalto.
1426	85c945e	37	fromage	formaggio		\N	2026-01-21 14:49:58.032137	0	2026-01-22 14:49:58.032137	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cheese	Käse	fromazy	\N
626	5b59e08	18	Marin	Marinaio		\N	2025-12-07 06:20:59.114168	0	2025-12-08 06:20:59.114168	{métier,italien}	2.5	0	0	\N	\N	\N	Sailor	Seemann	tantsambo	\N
1430	ead348a	37	sel	sale		\N	2026-01-21 14:49:58.20061	0	2026-01-22 14:49:58.20061	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	salt	Salz	sira	\N
1431	666bf87	37	poivre	pepe		\N	2026-01-21 14:49:58.229979	0	2026-01-22 14:49:58.229979	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pepper	Pfeffer	sakay	\N
631	8d5de13	18	Maçon	Muratore		\N	2025-12-07 06:20:59.209254	0	2025-12-08 06:20:59.209254	{métier,italien}	2.5	0	0	\N	\N	\N	Mason	Mason	Mason	\N
861	789c728	23	Qual è il suo primo film come regista?	Il suo primo film da regista è 'Tu mi turbi'.		\N	2025-12-10 08:41:45.583157	1	2025-12-11 15:17:23.383695	{italien,A2,cinéma,"Roberto Benigni"}	2.2	1	1	\N	\N	\N	His first film as director is 'Tu mi turbi'.	Sein erster Film als Regisseur ist „Tu mi turbi“.	Ny sarimihetsika voalohany nataony ho tale dia ny 'Tu mi turbi'.	\N
2548	c938972	65	granite	granito		https://upload.wikimedia.org/wikipedia/commons/7/7d/Hampi%2C_India%2C_Rocky_landscape_of_Hampi%2C_Granite_rocks_of_Matanga_Hill.jpg	2026-03-30 16:23:15.947764	0	2026-03-31 16:23:15.947764	{pétrologie,roche_magmatique}	2.5	0	0	\N	\N	Una roccia ignea intrusiva, composta principalmente da quarzo, feldspato e mica.	granite	Granit	granita	Molti monumenti sono scolpiti in duro granito grigio o rosa.
2549	354e19d	65	calcaire	calcare		https://upload.wikimedia.org/wikipedia/commons/d/d0/Trees_rising_out_of_Cheow_Lan_Lake%2C_blue_sky%2C_eternal_summer_in_Surat_Thani_edited.jpg	2026-03-30 16:23:22.643556	0	2026-03-31 16:23:22.643556	{pétrologie,roche_sédimentaire}	2.5	0	0	\N	\N	Roccia formata prevalentemente da carbonato di calcio.	limestone	Kalkstein	vatosokay	L'acqua piovana scioglie il calcare formando grotte carsiche.
849	2fbd09e	23	Dove ha studiato da ragazzo?	Ha studiato a Firenze.		\N	2025-12-10 08:41:45.323593	3	2025-12-31 09:02:39.644313	{italien,A2,éducation,"Roberto Benigni"}	2.6	21	3	\N	\N	\N	He studied in Florence.	Er studierte in Florenz.	Nianatra tany Florence izy.	\N
2289	ad08800	62	Ligne d'arrivée	Traguardo		\N	2026-02-24 15:25:51.498935	0	2026-02-25 15:25:51.498935	{sport,performance}	2.5	0	0	\N	\N	Punto finale di una gara di corsa.	Finish line	Ziellinie	Ligne d'arrivée	Ha tagliato per primo il traguardo.
2290	77b77dd	62	Amélioration	Miglioramento		\N	2026-02-24 15:25:57.629744	0	2026-02-25 15:25:57.629744	{sport,performance}	2.5	0	0	\N	\N	Progresso nelle prestazioni fisiche o tecniche.	Improvement	Verbesserung	Fanatsarana	L'allenamento costante porta a un costante miglioramento.
2291	0f36b51	62	Volley-ball	Pallavolo		\N	2026-02-24 15:26:05.826313	0	2026-02-25 15:26:05.826313	{sport,discipline}	2.5	0	0	\N	\N	Sport di squadra giocato con una palla sopra una rete.	Volleyball	Volleyball	Baolina voly	Il pallavolo richiede grande coordinazione di squadra.
2292	1b2a058	62	Tennis	Tennis		\N	2026-02-24 15:26:12.959087	0	2026-02-25 15:26:12.959087	{sport,discipline}	2.5	0	0	\N	\N	Sport individuale o di doppio con racchetta e palla.	Tennis	Tennis	Tennis	Il tennis migliora la rapidità e la concentrazione.
2293	a3891a2	62	Rugby	Rugby		\N	2026-02-24 15:26:19.828895	0	2026-02-25 15:26:19.828895	{sport,discipline}	2.5	0	0	\N	\N	Sport di contatto con palla ovale giocato da due squadre.	Rugby	Rugby	Rugby	Il rugby richiede forza e resistenza.
2294	27ca30c	62	Athlétisme léger	Atletica leggera		\N	2026-02-24 15:26:25.88462	0	2026-02-25 15:26:25.88462	{sport,discipline}	2.5	0	0	\N	\N	Discipline di corsa, salti e lanci su pista e campo.	Track and field	Leichtathletik	Fanatanjahan-tsaina maivana	L'atletica leggera è lo sport base delle Olimpiadi.
2295	02e8b69	62	Arts martiaux	Arti marziali		\N	2026-02-24 15:26:32.923047	0	2026-02-25 15:26:32.923047	{sport,discipline}	2.5	0	0	\N	\N	Insieme di discipline di combattimento con o senza armi.	Martial arts	Kampfsport	Kaly martial	Le arti marziali insegnano disciplina e rispetto.
2296	7f15c8e	62	Karaté	Karate		\N	2026-02-24 15:26:39.277164	0	2026-02-25 15:26:39.277164	{sport,discipline}	2.5	0	0	\N	\N	Arte marziale giapponese basata su colpi con mani e piedi.	Karate	Karate	Karate	Il karate sviluppa agilità e autocontrollo.
662	a4b09a7	19	Ours	Orso		\N	2025-12-07 06:26:42.962429	0	2025-12-08 06:26:42.962429	{animaux,italien}	2.5	0	0	\N	\N	\N	Bear	Tragen	bera	\N
1437	5f07c98	37	ail	aglio		\N	2026-01-21 14:49:58.40818	0	2026-01-22 14:49:58.40818	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	garlic	Knoblauch	tongolo gasy	\N
1438	dcd1755	37	courgette	zucchina		\N	2026-01-21 14:49:58.433816	0	2026-01-22 14:49:58.433816	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	zuchini	Zuchini	zuchini	\N
635	cf60f1c	18	Réceptionniste	Receptionist		\N	2025-12-07 06:20:59.287619	0	2025-12-08 06:20:59.287619	{métier,italien}	2.5	0	0	\N	\N	\N	Receptionist	Rezeptionistin	Receptionist	\N
982	d93e578	25	Micro-ondes	Forno a microonde		\N	2025-12-11 15:25:47.464824	0	2025-12-12 15:25:47.464824	{cuisine,italien}	2.5	0	0	\N	\N	\N	Microwave oven	Mikrowellenofen	Lafaoro microwave	\N
983	c04184e	25	Mixeur	Frullatore		\N	2025-12-11 15:25:47.483904	0	2025-12-12 15:25:47.483904	{cuisine,italien}	2.5	0	0	\N	\N	\N	Blender	Mixer	Blender	\N
1455	2825413	37	soupe	minestra		\N	2026-01-21 14:49:59.038338	0	2026-01-22 14:49:59.038338	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	soup	Suppe	lasopy	\N
1473	0b9b231	37	mangue	mango		\N	2026-01-21 14:50:00.073295	0	2026-01-22 14:50:00.073295	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	mango	Mango	manga	\N
643	3dfe2a0	19	Chien	Cane		\N	2025-12-07 06:26:42.501321	0	2025-12-08 06:26:42.501321	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Dog	Hund	amboa	\N
1445	7ec8a4c	37	viande	carne		\N	2026-01-21 14:49:58.614523	0	2026-01-22 14:49:58.614523	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	meat	Fleisch	hena	\N
864	812c78a	23	Che premi ha ricevuto per 'La vita è bella'?	Ha ricevuto l’Oscar come Miglior Attore.		\N	2025-12-10 08:41:45.643373	2	2025-12-16 15:15:13.016295	{italien,A2,prix,"Roberto Benigni"}	2.8	6	2	\N	\N	\N	He received the Oscar for Best Actor.	Er erhielt den Oscar als Bester Hauptdarsteller.	Nahazo ny Oscar ho an'ny mpilalao sarimihetsika tsara indrindra izy.	\N
1447	3c20db6	37	porc	maiale		\N	2026-01-21 14:49:58.667613	0	2026-01-22 14:49:58.667613	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pig	Schwein	kisoa	\N
1483	6f514d9	37	agneau	agnello		\N	2026-01-21 14:50:00.301478	0	2026-01-22 14:50:00.301478	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	lamb	Lamm	ondry	\N
1705	7e02ccd	39	fourgonnette	furgone		\N	2026-01-30 16:23:35.1361	0	2026-01-31 16:23:35.1361	{nom,italien,transport}	2.5	0	0	\N	\N	\N	van	Transporter	van	\N
1706	f14cde6	39	sous-marin	sottomarino		\N	2026-01-30 16:23:35.157674	0	2026-01-31 16:23:35.157674	{nom,italien,transport}	2.5	0	0	\N	\N	\N	submarine	U-Boot	sambo mpisitrika	\N
1707	f048f15	39	fusée	razzo		\N	2026-01-30 16:23:35.181178	0	2026-01-31 16:23:35.181178	{nom,italien,transport}	2.5	0	0	\N	\N	\N	rocket	Rakete	balafomanga	\N
1708	736b055	39	montgolfière	mongolfiera		\N	2026-01-30 16:23:35.208803	0	2026-01-31 16:23:35.208803	{nom,italien,transport}	2.5	0	0	\N	\N	\N	hot air balloon	Heißluftballon	balaonina mafana	\N
1789	c0402d4	40	Respectueux	rispettoso		\N	2026-01-31 15:19:22.62553	0	2026-02-01 15:19:22.62553	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che tratta gli altri con riguardo.	Respectful	Respektvoll	Manaja	È rispettoso verso gli anziani.
2297	0c5711a	62	Judo	Judo		\N	2026-02-24 15:26:46.050381	0	2026-02-25 15:26:46.050381	{sport,discipline}	2.5	0	0	\N	\N	Arte marziale giapponese basata su proiezioni e immobilizzazioni.	Judo	Judo	Judo	Il judo insegna a cadere e rialzarsi.
2298	d533f4c	62	Taekwondo	Taekwondo		\N	2026-02-24 15:26:52.894076	0	2026-02-25 15:26:52.894076	{sport,discipline}	2.5	0	0	\N	\N	Arte marziale coreana famosa per i calci alti.	Taekwondo	Taekwondo	Taekwondo	Il taekwondo richiede grande elasticità.
2299	5726925	62	Gymnastique	Ginnastica		\N	2026-02-24 15:26:59.373555	0	2026-02-25 15:26:59.373555	{sport,discipline}	2.5	0	0	\N	\N	Disciplina che sviluppa forza, equilibrio e coordinazione.	Gymnastics	Turnen	Gymnastique	La ginnastica artistica è spettacolare.
2300	1675bf4	62	Gymnastique artistique	Ginnastica artistica		\N	2026-02-24 15:27:05.945551	0	2026-02-25 15:27:05.945551	{sport,discipline}	2.5	0	0	\N	\N	Ginnastica con attrezzi come parallele e volteggio.	Artistic gymnastics	Kunstturnen	Gymnastique artistique	La ginnastica artistica richiede precisione.
2301	271eca8	62	Gymnastique rythmique	Ginnastica ritmica		\N	2026-02-24 15:27:12.21583	0	2026-02-25 15:27:12.21583	{sport,discipline}	2.5	0	0	\N	\N	Ginnastica con attrezzi come cerchio e nastro.	Rhythmic gymnastics	Rhythmische Sportgymnastik	Gymnastique rythmique	La ginnastica ritmica unisce danza e sport.
2302	5a91db5	62	Haltérophilie	Sollevamento pesi		\N	2026-02-24 15:27:18.212725	0	2026-02-25 15:27:18.212725	{sport,discipline}	2.5	0	0	\N	\N	Sport di sollevamento di bilancieri.	Weightlifting	Gewichtheben	Fanatontosana lanja	L'haltérophilie richiede potenza esplosiva.
1987	36fe334	60	Chronologie	Cronologia		\N	2026-02-24 13:09:04.262336	0	2026-02-25 13:09:04.262336	{histoire,méthodologie,temps}	2.5	0	0	\N	\N	Sequenza ordinata degli eventi storici disposti secondo la loro successione temporale.	Chronology	Chronologie	Kronolojia	La cronologia degli eventi della Rivoluzione Francese aiuta a comprendere le cause e le conseguenze.
986	dc37dd6	25	Spatule	Spatola		\N	2025-12-11 15:25:47.545577	0	2025-12-12 15:25:47.545577	{cuisine,italien}	2.5	0	0	\N	\N	\N	Spatula	Spatel	Spatula	\N
987	2c8e743	25	Épluche-légumes	Pelapatate		\N	2025-12-11 15:25:47.563736	0	2025-12-12 15:25:47.563736	{cuisine,italien}	2.5	0	0	\N	\N	\N	Potato peeler	Kartoffelschäler	Ovy peeler	\N
646	4aa60a3	19	Poisson	Pesce		\N	2025-12-07 06:26:42.575387	0	2025-12-08 06:26:42.575387	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Fish	Fisch	TRONDRO	\N
1989	7c6a323	60	Époque	Epoca		\N	2026-02-24 13:09:21.779735	0	2026-02-25 13:09:21.779735	{histoire,temps}	2.5	0	0	\N	\N	Periodo storico caratterizzato da particolari condizioni o eventi significativi.	Epoch	Epoche	Epoka	L'epoca delle grandi scoperte geografiche ha cambiato il mondo.
1990	b3e2ddc	60	Siècle	Secolo		\N	2026-02-24 13:09:34.438964	0	2026-02-25 13:09:34.438964	{histoire,temps}	2.5	0	0	\N	\N	Periodo di cento anni, spesso usato per dividere la storia in fasi temporali.	Century	Jahrhundert	Taonjato	Il ventesimo secolo è stato segnato da due guerre mondiali.
1991	835e39c	60	Civilisation	Civiltà		\N	2026-02-24 13:09:40.705594	0	2026-02-25 13:09:40.705594	{histoire,société,culture}	2.5	0	0	\N	\N	Complesso di società umane che hanno raggiunto un alto livello di sviluppo culturale, sociale e tecnologico.	Civilization	Zivilisation	Sivilizasiona	La civiltà romana ha influenzato profondamente il diritto e l'architettura europea.
842	311994b	23	Quando è nato Roberto Benigni?	È nato il 27 ottobre 1952.		\N	2025-12-10 08:41:45.103327	2	2025-12-17 08:32:53.116701	{italien,A2,date,"Roberto Benigni"}	2.6	6	2	\N	\N	\N	He was born on October 27, 1952.	Er wurde am 27. Oktober 1952 geboren.	Teraka tamin’ny 27 Oktobra 1952 izy.	\N
1494	41994a6	37	cappuccino	cappuccino		\N	2026-01-21 14:50:00.60868	0	2026-01-22 14:50:00.60868	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cappuccino	Cappuccino	cappuccino	\N
988	6b1b5de	25	Ciseaux de cuisine	Forbici da cucina		\N	2025-12-11 15:25:47.584946	0	2025-12-12 15:25:47.584946	{cuisine,italien}	2.5	0	0	\N	\N	\N	Kitchen scissors	Küchenschere	Hety an-dakozia	\N
1710	d0bac78	39	canoë	canoa		\N	2026-01-30 16:23:35.254159	0	2026-01-31 16:23:35.254159	{nom,italien,transport}	2.5	0	0	\N	\N	\N	canoe	Kanu	lakana	\N
1711	64d3145	39	croisière	crociera		\N	2026-01-30 16:23:35.277794	0	2026-01-31 16:23:35.277794	{nom,italien,transport}	2.5	0	0	\N	\N	\N	cruise	Kreuzfahrt	fitsangantsanganana	\N
1992	ddf9040	60	Société	Società		\N	2026-02-24 13:09:49.568913	0	2026-02-25 13:09:49.568913	{société,histoire}	2.5	0	0	\N	\N	Insieme di individui che vivono insieme secondo norme e istituzioni condivise.	Society	Gesellschaft	Fiarahamonina	La società feudale era basata su rapporti di vassallaggio e signoria.
1993	b6b8269	60	Culture	Cultura		\N	2026-02-24 13:09:58.42037	0	2026-02-25 13:09:58.42037	{culture,société}	2.5	0	0	\N	\N	Insieme di valori, credenze, usi e costumi che caratterizzano un gruppo umano.	Culture	Kultur	Kolontsaina	La cultura greca antica ha posto le basi per la filosofia occidentale.
1994	9b190ae	60	Tradition	Tradizione		\N	2026-02-24 13:10:05.403734	0	2026-02-25 13:10:05.403734	{culture,société}	2.5	0	0	\N	\N	Consuetudine o pratica trasmessa di generazione in generazione all'interno di una comunità.	Tradition	Tradition	Fomban-drazana	La tradizione del carnevale è molto radicata in molte culture europee.
1794	cfab583	40	Lâche	codardo		\N	2026-01-31 15:19:22.757231	0	2026-02-01 15:19:22.757231	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che evita i rischi per paura.	Cowardly	Feige	Saro-aina	È codardo e non difende mai gli amici.
1515	4192699	38	mode	moda		\N	2026-01-25 06:44:09.142691	0	2026-01-26 06:44:09.142691	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	fashion	Mode	Fashion	\N
1518	25dd739	38	top	top		\N	2026-01-25 06:44:09.209103	0	2026-01-26 06:44:09.209103	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	top	Spitze	ambony	\N
652	81344bf	19	Poulet	Pollo		\N	2025-12-07 06:26:42.70099	0	2025-12-08 06:26:42.70099	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Chicken	Huhn	akoho	\N
1995	ecbfc79	60	Héritage	Eredità		\N	2026-02-24 13:10:13.504852	0	2026-02-25 13:10:13.504852	{culture,histoire}	2.5	0	0	\N	\N	Patrimonio culturale, materiale o immateriale trasmesso dalle generazioni precedenti.	Heritage	Erbe	Lovasoa	L'eredità dell'Impero Romano include molte lingue romanze.
1996	ae659a1	60	Mémoire	Memoria		\N	2026-02-24 13:10:26.592069	0	2026-02-25 13:10:26.592069	{histoire,culture}	2.5	0	0	\N	\N	Ricordo collettivo o individuale di eventi passati che influenza l'identità di un gruppo.	Memory	Gedächtnis	Fahatsiarovana	La memoria della Resistenza è fondamentale per l'identità nazionale italiana post-bellica.
1997	07699cb	60	Source	Fonte		\N	2026-02-24 13:10:34.064105	0	2026-02-25 13:10:34.064105	{histoire,méthodologie}	2.5	0	0	\N	\N	Elemento originario che fornisce informazioni su fatti o fenomeni storici.	Source	Quelle	Loharano	Le fonti primarie come i diari sono essenziali per ricostruire gli eventi del passato.
1514	b170a1c	38	Vêtements	abbigliamento		\N	2026-01-25 06:44:09.09889	0	2026-01-26 06:44:09.09889	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	Indumenti tecnici per comfort e prestazione.	Clothing	Kleidung	Fitafiana	Indossa abbigliamento traspirante.
655	e89f291	19	Oie	Oca		\N	2025-12-07 06:26:42.767759	0	2025-12-08 06:26:42.767759	{animaux,italien}	2.5	0	0	\N	\N	\N	Goose	Gans	gisa	\N
658	f5252ca	19	Lion	Leone		\N	2025-12-07 06:26:42.853026	0	2025-12-08 06:26:42.853026	{animaux,italien}	2.5	0	0	\N	\N	\N	Lion	Löwe	Lion	\N
661	a1d09d9	19	Renard	Volpe		\N	2025-12-07 06:26:42.937427	0	2025-12-08 06:26:42.937427	{animaux,italien}	2.5	0	0	\N	\N	\N	Fox	Fuchs	amboahaolo	\N
664	49ecabb	19	Gorille	Gorilla		\N	2025-12-07 06:26:43.010607	0	2025-12-08 06:26:43.010607	{animaux,italien}	2.5	0	0	\N	\N	\N	Gorilla	Gorilla	rajako	\N
1000	fff20d8	25	Essuie-tout	Carta da cucina		\N	2025-12-11 15:25:47.83452	0	2025-12-12 15:25:47.83452	{cuisine,italien}	2.5	0	0	\N	\N	\N	Kitchen paper	Küchenpapier	Taratasy an-dakozia	\N
1002	1a5a2f6	25	Huile	Olio		\N	2025-12-11 15:25:47.872021	0	2025-12-12 15:25:47.872021	{cuisine,italien}	2.5	0	0	\N	\N	\N	Oil	Öl	SOLIKA	\N
1003	96a00e0	25	Sel	Sale		\N	2025-12-11 15:25:47.890981	0	2025-12-12 15:25:47.890981	{cuisine,italien}	2.5	0	0	\N	\N	\N	Salt	Salz	sira	\N
1012	d0592b8	25	Carafe	Caraffa		\N	2025-12-11 15:25:48.108218	0	2025-12-12 15:25:48.108218	{cuisine,italien}	2.5	0	0	\N	\N	\N	Carafe	Karaffe	Carafe	\N
1516	07a9e46	38	t-shirt	maglietta		\N	2026-01-25 06:44:09.166332	0	2026-01-26 06:44:09.166332	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	T-shirt	T-Shirt	T-shirt	\N
1998	dfb70a5	60	Archive	Archivio		\N	2026-02-24 13:10:41.563657	0	2026-02-25 13:10:41.563657	{histoire,méthodologie}	2.5	0	0	\N	\N	Raccolta organizzata di documenti e materiali storici conservati per la consultazione.	Archive	Archiv	Arisiva	Gli storici consultano l'archivio di Stato per studiare i trattati di pace.
1999	6f46d94	60	Témoignage	Testimonianza		\N	2026-02-24 13:10:48.352501	0	2026-02-25 13:10:48.352501	{histoire,méthodologie}	2.5	0	0	\N	\N	Racconto o prova orale o scritta di un evento vissuto direttamente.	Testimony	Zeugnis	Vavolombelona	La testimonianza di un sopravvissuto è cruciale per documentare gli orrori della guerra.
2303	084f59d	62	Triathlon	Triathlon		\N	2026-02-24 15:27:24.588059	0	2026-02-25 15:27:24.588059	{sport,discipline}	2.5	0	0	\N	\N	Sport multidisciplinare: nuoto, ciclismo e corsa.	Triathlon	Triathlon	Triathlon	Il triathlon mette alla prova resistenza e volontà.
2304	0b0d0fd	62	Aviron	Canottaggio		\N	2026-02-24 15:27:31.266117	0	2026-02-25 15:27:31.266117	{sport,discipline}	2.5	0	0	\N	\N	Sport di propulsione di imbarcazioni con remi.	Rowing	Rudern	Canottaggio	Il canottaggio rafforza schiena e braccia.
1519	86c0f02	38	chemise	camicia		\N	2026-01-25 06:44:09.228279	0	2026-01-26 06:44:09.228279	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	Shirt	Hemd	AKANJONAO	\N
1520	ba43e10	38	pantalon	pantaloni		\N	2026-01-25 06:44:09.249544	0	2026-01-26 06:44:09.249544	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	pants	Hose	pataloha	\N
1521	2066441	38	jeans	jeans		\N	2026-01-25 06:44:09.270318	0	2026-01-26 06:44:09.270318	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	jeans	Jeans	jeans	\N
1522	532b955	38	robe	vestito		\N	2026-01-25 06:44:09.288641	0	2026-01-26 06:44:09.288641	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	dress	Kleid	akanjo	\N
1523	953afc7	38	jupe	gonna		\N	2026-01-25 06:44:09.30433	0	2026-01-26 06:44:09.30433	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	skirt	Rock	zipo	\N
1530	ebafe99	38	short	pantaloncini		\N	2026-01-25 06:44:09.444138	0	2026-01-26 06:44:09.444138	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	shorts	Shorts	kilaoty	\N
1712	fc73497	39	ancre	ancora		\N	2026-01-30 16:23:35.30228	0	2026-01-31 16:23:35.30228	{nom,italien,transport}	2.5	0	0	\N	\N	\N	Still	Trotzdem	Na izany aza	\N
1713	cbf987d	39	gare routière	autostazione		\N	2026-01-30 16:23:35.326674	0	2026-01-31 16:23:35.326674	{nom,italien,transport}	2.5	0	0	\N	\N	\N	bus station	Busbahnhof	fiantsonan'ny bisy	\N
1714	18fc046	39	contrôleur	controllore		\N	2026-01-30 16:23:35.349368	0	2026-01-31 16:23:35.349368	{nom,italien,transport}	2.5	0	0	\N	\N	\N	controller	Regler	-maso	\N
1715	ef205fa	39	panneau de signalisation	cartello stradale		\N	2026-01-30 16:23:35.37146	0	2026-01-31 16:23:35.37146	{nom,italien,transport}	2.5	0	0	\N	\N	\N	road sign	Straßenschild	famantarana ny lalana	\N
1716	4e7c794	39	virage	curva		\N	2026-01-30 16:23:35.396157	0	2026-01-31 16:23:35.396157	{nom,italien,transport}	2.5	0	0	\N	\N	\N	curve	Kurve	curve	\N
1717	654962b	39	intersection	incrocio		\N	2026-01-30 16:23:35.419512	0	2026-01-31 16:23:35.419512	{nom,italien,transport}	2.5	0	0	\N	\N	\N	intersection	Überschneidung	Fihaonan-dalana	\N
1718	e107526	39	passage piéton	strisce pedonali		\N	2026-01-30 16:23:35.442846	0	2026-01-31 16:23:35.442846	{nom,italien,transport}	2.5	0	0	\N	\N	\N	pedestrian crossings	Fußgängerüberwege	fiampitana mpandeha an-tongotra	\N
647	f78c208	19	Vache	Mucca		\N	2025-12-07 06:26:42.594472	0	2025-12-08 06:26:42.594472	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Cow	Kuh	OMBIVAVY	\N
650	6a18a51	19	Cochon	Maiale		\N	2025-12-07 06:26:42.656823	0	2025-12-08 06:26:42.656823	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Pig	Schwein	kisoa	\N
651	78c8730	19	Chèvre	Capra		\N	2025-12-07 06:26:42.677781	0	2025-12-08 06:26:42.677781	{animaux,italien,pareto}	2.5	0	0	\N	\N	\N	Goat	Ziege	Goat	\N
2305	fd65582	62	Escalade	Arrampicata		\N	2026-02-24 15:27:38.536618	0	2026-02-25 15:27:38.536618	{sport,discipline}	2.5	0	0	\N	\N	Attività di salire su pareti naturali o artificiali.	Climbing	Klettern	Fanapahana	L'arrampicata sviluppa forza e concentrazione.
2306	e8c074c	62	Physique	Fisico		\N	2026-02-24 15:27:45.94179	0	2026-02-25 15:27:45.94179	{sport,corps,physiologie}	2.5	0	0	\N	\N	Aspetto e struttura del corpo umano.	Physique	Körperbau	Fisika	Un fisico atletico richiede allenamento costante.
1533	1e59734	38	baskets	scarpe da ginnastica		\N	2026-01-25 06:44:09.503747	0	2026-01-26 06:44:09.503747	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	gym shoes	Turnschuhe	kiraro fanaovana fanatanjahan-tena	\N
2307	c66c8bb	62	Corps	Corpo		\N	2026-02-24 15:27:52.855859	0	2026-02-25 15:27:52.855859	{sport,corps,physiologie}	2.5	0	0	\N	\N	Insieme delle parti che costituiscono l'essere umano.	Body	Körper	Vatana	Il corpo risponde bene all'allenamento regolare.
2308	66d2cf0	62	Squelette	Scheletro		\N	2026-02-24 15:27:59.660223	0	2026-02-25 15:27:59.660223	{sport,corps,physiologie}	2.5	0	0	\N	\N	Struttura ossea che sostiene il corpo.	Skeleton	Skelett	Taolan'ny vatana	Il sistema scheletrico protegge gli organi.
1534	8d23c41	38	bottes	stivali		\N	2026-01-25 06:44:09.522343	0	2026-01-26 06:44:09.522343	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	boots	Stiefel	kiraro	\N
653	2c608e3	19	Lapin	Coniglio		\N	2025-12-07 06:26:42.72241	0	2025-12-08 06:26:42.72241	{animaux,italien}	2.5	0	0	\N	\N	\N	Rabbit	Kaninchen	Bitro	\N
656	f2e29f3	19	Dinde	Tacchino		\N	2025-12-07 06:26:42.795332	0	2025-12-08 06:26:42.795332	{animaux,italien}	2.5	0	0	\N	\N	\N	Turkey	Truthahn	vorontsiloza	\N
659	133753e	19	Tigre	Tigre		\N	2025-12-07 06:26:42.883756	0	2025-12-08 06:26:42.883756	{animaux,italien}	2.5	0	0	\N	\N	\N	Tiger	Tiger	Tiger	\N
660	6ba7b9b	19	Loup	Lupo		\N	2025-12-07 06:26:42.90958	0	2025-12-08 06:26:42.90958	{animaux,italien}	2.5	0	0	\N	\N	\N	Wolf	Wolf	Wolf	\N
663	bd51b65	19	Singe	Scimmia		\N	2025-12-07 06:26:42.984926	0	2025-12-08 06:26:42.984926	{animaux,italien}	2.5	0	0	\N	\N	\N	Monkey	Affe	gidro	\N
1017	0dea95c	25	Tablier	Grembiule		\N	2025-12-11 15:25:48.351755	0	2025-12-12 15:25:48.351755	{cuisine,italien}	2.5	0	0	\N	\N	\N	Apron	Schürze	Apron	\N
1543	13a113f	38	chapeau haut de forme	cilindro		\N	2026-01-25 06:44:09.699288	0	2026-01-26 06:44:09.699288	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	cylinder	Zylinder	Varingarin'i	\N
1544	ef33a07	38	casquette	berretto		\N	2026-01-25 06:44:09.719988	0	2026-01-26 06:44:09.719988	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	cap	Kappe	cap	\N
1545	e8bd7c8	38	écharpe	sciarpa		\N	2026-01-25 06:44:09.739616	0	2026-01-26 06:44:09.739616	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	scarf	Schal	fehy	\N
1546	7c7faa0	38	gants	guanti		\N	2026-01-25 06:44:09.761159	0	2026-01-26 06:44:09.761159	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	gloves	Handschuhe	fonon-tanana	\N
2309	3ba2471	62	Os	Ossa		\N	2026-02-24 15:28:06.423524	0	2026-02-25 15:28:06.423524	{sport,corps,physiologie}	2.5	0	0	\N	\N	Elementi rigidi che formano lo scheletro.	Bones	Knochen	Taolana	Le ossa si rafforzano con attività a impatto.
2310	6509b81	62	Tendon	Tendine		\N	2026-02-24 15:28:12.407657	0	2026-02-25 15:28:12.407657	{sport,corps,physiologie}	2.5	0	0	\N	\N	Tessuto che collega muscolo a osso.	Tendon	Sehne	Tendine	Il tendine di Achille è molto sollecitato nella corsa.
666	a7c0849	19	Koala	Koala		\N	2025-12-07 06:26:43.053501	0	2025-12-08 06:26:43.053501	{animaux,italien}	2.5	0	0	\N	\N	\N	Koala	Koala	Koala	\N
669	e582d53	19	Girafe	Giraffa		\N	2025-12-07 06:26:43.12523	0	2025-12-08 06:26:43.12523	{animaux,italien}	2.5	0	0	\N	\N	\N	Giraffe	Giraffe	Zirafy	\N
672	b08c3d3	19	Rhinocéros	Rinoceronte		\N	2025-12-07 06:26:43.19099	0	2025-12-08 06:26:43.19099	{animaux,italien}	2.5	0	0	\N	\N	\N	Rhinoceros	Nashorn	Rhinoceros	\N
675	d0822e7	19	Grenouille	Rana		\N	2025-12-07 06:26:43.252383	0	2025-12-08 06:26:43.252383	{animaux,italien}	2.5	0	0	\N	\N	\N	Frog	Frosch	sahona	\N
693	d20e67e	20	Battre	Sbattere		\N	2025-12-07 06:31:34.132425	2	2025-12-17 08:28:34.190178	{cuisine,italien}	2.5	6	2	\N	\N	\N	Whisk	Schneebesen	kobanina	\N
1270	2187796	31	Photosynthèse	Fotosintesi		\N	2026-01-11 15:36:50.53078	0	2026-01-12 15:36:50.53078	{nom,italien,écologie}	2.5	0	0	\N	\N	\N	Photosynthesis	Photosynthese	Photosynthesis	\N
665	c6d0eb9	19	Panda	Panda		\N	2025-12-07 06:26:43.032047	0	2025-12-08 06:26:43.032047	{animaux,italien}	2.5	0	0	\N	\N	\N	Panda	Panda	pandà	\N
1539	6aa2798	38	ballerines	ballerine		\N	2026-01-25 06:44:09.61681	0	2026-01-26 06:44:09.61681	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	dancers	Tänzer	mpandihy	\N
1541	4c26d03	38	chapeau	cappello		\N	2026-01-25 06:44:09.660193	0	2026-01-26 06:44:09.660193	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	hat	Hut	satroka	\N
1542	a8f432d	38	chapeau de paille	cappello di paglia		\N	2026-01-25 06:44:09.68	0	2026-01-26 06:44:09.68	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	straw hat	Strohhut	satroka mololo	\N
2311	1bce11a	62	Ligament	Legamento		\N	2026-02-24 15:28:18.489602	0	2026-02-25 15:28:18.489602	{sport,corps,physiologie}	2.5	0	0	\N	\N	Tessuto che collega ossa tra loro.	Ligament	Band	Ligament	I legamenti stabilizzano le articolazioni.
1038	c63c12c	28	Se passer	Accadere		\N	2026-01-08 15:19:17.723857	1	2026-02-02 15:23:01.220695	{verbe,italien,événement}	2.6	1	1	\N	\N	\N	Happen	Passieren	Ela!	\N
668	4142a35	19	Éléphant	Elefante		\N	2025-12-07 06:26:43.10202	0	2025-12-08 06:26:43.10202	{animaux,italien}	2.5	0	0	\N	\N	\N	Elephant	Elefant	elefanta	\N
671	e83fbc9	19	Hippopotame	Ippopotamo		\N	2025-12-07 06:26:43.170315	0	2025-12-08 06:26:43.170315	{animaux,italien}	2.5	0	0	\N	\N	\N	Hippopotamus	Nilpferd	hipopotama	\N
674	e72e3be	19	Tortue	Tartaruga		\N	2025-12-07 06:26:43.231838	0	2025-12-08 06:26:43.231838	{animaux,italien}	2.5	0	0	\N	\N	\N	Turtle	Schildkröte	sokatra	\N
676	11835bd	19	Escargot	Lumaca		\N	2025-12-07 06:26:43.272814	0	2025-12-08 06:26:43.272814	{animaux,italien}	2.5	0	0	\N	\N	\N	Snail	Schnecke	Sifotra	\N
1039	106b2e6	28	Gaspiller	Sprecare		\N	2026-01-08 15:19:17.746395	1	2026-02-02 15:32:58.093511	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Waste	Abfall	fandaniam-poana	\N
677	052ddc3	19	Crabe	Granchio		\N	2025-12-07 06:26:43.293305	0	2025-12-08 06:26:43.293305	{animaux,italien}	2.5	0	0	\N	\N	\N	Crab	Krabbe	Drakaka	\N
2312	44462df	62	Circulation	Circolazione		\N	2026-02-24 15:28:24.700977	0	2026-02-25 15:28:24.700977	{sport,corps,physiologie}	2.5	0	0	\N	\N	Movimento del sangue nel sistema cardiovascolare.	Circulation	Kreislauf	Fikorianana	L'esercizio migliora la circolazione sanguigna.
2313	8a3dd70	62	Battement	Battito		\N	2026-02-24 15:28:31.929865	0	2026-02-25 15:28:31.929865	{sport,corps,physiologie}	2.5	0	0	\N	\N	Contrazione ritmica del cuore.	Heartbeat	Herzschlag	Fifamaranana	Il battito cardiaco aumenta durante lo sforzo.
1042	cf66b3e	28	Changement climatique	Cambiamento climatico		\N	2026-01-08 15:19:17.821058	1	2026-02-02 15:29:52.206107	{expression,italien,climat}	2.6	1	1	\N	\N	\N	Climate change	Klimawandel	Fiovan'ny toetr'andro	\N
1043	3d1ef00	28	Réchauffement climatique	Riscaldamento globale		\N	2026-01-08 15:19:17.854086	1	2026-02-02 15:37:58.972177	{expression,italien,climat}	2.6	1	1	\N	\N	\N	Global warming	Globale Erwärmung	Fihafanan'ny tany	\N
2000	f48911a	60	Document	Documento		\N	2026-02-24 13:10:55.791481	0	2026-02-25 13:10:55.791481	{histoire,méthodologie}	2.5	0	0	\N	\N	Qualsiasi supporto scritto o registrato che attesta fatti o eventi.	Document	Dokument	Antontan-taratasy	Il documento originale della Dichiarazione d'Indipendenza è conservato in un museo.
2001	4b7ee6a	60	Interprétation	Interpretazione		\N	2026-02-24 13:11:03.593383	0	2026-02-25 13:11:03.593383	{histoire,méthodologie}	2.5	0	0	\N	\N	Analisi e spiegazione del significato di fatti o fonti storiche.	Interpretation	Interpretation	Fanazavana	L'interpretazione degli storici sul Rinascimento varia a seconda delle prospettive.
680	4a23498	19	Baleine	Balena		\N	2025-12-07 06:26:43.353466	0	2025-12-08 06:26:43.353466	{animaux,italien}	2.5	0	0	\N	\N	\N	Whale	Wal	trozona	\N
683	1164249	19	Abeille	Ape		\N	2025-12-07 06:26:43.411074	0	2025-12-08 06:26:43.411074	{animaux,italien}	2.5	0	0	\N	\N	\N	Bee	Biene	renitantely	\N
686	704f261	19	Araignée	Ragno		\N	2025-12-07 06:26:43.473852	0	2025-12-08 06:26:43.473852	{animaux,italien}	2.5	0	0	\N	\N	\N	Spider	Spinne	hala	\N
678	f2f676a	19	Dauphin	Delfino		\N	2025-12-07 06:26:43.313705	0	2025-12-08 06:26:43.313705	{animaux,italien}	2.5	0	0	\N	\N	\N	Dolphin	Delphin	feso	\N
682	00b482f	19	Méduse	Medusa		\N	2025-12-07 06:26:43.392118	0	2025-12-08 06:26:43.392118	{animaux,italien}	2.5	0	0	\N	\N	\N	Jellyfish	Qualle	Jellyfish	\N
685	65658e0	19	Moustique	Zanzara		\N	2025-12-07 06:26:43.45232	0	2025-12-08 06:26:43.45232	{animaux,italien}	2.5	0	0	\N	\N	\N	Mosquito	Moskito	moka	\N
1056	a7ae5c6	28	Animal	Animale		\N	2026-01-08 15:19:18.286686	1	2026-02-02 15:34:33.656986	{nom,italien,nature}	2.6	1	1	\N	\N	\N	Animal	Tier	biby	\N
689	4c64786	20	Hacher	Tritare		\N	2025-12-07 06:31:34.038641	2	2025-12-16 07:47:14.144232	{cuisine,italien}	2.7	6	2	\N	\N	\N	Chop	Hacken	mitetika	\N
692	7d911ad	20	Remuer	Girare		\N	2025-12-07 06:31:34.109598	3	2025-12-26 08:30:26.516966	{cuisine,italien}	2	15	3	\N	\N	\N	Spin	Drehen	kofehy ireny	\N
2002	e46a677	60	Contexte	Contesto		\N	2026-02-24 13:11:12.459273	0	2026-02-25 13:11:12.459273	{histoire,méthodologie}	2.5	0	0	\N	\N	Insieme di circostanze storiche, sociali ed economiche che circondano un evento.	Context	Kontext	Seha-kevitra	Per comprendere la Rivoluzione, è necessario analizzare il contesto economico dell'epoca.
2003	18681c2	60	Événement	Evento		\N	2026-02-24 13:11:20.79037	0	2026-02-25 13:11:20.79037	{histoire}	2.5	0	0	\N	\N	Fatto o accadimento di rilevanza storica che modifica il corso degli eventi.	Event	Ereignis	Zava-nitranga	L'evento della presa della Bastiglia segnò l'inizio della Rivoluzione Francese.
2004	dfde2d1	60	Analyse	Analisi		\N	2026-02-24 13:11:34.9915	0	2026-02-25 13:11:34.9915	{histoire,méthodologie}	2.5	0	0	\N	\N	Esame dettagliato di fonti e fatti per comprendere cause e conseguenze.	Analysis	Analyse	Fanadihadiana	L'analisi delle cause della Prima Guerra Mondiale rivela tensioni nazionaliste.
696	7d07a87	20	Frire	Friggere		\N	2025-12-07 06:31:34.287357	2	2025-12-16 07:48:55.972157	{cuisine,italien}	2.7	6	2	\N	\N	\N	Fry	Braten	Fry	\N
894	1b8af2b	24	Fourchette	Forchetta		\N	2025-12-10 15:39:06.14541	0	2025-12-11 15:39:06.14541	{maison,italien}	2.5	0	0	\N	\N	\N	Fork	Gabel	Fork	\N
1448	f4daf8c	37	jambon	prosciutto		\N	2026-01-21 14:49:58.70332	0	2026-01-22 14:49:58.70332	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	dried ham	getrockneter Schinken	ham maina	\N
681	ad07668	19	Poulpe	Polpo		\N	2025-12-07 06:26:43.373725	0	2025-12-08 06:26:43.373725	{animaux,italien}	2.5	0	0	\N	\N	\N	Octopus	Oktopus	Orita	\N
895	47539d9	24	Couteau	Coltello		\N	2025-12-10 15:39:06.166669	0	2025-12-11 15:39:06.166669	{maison,italien}	2.5	0	0	\N	\N	\N	Knife	Messer	antsy	\N
896	85d81fd	24	Cuillère	Cucchiaio		\N	2025-12-10 15:39:06.184987	0	2025-12-11 15:39:06.184987	{maison,italien}	2.5	0	0	\N	\N	\N	Table spoon	Esslöffel	Latabatra sotro	\N
1152	547b2b8	30	S'effondrer	Venire giù		\N	2026-01-09 16:10:10.876486	0	2026-01-10 16:10:10.876486	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Come down	Herunter kommen	Midina	\N
2005	a6779d8	60	Nation	Nazione		\N	2026-02-24 13:11:56.039874	0	2026-02-25 13:11:56.039874	{politique,société}	2.5	0	0	\N	\N	Comunità di persone unite da lingua, cultura, storia e territorio condivisi.	Nation	Nation	Firenena	La nazione italiana si unificò nel Risorgimento del XIX secolo.
2006	76e59ce	60	Empire	Impero		\N	2026-02-24 13:12:07.683021	0	2026-02-25 13:12:07.683021	{politique,histoire}	2.5	0	0	\N	\N	Forma di governo che estende il dominio su più popoli e territori vasti.	Empire	Reich	Emperora	L'Impero Romano d'Occidente cadde nel 476 d.C.
1063	c65ae52	28	Déchet	Rifiuto		\N	2026-01-08 15:19:18.462497	1	2026-02-02 15:21:18.101257	{nom,italien,déchets}	2.6	1	1	\N	\N	\N	Rejection	Ablehnung	fandavana	\N
1065	d8c469e	28	Recycler	Riciclare		\N	2026-01-08 15:19:18.509858	0	2026-02-01 15:49:01.93926	{verbe,italien,recyclage}	2.0999999999999996	0	0	\N	\N	\N	Recycle	Recyceln	fanamboarana ny	\N
1066	853cf53	28	Recyclage	Riciclaggio		\N	2026-01-08 15:19:18.536158	0	2026-02-01 15:46:21.168728	{nom,italien,recyclage}	2.0999999999999996	0	0	\N	\N	\N	Recycling	Recycling	fanodinana	\N
1068	f1035bf	28	Tri sélectif	Raccolta differenziata		\N	2026-01-08 15:19:18.584033	0	2026-02-01 15:48:36.767368	{expression,italien,déchets}	2.0999999999999996	0	0	\N	\N	\N	Waste sorting	Müllsortierung	Fanasokajiana fako	\N
1559	6b9b604	38	lunettes	occhiali		\N	2026-01-25 06:44:10.0435	0	2026-01-26 06:44:10.0435	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	eyeglasses	Brille	solomaso	\N
1064	014a645	28	Poubelle	Cestino		\N	2026-01-08 15:19:18.484969	1	2026-02-02 15:35:57.81764	{nom,italien,déchets}	2.6	1	1	\N	\N	\N	Basket	Korb	harona	\N
1571	6187a80	38	collier de perles	collana di perle		\N	2026-01-25 06:44:10.39956	0	2026-01-26 06:44:10.39956	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	pearl necklace	Perlenkette	rojo perla	\N
707	f7fa470	20	Mesurer	Misurare		\N	2025-12-07 06:31:34.532825	1	2025-12-11 14:00:42.906024	{cuisine,italien}	2.4	1	1	\N	\N	\N	Measure	Messen	ohatra	\N
898	5226c57	24	Chaise	Sedia		\N	2025-12-10 15:39:06.224275	0	2025-12-11 15:39:06.224275	{maison,italien}	2.5	0	0	\N	\N	\N	Chair	Stuhl	seza	\N
1206	9e373af	31	Éolienne	Turbina eolica		\N	2026-01-11 15:36:49.047072	0	2026-01-12 15:36:49.047072	{nom,italien,énergie}	2.5	0	0	\N	\N	\N	Wind turbine	Windkraftanlage	Turbine rivotra	\N
702	9356a1f	20	Saler	Salare		\N	2025-12-07 06:31:34.432911	2	2025-12-17 08:28:21.562603	{cuisine,italien}	2.7	6	2	\N	\N	\N	Salt	Salz	sira	\N
1566	03621ae	38	mallette	valigetta		\N	2026-01-25 06:44:10.276631	0	2026-01-26 06:44:10.276631	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	briefcase	Aktentasche	kitapo	\N
1567	92c5c51	38	bijoux	gioielli		\N	2026-01-25 06:44:10.307481	0	2026-01-26 06:44:10.307481	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	jewels	Juwelen	firavaka	\N
2009	d3180ee	60	République	Repubblica		\N	2026-02-24 13:12:33.444496	0	2026-02-25 13:12:33.444496	{politique,gouvernance}	2.5	0	0	\N	\N	Forma di governo in cui il potere è esercitato da rappresentanti eletti dal popolo.	Republic	Republik	Repoblika	La Repubblica Romana durò dal 509 a.C. al 27 a.C.
2007	022943c	60	Royaume	Regno		\N	2026-02-24 13:12:16.155591	0	2026-02-25 13:12:16.155591	{politique,gouvernance}	2.5	0	0	\N	\N	Entità politica governata da un re o regina con potere ereditario.	Kingdom	Königreich	Fanjakana	Il Regno di Francia sotto Luigi XIV raggiunse l'apice dell'assolutismo.
2008	6236785	60	Monarchie	Monarchia		\N	2026-02-24 13:12:25.266771	0	2026-02-25 13:12:25.266771	{politique,gouvernance}	2.5	0	0	\N	\N	Sistema di governo in cui il potere supremo è detenuto da un sovrano ereditario.	Monarchy	Monarchie	Monarkia	La monarchia costituzionale britannica limita i poteri del re.
2314	d523a85	62	Souffle	Fiato		\N	2026-02-24 15:28:39.283066	0	2026-02-25 15:28:39.283066	{sport,corps,physiologie}	2.5	0	0	\N	\N	Capacità di inspirare ed espirare durante l'attività.	Breath	Atem	Fiainana	Mantieni il fiato durante lo sforzo massimo.
1084	d9b0ab1	28	Pollué	Inquinato		\N	2026-01-08 15:19:19.839136	1	2026-02-02 15:29:58.531175	{adjectif,italien,pollution}	2.6	1	1	\N	\N	\N	Polluted	Verschmutzt	maloto	\N
1085	c7d8afb	28	Durable	Sostenibile		\N	2026-01-08 15:19:19.863204	1	2026-02-02 15:31:55.921935	{adjectif,italien,développement}	2.6	1	1	\N	\N	\N	Sustainable	Nachhaltig	Maharitra	\N
1086	05d8457	28	Écologique	Ecologico		\N	2026-01-08 15:19:19.887175	1	2026-02-02 15:21:04.057755	{adjectif,italien,développement}	2.6	1	1	\N	\N	\N	Ecological	Ökologisch	tontolo iainana	\N
1087	da9db84	28	Naturel	Naturale		\N	2026-01-08 15:19:19.911662	1	2026-02-02 15:20:51.373541	{adjectif,italien,nature}	2.6	1	1	\N	\N	\N	Natural	Natürlich	Natural	\N
901	8163952	24	Baignoire	Vasca da bagno		\N	2025-12-10 15:39:06.285683	0	2025-12-11 15:39:06.285683	{maison,italien}	2.5	0	0	\N	\N	\N	Bath tub	Badewanne	koveta fandroana	\N
1451	0864fb8	37	glace	gelato		\N	2026-01-21 14:49:58.796792	0	2026-01-22 14:49:58.796792	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	ice-cream	Eiscreme	gilasy	\N
1452	62e1e1c	37	gâteau	torta		\N	2026-01-21 14:49:58.829639	0	2026-01-22 14:49:58.829639	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cake	Kuchen	mofomamy	\N
1453	ed8657a	37	chocolat	cioccolato		\N	2026-01-21 14:49:58.865479	0	2026-01-22 14:49:58.865479	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	chocolate	Schokolade	sôkôla	\N
114	16d4cec	9	Créer	Creare		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f195.svg	2025-12-03 13:33:24.007559	1	2025-12-08 06:58:05.861643	{verbe,italien,fréquent,travail}	2.6	1	1	\N	\N	\N	Create	Erstellen	MANANGANA	\N
2010	9f86c6f	60	Démocratie	Democrazia		\N	2026-02-24 13:12:40.592268	0	2026-02-25 13:12:40.592268	{politique,gouvernance}	2.5	0	0	\N	\N	Sistema politico in cui il potere appartiene al popolo attraverso elezioni e partecipazione.	Democracy	Demokratie	Demokrasia	La democrazia ateniese è considerata il modello antico di governo popolare.
2011	c0a118d	60	Dictature	Dittatura		\N	2026-02-24 13:12:47.119993	0	2026-02-25 13:12:47.119993	{politique,gouvernance}	2.5	0	0	\N	\N	Regime in cui il potere è concentrato nelle mani di un solo individuo o gruppo senza limiti.	Dictatorship	Diktatur	Diktatora	La dittatura di Mussolini in Italia durò dal 1922 al 1943.
2012	2b5638f	60	Tyrannie	Tirannia		\N	2026-02-24 13:12:54.715837	0	2026-02-25 13:12:54.715837	{politique,gouvernance}	2.5	0	0	\N	\N	Governo oppressivo e arbitrario esercitato da un tiranno.	Tyranny	Tyrannei	Fanjakana jadona	La tirannia di Pisistrato ad Atene fu un periodo di riforme ma anche di autoritarismo.
1093	f2dccce	28	Mesure	Misura		\N	2026-01-08 15:19:20.080626	1	2026-02-02 15:21:58.046994	{nom,italien,politique}	2.6	1	1	\N	\N	Valore quantitativo ottenuto con strumenti.	Measurement	Messung	Fandrefesana	La misura è stata ripetuta tre volte.
153	7fdaebd	9	Perdre	Perdere		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f622.svg	2025-12-03 13:33:24.807075	1	2025-12-08 07:01:28.350002	{verbe,italien,fréquent,action}	2.6	1	1	\N	\N	\N	LOSE	VERLIEREN	very	\N
1091	5522ccc	28	Ressource minière	Risorsa mineraria		\N	2026-01-08 15:19:20.031715	0	2026-02-01 15:39:41.127697	{expression,italien,nature}	2.3	0	0	\N	\N	\N	Mineral resource	Mineralische Ressource	Harena mineraly	\N
1092	757b653	28	Protection	Protezione		\N	2026-01-08 15:19:20.05626	0	2026-02-01 15:45:25.310313	{nom,italien,conservation}	2.3	0	0	\N	\N	\N	Protection	Schutz	MIARO	\N
709	06eb637	20	Servir	Servire		\N	2025-12-07 06:31:34.573211	2	2025-12-16 07:47:34.302689	{cuisine,italien}	2.7	6	2	\N	\N	\N	Serve	Aufschlag	manompo	\N
1240	0c27a65	31	Décharge	Discarica		\N	2026-01-11 15:36:49.884919	0	2026-01-12 15:36:49.884919	{nom,italien,déchets}	2.5	0	0	\N	\N	\N	Dump	Entsorgen	fanariam	\N
903	3e830f6	24	Toilettes	Gabinetto		\N	2025-12-10 15:39:06.320253	0	2025-12-11 15:39:06.320253	{maison,italien}	2.5	0	0	\N	\N	\N	Toilet	Toilette	trano fidiovana	\N
904	789b69c	24	Miroir	Specchio		\N	2025-12-10 15:39:06.336021	0	2025-12-11 15:39:06.336021	{maison,italien}	2.5	0	0	\N	\N	\N	Mirror	Spiegel	fitaratra	\N
969	d97661b	25	Éponge	Spugna		\N	2025-12-11 15:25:47.046698	0	2025-12-12 15:25:47.046698	{cuisine,italien}	2.5	0	0	\N	\N	\N	Sponge	Schwamm	sponjy	\N
1458	c7e72c3	37	légume	verdura		\N	2026-01-21 14:49:59.414778	0	2026-01-22 14:49:59.414778	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	vegetables	Gemüse	legioma	\N
1106	97b6bb5	28	Déforestation	Deforestazione		\N	2026-01-08 15:19:20.481108	1	2026-02-02 15:22:55.573359	{nom,italien,biodiversité}	2.6	1	1	\N	\N	\N	Deforestation	Abholzung	fandripahana ala	\N
1581	4ab5a3b	38	soie	seta		\N	2026-01-25 06:44:10.615767	0	2026-01-26 06:44:10.615767	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	silk	Seide	landy	\N
1096	4f25223	28	Accord	Accordo		\N	2026-01-08 15:19:20.147472	1	2026-02-02 15:24:29.152032	{nom,italien,politique}	2.6	1	1	\N	\N	\N	Agreement	Vereinbarung	fifanarahana	\N
1097	dfc23f3	28	conférence	conferenza		\N	2026-01-08 15:19:20.169728	1	2026-02-02 15:34:49.147012	{abbreviation,italien,politique}	2.6	1	1	\N	\N	\N	conference	Konferenz	NY FIHAONAMBE	\N
2013	b1be452	60	Gouvernement	Governo		\N	2026-02-24 13:13:02.729112	0	2026-02-25 13:13:02.729112	{politique,gouvernance}	2.5	0	0	\N	\N	Organo che esercita il potere esecutivo e amministra lo Stato.	Government	Regierung	Governemanta	Il governo provvisorio francese guidò la transizione dopo la Rivoluzione.
2014	e497344	60	Constitution	Costituzione		\N	2026-02-24 13:13:10.398254	0	2026-02-25 13:13:10.398254	{politique,droit}	2.5	0	0	\N	\N	Documento fondamentale che definisce i principi e le istituzioni dello Stato.	Constitution	Verfassung	Lalàm-panorenana	La Costituzione degli Stati Uniti del 1787 è la più antica ancora in vigore.
1094	11b9da8	28	Loi	Legge		\N	2026-01-08 15:19:20.102506	1	2026-02-02 15:35:05.194447	{nom,italien,politique}	2.6	1	1	\N	\N	Norma giuridica obbligatoria emanata dal potere legislativo.	Law	Gesetz	Lalàna	La legge salica escludeva le donne dalla successione al trono in Francia.
2015	91d8e3d	60	Réforme	Riforma		\N	2026-02-24 13:13:36.891583	0	2026-02-25 13:13:36.891583	{politique,société}	2.5	0	0	\N	\N	Cambiamento strutturale introdotto per migliorare istituzioni o società senza rottura violenta.	Reform	Reform	Fanavaozana	La riforma protestante di Lutero divise la cristianità europea.
2016	e03f269	60	Révolution	Rivoluzione		\N	2026-02-24 13:13:47.479217	0	2026-02-25 13:13:47.479217	{politique,histoire}	2.5	0	0	\N	\N	Cambiamento radicale e spesso violento delle strutture politiche e sociali.	Revolution	Revolution	Revolisiona	La Rivoluzione Industriale trasformò l'economia europea nel XIX secolo.
1582	d515fd8	38	bouton	bottone		\N	2026-01-25 06:44:10.641815	0	2026-01-26 06:44:10.641815	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	button	Taste	bokotra	\N
1583	a7d186e	38	poche	tasca		\N	2026-01-25 06:44:10.671246	0	2026-01-26 06:44:10.671246	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	pocket	Tasche	paosy	\N
1584	900087c	38	taille	taglia		\N	2026-01-25 06:44:10.701396	0	2026-01-26 06:44:10.701396	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	cut	schneiden	Hetezo	\N
1585	ca33d2b	38	étiquette	etichetta		\N	2026-01-25 06:44:10.725773	0	2026-01-26 06:44:10.725773	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	label	Etikett	etikety	\N
1586	6fbca31	38	kimono	kimono		\N	2026-01-25 06:44:10.745299	0	2026-01-26 06:44:10.745299	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	kimono	Kimono	kimono	\N
2017	a82804d	60	Coup d’État	Colpo di Stato		\N	2026-02-24 13:13:55.867791	0	2026-02-25 13:13:55.867791	{politique,conflit}	2.5	0	0	\N	\N	Azione improvvisa e illegale per rovesciare il governo in carica.	Coup d'État	Staatsstreich	Fanonganana fanjakana	Il colpo di Stato di Napoleone Bonaparte nel 1799 portò al Consolato.
1099	e19ffb8	28	Planète	Pianeta		\N	2026-01-08 15:19:20.292605	1	2026-02-02 15:32:13.447214	{nom,italien,global}	2.6	1	1	\N	\N	\N	Planet	Planet	Planeta	\N
1102	8f54980	28	Inondation	Inondazione		\N	2026-01-08 15:19:20.378259	1	2026-02-02 15:27:02.882242	{nom,italien,catastrophe}	2.6	1	1	\N	\N	\N	Flood	Flut	Safo-drano	\N
909	c21d6bb	24	Ordinateur	Computer		\N	2025-12-10 15:39:06.420036	0	2025-12-11 15:39:06.420036	{maison,italien}	2.5	0	0	\N	\N	\N	Computer	Computer	KAJIMIRINDRA	\N
911	023621f	24	Fenêtre	Finestra		\N	2025-12-10 15:39:06.458068	0	2025-12-11 15:39:06.458068	{maison,italien}	2.5	0	0	\N	\N	\N	Window	Fenster	Window	\N
913	f3648bf	24	Porte	Porta		\N	2025-12-10 15:39:06.493139	0	2025-12-11 15:39:06.493139	{maison,italien}	2.5	0	0	\N	\N	\N	Brings	Bringt	mitondra	\N
918	4cae898	24	Voiture	Auto		\N	2025-12-10 15:39:06.583015	0	2025-12-11 15:39:06.583015	{maison,italien}	2.5	0	0	\N	\N	\N	Car	Auto	Fiara	\N
2018	37a413b	60	Indépendance	Indipendenza		\N	2026-02-24 13:14:03.641731	0	2026-02-25 13:14:03.641731	{politique,histoire}	2.5	0	0	\N	\N	Condizione di uno Stato libero da dominio esterno.	Independence	Unabhängigkeit	Fahaleovantena	L'indipendenza delle colonie americane fu proclamata nel 1776.
2019	383dff1	60	Colonisation	Colonizzazione		\N	2026-02-24 13:14:11.235457	0	2026-02-25 13:14:11.235457	{histoire,politique}	2.5	0	0	\N	\N	Processo di conquista e insediamento di territori da parte di una potenza straniera.	Colonization	Kolonisation	Fanjanahantany	La colonizzazione europea dell'Africa culminò nella Conferenza di Berlino del 1884.
1103	e3d0574	28	Sécheresse	Siccità		\N	2026-01-08 15:19:20.401323	0	2026-02-01 15:41:20.758954	{nom,italien,catastrophe}	2.3	0	0	\N	\N	\N	Drought	Trockenheit	Hain-tany	\N
1127	73cfac2	28	Sensibilisation	Sensibilizzazione		\N	2026-01-08 15:19:21.049568	1	2026-02-02 15:26:26.629488	{nom,italien,communication}	2.6	1	1	\N	\N	\N	Raising awareness	Bewusstsein schaffen	Fampitandremana	\N
1104	89b2615	28	Incendie	Incendio		\N	2026-01-08 15:19:20.431748	1	2026-02-02 15:39:08.220621	{nom,italien,catastrophe}	2.4	1	1	\N	\N	\N	Fire	Feuer	AFO	\N
922	392ef6b	24	Arbre	Albero		\N	2025-12-10 15:39:06.658842	0	2025-12-11 15:39:06.658842	{maison,italien}	2.5	0	0	\N	\N	\N	Tree	Baum	HAZO	\N
1467	f18d65e	37	cerise	ciliegia		\N	2026-01-21 14:49:59.784181	0	2026-01-22 14:49:59.784181	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cherry	Kirsche	serizy	\N
1468	80d7f9e	37	ananas	ananas		\N	2026-01-21 14:49:59.813405	0	2026-01-22 14:49:59.813405	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	pineapple	Ananas	mananasy	\N
1596	b15ec9b	38	pantoufles	pantofole		\N	2026-01-25 06:44:10.959468	0	2026-01-26 06:44:10.959468	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	slippers	Hausschuhe	kapany	\N
1469	ea21847	37	melon	melone		\N	2026-01-21 14:49:59.848436	0	2026-01-22 14:49:59.848436	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	melon	Melone	voatavo	\N
1597	41f0c18	38	lacet	laccio		\N	2026-01-25 06:44:10.978273	0	2026-01-26 06:44:10.978273	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	lace	Spitze	dantelina	\N
1107	1ce4782	28	Reboiser	Riforestare		\N	2026-01-08 15:19:20.504455	0	2026-02-01 15:44:24.312461	{verbe,italien,action}	2.0999999999999996	0	0	\N	\N	\N	Reforest	Aufforsten	Famerenana ala	\N
1109	8825802	28	Pesticide	Pesticida		\N	2026-01-08 15:19:20.550497	0	2026-02-01 15:34:35.298496	{nom,italien,agriculture}	2.3	0	0	\N	\N	\N	Pesticide	Pestizid	fanafody famonoana bibikely	\N
2020	578e7eb	60	Décolonisation	Decolonizzazione		\N	2026-02-24 13:14:20.225001	0	2026-02-25 13:14:20.225001	{histoire,politique}	2.5	0	0	\N	\N	Processo di acquisizione dell'indipendenza da parte delle colonie.	Decolonization	Dekolonisation	Fanafahana tany	La decolonizzazione dell'India avvenne nel 1947 con Gandhi.
2021	48d2b47	60	Souveraineté	Sovranità		\N	2026-02-24 13:14:27.925137	0	2026-02-25 13:14:27.925137	{politique,droit}	2.5	0	0	\N	\N	Potere supremo e indipendente di uno Stato sul suo territorio.	Sovereignty	Souveränität	Fahaleovantenana	La sovranità nazionale è un principio chiave del diritto internazionale.
2022	1ff2aeb	60	Idéologie	Ideologia		\N	2026-02-24 13:14:37.215483	0	2026-02-25 13:14:37.215483	{politique,philosophie}	2.5	0	0	\N	\N	Sistema di idee e valori che orienta l'azione politica e sociale.	Ideology	Ideologie	Ideolojia	L'ideologia liberale promosse i diritti individuali durante le rivoluzioni borghesi.
2023	f4df4c5	60	Guerre	Guerra		\N	2026-02-24 13:14:45.070672	0	2026-02-25 13:14:45.070672	{conflit,histoire}	2.5	0	0	\N	\N	Conflitto armato tra Stati o gruppi per motivi territoriali, economici o ideologici.	War	Krieg	Ady	La guerra dei Trent'anni devastò l'Europa centrale nel XVII secolo.
2024	e65fabc	60	Conflit	Conflitto		\N	2026-02-24 13:14:52.062661	0	2026-02-25 13:14:52.062661	{conflit,histoire}	2.5	0	0	\N	\N	Scontro tra interessi o forze opposte che può sfociare in violenza.	Conflict	Konflikt	Fifandirana	Il conflitto tra papato e impero segnò il Medioevo.
2025	632c86d	60	Bataille	Battaglia		\N	2026-02-24 13:14:58.294513	0	2026-02-25 13:14:58.294513	{conflit,histoire}	2.5	0	0	\N	\N	Scontro armato tra eserciti in un luogo e tempo definito durante una guerra.	Battle	Schlacht	Ady	La battaglia di Waterloo segnò la sconfitta definitiva di Napoleone.
2026	9e96b1a	60	Armée	Esercito		\N	2026-02-24 13:15:04.310619	0	2026-02-25 13:15:04.310619	{conflit,politique}	2.5	0	0	\N	\N	Forza militare organizzata per la difesa o l'offensiva di uno Stato.	Army	Armee	Tafika	L'esercito rivoluzionario francese introdusse la leva di massa.
2027	5539a7e	60	Alliance	Alleanza		\N	2026-02-24 13:15:10.565095	0	2026-02-25 13:15:10.565095	{conflit,diplomatie}	2.5	0	0	\N	\N	Accordo tra Stati per cooperare in campo militare o politico.	Alliance	Allianz	Aliansa	L'alleanza della Triplice Intesa oppose la Germania nella Prima Guerra Mondiale.
2028	3a92383	60	Traité	Trattato		\N	2026-02-24 13:15:17.500115	0	2026-02-25 13:15:17.500115	{diplomatie,droit}	2.5	0	0	\N	\N	Accordo formale tra Stati per regolare relazioni internazionali.	Treaty	Vertrag	Fifanarahana	Il trattato di Versailles pose fine alla Prima Guerra Mondiale.
1111	0f2e0fb	28	Consommation	Consumo		\N	2026-01-08 15:19:20.599573	0	2026-02-01 15:40:37.662155	{nom,italien,économie}	2.3	0	0	\N	\N	\N	Consumption	Verbrauch	fihinanana	\N
1113	c313556	28	Consommer	Consumare		\N	2026-01-08 15:19:20.657952	1	2026-02-02 15:26:17.492279	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Consume	Verbrauchen	Aringano	\N
1114	e103ea0	28	Transport	Trasporto		\N	2026-01-08 15:19:20.68036	1	2026-02-02 15:22:32.767683	{nom,italien,transport}	2.6	1	1	\N	\N	\N	Transport	Transport	Transport	\N
1128	0afd34d	28	Volontaire	Volontario		\N	2026-01-08 15:19:21.075591	1	2026-02-02 15:22:21.877656	{nom/adjectif,italien,social}	2.6	1	1	\N	\N	\N	Voluntary	Freiwillig	An-tsitrapo	\N
1593	fa82e90	38	casque militaire	elmetto		\N	2026-01-25 06:44:10.908272	0	2026-01-26 06:44:10.908272	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	helmet	Helm	fiarovan-doha	\N
1594	ecc7df9	38	masque	maschera		\N	2026-01-25 06:44:10.923543	0	2026-01-26 06:44:10.923543	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	mask	Maske	hanafina	\N
1595	d7325ab	38	lunettes de protection	occhialini		\N	2026-01-25 06:44:10.94155	0	2026-01-26 06:44:10.94155	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	goggles	Brille	solomaso	\N
932	410cc64	24	Prise	Presa		\N	2025-12-10 15:39:06.837967	0	2025-12-11 15:39:06.837967	{maison,italien}	2.5	0	0	\N	\N	\N	Taken	Genommen	nalaina	\N
935	e9ea140	24	Climatiseur	Aria condizionata		\N	2025-12-10 15:39:06.890123	0	2025-12-11 15:39:06.890123	{maison,italien}	2.5	0	0	\N	\N	\N	Air conditioning	Klimaanlage	Klimatizasiona	\N
936	73e77e2	24	Seau	Secchio		\N	2025-12-10 15:39:06.912248	0	2025-12-11 15:39:06.912248	{maison,italien}	2.5	0	0	\N	\N	\N	Bucket	Eimer	siny	\N
1116	9ca4781	28	Bus	Autobus		\N	2026-01-08 15:19:20.732734	1	2026-02-02 15:22:41.675638	{nom,italien,transport}	2.6	1	1	\N	\N	\N	Bus	Bus	fiara fitateram-bahoaka	\N
1124	08cd38d	28	Santé	Salute		\N	2026-01-08 15:19:20.965999	1	2026-02-02 15:29:29.062708	{nom,italien,social}	2.6	1	1	\N	\N	Stato di completo benessere fisico, mentale e sociale.	Health	Gesundheit	Fahasalamana	Lo sport contribuisce alla salute generale.
1123	b09fb34	28	Qualité de l'air	Qualità dell'aria		\N	2026-01-08 15:19:20.940475	0	2026-02-01 15:34:48.068512	{expression,italien,air}	2.3	0	0	\N	\N	\N	Air quality	Luftqualität	kalitaon'ny rivotra	\N
1125	5160627	28	Communauté	Comunità		\N	2026-01-08 15:19:20.993469	0	2026-02-01 15:37:49.678145	{nom,italien,social}	2.3	0	0	\N	\N	\N	Community	Gemeinschaft	COMMUNITY	\N
1598	6c7b297	38	fermeture éclair	cerniera		\N	2026-01-25 06:44:10.995196	0	2026-01-26 06:44:10.995196	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	hinge	Scharnier	miankina	\N
1117	025650f	28	Train	Treno		\N	2026-01-08 15:19:20.760315	1	2026-02-02 15:36:06.441604	{nom,italien,transport}	2.6	1	1	\N	\N	\N	Train	Zug	fiaran-dalamby	\N
1118	59e8e02	28	Bicyclette	Bicicletta		\N	2026-01-08 15:19:20.787226	1	2026-02-02 15:35:46.86427	{nom,italien,transport}	2.6	1	1	\N	\N	\N	Bicycle	Fahrrad	Bisikileta	\N
1119	e8f8259	28	Transports publics	Trasporti pubblici		\N	2026-01-08 15:19:20.818583	0	2026-02-01 15:48:24.864412	{expression,italien,transport}	2.0999999999999996	0	0	\N	\N	\N	Public transport	Öffentliche Verkehrsmittel	Fiara fitateram-bahoaka	\N
2029	b68843c	60	Paix	Pace		\N	2026-02-24 13:15:24.2828	0	2026-02-25 13:15:24.2828	{conflit,diplomatie}	2.5	0	0	\N	\N	Condizione di assenza di guerra e di risoluzione pacifica dei conflitti.	Peace	Frieden	Fihavanana	La pace di Westfalia stabilì il principio di sovranità statale.
2030	72d113a	60	Invasion	Invasione		\N	2026-02-24 13:15:30.809315	0	2026-02-25 13:15:30.809315	{conflit,histoire}	2.5	0	0	\N	\N	Ingresso armato di truppe straniere in un territorio per conquistarlo.	Invasion	Invasion	Fanafihana	L'invasione della Normandia nel 1944 fu decisiva per la liberazione dell'Europa.
1121	ee74a8f	28	Ville	Città		\N	2026-01-08 15:19:20.87791	1	2026-02-02 15:26:04.003309	{nom,italien,urbain}	2.6	1	1	\N	\N	Agglomerato urbano con popolazione numerosa e funzioni amministrative e commerciali.	City	Stadt	Tanàna	Milano è una città industriale importante.
2316	4d11edc	62	Masse musculaire	Massa muscolare		\N	2026-02-24 15:28:52.461104	0	2026-02-25 15:28:52.461104	{sport,corps,physiologie}	2.5	0	0	\N	\N	Quantità totale di tessuto muscolare.	Muscle mass	Muskelmasse	Habe hozatra	La massa muscolare aumenta con la muscolazione.
1120	3afd9fa	28	Mobilité durable	Mobilità sostenibile		\N	2026-01-08 15:19:20.847321	1	2026-02-02 15:28:47.28541	{expression,italien,transport}	2.6	1	1	\N	\N	\N	Sustainable mobility	Nachhaltige Mobilität	Fihetseham-po maharitra	\N
1122	c93efad	28	Zone rurale	Zona rurale		\N	2026-01-08 15:19:20.907242	1	2026-02-02 15:29:02.250038	{expression,italien,géo}	2.6	1	1	\N	\N	\N	Rural area	Ländlicher Raum	Faritra ambanivohitra	\N
1126	93a8a94	28	Éducation	Educazione		\N	2026-01-08 15:19:21.020496	1	2026-02-02 15:31:49.654281	{nom,italien,social}	2.6	1	1	\N	\N	\N	Education	Ausbildung	FAMPIANARANA	\N
2317	c63994d	62	Graisse corporelle	Grasso corporeo		\N	2026-02-24 15:28:59.332232	0	2026-02-25 15:28:59.332232	{sport,corps,physiologie}	2.5	0	0	\N	\N	Quantità di tessuto adiposo presente nel corpo.	Body fat	Körperfett	Menaka vatana	Ridurre il grasso corporeo migliora le prestazioni.
2318	5a39c9e	62	Respiration	Respiro		\N	2026-02-24 15:29:08.537451	0	2026-02-25 15:29:08.537451	{sport,corps,physiologie}	2.5	0	0	\N	\N	Processo di scambio di ossigeno e anidride carbonica.	Breathing	Atem	Fisefana	Una respirazione controllata ottimizza lo sforzo.
2319	e313c9e	62	Épaules	Spalle		\N	2026-02-24 15:29:15.665653	0	2026-02-25 15:29:15.665653	{sport,corps,physiologie}	2.5	0	0	\N	\N	Parte superiore del tronco che collega braccia al corpo.	Shoulders	Schultern	Soroka	Le spalle si allenano con i sollevamenti laterali.
937	d60d0e3	24	Balayette	Scopa		\N	2025-12-10 15:39:06.938322	0	2025-12-11 15:39:06.938322	{maison,italien}	2.5	0	0	\N	\N	\N	Broom	Besen	kifafa	\N
1129	3964c8d	28	Projet	Progetto		\N	2026-01-08 15:19:21.099914	1	2026-02-02 15:28:32.903015	{nom,italien,plan}	2.6	1	1	\N	\N	\N	Project	Projekt	TETIKASA	\N
1130	843f417	28	Financement	Finanziamento		\N	2026-01-08 15:19:21.124594	1	2026-02-02 15:33:12.221201	{nom,italien,économie}	2.6	1	1	\N	\N	\N	Financing	Finanzierung	Famatsiam-bola	\N
938	a7e9ca6	24	Poubelle	Bidone		\N	2025-12-10 15:39:06.962776	0	2025-12-11 15:39:06.962776	{maison,italien}	2.5	0	0	\N	\N	\N	Bin	Bin	Bin	\N
939	96f18ca	24	Robinet	Rubinetto		\N	2025-12-10 15:39:06.980425	0	2025-12-11 15:39:06.980425	{maison,italien}	2.5	0	0	\N	\N	\N	Faucet	Wasserhahn	Faucet	\N
2320	2acd537	62	Nutrition	Nutrizione		\N	2026-02-24 15:29:22.699247	0	2026-02-25 15:29:22.699247	{sport,alimentation}	2.5	0	0	\N	\N	Insieme dei processi di assunzione e utilizzo degli alimenti.	Nutrition	Ernährung	Fanomezana otrikaina	Una buona nutrizione è alla base delle prestazioni.
1143	4888a1f	28	Débat	Dibattito		\N	2026-01-08 15:19:21.433654	1	2026-02-02 15:24:08.965674	{nom,italien,communication}	2.6	1	1	\N	\N	\N	Debate	Debatte	adihevitra	\N
992	48184fd	25	Grattoir de cuisine	Raschiatore		\N	2025-12-11 15:25:47.668602	0	2025-12-12 15:25:47.668602	{cuisine,italien}	2.5	0	0	\N	\N	\N	Scraper	Schaber	Scraper	\N
1484	d08b9bd	37	lapin	coniglio		\N	2026-01-21 14:50:00.320033	0	2026-01-22 14:50:00.320033	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	rabbit	Kaninchen	bitro	\N
1485	00bc0cf	37	thon	tonno		\N	2026-01-21 14:50:00.338558	0	2026-01-22 14:50:00.338558	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	tuna	Thunfisch	lamàtra	\N
1486	617e530	37	crevette	gambero		\N	2026-01-21 14:50:00.356343	0	2026-01-22 14:50:00.356343	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	shrimp	Garnele	makamba	\N
923	af5bf76	24	Terrasse	Terrazza		\N	2025-12-10 15:39:06.678462	0	2025-12-11 15:39:06.678462	{maison,italien}	2.5	0	0	\N	\N	\N	Terrace	Terrasse	lavarangana	\N
947	c7c5953	25	Papier d'aluminium	Carta stagnola		\N	2025-12-11 15:25:46.513504	0	2025-12-12 15:25:46.513504	{cuisine,italien}	2.5	0	0	\N	\N	\N	Foil paper	Folienpapier	Taratasy foil	\N
948	e2363b0	25	Tire-bouchon	Cavatappi		\N	2025-12-11 15:25:46.536552	0	2025-12-12 15:25:46.536552	{cuisine,italien}	2.5	0	0	\N	\N	\N	Corkscrew	Korkenzieher	Corkscrew	\N
949	54d4c01	25	Passoire	Colino		\N	2025-12-11 15:25:46.562988	0	2025-12-12 15:25:46.562988	{cuisine,italien}	2.5	0	0	\N	\N	\N	Colander	Sieb	Colander	\N
1131	ba14534	28	Taxe carbone	Tassa sul carbonio		\N	2026-01-08 15:19:21.148544	0	2026-02-01 15:44:41.98067	{expression,italien,politique}	2.3	0	0	\N	\N	\N	Carbon tax	Kohlenstoffsteuer	Hetra karbona	\N
1488	c6080ad	37	calmar	calamaro		\N	2026-01-21 14:50:00.477453	0	2026-01-22 14:50:00.477453	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	squid	Tintenfisch	kalamara	\N
1490	9e9210d	37	biscuit	biscotto		\N	2026-01-21 14:50:00.521768	0	2026-01-22 14:50:00.521768	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	cookie	Plätzchen	mofomamy	\N
1491	f970321	37	dessert	dolce		\N	2026-01-21 14:50:00.541866	0	2026-01-22 14:50:00.541866	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	\N	Sweet	Süß	hanitra	\N
1608	a8204c8	38	vernis à ongles	smalto		\N	2026-01-25 06:44:11.238599	0	2026-01-26 06:44:11.238599	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	enamel	Emaille	karazana verinia	\N
1609	88cb6ff	38	parfum	profumo		\N	2026-01-25 06:44:11.258697	0	2026-01-26 06:44:11.258697	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	perfume	Parfüm	ditin-kazo manitra	\N
2032	c4b1639	60	Rébellion	Ribellione		\N	2026-02-24 13:15:44.55205	0	2026-02-25 13:15:44.55205	{conflit,société}	2.5	0	0	\N	\N	Sollevamento armato contro l'autorità costituita.	Rebellion	Rebellion	Fikomiana	La ribellione dei Boxer in Cina oppose la penetrazione straniera.
1610	4c1c4a4	38	couronne	corona		\N	2026-01-25 06:44:11.27868	0	2026-01-26 06:44:11.27868	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	crown	Krone	satro-boninahitra	\N
1138	b12f6b5	28	Comportement	Comportamento		\N	2026-01-08 15:19:21.3168	1	2026-02-02 15:21:52.281996	{nom,italien,social}	2.6	1	1	\N	\N	\N	Behavior	Verhalten	FITONDRANTENA	\N
1139	af9b39f	28	Mode de vie	Stile di vita		\N	2026-01-08 15:19:21.343707	1	2026-02-02 15:20:58.099519	{expression,italien,social}	2.6	1	1	\N	\N	\N	Lifestyle	Lebensstil	fiainana	\N
1140	b5601d6	28	Participer	Partecipare		\N	2026-01-08 15:19:21.36847	1	2026-02-02 15:23:07.33883	{verbe,italien,action}	2.6	1	1	\N	\N	\N	Participate	Teilnehmen	Mandray anjara	\N
2033	d32d63f	60	Répression	Repressione		\N	2026-02-24 13:15:51.378704	0	2026-02-25 13:15:51.378704	{politique,conflit}	2.5	0	0	\N	\N	Azione violenta dello Stato per soffocare opposizioni o rivolte.	Repression	Unterdrückung	Fanerena	La repressione del 1848 in Europa portò alla fine delle rivoluzioni liberali.
2034	0ed3bc9	60	Conquête	Conquista		\N	2026-02-24 13:15:58.224748	0	2026-02-25 13:15:58.224748	{conflit,histoire}	2.5	0	0	\N	\N	Acquisizione di un territorio mediante forza militare.	Conquest	Eroberung	Fahazoana	La conquista normanna dell'Inghilterra avvenne nel 1066.
1134	9fe5a10	28	Innovation	Innovazione		\N	2026-01-08 15:19:21.22528	1	2026-02-02 15:25:01.103516	{nom,italien,tech}	2.6	1	1	\N	\N	Introduzione di novità che migliorano processi o prodotti.	Innovation	Innovation	Innovation	L'innovazione è il motore del progresso.
1135	406c5aa	28	Recherche	Ricerca		\N	2026-01-08 15:19:21.248798	1	2026-02-02 15:36:11.264693	{nom,italien,science}	2.6	1	1	\N	\N	Attività sistematica per scoprire nuove conoscenze.	Research	Forschung	Recherche	La ricerca è finanziata dallo Stato.
1136	0d5bf7d	28	Solution	Soluzione		\N	2026-01-08 15:19:21.27311	1	2026-02-02 15:24:01.540336	{nom,italien,action}	2.6	1	1	\N	\N	\N	Solution	Lösung	vahaolana	\N
1141	682d598	28	Soutenir	Sostenere		\N	2026-01-08 15:19:21.39281	0	2026-02-01 15:45:40.534566	{verbe,italien,action}	2.3	0	0	\N	\N	\N	Hold up	Halten	Hold up	\N
1611	d3fb8e1	38	chapeau de diplômé	tocco		\N	2026-01-25 06:44:11.302749	0	2026-01-26 06:44:11.302749	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	touch	berühren	mikasika	\N
1612	10f15d3	38	voile	velo		\N	2026-01-25 06:44:11.319949	0	2026-01-26 06:44:11.319949	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	veil	Schleier	VOALY	\N
712	e8036f2	20	Faire revenir	Soffriggere		\N	2025-12-07 06:31:34.635793	0	2025-12-11 08:38:44.856845	{cuisine,italien}	1.6999999999999997	0	0	\N	\N	\N	Fry	Braten	Fry	\N
1146	1140f29	28	Effet de serre	Effetto serra		\N	2026-01-08 15:19:21.514734	0	2026-02-01 15:35:22.53597	{nom,italien,environnement}	2.3	0	0	\N	\N	\N	Greenhouse effect	Treibhauseffekt	Vokatry ny trano maitso	\N
1147	2638b5f	28	Développement durable	Sviluppo sostenibile		\N	2026-01-08 15:19:21.542693	1	2026-02-02 15:20:20.839737	{expression,italien,environnement}	2.6	1	1	\N	\N	\N	Sustainable development	Nachhaltige Entwicklung	Fampandrosoana maharitra	\N
1145	6b4958a	28	Statistique	Statistica		\N	2026-01-08 15:19:21.482612	1	2026-02-02 15:35:52.030279	{nom,italien,data}	2.6	1	1	\N	\N	\N	Statistics	Statistiken	antontan'isa	\N
2036	d5207cc	60	Stratégie	Strategia		\N	2026-02-24 13:16:14.008184	0	2026-02-25 13:16:14.008184	{conflit,diplomatie}	2.5	0	0	\N	\N	Piano complessivo per raggiungere obiettivi militari o politici.	Strategy	Strategie	Strategia	La strategia della guerra lampo fu usata dalla Germania nel 1940.
2037	ab0d387	60	Diplomatie	Diplomazia		\N	2026-02-24 13:16:21.425638	0	2026-02-25 13:16:21.425638	{politique,diplomatie}	2.5	0	0	\N	\N	Arte di gestire le relazioni internazionali attraverso negoziati.	Diplomacy	Diplomatie	Diplomatie	La diplomazia di Bismarck unificò la Germania.
2321	1c8c687	62	Bien-être	Benessere		\N	2026-02-24 15:29:29.36073	0	2026-02-25 15:29:29.36073	{sport,alimentation}	2.5	0	0	\N	\N	Stato di equilibrio fisico e mentale.	Well-being	Wohlbefinden	Fahasalamana	Lo sport contribuisce al benessere generale.
1738	804f332	40	calme	calmo		\N	2026-01-31 15:19:21.741136	0	2026-02-01 15:19:21.741136	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	\N	calm	ruhig	tony	\N
2038	340f00c	60	Économie	Economia		\N	2026-02-24 13:16:28.100955	0	2026-02-25 13:16:28.100955	{économie,société}	2.5	0	0	\N	\N	Sistema di produzione, distribuzione e consumo di beni e servizi.	Economy	Wirtschaft	Ekonomia	L'economia mercantilista dominò l'Europa dal XVI al XVIII secolo.
2039	d2107f9	60	Commerce	Commercio		\N	2026-02-24 13:16:34.541655	0	2026-02-25 13:16:34.541655	{économie}	2.5	0	0	\N	\N	Scambio di beni e servizi tra individui, regioni o nazioni.	Trade	Handel	Varotra	Il commercio triangolare arricchì le potenze europee nel XVIII secolo.
2040	c212121	60	Industrie	Industria		\N	2026-02-24 13:16:40.825802	0	2026-02-25 13:16:40.825802	{économie}	2.5	0	0	\N	\N	Settore della produzione manifatturiera su larga scala.	Industry	Industrie	Indostria	L'industria tessile fu pioniera della Rivoluzione Industriale in Inghilterra.
1108	2590d70	28	Agriculture	Agricoltura		\N	2026-01-08 15:19:20.527303	1	2026-02-02 15:22:05.177351	{nom,italien,agriculture}	2.6	1	1	\N	\N	Coltivazione della terra per produrre alimenti e materie prime.	Agriculture	Landwirtschaft	Fambolena	L'agricoltura a rotazione triennale migliorò la produttività nel Medioevo.
2041	d33b1f6	60	Capitalisme	Capitalismo		\N	2026-02-24 13:16:55.071502	0	2026-02-25 13:16:55.071502	{économie,idéologie}	2.5	0	0	\N	\N	Sistema economico basato sulla proprietà privata dei mezzi di produzione e sul profitto.	Capitalism	Kapitalismus	Kapitalisma	Il capitalismo industriale emerse in Inghilterra nel XIX secolo.
2042	2342d1e	60	Socialisme	Socialismo		\N	2026-02-24 13:17:05.026577	0	2026-02-25 13:17:05.026577	{économie,idéologie}	2.5	0	0	\N	\N	Sistema che prevede la proprietà collettiva dei mezzi di produzione.	Socialism	Sozialismus	Sosialisma	Il socialismo utopico precedette quello scientifico di Marx.
2043	4d65792	60	Esclavage	Schiavitù		\N	2026-02-24 13:17:12.540915	0	2026-02-25 13:17:12.540915	{société,économie}	2.5	0	0	\N	\N	Condizione di chi è proprietà di un altro e privato della libertà.	Slavery	Sklaverei	Fanandevozana	Lo schiavismo transatlantico fu abolito nel XIX secolo.
2035	2e6cb07	60	Emploi	Occupazione		\N	2026-02-24 13:16:07.315894	0	2026-02-25 13:16:07.315894	{conflit,politique}	2.5	0	0	\N	\N	Situazione lavorativa della popolazione attiva.	Employment	Beschäftigung	Asa	L'occupazione giovanile è un obiettivo delle politiche europee.
1737	0eca898	40	Patient	paziente		\N	2026-01-31 15:19:21.705077	0	2026-02-01 15:19:21.705077	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che sa aspettare senza irritarsi.	Patient	Geduldig	Miaritra	È paziente con i bambini e spiega tutto con calma.
2322	c2912a3	62	Macronutriments	Macronutrienti		\N	2026-02-24 15:29:35.5537	0	2026-02-25 15:29:35.5537	{sport,alimentation}	2.5	0	0	\N	\N	Nutrienti necessari in grandi quantità: proteine, carboidrati, grassi.	Macronutrients	Makronährstoffe	Macronutriments	I macronutrienti forniscono l'energia principale.
2323	69212e4	62	Micronutriments	Micronutrienti		\N	2026-02-24 15:29:42.349636	0	2026-02-25 15:29:42.349636	{sport,alimentation}	2.5	0	0	\N	\N	Vitamine e minerali necessari in piccole quantità.	Micronutrients	Mikronährstoffe	Micronutriments	I micronutrienti supportano il metabolismo.
2044	edd5560	60	Classe sociale	Classe sociale		\N	2026-02-24 13:17:18.877737	0	2026-02-25 13:17:18.877737	{société,économie}	2.5	0	0	\N	\N	Gruppo di individui con simile posizione economica e status nella società.	Social class	Soziale Klasse	Kilasy sosialy	La classe sociale borghese emerse durante la Rivoluzione Industriale.
2045	7d516d9	60	Bourgeoisie	Borghesia		\N	2026-02-24 13:17:25.696055	0	2026-02-25 13:17:25.696055	{société,économie}	2.5	0	0	\N	\N	Classe media proprietaria di capitali e impegnata in attività commerciali.	Bourgeoisie	Bürgertum	Bourgeoisie	La borghesia guidò le rivoluzioni liberali del 1789 e 1848.
2046	1cadcbc	60	Prolétariat	Proletariato		\N	2026-02-24 13:17:32.507165	0	2026-02-25 13:17:32.507165	{société,économie}	2.5	0	0	\N	\N	Classe operaia priva di mezzi di produzione che vive del proprio lavoro salariato.	Proletariat	Proletariat	Proletaria	Il proletariato industriale fu protagonista delle lotte socialiste.
2047	dd55886	60	Migration	Migrazione		\N	2026-02-24 13:17:38.591479	0	2026-02-25 13:17:38.591479	{société,histoire}	2.5	0	0	\N	\N	Spostamento di popolazione da una regione a un'altra per motivi economici o politici.	Migration	Migration	Fifindrana	La migrazione verso le Americhe nel XIX secolo fu massiccia.
1157	4657f9b	30	Avaler	Mandare giù		\N	2026-01-09 16:10:10.979914	0	2026-01-10 16:10:10.979914	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Swallow	Schlucken	sidintsidina	\N
1158	fcbcc36	30	Mettre de côté	Mettere via		\N	2026-01-09 16:10:10.99801	0	2026-01-10 16:10:10.99801	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Put away	Weglegen	Esory	\N
1159	d5b4fb5	30	Se mettre en couple	Mettersi insieme		\N	2026-01-09 16:10:11.015587	0	2026-01-10 16:10:11.015587	{verbe,italien,relation}	2.5	0	0	\N	\N	\N	Get together	Kommt zusammen	Hiaraka	\N
1531	0446b6b	38	chaussettes	calzini		\N	2026-01-25 06:44:09.465245	0	2026-01-26 06:44:09.465245	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	socks	Socken	ba kiraro	\N
2048	c7c7691	60	Urbanisation	Urbanizzazione		\N	2026-02-24 13:17:45.059557	0	2026-02-25 13:17:45.059557	{société,économie}	2.5	0	0	\N	\N	Processo di crescita delle città e concentrazione della popolazione urbana.	Urbanization	Urbanisierung	Fanamboarana tanàna	L'urbanizzazione accelerò durante la Rivoluzione Industriale.
2049	ab81c34	60	Crise	Crisi		\N	2026-02-24 13:17:51.631451	0	2026-02-25 13:17:51.631451	{économie,société}	2.5	0	0	\N	\N	Momento di grave difficoltà economica, politica o sociale.	Crisis	Krise	Krizy	La crisi del 1929 scatenò la Grande Depressione.
2051	2456a73	60	Modernisation	Modernizzazione		\N	2026-02-24 13:18:03.797394	0	2026-02-25 13:18:03.797394	{société,économie}	2.5	0	0	\N	\N	Adattamento della società a modelli moderni di organizzazione e tecnologia.	Modernization	Modernisierung	Fanavaozana	La modernizzazione del Giappone nell'era Meiji fu rapida.
2052	30a9d2b	60	Humanisme	Umanesimo		\N	2026-02-24 13:18:09.719198	0	2026-02-25 13:18:09.719198	{culture,philosophie}	2.5	0	0	\N	\N	Corrente di pensiero che pone l'uomo al centro della riflessione filosofica e artistica.	Humanism	Humanismus	Humanisma	L'umanesimo rinascimentale valorizzò lo studio dei classici latini e greci.
2053	2cf8d05	60	Lumières	Illuminismo		\N	2026-02-24 13:18:15.809056	0	2026-02-25 13:18:15.809056	{philosophie,histoire}	2.5	0	0	\N	\N	Movimento intellettuale del XVIII secolo basato sulla ragione e sui diritti naturali.	Enlightenment	Aufklärung	Fanazavana	L'Illuminismo influenzò le rivoluzioni americana e francese.
2054	9f632bb	60	Nationalisme	Nazionalismo		\N	2026-02-24 13:18:22.533434	0	2026-02-25 13:18:22.533434	{idéologie,politique}	2.5	0	0	\N	\N	Ideologia che esalta l'identità e gli interessi della nazione sopra tutto.	Nationalism	Nationalismus	Nazionalisma	Il nazionalismo tedesco portò all'unificazione del 1871.
2324	66feb84	62	Besoins	Fabbisogno		\N	2026-02-24 15:29:49.241481	0	2026-02-25 15:29:49.241481	{sport,alimentation}	2.5	0	0	\N	\N	Quantità di nutrienti necessari all'organismo.	Requirements	Bedarf	Filana	I bisogni energetici aumentano con l'allenamento.
2550	76494dc	65	argile	argilla		https://upload.wikimedia.org/wikipedia/commons/6/6c/Mexican_clay_skulls.jpg	2026-03-30 16:23:29.286834	0	2026-03-31 16:23:29.286834	{sédimentologie,minéralogie}	2.5	0	0	\N	\N	Deposito sedimentario costituito da particelle finissime che diventano plastiche se idratate.	clay	Ton	tanimanga	L'argilla umida è impermeabile all'acqua.
2551	e00cd32	65	sable	sabbia		https://upload.wikimedia.org/wikipedia/commons/6/6e/00065_sand_collage.jpg	2026-03-30 16:23:35.550135	0	2026-03-31 16:23:35.550135	{sédimentologie,matériaux}	2.5	0	0	\N	\N	Granuli clastici di origine minerale compresi tra dimensioni fini e ghiaiose, tipici delle coste.	sand	Sand	fasika	La sabbia bianca della spiaggia deriva da frammenti di coralli.
1166	2d2f876	30	Grossir	Mettere su		\N	2026-01-09 16:10:11.154231	0	2026-01-10 16:10:11.154231	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Put up	Aufstellen	Miaritra	\N
1580	aec3501	38	cuir	cuoio		\N	2026-01-25 06:44:10.585404	0	2026-01-26 06:44:10.585404	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	\N	leather	Leder	hoditra	\N
1691	9244bcc	39	accident	incidente		\N	2026-01-30 16:23:23.613932	0	2026-01-31 16:23:23.613932	{nom,italien,transport}	2.5	0	0	\N	\N	\N	accident	Unfall	Nitombo ny	\N
1699	8e5b331	39	ascenseur	ascensore		\N	2026-01-30 16:23:23.814318	0	2026-01-31 16:23:23.814318	{nom,italien,transport}	2.5	0	0	\N	\N	\N	elevator	Aufzug	ascenseur	\N
2552	a4e058c	65	sol	suolo		https://upload.wikimedia.org/wikipedia/commons/5/55/Fischerkirche%2C_Born_a._Dar%C3%9F%2C_SW_view.jpg	2026-03-30 16:23:43.587168	0	2026-03-31 16:23:43.587168	{pédologie,surface}	2.5	0	0	\N	\N	Strato superficiale alterato della superficie terrestre, in cui prospera la vegetazione.	soil	Boden	nofon-tany	Il suolo vulcanico è particolarmente fertile per l'agricoltura.
2055	198cbcd	60	Libéralisme	Liberalismo		\N	2026-02-24 13:18:28.531367	0	2026-02-25 13:18:28.531367	{idéologie,politique}	2.5	0	0	\N	\N	Dottrina che difende la libertà individuale, il libero mercato e i diritti civili.	Liberalism	Liberalismus	Liberalisma	Il liberalismo ispirò la Costituzione americana del 1787.
2056	f683063	60	Communisme	Comunismo		\N	2026-02-24 13:18:34.515475	0	2026-02-25 13:18:34.515475	{idéologie,économie}	2.5	0	0	\N	\N	Ideologia che prevede l'abolizione della proprietà privata e la società senza classi.	Communism	Kommunismus	Kominisma	Il comunismo fu teorizzato da Marx e Engels nel Manifesto del 1848.
2057	5fd86ad	60	Fascisme	Fascismo		\N	2026-02-24 13:18:41.158401	0	2026-02-25 13:18:41.158401	{idéologie,politique}	2.5	0	0	\N	\N	Ideologia totalitaria nazionalista e autoritaria del XX secolo.	Fascism	Faschismus	Fasizma	Il fascismo italiano di Mussolini salì al potere nel 1922.
2058	778df9f	60	Totalitarisme	Totalitarismo		\N	2026-02-24 13:18:47.803191	0	2026-02-25 13:18:47.803191	{idéologie,politique}	2.5	0	0	\N	\N	Regime che controlla totalmente la società attraverso propaganda e repressione.	Totalitarianism	Totalitarismus	Totalitarisma	Il totalitarismo staliniano in URSS eliminò ogni opposizione.
2059	afc5b5d	60	Réforme religieuse	Riforma religiosa		\N	2026-02-24 13:18:54.499069	0	2026-02-25 13:18:54.499069	{culture,histoire}	2.5	0	0	\N	\N	Movimento di rinnovamento interno o scissione all'interno di una religione.	Religious reform	Religiöse Reform	Fanavaozana ara-pivavahana	La Riforma religiosa protestante di Lutero iniziò nel 1517.
2060	708fa31	60	Renaissance	Rinascimento		\N	2026-02-24 13:19:00.416693	0	2026-02-25 13:19:00.416693	{culture,histoire}	2.5	0	0	\N	\N	Periodo di rinascita culturale, artistica e scientifica in Europa tra XIV e XVI secolo.	Renaissance	Renaissance	Renesansy	Il Rinascimento fiorentino produsse opere di Leonardo e Michelangelo.
1173	fadf82d	30	Pardonner	Passare sopra		\N	2026-01-09 16:10:11.293874	0	2026-01-10 16:10:11.293874	{verbe,italien,émotion}	2.5	0	0	\N	\N	\N	Pass over	Übergehen	Mandalo	\N
1174	54d64bc	30	Se moquer de	Prendere in giro		\N	2026-01-09 16:10:11.313466	0	2026-01-10 16:10:11.313466	{verbe,italien,relation}	2.5	0	0	\N	\N	\N	Make fun of	Machen Sie sich lustig	Maneso	\N
1175	deeabc5	30	Rester dehors	Rimanere fuori		\N	2026-01-09 16:10:11.333847	0	2026-01-10 16:10:11.333847	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Stay out	Bleiben Sie draußen	Mijanòna any ivelany	\N
1185	e3556a9	30	Entrer	Entrare dentro		\N	2026-01-09 16:10:11.528959	0	2026-01-10 16:10:11.528959	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go inside	Geh hinein	Midira ao anatiny	\N
2061	0bee021	60	Industrialisation	Industrializzazione		\N	2026-02-24 13:19:06.377902	0	2026-02-25 13:19:06.377902	{économie,histoire}	2.5	0	0	\N	\N	Processo di passaggio da economia agraria a economia basata sull'industria.	Industrialization	Industrialisierung	Fanamboarana indostrialy	L'industrializzazione inglese iniziò con la macchina a vapore.
2062	f0e6272	60	Impérialisme	Imperialismo		\N	2026-02-24 13:19:12.82775	0	2026-02-25 13:19:12.82775	{politique,histoire}	2.5	0	0	\N	\N	Politica di espansione coloniale e dominio economico di una nazione su altre.	Imperialism	Imperialismus	Imperialisma	L'imperialismo europeo culminò nella spartizione dell'Africa.
2344	4d0bb73	62	Autodiscipline	Autodisciplina		\N	2026-02-24 15:32:21.097984	0	2026-02-25 15:32:21.097984	{sport,mental}	2.5	0	0	\N	\N	Capacità di seguire regole senza supervisione.	Self-discipline	Selbstdisziplin	Fifehezana tena	L'autodisciplina è la base del successo.
2063	a9bca1f	60	Patriotisme	Patriottismo		\N	2026-02-24 13:19:18.927197	0	2026-02-25 13:19:18.927197	{idéologie,société}	2.5	0	0	\N	\N	Sentimento di amore e devozione verso la propria patria.	Patriotism	Patriotismus	Patriotisma	Il patriottismo italiano alimentò il Risorgimento.
2064	0a2dcb1	60	Propagande	Propaganda		\N	2026-02-24 13:19:24.903322	0	2026-02-25 13:19:24.903322	{politique,société}	2.5	0	0	\N	\N	Diffusione sistematica di informazioni per influenzare l'opinione pubblica.	Propaganda	Propaganda	Propaganda	La propaganda nazista usò i media per promuovere l'ideologia hitleriana.
2065	096e2c8	60	Droits	Diritti		\N	2026-02-24 13:19:31.201785	0	2026-02-25 13:19:31.201785	{politique,droit}	2.5	0	0	\N	\N	Facoltà o prerogative riconosciute agli individui dalla legge o dai principi naturali.	Rights	Rechte	Zon'olombelona	I diritti naturali furono affermati nella Dichiarazione del 1789.
2066	4522da8	60	Citoyenneté	Cittadinanza		\N	2026-02-24 13:19:38.07251	0	2026-02-25 13:19:38.07251	{politique,société}	2.5	0	0	\N	\N	Status di membro a pieno titolo di uno Stato con diritti e doveri.	Citizenship	Staatsbürgerschaft	Zom-pirenena	La cittadinanza romana fu estesa a tutti gli abitanti dell'Impero nel 212 d.C.
2067	6f3031c	60	Cause	Causa		\N	2026-02-24 13:19:45.056009	0	2026-02-25 13:19:45.056009	{histoire,méthodologie}	2.5	0	0	\N	\N	Fattore o evento che provoca un determinato effetto storico.	Cause	Ursache	Antony	La causa principale della Rivoluzione Francese fu la crisi finanziaria.
2068	2a3849d	60	Conséquence	Conseguenza		\N	2026-02-24 13:19:51.737923	0	2026-02-25 13:19:51.737923	{histoire,méthodologie}	2.5	0	0	\N	\N	Effetto o risultato derivante da un evento o azione storica.	Consequence	Folge	Vokatra	La conseguenza della sconfitta di Waterloo fu l'esilio di Napoleone.
1182	c38824d	30	Descendre	Andare giù		\N	2026-01-09 16:10:11.4695	0	2026-01-10 16:10:11.4695	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Go down	Gehen	Midina	\N
1183	7e563d8	30	Courir en haut	Correre su		\N	2026-01-09 16:10:11.488507	0	2026-01-10 16:10:11.488507	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Run up	Lauf hoch	Mihazakazaha	\N
1184	47f3ba0	30	Sortir	Uscire fuori		\N	2026-01-09 16:10:11.510855	0	2026-01-10 16:10:11.510855	{verbe,italien,mouvement}	2.5	0	0	\N	\N	\N	Walk out	Hinausgehen	Hivoaka	\N
2069	678c1a6	60	Impact	Impatto		\N	2026-02-24 13:19:58.533096	0	2026-02-25 13:19:58.533096	{histoire,méthodologie}	2.5	0	0	\N	\N	Effetto profondo e duraturo prodotto da un evento o fenomeno.	Impact	Auswirkung	Fiantraikany	L'impatto della stampa di Gutenberg rivoluzionò la diffusione della conoscenza.
2070	007e355	60	Influence	Influenza		\N	2026-02-24 13:20:04.640579	0	2026-02-25 13:20:04.640579	{histoire,culture}	2.5	0	0	\N	\N	Azione che modifica idee, comportamenti o eventi in modo indiretto.	Influence	Einfluss	Fiantraikany	L'influenza della cultura greca è visibile nel Rinascimento.
2071	d3f1eae	60	Origine	Origine		\N	2026-02-24 13:20:11.487913	0	2026-02-25 13:20:11.487913	{histoire,méthodologie}	2.5	0	0	\N	\N	Punto di partenza o causa iniziale di un fenomeno storico.	Origin	Ursprung	Niaviana	L'origine della democrazia si trova nell'antica Atene.
2072	315bd1b	60	Évolution	Evoluzione		\N	2026-02-24 13:20:17.696132	0	2026-02-25 13:20:17.696132	{histoire,méthodologie}	2.5	0	0	\N	\N	Processo di trasformazione graduale di istituzioni o società nel tempo.	Evolution	Evolution	Evolisiona	L'evoluzione del sistema feudale portò alla nascita degli Stati moderni.
2073	fef78d8	60	Transformation	Trasformazione		\N	2026-02-24 13:20:24.363406	0	2026-02-25 13:20:24.363406	{histoire,société}	2.5	0	0	\N	\N	Cambiamento radicale nella struttura di una società o istituzione.	Transformation	Transformation	Fiovana	La trasformazione dell'economia agraria in industriale cambiò la società.
2074	1f13318	60	Continuité	Continuità		\N	2026-02-24 13:20:30.555887	0	2026-02-25 13:20:30.555887	{histoire,méthodologie}	2.5	0	0	\N	\N	Persistenza di elementi storici attraverso periodi diversi.	Continuity	Kontinuität	Faharetana	La continuità del diritto romano si mantenne nel Medioevo.
2075	d37a641	60	Rupture	Rottura		\N	2026-02-24 13:20:36.939103	0	2026-02-25 13:20:36.939103	{histoire,méthodologie}	2.5	0	0	\N	\N	Interruzione improvvisa di un ordine precedente.	Break	Bruch	Fisarahana	La Rottura del 1789 segnò la fine dell'Ancien Régime in Francia.
2076	fcae5bf	60	Comparaison	Confronto		\N	2026-02-24 13:20:43.771586	0	2026-02-25 13:20:43.771586	{histoire,méthodologie}	2.5	0	0	\N	\N	Analisi parallela di fenomeni storici per evidenziare somiglianze e differenze.	Comparison	Vergleich	Fampitahana	Il confronto tra Rivoluzione Francese e Russa rivela analogie ideologiche.
2078	84412ea	60	Argument	Argomento		\N	2026-02-24 13:20:56.520154	0	2026-02-25 13:20:56.520154	{histoire,méthodologie}	2.5	0	0	\N	\N	Ragionamento logico a sostegno di una tesi storica.	Argument	Argument	Laza	L'argomento economico spiega l'espansione coloniale europea.
2079	2d2a6ab	60	Preuve	Prova		\N	2026-02-24 13:21:03.055197	0	2026-02-25 13:21:03.055197	{histoire,méthodologie}	2.5	0	0	\N	\N	Elemento fattuale o documentale che conferma una tesi storica.	Proof	Beweis	Porofon	Le prove archeologiche confermano la distruzione di Pompei nel 79 d.C.
1189	df545f4	30	Sortir quelqu'un	Portare fuori		\N	2026-01-09 16:10:11.606673	0	2026-01-10 16:10:11.606673	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Take out	Mitnahme	Mamoaka	\N
1709	5cfdb50	39	voilier	barca a vela		\N	2026-01-30 16:23:35.231986	0	2026-01-31 16:23:35.231986	{nom,italien,transport}	2.5	0	0	\N	\N	\N	sailboat	Segelboot	sambo	\N
2080	212d988	60	Objectivité	Oggettività		\N	2026-02-24 13:21:09.604151	0	2026-02-25 13:21:09.604151	{histoire,méthodologie}	2.5	0	0	\N	\N	Approccio imparziale nello studio della storia basato su fatti verificabili.	Objectivity	Objektivität	Objectivité	L'oggettività dello storico richiede l'uso critico delle fonti.
2081	db6d312	60	Subjectivité	Soggettività		\N	2026-02-24 13:21:16.018787	0	2026-02-25 13:21:16.018787	{histoire,méthodologie}	2.5	0	0	\N	\N	Influenza delle opinioni personali nell'interpretazione degli eventi storici.	Subjectivity	Subjektivität	Subjectivité	La soggettività è inevitabile nelle memorie dei protagonisti storici.
2082	dd28187	60	Préhistoire	Preistoria		\N	2026-02-24 13:21:22.605359	0	2026-02-25 13:21:22.605359	{histoire,temps}	2.5	0	0	\N	\N	Periodo della storia umana prima dell'invenzione della scrittura.	Prehistory	Vorgeschichte	Taloha ny tantara	La Preistoria termina con l'invenzione della scrittura intorno al 3500 a.C.
2083	267d4d5	60	Antiquité	Antichità		\N	2026-02-24 13:21:29.202619	0	2026-02-25 13:21:29.202619	{histoire,temps}	2.5	0	0	\N	\N	Epoca storica delle antiche civiltà greca, romana e orientali.	Antiquity	Antike	Antenatenany	L'Antichità classica influì profondamente sulla cultura europea.
2084	3275916	60	Moyen Âge	Medioevo		\N	2026-02-24 13:21:35.729816	0	2026-02-25 13:21:35.729816	{histoire,temps}	2.5	0	0	\N	\N	Periodo storico europeo tra la caduta dell'Impero Romano e il Rinascimento.	Middle Ages	Mittelalter	Andro Antenatenany	Il Medioevo vide la nascita delle università e del feudalesimo.
2085	750ab88	60	Révolution industrielle	Rivoluzione industriale		\N	2026-02-24 13:21:41.619949	0	2026-02-25 13:21:41.619949	{économie,histoire}	2.5	0	0	\N	\N	Trasformazione economica e sociale dovuta all'introduzione delle macchine e della produzione di massa.	Industrial Revolution	Industrielle Revolution	Revolisiona indostrialy	La Rivoluzione industriale iniziò in Inghilterra alla fine del XVIII secolo.
2086	f9b0716	60	Guerres mondiales	Guerre mondiali		\N	2026-02-24 13:21:47.533798	0	2026-02-25 13:21:47.533798	{conflit,histoire}	2.5	0	0	\N	\N	I due conflitti globali del XX secolo (1914-1918 e 1939-1945).	World Wars	Weltkriege	Ady eran-tany	Le Guerre mondiali causarono milioni di morti e ridisegnarono la mappa del mondo.
2087	d5cfb8f	60	Guerre froide	Guerra fredda		\N	2026-02-24 13:21:54.142418	0	2026-02-25 13:21:54.142418	{conflit,histoire}	2.5	0	0	\N	\N	Confronto ideologico e geopolitico tra USA e URSS senza scontri diretti.	Cold War	Kalte Krieg	Ady mangatsiaka	La Guerra fredda durò dal 1947 al 1991 e divise l'Europa in blocchi.
2088	316ecc0	60	Déclaration	Dichiarazione		\N	2026-02-24 13:22:00.344802	0	2026-02-25 13:22:00.344802	{politique,droit}	2.5	0	0	\N	\N	Documento formale che proclama principi o diritti.	Declaration	Erklärung	Fanambarana	La Dichiarazione d'Indipendenza americana del 1776 segnò la nascita degli USA.
2089	c3602f8	60	Droits de l’homme	Diritti umani		\N	2026-02-24 13:22:07.092085	0	2026-02-25 13:22:07.092085	{politique,droit}	2.5	0	0	\N	\N	Diritti fondamentali inerenti a ogni essere umano.	Human rights	Menschenrechte	Zon'olombelona	La Dichiarazione Universale dei Diritti Umani fu adottata nel 1948.
1619	7804342	39	bus / autobus	autobus		\N	2026-01-30 16:23:21.893656	0	2026-01-31 16:23:21.893656	{nom,italien,transport}	2.5	0	0	\N	\N	\N	bus	Bus	fiara fitateram-bahoaka	\N
777	f924cf9	22	État	Stato		\N	2025-12-08 16:20:07.600362	0	2025-12-09 16:20:07.600362	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	Organizzazione politica sovrana che esercita autorità su un territorio e una popolazione.	State	Staat	Fanjakana	Lo Stato moderno emerse dopo il Trattato di Westfalia nel 1648.
1728	5747f43	40	Aimable	amabile		\N	2026-01-31 15:19:21.445599	0	2026-02-01 15:19:21.445599	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona cordiale e piacevole che rende facile instaurare rapporti.	Amiable	Liebenswürdig	Malemy fanahy	La sua natura amabile conquista tutti al primo incontro.
1620	d87e0e4	39	train	treno		\N	2026-01-30 16:23:21.914692	0	2026-01-31 16:23:21.914692	{nom,italien,transport}	2.5	0	0	\N	\N	\N	train	Zug	fiaran-dalamby	\N
1724	bc72423	39	vitesse	marcia		\N	2026-01-31 14:36:01.175645	0	2026-02-01 14:36:01.175645	{}	2.5	0	0	\N	\N	\N	gear	Gang	fitaovana	\N
1726	840def2	39	priorité	precedenza		\N	2026-01-31 14:42:05.537026	0	2026-02-01 14:42:05.537026	{}	2.5	0	0	\N	\N	\N	precedence	Vorrang	tiana	\N
1727	eff1907	40	gentil	gentile		\N	2026-01-31 15:19:21.429475	0	2026-02-01 15:19:21.429475	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	\N	Kind	Art	AHOANA	\N
1729	8c241ae	40	sympathique	simpatico		\N	2026-01-31 15:19:21.460717	0	2026-02-01 15:19:21.460717	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	\N	friendly	freundlich	sariaka	\N
780	a94f1e7	22	Mettere	Messo		\N	2025-12-08 16:20:07.667575	0	2025-12-09 16:20:07.667575	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Put in order	Ordnen Sie	Ataovy amin'ny filaharana	\N
781	1a40a93	22	Perdere	Perso		\N	2025-12-08 16:20:07.683699	0	2025-12-09 16:20:07.683699	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Lost	Verloren	VERY	\N
806	db534cd	22	Morire	Morto		\N	2025-12-08 16:20:08.16882	0	2025-12-09 16:20:08.16882	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Died	Gestorben	MATY	\N
1210	8832c87	31	Extinction	Estinzione		\N	2026-01-11 15:36:49.123639	0	2026-01-12 15:36:49.123639	{nom,italien,biodiversité}	2.5	0	0	\N	\N	\N	Extinction	Aussterben	lany tamingana	\N
1211	1431e47	31	Vie sauvage	Vita selvatica		\N	2026-01-11 15:36:49.145966	0	2026-01-12 15:36:49.145966	{expression,italien,nature}	2.5	0	0	\N	\N	\N	Wild life	Wildes Leben	Fiainana bibidia	\N
2090	8d4ed41	60	Patrimoine	Patrimonio		\N	2026-02-24 13:22:13.946862	0	2026-02-25 13:22:13.946862	{culture,histoire}	2.5	0	0	\N	\N	Insieme di beni culturali, artistici e storici da preservare.	Heritage	Erbe	Lovantsoa	Il patrimonio dell'umanità include siti UNESCO come le piramidi.
2345	d6032af	62	Ténacité	Tenacia		\N	2026-02-24 15:32:27.107264	0	2026-02-25 15:32:27.107264	{sport,mental}	2.5	0	0	\N	\N	Capacità di non arrendersi.	Tenacity	Zähigkeit	Faharetana	La tenacia ha portato alla vittoria finale.
2346	781f8f7	62	Courage	Coraggio		\N	2026-02-24 15:32:33.609125	0	2026-02-25 15:32:33.609125	{sport,mental}	2.5	0	0	\N	\N	Forza d'animo di affrontare difficoltà.	Courage	Mut	Mahery fo	Il coraggio lo ha spinto a continuare.
1217	bd2e7b0	31	Cyclone	Ciclone		\N	2026-01-11 15:36:49.261897	0	2026-01-12 15:36:49.261897	{nom,italien,catastrophe}	2.5	0	0	\N	\N	\N	Cyclone	Zyklon	rivo-doza	\N
1218	fc25625	31	Tremblement de terre	Terremoto		\N	2026-01-11 15:36:49.287896	0	2026-01-12 15:36:49.287896	{nom,italien,catastrophe}	2.5	0	0	\N	\N	\N	Earthquake	Erdbeben	Horohorontany	\N
1622	c803661	39	vélo	bicicletta		\N	2026-01-30 16:23:21.968768	0	2026-01-31 16:23:21.968768	{nom,italien,transport}	2.5	0	0	\N	\N	\N	bicycle	Fahrrad	bisikileta	\N
1623	b4762a2	39	moto	moto		\N	2026-01-30 16:23:21.992887	0	2026-01-31 16:23:21.992887	{nom,italien,transport}	2.5	0	0	\N	\N	\N	motorcycle	Motorrad	Motorcycle	\N
1624	5ce8133	39	scooter	motorino		\N	2026-01-30 16:23:22.013831	0	2026-01-31 16:23:22.013831	{nom,italien,transport}	2.5	0	0	\N	\N	\N	moped	Moped	moped	\N
1625	ba6e3e0	39	taxi	taxi		\N	2026-01-30 16:23:22.102966	0	2026-01-31 16:23:22.102966	{nom,italien,transport}	2.5	0	0	\N	\N	\N	Taxi	Taxi	Taxi	\N
1725	5dece6e	39	panne	guasto		\N	2026-01-31 14:39:22.591746	0	2026-02-01 14:39:22.591746	{}	2.5	0	0	\N	\N	\N	broken down	kaputt	tapaka	\N
786	cfadd33	22	Spendere	Speso		\N	2025-12-08 16:20:07.786478	0	2025-12-09 16:20:07.786478	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Spent	Ausgegeben	lany Teny	\N
788	1a7d862	22	Succedere	Successo		\N	2025-12-08 16:20:07.830794	0	2025-12-09 16:20:07.830794	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Success	Erfolg	FETY	\N
789	b112650	22	Giungere	Giunto		\N	2025-12-08 16:20:07.84977	0	2025-12-09 16:20:07.84977	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Arrived	Angekommen	TONGA	\N
790	5afeffb	22	Leggere	Letto		\N	2025-12-08 16:20:07.870102	0	2025-12-09 16:20:07.870102	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Bed	Bett	fandriana	\N
816	eb57ede	22	Cogliere	Colto		\N	2025-12-08 16:20:08.376785	0	2025-12-09 16:20:08.376785	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Cultured	Kultiviert	Kolontsaina	\N
817	998a37e	22	Porre	Posto		\N	2025-12-08 16:20:08.395245	0	2025-12-09 16:20:08.395245	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Place	Ort	Place	\N
792	e4ef900	22	Fait	Fatto		\N	2025-12-08 16:20:07.908798	0	2025-12-09 16:20:07.908798	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	Elemento verificabile e oggettivo accaduto nel passato.	Fact	Tatsache	Zava-misy	Il fatto della caduta di Costantinopoli nel 1453 segnò la fine dell'Impero Bizantino.
2091	10b0fb2	57	Relief	Rilievo		\N	2026-02-24 13:48:49.982574	0	2026-02-25 13:48:49.982574	{géographie,physique,relief}	2.5	0	0	\N	\N	Insieme delle irregolarità della superficie terrestre dovute a processi geologici e geomorfologici.	Relief	Relief	Endriky ny tany	Il rilievo delle Alpi è molto accidentato rispetto alla pianura padana.
2095	63b0cfb	57	Altitude	Altitudine		\N	2026-02-24 13:49:15.585601	0	2026-02-25 13:49:15.585601	{géographie,physique}	2.5	0	0	\N	\N	Distanza verticale di un punto dalla superficie del mare misurata in metri.	Altitude	Höhe	Haavo	L'altitudine del Monte Bianco supera i 4800 metri.
1229	0a7f7ff	31	Espèces invasives	Specie invasive		\N	2026-01-11 15:36:49.538314	0	2026-01-12 15:36:49.538314	{expression,italien,biodiversité}	2.5	0	0	\N	\N	\N	Invasive species	Invasive Arten	Karazana invasive	\N
1230	684ae83	31	Braconnage	Bracconaggio		\N	2026-01-11 15:36:49.55936	0	2026-01-12 15:36:49.55936	{nom,italien,conservation}	2.5	0	0	\N	\N	\N	Poaching	Wilderei	fihazana	\N
1231	92cde81	31	Aire protégée	Area protetta		\N	2026-01-11 15:36:49.667251	0	2026-01-12 15:36:49.667251	{expression,italien,conservation}	2.5	0	0	\N	\N	\N	Protected area	Geschützter Bereich	Faritra arovana	\N
1232	f6296ca	31	Parc national	Parco nazionale		\N	2026-01-11 15:36:49.706088	0	2026-01-12 15:36:49.706088	{nom,italien,nature}	2.5	0	0	\N	\N	\N	National park	Nationalpark	National park	\N
1236	480a49a	31	Biomasse	Biomassa		\N	2026-01-11 15:36:49.795992	0	2026-01-12 15:36:49.795992	{nom,italien,énergie}	2.5	0	0	\N	\N	\N	Biomass	Biomasse	Biomass	\N
1627	3f96d1e	39	tram	tram		\N	2026-01-30 16:23:22.179803	0	2026-01-31 16:23:22.179803	{nom,italien,transport}	2.5	0	0	\N	\N	\N	tram	Tram	tram	\N
1628	65082bc	39	camion	camion		\N	2026-01-30 16:23:22.199792	0	2026-01-31 16:23:22.199792	{nom,italien,transport}	2.5	0	0	\N	\N	\N	truck	LKW	kamiao	\N
1629	dfe9769	39	bateau	barca		\N	2026-01-30 16:23:22.221428	0	2026-01-31 16:23:22.221428	{nom,italien,transport}	2.5	0	0	\N	\N	\N	boat	Boot	SAMBO	\N
791	44f7605	22	Vincere	Vinto		\N	2025-12-08 16:20:07.888617	0	2025-12-09 16:20:07.888617	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Won	Won	Nandresy	\N
794	635d83e	22	Spegnere	Spento		\N	2025-12-08 16:20:07.945301	0	2025-12-09 16:20:07.945301	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Worn out	Abgenutzt	Tonta	\N
1226	8f4445b	31	Empreinte carbone	Impronta di carbonio		\N	2026-01-11 15:36:49.469494	0	2026-01-12 15:36:49.469494	{expression,italien,climat}	2.5	0	0	\N	\N	\N	Carbon footprint	CO2-Fußabdruck	dian karbona	\N
1227	86d1578	31	Services écosystémiques	Servizi ecosistemici		\N	2026-01-11 15:36:49.495864	0	2026-01-12 15:36:49.495864	{expression,italien,écologie}	2.5	0	0	\N	\N	\N	Ecosystem services	Ökosystemleistungen	Serivisy momba ny tontolo iainana	\N
1228	07b270e	31	Perte de biodiversité	Perdita di biodiversità		\N	2026-01-11 15:36:49.517552	0	2026-01-12 15:36:49.517552	{expression,italien,biodiversité}	2.5	0	0	\N	\N	\N	Loss of biodiversity	Verlust der Artenvielfalt	Fahaverezan'ny zavamananaina	\N
1304	e0399b1	32	Qui aboie ne mord pas	Can che abbaia non morde		\N	2026-01-12 12:49:14.459508	0	2026-01-13 12:49:14.459508	{expression,italien,animal,comportement}	2.5	0	0	\N	\N	\N	A dog that barks doesn't bite	Ein Hund, der bellt, beißt nicht	Ny alika mivovo tsy manaikitra	\N
2097	2621eca	57	Méridien	Meridiano		\N	2026-02-24 13:49:28.49734	0	2026-02-25 13:49:28.49734	{géographie,cartographie}	2.5	0	0	\N	\N	Semicerchio che unisce i due poli terrestri passando per un determinato punto.	Meridian	Meridian	Meridiana	Il meridiano di Greenwich è il riferimento internazionale per la longitudine.
2098	5520491	57	Coordonnée	Coordinata		\N	2026-02-24 13:49:35.185548	0	2026-02-25 13:49:35.185548	{géographie,cartographie}	2.5	0	0	\N	\N	Coppia di valori (latitudine e longitudine) che identifica univocamente un punto sulla superficie terrestre.	Coordinate	Koordinate	Koordinata	Le coordinate di New York sono 40° N e 74° W.
2099	909b408	57	Carte	Carta		\N	2026-02-24 13:49:41.457667	0	2026-02-25 13:49:41.457667	{géographie,cartographie}	2.5	0	0	\N	\N	Rappresentazione grafica ridotta della superficie terrestre o di una sua parte.	Map	Karte	Saritany	La carta geografica mostra i confini tra i paesi europei.
2100	2a097a1	57	Colline	Collina		\N	2026-02-24 13:49:54.160844	0	2026-02-25 13:49:54.160844	{géographie,physique,relief}	2.5	0	0	\N	\N	Elevazione del terreno di modesta altitudine e con pendii dolci.	Hill	Hügel	Tanety	Le colline toscane sono famose per i vigneti.
2101	21e13d0	57	Plateau	Altopiano		\N	2026-02-24 13:50:00.434265	0	2026-02-25 13:50:00.434265	{géographie,physique,relief}	2.5	0	0	\N	\N	Vasta area pianeggiante situata a notevole altitudine.	Plateau	Hochebene	Altopiano	L'altopiano del Tibet è il più alto del mondo.
2347	fbb8f87	62	Passion	Passione		\N	2026-02-24 15:32:40.961399	0	2026-02-25 15:32:40.961399	{sport,mental}	2.5	0	0	\N	\N	Amore profondo per lo sport.	Passion	Leidenschaft	Fitiavana	La passione lo motiva ogni giorno.
2348	03e73df	62	Inspiration	Ispirazione		\N	2026-02-24 15:32:48.28799	0	2026-02-25 15:32:48.28799	{sport,mental}	2.5	0	0	\N	\N	Stimolo che spinge a migliorare.	Inspiration	Inspiration	Fahazavana	I campioni sono fonte di ispirazione.
2349	c94e48c	62	Vestiaire	Spogliatoio		\N	2026-02-24 15:32:55.977466	0	2026-02-25 15:32:55.977466	{sport,matériel,structures}	2.5	0	0	\N	\N	Locale dove gli atleti si cambiano.	Locker room	Umkleideraum	Efitra fiovana	Nel vestiaire si discute la tattica.
795	0bd06e5	22	Scrivere	Scritto		\N	2025-12-08 16:20:07.966235	0	2025-12-09 16:20:07.966235	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Written	Geschrieben	ny mpanoratra	\N
796	b40cd89	22	Dire	Detto		\N	2025-12-08 16:20:07.987705	0	2025-12-09 16:20:07.987705	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Said	Sagte	Hoy	\N
807	a7eab62	22	Venire	Venuto		\N	2025-12-08 16:20:08.189544	0	2025-12-09 16:20:08.189544	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Came	Kam	Tonga	\N
1247	a2dea29	31	Activiste	Attivista		\N	2026-01-11 15:36:50.039011	0	2026-01-12 15:36:50.039011	{nom,italien,social}	2.5	0	0	\N	\N	\N	Activist	Aktivist	mafana fo	\N
1248	cf6114a	31	Manifestation	Manifestazione		\N	2026-01-11 15:36:50.060301	0	2026-01-12 15:36:50.060301	{nom,italien,action}	2.5	0	0	\N	\N	\N	Demonstration	Demonstration	fampisehoana	\N
1267	834be05	31	Zone humide	Zona umida		\N	2026-01-11 15:36:50.472695	0	2026-01-12 15:36:50.472695	{expression,italien,nature}	2.5	0	0	\N	\N	\N	Wetland	Feuchtgebiet	faritra mando	\N
1630	232b506	39	gondole (Venise)	gondola		\N	2026-01-30 16:23:22.242607	0	2026-01-31 16:23:22.242607	{nom,italien,transport}	2.5	0	0	\N	\N	\N	gondola	Gondel	gondola	\N
1631	a3ce770	39	navire	nave		\N	2026-01-30 16:23:22.26247	0	2026-01-31 16:23:22.26247	{nom,italien,transport}	2.5	0	0	\N	\N	\N	ship	Schiff	sambo	\N
1632	6aacb7f	39	ferry	traghetto		\N	2026-01-30 16:23:22.282051	0	2026-01-31 16:23:22.282051	{nom,italien,transport}	2.5	0	0	\N	\N	\N	ferry	Fähre	baka	\N
1633	00ab5fc	39	hélicoptère	elicottero		\N	2026-01-30 16:23:22.302079	0	2026-01-31 16:23:22.302079	{nom,italien,transport}	2.5	0	0	\N	\N	\N	helicopter	Hubschrauber	angidimby	\N
1634	b44b487	39	carrosse	carrozza		\N	2026-01-30 16:23:22.320971	0	2026-01-31 16:23:22.320971	{nom,italien,transport}	2.5	0	0	\N	\N	\N	carriage	Wagen	entany	\N
1635	966cd9b	39	gare	stazione		\N	2026-01-30 16:23:22.341442	0	2026-01-31 16:23:22.341442	{nom,italien,transport}	2.5	0	0	\N	\N	\N	station	Station	peo	\N
1268	a626dbf	31	Tourbière	Torba		\N	2026-01-11 15:36:50.491091	0	2026-01-12 15:36:50.491091	{nom,italien,sol}	2.5	0	0	\N	\N	\N	Peat	Torf	Peat	\N
1636	efeacbf	39	aéroport	aeroporto		\N	2026-01-30 16:23:22.363336	0	2026-01-31 16:23:22.363336	{nom,italien,transport}	2.5	0	0	\N	\N	\N	airport	Flughafen	Airport	\N
1637	29bbee0	39	port	porto		\N	2026-01-30 16:23:22.386325	0	2026-01-31 16:23:22.386325	{nom,italien,transport}	2.5	0	0	\N	\N	\N	port	Hafen	seranana	\N
1638	c17de5a	39	arrêt de bus	fermata		\N	2026-01-30 16:23:22.407483	0	2026-01-31 16:23:22.407483	{nom,italien,transport}	2.5	0	0	\N	\N	\N	stop	stoppen	Mijanòna	\N
1639	9704aae	39	quai (gare)	binario		\N	2026-01-30 16:23:22.43213	0	2026-01-31 16:23:22.43213	{nom,italien,transport}	2.5	0	0	\N	\N	\N	tracks	Spuren	titres	\N
2103	aa342dc	57	Plaine	Pianura		\N	2026-02-24 13:50:13.656548	0	2026-02-25 13:50:13.656548	{géographie,physique,relief}	2.5	0	0	\N	\N	Vasta estensione di terreno piatto o quasi piatto a bassa altitudine.	Plain	Ebene	Tany lemaka	La pianura padana è molto fertile.
2104	4149538	57	Canyon	Canyon		\N	2026-02-24 13:50:20.064235	0	2026-02-25 13:50:20.064235	{géographie,physique,relief}	2.5	0	0	\N	\N	Profonda gola scavata dall'erosione fluviale in rocce resistenti.	Canyon	Canyon	Kanyon	Il Grand Canyon è uno dei canyon più spettacolari del mondo.
1421	7237db2	37	eau	acqua		\N	2026-01-21 14:49:57.899654	0	2026-01-22 14:49:57.899654	{nom,italien,"cibo e bevande"}	2.5	0	0	\N	\N	Sostanza liquida indispensabile per la vita e agente primario nel modellamento del paesaggio.	water	Wasser	rano	L'acqua di fusione dei ghiacciai alimenta i grandi fiumi.
797	f879918	22	Nascere	Nato		\N	2025-12-08 16:20:08.005096	0	2025-12-09 16:20:08.005096	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Born	Geboren	TERAKA	\N
801	65ec1c9	22	Vedere	Visto		\N	2025-12-08 16:20:08.073489	0	2025-12-09 16:20:08.073489	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	View	Sicht	View	\N
805	657e712	22	Offrire	Offerto		\N	2025-12-08 16:20:08.147178	0	2025-12-09 16:20:08.147178	{verbe,italien,irrégulier,"participio passato"}	2.5	0	0	\N	\N	\N	Offered	Angeboten	nanatitra	\N
1249	fac519f	31	Subvention	Sovvenzione		\N	2026-01-11 15:36:50.084422	0	2026-01-12 15:36:50.084422	{nom,italien,économie}	2.5	0	0	\N	\N	\N	Grant	Gewähren	Grant	\N
2107	5b008bd	57	Col	Colle		\N	2026-02-24 13:50:44.739159	0	2026-02-25 13:50:44.739159	{géographie,physique,relief}	2.5	0	0	\N	\N	Depressione tra due vette che permette il passaggio tra versanti opposti.	Pass	Pass	Col	Il colle del Moncenisio collega Italia e Francia.
2108	aa750b6	57	Ruisseau	Ruscello		\N	2026-02-24 13:51:16.869462	0	2026-02-25 13:51:16.869462	{géographie,hydrologie}	2.5	0	0	\N	\N	Piccolo corso d'acqua superficiale di modesto portata.	Stream	Bach	Renirano kely	Un ruscello attraversa il bosco vicino al villaggio.
1059	c041658	28	Lac	Lago		\N	2026-01-08 15:19:18.368925	1	2026-02-02 15:27:27.708971	{nom,italien,eau}	2.6	1	1	\N	\N	Massa d'acqua dolce o salata racchiusa in una depressione del terreno.	Lake	See	Farihy	Il lago di Como è uno dei laghi prealpini più famosi.
2109	d5c8370	57	Étang	Stagno		\N	2026-02-24 13:51:31.002742	0	2026-02-25 13:51:31.002742	{géographie,hydrologie}	2.5	0	0	\N	\N	Piccolo bacino d'acqua dolce di origine naturale o artificiale.	Pond	Teich	Farihy kely	Lo stagno è un habitat ideale per molte specie di uccelli.
2110	c2fc338	57	Estuaire	Estuario		\N	2026-02-24 13:51:37.128067	0	2026-02-25 13:51:37.128067	{géographie,hydrologie}	2.5	0	0	\N	\N	Zona di transizione tra la foce di un fiume e il mare dove si mescolano acque dolci e salate.	Estuary	Ästuar	Estuaire	L'estuario della Senna è molto importante per il porto di Le Havre.
1260	fcaf1b2	31	Rayonnement	Radiazione		\N	2026-01-11 15:36:50.320933	0	2026-01-12 15:36:50.320933	{nom,italien,pollution}	2.5	0	0	\N	\N	Emissione e propagazione di energia sotto forma di onde.	Radiation	Strahlung	Rayonnement	Il radiazione solare raggiunge la Terra.
2553	2ba5fa7	65	océan	oceano		https://upload.wikimedia.org/wikipedia/commons/e/ef/Ocean_beach_at_low_tide_against_the_sun.jpg	2026-03-30 16:23:49.816466	0	2026-03-31 16:23:49.816466	{hydrologie,géographie}	2.5	0	0	\N	\N	Vasta estensione di massa liquida salata che ricopre la maggior parte del pianeta.	ocean	Ozean	ranomasimbe	L'espansione del fondale nell'oceano Atlantico spinge i continenti lontani.
2554	91a0979	65	continent	continente		https://upload.wikimedia.org/wikipedia/commons/c/c5/Morocco_Africa_Flickr_Rosino_December_2005_84514010_edited_by_Buchling.jpg	2026-03-30 16:24:00.07078	0	2026-03-31 16:24:00.07078	{géographie,tectonique}	2.5	0	0	\N	\N	Le principali masse di terraferma emerse del pianeta.	continent	Kontinent	kaontinanta	In passato, ogni continente era unito nell'antico supercontinente Pangea.
1255	3208a6a	31	Microplastique	Microplastica		\N	2026-01-11 15:36:50.217939	0	2026-01-12 15:36:50.217939	{nom,italien,pollution}	2.5	0	0	\N	\N	\N	Microplastic	Mikroplastik	Microplastic	\N
1256	cae866a	31	Marée noire	Marea nera		\N	2026-01-11 15:36:50.238521	0	2026-01-12 15:36:50.238521	{expression,italien,pollution}	2.5	0	0	\N	\N	\N	Oil spill	Ölpest	Fiparitahana solika	\N
1257	b3258cf	31	Contamination	Contaminazione		\N	2026-01-11 15:36:50.258988	0	2026-01-12 15:36:50.258988	{nom,italien,pollution}	2.5	0	0	\N	\N	\N	Contamination	Kontamination	fandotoana	\N
1258	b285e3c	31	Toxine	Tossina		\N	2026-01-11 15:36:50.280312	0	2026-01-12 15:36:50.280312	{nom,italien,pollution}	2.5	0	0	\N	\N	\N	Toxin	Toxin	poizina	\N
1259	7e73271	31	Déchet dangereux	Rifiuto pericoloso		\N	2026-01-11 15:36:50.301178	0	2026-01-12 15:36:50.301178	{expression,italien,déchets}	2.5	0	0	\N	\N	\N	Dangerous waste	Gefährlicher Abfall	Fako mampidi-doza	\N
1261	4a36004	31	Pollution sonore	Inquinamento acustico		\N	2026-01-11 15:36:50.342869	0	2026-01-12 15:36:50.342869	{expression,italien,pollution}	2.5	0	0	\N	\N	\N	Noise pollution	Lärmbelästigung	Fandotoana tabataba	\N
1269	17d5a75	31	Puits de carbone	Pozzo di carbonio		\N	2026-01-11 15:36:50.510255	0	2026-01-12 15:36:50.510255	{expression,italien,climat}	2.5	0	0	\N	\N	\N	Carbon sink	Kohlenstoffsenke	Karbonina hilentika	\N
1640	bd4ff22	39	billet / ticket	biglietto		\N	2026-01-30 16:23:22.453569	0	2026-01-31 16:23:22.453569	{nom,italien,transport}	2.5	0	0	\N	\N	\N	ticket	Ticket	tapakila	\N
1641	dda39cc	39	passeport	passaporto		\N	2026-01-30 16:23:22.477304	0	2026-01-31 16:23:22.477304	{nom,italien,transport}	2.5	0	0	\N	\N	\N	passport	Reisepass	pasipaoro	\N
1642	ba120e7	39	bagage	bagaglio		\N	2026-01-30 16:23:22.498393	0	2026-01-31 16:23:22.498393	{nom,italien,transport}	2.5	0	0	\N	\N	\N	luggage	Gepäck	entana	\N
393	1a55d32	13	Gorge	Gola		\N	2025-12-06 14:15:35.52065	0	2025-12-07 14:15:35.52065	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	Valle stretta e profonda con pareti ripide scavata da un corso d'acqua.	Gorge	Schlucht	Gorge	La gola del Verdon è famosa per le sue pareti verticali.
2105	754b1cf	57	Crête	Cresta		\N	2026-02-24 13:50:32.723134	0	2026-02-25 13:50:32.723134	{géographie,physique,relief}	2.5	0	0	\N	\N	Linea di sommità allungata che unisce le cime di una catena montuosa.	Ridge	Kamm	Tendro	La cresta del Monte Rosa offre viste spettacolari.
2106	53fdda3	57	Bassin	Bacino		\N	2026-02-24 13:50:38.783414	0	2026-02-25 13:50:38.783414	{géographie,physique,hydrologie}	2.5	0	0	\N	\N	Depressione del terreno che raccoglie le acque di un fiume o di un lago.	Basin	Becken	Basin	Il bacino del Rio delle Amazzoni è il più grande del mondo.
2114	b8f6033	57	Humidité	Umidità		\N	2026-02-24 13:52:15.383097	0	2026-02-25 13:52:15.383097	{géographie,climat}	2.5	0	0	\N	\N	Quantità di vapore acqueo presente nell'aria.	Humidity	Feuchtigkeit	Hamando	L'umidità elevata rende il caldo estivo più opprimente.
2115	a9cf5f7	57	Aridité	Aridità		\N	2026-02-24 13:52:21.407713	0	2026-02-25 13:52:21.407713	{géographie,climat}	2.5	0	0	\N	\N	Condizione climatica caratterizzata da scarsissime precipitazioni.	Aridity	Trockenheit	Maina	L'aridità del Sahara rende impossibile l'agricoltura senza irrigazione.
2116	59a0eac	57	Saison	Stagione		\N	2026-02-24 13:52:28.534141	0	2026-02-25 13:52:28.534141	{géographie,climat}	2.5	0	0	\N	\N	Periodo dell'anno caratterizzato da particolari condizioni climatiche.	Season	Jahreszeit	Fotoana	La stagione delle piogge in India porta la monsone.
2117	dc9ca0b	57	Mousson	Monsone		\N	2026-02-24 13:52:35.345251	0	2026-02-25 13:52:35.345251	{géographie,climat}	2.5	0	0	\N	\N	Vento stagionale che porta abbondanti precipitazioni in certe regioni tropicali.	Monsoon	Monsun	Mousson	La monsone estiva è vitale per l'agricoltura in Asia meridionale.
2118	e1462bb	57	Courant	Corrente		\N	2026-02-24 13:52:41.760213	0	2026-02-25 13:52:41.760213	{géographie,océanographie}	2.5	0	0	\N	\N	Movimento orizzontale delle masse d'acqua negli oceani e nei mari.	Current	Strömung	Courant	La corrente del Golfo riscalda il clima dell'Europa occidentale.
2119	afacdfd	57	Microclimat	Microclima		\N	2026-02-24 13:52:48.322871	0	2026-02-25 13:52:48.322871	{géographie,climat}	2.5	0	0	\N	\N	Clima locale di una piccola area che differisce dal clima regionale.	Microclimate	Mikroklima	Mikroklima	Il microclima delle vigne in collina è ideale per la produzione di vino.
2120	6e52561	57	Tempête	Tempesta		\N	2026-02-24 13:52:54.315289	0	2026-02-25 13:52:54.315289	{géographie,climat,météo}	2.5	0	0	\N	\N	Fenomeno atmosferico violento con forti venti e precipitazioni.	Storm	Sturm	Tantara	La tempesta ha causato allagamenti in molte città costiere.
2121	38654cf	57	Taïga	Taiga		\N	2026-02-24 13:53:06.971626	0	2026-02-25 13:53:06.971626	{géographie,écosystème}	2.5	0	0	\N	\N	Foresta boreale di conifere tipica delle regioni subartiche.	Taiga	Taiga	Taiga	La taiga siberiana è la foresta più estesa del mondo.
1262	50faebb	31	Pollution lumineuse	Inquinamento luminoso		\N	2026-01-11 15:36:50.365685	0	2026-01-12 15:36:50.365685	{expression,italien,pollution}	2.5	0	0	\N	\N	\N	Light pollution	Lichtverschmutzung	Fahalotoana maivana	\N
1264	8186f33	31	Surpêche	Sovrapesca		\N	2026-01-11 15:36:50.408887	0	2026-01-12 15:36:50.408887	{nom,italien,eau}	2.5	0	0	\N	\N	\N	Overfishing	Überfischung	fanjonoana mihoa-pampana	\N
1265	6169914	31	Aquaculture	Acquacoltura		\N	2026-01-11 15:36:50.429419	0	2026-01-12 15:36:50.429419	{nom,italien,agriculture}	2.5	0	0	\N	\N	\N	Aquaculture	Aquakultur	Aquaculture	\N
1644	9b7f03f	39	route	strada		\N	2026-01-30 16:23:22.544214	0	2026-01-31 16:23:22.544214	{nom,italien,transport}	2.5	0	0	\N	\N	\N	street	Straße	eny an-dalana	\N
1645	3bf2504	39	autoroute	autostrada		\N	2026-01-30 16:23:22.566263	0	2026-01-31 16:23:22.566263	{nom,italien,transport}	2.5	0	0	\N	\N	\N	motorway	Autobahn	manivaka	\N
1646	72c2632	39	trottoir	marciapiede		\N	2026-01-30 16:23:22.588154	0	2026-01-31 16:23:22.588154	{nom,italien,transport}	2.5	0	0	\N	\N	\N	sidewalk	Gehweg	sisin-dalana	\N
1647	43fcce4	39	feu de circulation	semaforo		\N	2026-01-30 16:23:22.609196	0	2026-01-31 16:23:22.609196	{nom,italien,transport}	2.5	0	0	\N	\N	\N	stoplight	Ampel	jiro fiatoana	\N
2111	b78a551	57	Delta	Delta		\N	2026-02-24 13:51:43.502261	0	2026-02-25 13:51:43.502261	{géographie,hydrologie}	2.5	0	0	\N	\N	Deposito sedimentario a forma di ventaglio alla foce di un fiume in mare.	Delta	Delta	Delta	Il delta del Nilo è una delle zone agricole più fertili.
2112	d688f58	57	Marais	Palude		\N	2026-02-24 13:51:49.594651	0	2026-02-25 13:51:49.594651	{géographie,hydrologie,écosystème}	2.5	0	0	\N	\N	Zona umida caratterizzata da acque stagnanti e vegetazione acquatica.	Marsh	Sumpf	Tanim-bazaha	La palude di Venezia è un ecosistema unico.
2113	048d283	57	Précipitation	Precipitazione		\N	2026-02-24 13:52:09.147354	0	2026-02-25 13:52:09.147354	{géographie,climat}	2.5	0	0	\N	\N	Caduta di acqua dall'atmosfera sotto forma di pioggia, neve o grandine.	Precipitation	Niederschlag	Rano latsaka	Le precipitazioni abbondanti favoriscono la crescita delle foreste.
2127	fcec9c8	57	Bosquet	Boschetto		\N	2026-02-24 13:53:51.257543	0	2026-02-25 13:53:51.257543	{géographie,écosystème}	2.5	0	0	\N	\N	Piccolo gruppo di alberi o piccolo bosco.	Grove	Gehölz	Ala kely	Un boschetto di querce ombreggia il sentiero.
2128	06d5022	57	Prairie	Prateria		\N	2026-02-24 13:53:57.278727	0	2026-02-25 13:53:57.278727	{géographie,écosystème}	2.5	0	0	\N	\N	Vasta distesa erbosa tipica delle regioni temperate.	Prairie	Prärie	Prairie	La prateria nordamericana è ideale per l'allevamento di bisonti.
2129	62c817d	57	Forêt dense	Foresta pluviale		\N	2026-02-24 13:54:03.805532	0	2026-02-25 13:54:03.805532	{géographie,écosystème}	2.5	0	0	\N	\N	Foresta tropicale caratterizzata da altissima piovosità e biodiversità.	Rainforest	Regenwald	Ala mateza	La foresta pluviale amazzonica ospita milioni di specie.
2131	243d90c	57	Volcanisme	Vulcanismo		\N	2026-02-24 13:54:22.571755	0	2026-02-25 13:54:22.571755	{géographie,géologie}	2.5	0	0	\N	\N	Insieme dei fenomeni legati all'emissione di magma dalla crosta terrestre.	Volcanism	Vulkanismus	Volkanisma	Il vulcanismo ha creato le isole Hawaii.
2133	51ec0b9	57	Glaciation	Glaciazione		\N	2026-02-24 13:54:35.241271	0	2026-02-25 13:54:35.241271	{géographie,géomorphologie}	2.5	0	0	\N	\N	Periodo in cui grandi masse di ghiaccio coprono vaste aree della Terra.	Glaciation	Vereisung	Glaciation	L'ultima glaciazione ha modellato i laghi alpini.
2134	e5cdcee	57	Éboulement	Frana		\N	2026-02-24 13:54:41.145486	0	2026-02-25 13:54:41.145486	{géographie,géomorphologie}	2.5	0	0	\N	\N	Caduta improvvisa di masse rocciose o terriccio lungo un pendio.	Landslide	Erdrutsch	Fikorontana	L'éboulement ha ostruito la strada di montagna.
1272	497988e	31	Prédateur	Predatore		\N	2026-01-11 15:36:50.5706	0	2026-01-12 15:36:50.5706	{nom,italien,biodiversité}	2.5	0	0	\N	\N	\N	Predator	Raubtier	mpiremby	\N
1273	a77521d	31	Proie	Preda		\N	2026-01-11 15:36:50.590021	0	2026-01-12 15:36:50.590021	{nom,italien,biodiversité}	2.5	0	0	\N	\N	\N	Prey	Beute	remby	\N
1274	8109182	31	Symbiose	Simbiosi		\N	2026-01-11 15:36:50.60989	0	2026-01-12 15:36:50.60989	{nom,italien,écologie}	2.5	0	0	\N	\N	\N	Symbiosis	Symbiose	Symbiose	\N
1275	7eeeb35	31	Parasite	Parassita		\N	2026-01-11 15:36:50.63049	0	2026-01-12 15:36:50.63049	{nom,italien,biodiversité}	2.5	0	0	\N	\N	\N	Parasite	Parasit	Parasite	\N
1276	0638edf	31	Équilibre écologique	Equilibrio ecologico		\N	2026-01-11 15:36:50.650898	0	2026-01-12 15:36:50.650898	{expression,italien,écologie}	2.5	0	0	\N	\N	\N	Ecological balance	Ökologisches Gleichgewicht	Fandanjalanjana ekolojika	\N
1277	15028cb	31	Impact humain	Impatto umano		\N	2026-01-11 15:36:50.672182	0	2026-01-12 15:36:50.672182	{expression,italien,anthropique}	2.5	0	0	\N	\N	\N	Human impact	Menschlicher Einfluss	Ny fiantraikan'ny olombelona	\N
1278	adfcde2	31	Anthropocène	Antropocene		\N	2026-01-11 15:36:50.692992	0	2026-01-12 15:36:50.692992	{nom,italien,époque}	2.5	0	0	\N	\N	\N	Anthropocene	Anthropozän	Anthropocene	\N
1648	e6de09b	39	embouteillage	traffico		\N	2026-01-30 16:23:22.630303	0	2026-01-31 16:23:22.630303	{nom,italien,transport}	2.5	0	0	\N	\N	\N	traffic	Verkehr	fifamoivoizana	\N
1649	63f9ce0	39	conducteur	autista		\N	2026-01-30 16:23:22.651217	0	2026-01-31 16:23:22.651217	{nom,italien,transport}	2.5	0	0	\N	\N	\N	driver	Treiber	Driver	\N
1650	c9180c7	39	passager	passeggero		\N	2026-01-30 16:23:22.672755	0	2026-01-31 16:23:22.672755	{nom,italien,transport}	2.5	0	0	\N	\N	\N	passenger	Passagier	mpandeha	\N
1651	5c6d3df	39	piéton	pedone		\N	2026-01-30 16:23:22.693124	0	2026-01-31 16:23:22.693124	{nom,italien,transport}	2.5	0	0	\N	\N	\N	pedestrian	Fußgänger	mpandeha an-tongotra	\N
1652	196571d	39	vol (avion)	volo		\N	2026-01-30 16:23:22.714553	0	2026-01-31 16:23:22.714553	{nom,italien,transport}	2.5	0	0	\N	\N	\N	flight	Flug	NANDOSITRA	\N
2122	01488a7	57	Toundra	Tundra		\N	2026-02-24 13:53:13.286326	0	2026-02-25 13:53:13.286326	{géographie,écosystème}	2.5	0	0	\N	\N	Bioma caratterizzato da suolo gelato per gran parte dell'anno e vegetazione bassa.	Tundra	Tundra	Toundra	La tundra artica ospita renne e muschi.
2123	cdb4e5c	57	Savane	Savana		\N	2026-02-24 13:53:19.467333	0	2026-02-25 13:53:19.467333	{géographie,écosystème}	2.5	0	0	\N	\N	Prateria tropicale con alberi sparsi tipica delle regioni intertropicali.	Savanna	Savanne	Savane	La savana africana è l'habitat dei grandi mammiferi.
2124	1a9f8e2	57	Steppe	Steppa		\N	2026-02-24 13:53:26.046825	0	2026-02-25 13:53:26.046825	{géographie,écosystème}	2.5	0	0	\N	\N	Vasta pianura arida o semi-arida coperta da erbe basse.	Steppe	Steppe	Steppe	La steppa russa è utilizzata per l'allevamento.
2125	3a2c455	57	Chaparral	Macchia mediterranea		\N	2026-02-24 13:53:32.286228	0	2026-02-25 13:53:32.286228	{géographie,écosystème}	2.5	0	0	\N	\N	Vegetazione arbustiva tipica delle regioni mediterranee con estati secche.	Chaparral	Chaparral	Chaparral	Il chaparral in California è soggetto a frequenti incendi.
1266	710a148	31	Mangrove	Mangrovia		\N	2026-01-11 15:36:50.450445	0	2026-01-12 15:36:50.450445	{nom,italien,nature}	2.5	0	0	\N	\N	Foresta costiera tropicale formata da alberi che tollerano l'acqua salmastra.	Mangrove	Mangrove	Mangrove	La mangrovia protegge le coste dall'erosione marina.
2126	70f2af7	57	Maquis	Macchia		\N	2026-02-24 13:53:45.05017	0	2026-02-25 13:53:45.05017	{géographie,écosystème}	2.5	0	0	\N	\N	Vegetazione arbustiva densa tipica delle regioni mediterranee.	Maquis	Macchia	Maquis	Il maquis corso è ricco di piante aromatiche.
2139	19f41fb	57	Légende	Legenda		\N	2026-02-24 13:55:27.203012	0	2026-02-25 13:55:27.203012	{géographie,cartographie}	2.5	0	0	\N	\N	Elenco dei simboli e colori utilizzati nella carta con la loro spiegazione.	Legend	Legende	Legend	La legenda indica che il blu rappresenta i fiumi.
2140	d41b09a	57	Toponyme	Toponimo		\N	2026-02-24 13:55:33.725292	0	2026-02-25 13:55:33.725292	{géographie,cartographie}	2.5	0	0	\N	\N	Nome proprio di un luogo geografico.	Toponym	Toponym	Toponimo	Roma è un toponimo di origine etrusca.
2141	1d847cd	57	Globe	Globo		\N	2026-02-24 13:55:47.572874	0	2026-02-25 13:55:47.572874	{géographie,cartographie}	2.5	0	0	\N	\N	Modello sferico in scala ridotta della Terra.	Globe	Globus	Globe	Il globo terrestre mostra i continenti e gli oceani.
1279	de78c6a	31	Objectifs de développement durable	Obiettivi di sviluppo sostenibile		\N	2026-01-11 15:36:50.714461	0	2026-01-12 15:36:50.714461	{expression,italien,développement}	2.5	0	0	\N	\N	\N	Sustainable Development Goals	Ziele für nachhaltige Entwicklung	Tanjona amin'ny fampandrosoana maharitra	\N
1280	d475489	31	Vent	Vento		\N	2026-01-11 15:36:50.735555	0	2026-01-12 15:36:50.735555	{nom,italien,climat}	2.5	0	0	\N	\N	\N	Wind	Wind	Rivotra	\N
1281	28ba002	31	Neige	Neve		\N	2026-01-11 15:36:50.756829	0	2026-01-12 15:36:50.756829	{nom,italien,climat}	2.5	0	0	\N	\N	\N	Snow	Schnee	oram-panala	\N
1282	2f92a83	31	Pluie	Pioggia		\N	2026-01-11 15:36:50.779296	0	2026-01-12 15:36:50.779296	{nom,italien,climat}	2.5	0	0	\N	\N	\N	Rain	Regen	orana	\N
1283	ba952ba	31	Nuage	Nuvola		\N	2026-01-11 15:36:50.804699	0	2026-01-12 15:36:50.804699	{nom,italien,climat}	2.5	0	0	\N	\N	\N	Cloud	Wolke	rahona	\N
1284	252046a	31	Soleil	Sole		\N	2026-01-11 15:36:50.916239	0	2026-01-12 15:36:50.916239	{nom,italien,nature}	2.5	0	0	\N	\N	\N	Sun	Sonne	Masoandro	\N
1653	9746c6c	39	départ	partenza		\N	2026-01-30 16:23:22.737486	0	2026-01-31 16:23:22.737486	{nom,italien,transport}	2.5	0	0	\N	\N	\N	departure	Abfahrt	lasa	\N
1654	3fc5af9	39	arrivée	arrivo		\N	2026-01-30 16:23:22.757672	0	2026-01-31 16:23:22.757672	{nom,italien,transport}	2.5	0	0	\N	\N	\N	I arrive	Ich komme an	tonga aho	\N
1655	a6aa090	39	retard	ritardo		\N	2026-01-30 16:23:22.779469	0	2026-01-31 16:23:22.779469	{nom,italien,transport}	2.5	0	0	\N	\N	\N	delay	Verzögerung	fahatarana	\N
1656	7eb557d	39	horaire	orario		\N	2026-01-30 16:23:22.798726	0	2026-01-31 16:23:22.798726	{nom,italien,transport}	2.5	0	0	\N	\N	\N	hours	Std.	ORA	\N
1657	ca7cc35	39	réservation	prenotazione		\N	2026-01-30 16:23:22.818858	0	2026-01-31 16:23:22.818858	{nom,italien,transport}	2.5	0	0	\N	\N	\N	reservation	Reservierung	famandrihana	\N
2135	a255a00	57	Alluvion	Alluvione		\N	2026-02-24 13:54:47.564194	0	2026-02-25 13:54:47.564194	{géographie,hydrologie}	2.5	0	0	\N	\N	Deposito di sedimenti trasportati e abbandonati dalle acque di un fiume.	Alluvium	Alluvion	Alluvion	Le alluvioni hanno reso fertile la pianura.
2136	4deb56a	57	Subsidence	Subsidenza		\N	2026-02-24 13:54:54.382197	0	2026-02-25 13:54:54.382197	{géographie,géologie}	2.5	0	0	\N	\N	Abbassamento lento e progressivo del terreno per cause naturali o antropiche.	Subsidence	Absenkung	Subsidence	La subsidenza a Venezia è aggravata dal pompaggio di acqua sotterranea.
2137	c38bd4b	57	Karstification	Carsismo		\N	2026-02-24 13:55:01.237264	0	2026-02-25 13:55:01.237264	{géographie,géomorphologie}	2.5	0	0	\N	\N	Processo di dissoluzione delle rocce calcaree che forma grotte e doline.	Karstification	Karstbildung	Karstification	Il carsismo è tipico delle Prealpi venete.
1263	d547622	31	Désertification	Desertificazione		\N	2026-01-11 15:36:50.388545	0	2026-01-12 15:36:50.388545	{nom,italien,sol}	2.5	0	0	\N	\N	Degradazione del suolo che trasforma terre fertili in deserti.	Desertification	Wüstenbildung	Fahazoana tany maina	La desertificazione colpisce il Sahel in Africa.
2138	7f884e1	57	Projection	Proiezione		\N	2026-02-24 13:55:14.211055	0	2026-02-25 13:55:14.211055	{géographie,cartographie}	2.5	0	0	\N	\N	Metodo matematico per rappresentare la superficie curva della Terra su una superficie piana.	Projection	Projektion	Projection	La proiezione di Mercatore è usata nelle carte nautiche.
2555	67f4cc7	65	montagne	montagna		https://upload.wikimedia.org/wikipedia/commons/2/29/Himalayas%2C_Ama_Dablam%2C_Nepal.jpg	2026-03-30 16:24:06.176929	0	2026-03-31 16:24:06.176929	{géomorphologie,orogenèse}	2.5	0	0	\N	\N	Rilievo naturale della superficie terrestre di notevole altitudine.	mountain	Berg	tendrombohitra	La formazione della montagna è avvenuta a causa dello scontro tra due placche.
2556	8d00d2c	65	vallée	valle		https://upload.wikimedia.org/wikipedia/commons/5/5a/Mountains_in_snow%2C_Mountain_lake%2C_Chola_Valley%2C_Nepal%2C_Himalayas.jpg	2026-03-30 16:24:12.965165	0	2026-03-31 16:24:12.965165	{géomorphologie,paysage}	2.5	0	0	\N	\N	Depressione del paesaggio delimitata da rilievi, spesso percorsa da corsi idrici.	valley	Tal	lohasaha	La valle a forma di U è stata scavata da un antico ghiacciaio.
2557	e94d23d	65	glacier	ghiacciaio		https://upload.wikimedia.org/wikipedia/commons/1/16/Sofia_Massif_and_Sofia_Glacier%2C_Karachay-Cherkessia%2C_Caucasus_Mountains.jpg	2026-03-30 16:24:18.785292	0	2026-03-31 16:24:18.785292	{glaciologie,géomorphologie}	2.5	0	0	\N	\N	Massa di ghiaccio in lento scorrimento derivante dall'accumulo di neve.	glacier	Gletscher	ranomandry	Il ritiro del ghiacciaio negli ultimi anni è una prova del riscaldamento globale.
2558	da4eba6	65	rivière	fiume		https://upload.wikimedia.org/wikipedia/commons/8/89/Wilkin_River_close_to_its_confluence_with_Makarora_River%2C_Otago%2C_New_Zealand.jpg	2026-03-30 16:24:25.005929	0	2026-03-31 16:24:25.005929	{hydrologie,géomorphologie}	2.5	0	0	\N	\N	Corso d'acqua dolce permanente che scorre verso il mare o un altro bacino idrico.	river	Fluss	renirano	Il fiume scava il proprio alveo trasportando sedimenti verso la valle.
2559	b92167b	65	nappe phréatique	falda acquifera		https://upload.wikimedia.org/wikipedia/commons/e/e3/Evolution_of_groundwater_chemistry.jpg	2026-03-30 16:24:30.641516	0	2026-03-31 16:24:30.641516	{hydrogéologie,ressources}	2.5	0	0	\N	\N	Corpo idrico sotterraneo ospitato nelle rocce o nei sedimenti permeabili.	groundwater	Grundwasser	rano ambanin'ny tany	Il pozzo è stato scavato molto profondo per raggiungere la falda acquifera incontaminata.
2560	f4ae7f9	65	atmosphère	atmosfera		https://upload.wikimedia.org/wikipedia/commons/b/be/Top_of_Atmosphere.jpg	2026-03-30 16:24:37.670238	0	2026-03-31 16:24:37.670238	{climatologie,géologie_générale}	2.5	0	0	\N	\N	L'involucro gassoso che avvolge il nostro pianeta.	atmosphere	Atmosphäre	atmosfera	Le eruzioni vulcaniche massicce possono alterare la composizione chimica dell'atmosfera.
2561	e40cd12	65	lithosphère	litosfera		https://upload.wikimedia.org/wikipedia/commons/d/da/Age_of_oceanic_lithosphere.png	2026-03-30 16:24:43.639988	0	2026-03-31 16:24:43.639988	{tectonique,structure_interne}	2.5	0	0	\N	\N	Guscio rigido ed esterno, che include crosta e la porzione più alta del mantello solido.	lithosphere	Lithosphäre	litosfera	La litosfera terrestre è frammentata in diverse zolle tettoniche.
2562	5445afc	65	asthénosphère	astenosfera		https://upload.wikimedia.org/wikipedia/commons/d/df/Le_Keltons.png	2026-03-30 16:24:51.245472	0	2026-03-31 16:24:51.245472	{tectonique,structure_interne}	2.5	0	0	\N	\N	Strato duttile e parzialmente fuso sottostante alla porzione rigida esterna terrestre.	asthenosphere	Asthenosphäre	astenosfera	I movimenti convettivi nell'astenosfera guidano la deriva dei continenti.
2563	32ac341	65	subduction	subduzione		https://upload.wikimedia.org/wikipedia/commons/9/9a/Cascadia_Subduction_Zone.jpg	2026-03-30 16:24:57.849522	0	2026-03-31 16:24:57.849522	{tectonique,dynamique}	2.5	0	0	\N	\N	Scorrimento e sprofondamento di una zolla tettonica oceanica sotto un'altra zolla.	subduction	Subduktion	fitsitsohana	La fossa delle Marianne è formata dall'intensa zona di subduzione del Pacifico.
2564	4f02f13	65	collision	collisione		https://upload.wikimedia.org/wikipedia/commons/3/33/H._R._Millar_-_Rudyard_Kipling_-_Puck_of_Pook%27s_Hill_6.jpg	2026-03-30 16:25:04.187012	0	2026-03-31 16:25:04.187012	{tectonique,orogenèse}	2.5	0	0	\N	\N	Incontro frontale tra due placche continentali che genera imponenti catene montuose.	collision	Kollision	fifandonana	L'Himalaya si è formata grazie alla collisione tra la placca indiana e quella euroasiatica.
1288	1e301c0	31	Insecte	Insetto		\N	2026-01-11 15:36:51.017859	0	2026-01-12 15:36:51.017859	{nom,italien,biodiversité}	2.5	0	0	\N	\N	\N	Insect	Insekt	bibikely	\N
1289	e7c1a0a	31	Fleur	Fiore		\N	2026-01-11 15:36:51.038269	0	2026-01-12 15:36:51.038269	{nom,italien,nature}	2.5	0	0	\N	\N	\N	Flower	Blume	Voninkazo	\N
1290	2c07a00	31	Herbe	Erba		\N	2026-01-11 15:36:51.057717	0	2026-01-12 15:36:51.057717	{nom,italien,nature}	2.5	0	0	\N	\N	\N	Grass	Gras	ahitra	\N
1293	de0f92b	31	Ventilation	Ventilazione		\N	2026-01-11 15:36:51.120586	0	2026-01-12 15:36:51.120586	{nom,italien,air}	2.5	0	0	\N	\N	\N	Ventilation	Belüftung	rivotra	\N
1294	8e08a12	31	Purifier	Purificare		\N	2026-01-11 15:36:51.143747	0	2026-01-12 15:36:51.143747	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Purify	Reinigen	hanadio	\N
1295	5581647	31	Filtrer	Filtrare		\N	2026-01-11 15:36:51.168981	0	2026-01-12 15:36:51.168981	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Filter	Filter	Sivana	\N
1296	e6e8aa6	31	Contaminer	Contaminare		\N	2026-01-11 15:36:51.189271	0	2026-01-12 15:36:51.189271	{verbe,italien,pollution}	2.5	0	0	\N	\N	\N	Contaminate	Verunreinigen	ho nitera-pahavoazana	\N
1297	43bdd53	31	Dégrader	Degradare		\N	2026-01-11 15:36:51.210854	0	2026-01-12 15:36:51.210854	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Degrade	Degradieren	Manambany	\N
1298	4a9843c	31	Régénérer	Rigenerare		\N	2026-01-11 15:36:51.232888	0	2026-01-12 15:36:51.232888	{verbe,italien,action}	2.5	0	0	\N	\N	\N	Regenerate	Regenerieren	, vokatr'izany	\N
1299	5d1e78f	31	Restaurer	Restaurare		\N	2026-01-11 15:36:51.255303	0	2026-01-12 15:36:51.255303	{verbe,italien,conservation}	2.5	0	0	\N	\N	\N	Restore	Wiederherstellen	Ampodio	\N
2142	1f5fcb3	57	Atlas	Atlante		\N	2026-02-24 13:55:54.288583	0	2026-02-25 13:55:54.288583	{géographie,cartographie}	2.5	0	0	\N	\N	Raccolta di carte geografiche rilegate in volume.	Atlas	Atlas	Atlas	L'atlante scolastico contiene mappe di tutti i continenti.
2143	6a958f1	57	Boussole	Bussola		\N	2026-02-24 13:56:00.496286	0	2026-02-25 13:56:00.496286	{géographie,cartographie,orientation}	2.5	0	0	\N	\N	Strumento che indica la direzione del nord magnetico.	Compass	Kompass	Boussole	La bussola è indispensabile per l'orientamento in montagna.
2144	9710464	57	Satellite	Satellite		\N	2026-02-24 13:56:06.698971	0	2026-02-25 13:56:06.698971	{géographie,cartographie,technologie}	2.5	0	0	\N	\N	Corpo artificiale in orbita intorno alla Terra che fornisce immagini e dati.	Satellite	Satellit	Satellite	Il satellite Landsat monitora i cambiamenti ambientali.
1662	a7ff74d	39	essence	benzina		\N	2026-01-30 16:23:22.923646	0	2026-01-31 16:23:22.923646	{nom,italien,transport}	2.5	0	0	\N	\N	\N	gas	Gas	mandatsa-dranomaso	\N
1663	b97b83c	39	station-service	distributore		\N	2026-01-30 16:23:22.944517	0	2026-01-31 16:23:22.944517	{nom,italien,transport}	2.5	0	0	\N	\N	\N	distributor	Verteiler	mpizara	\N
1664	697a63f	39	diesel	gasolio		\N	2026-01-30 16:23:22.964966	0	2026-01-31 16:23:22.964966	{nom,italien,transport}	2.5	0	0	\N	\N	\N	diesel	Diesel	gazoala	\N
2566	5e4dfa6	65	dorsale	dorsale		https://upload.wikimedia.org/wikipedia/commons/4/4c/Alpinistes_Aiguille_du_Midi_03.JPG	2026-03-30 16:25:16.840502	0	2026-03-31 16:25:16.840502	{tectonique,structure_sous_marine}	2.5	0	0	\N	\N	Catena montuosa sottomarina che corre al centro degli oceani, dove si genera nuova crosta.	ridge	Rücken	havoana anaty ranomasina	L'Islanda è l'unico luogo dove la dorsale medio-atlantica emerge in superficie.
1666	61457e7	39	roue	ruota		\N	2026-01-30 16:23:23.005414	0	2026-01-31 16:23:23.005414	{nom,italien,transport}	2.5	0	0	\N	\N	\N	wheel	Rad	kodia	\N
1667	e990a19	39	pneu	pneumatico		\N	2026-01-30 16:23:23.024541	0	2026-01-31 16:23:23.024541	{nom,italien,transport}	2.5	0	0	\N	\N	\N	tire	Reifen	TYRO	\N
1665	8cae1c1	39	Moteur	motore		\N	2026-01-30 16:23:22.984676	0	2026-01-31 16:23:22.984676	{nom,italien,transport}	2.5	0	0	\N	\N	Dispositivo che trasforma energia in movimento.	Engine	Motor	Moteur	Il motore elettrico è silenzioso.
2567	0b1f7cb	65	orogenèse	orogenesi		https://upload.wikimedia.org/wikipedia/commons/a/aa/Cape_Orogeny_A5.png	2026-03-30 16:25:23.540708	0	2026-03-31 16:25:23.540708	{tectonique,orogenèse}	2.5	0	0	\N	\N	Insieme dei processi geologici che portano alla formazione di imponenti catene montuose.	orogeny	Orogenese	fiforonan-tendrombohitra	L'orogenesi alpina ha sollevato le montagne più alte d'Europa.
2568	032d88b	65	altération	alterazione		https://upload.wikimedia.org/wikipedia/commons/c/c4/Mountain_landscape%2C_Weathering_and_erosion_in_glacial_valley%2C_Ergaki%2C_Sayan_Mountains%2C_Siberia.jpg	2026-03-30 16:25:29.816789	0	2026-03-31 16:25:29.816789	{processus,géomorphologie}	2.5	0	0	\N	\N	Degradazione e scomposizione chimica o fisica dei materiali affioranti in superficie.	weathering	Verwitterung	fahasimbana	L'alterazione dei minerali di ferro produce la colorazione rossastra delle rocce.
2569	840c519	65	sédimentation	sedimentazione		https://upload.wikimedia.org/wikipedia/commons/6/6f/Erythrocyte_sedimentation_rate_%28ESR%29.jpg	2026-03-30 16:25:36.206368	0	2026-03-31 16:25:36.206368	{sédimentologie,processus}	2.5	0	0	\N	\N	Processo di accumulo e deposito di particelle solide trasportate da fluidi sulla superficie terrestre.	sedimentation	Sedimentation	fiangonan'ny antsanga	Il lago si sta riempiendo di sabbia a causa della forte sedimentazione fluviale.
2570	a6fb508	65	métamorphisme	metamorfismo		https://upload.wikimedia.org/wikipedia/commons/6/6d/RehbergerGrabenGoethePlatz.jpg	2026-03-30 16:25:42.591141	0	2026-03-31 16:25:42.591141	{pétrologie,processus}	2.5	0	0	\N	\N	Trasformazione di un minerale o di una massa lapidea preesistente allo stato solido per variazioni di pressione e temperatura.	metamorphism	Metamorphose	metamorfisma	Il marmo deriva dal metamorfismo di un preesistente banco calcareo.
1309	fed4504	32	Il fait très froid	Fare un freddo cane		\N	2026-01-12 12:49:14.586067	0	2026-01-13 12:49:14.586067	{expression,italien,animal,météo}	2.5	0	0	\N	\N	\N	It's freezing cold	Es ist eiskalt	Mangatsiaka ny andro	\N
1310	8e43c5e	32	Silence total	Non sentire volare una mosca		\N	2026-01-12 12:49:14.607972	0	2026-01-13 12:49:14.607972	{expression,italien,animal,silence}	2.5	0	0	\N	\N	\N	Don't hear a fly	Höre keine Fliege	Aza mandre lalitra	\N
1311	ec45ee7	32	Être très peu nombreux	Essere quattro gatti		\N	2026-01-12 12:49:14.630392	0	2026-01-13 12:49:14.630392	{expression,italien,animal,quantité}	2.5	0	0	\N	\N	\N	Being four cats	Vier Katzen sein	Ny maha-saka efatra	\N
1312	f526892	32	Avoir une excellente mémoire	Avere la memoria d’elefante		\N	2026-01-12 12:49:14.653387	0	2026-01-13 12:49:14.653387	{expression,italien,animal,mémoire}	2.5	0	0	\N	\N	\N	Have the memory of an elephant	Habe die Erinnerung an einen Elefanten	Manàna fahatsiarovana elefanta	\N
1313	1dac61b	32	Se coucher très tôt	Andare a letto con le galline		\N	2026-01-12 12:49:14.67515	0	2026-01-13 12:49:14.67515	{expression,italien,animal,habitude}	2.5	0	0	\N	\N	\N	Sleeping with chickens	Mit Hühnern schlafen	Matory miaraka amin'ny akoho	\N
1314	05d87d7	32	Avoir la chair de poule	Avere la pelle d’oca		\N	2026-01-12 12:49:14.696286	0	2026-01-13 12:49:14.696286	{expression,italien,animal,émotion}	2.5	0	0	\N	\N	\N	Having goosebumps	Gänsehaut bekommen	Manana goosebumps	\N
1315	42f8399	32	Être solitaire	Essere un lupo solitario		\N	2026-01-12 12:49:14.719703	0	2026-01-13 12:49:14.719703	{expression,italien,animal,personnalité}	2.5	0	0	\N	\N	\N	Being a lone wolf	Ein einsamer Wolf sein	Ny maha-amboadia irery	\N
1316	ea5814f	32	Se sentir coupable / susceptible	Avere la coda di paglia		\N	2026-01-12 12:49:14.739905	0	2026-01-13 12:49:14.739905	{expression,italien,animal,comportement}	2.5	0	0	\N	\N	\N	Having a straw tail	Einen Strohschwanz haben	Manana rambony mololo	\N
1658	68fff94	39	siège	posto		\N	2026-01-30 16:23:22.841386	0	2026-01-31 16:23:22.841386	{nom,italien,transport}	2.5	0	0	\N	\N	\N	place	Ort	Place	\N
1659	631c016	39	fenêtre / hublot	finestrino		\N	2026-01-30 16:23:22.860693	0	2026-01-31 16:23:22.860693	{nom,italien,transport}	2.5	0	0	\N	\N	\N	window	Fenster	varavarankely	\N
1660	7a0049d	39	couloir	corridoio		\N	2026-01-30 16:23:22.881132	0	2026-01-31 16:23:22.881132	{nom,italien,transport}	2.5	0	0	\N	\N	\N	hallway	Flur	lalantsara	\N
1661	b1564f5	39	parking	parcheggio		\N	2026-01-30 16:23:22.901407	0	2026-01-31 16:23:22.901407	{nom,italien,transport}	2.5	0	0	\N	\N	\N	parking	Parken	fijanonana	\N
2565	695f120	65	rift	rift		https://upload.wikimedia.org/wikipedia/commons/1/14/Rift_segmentation.png	2026-03-30 16:25:10.373534	0	2026-03-31 16:25:10.373534	{tectonique,structure}	2.5	0	0	\N	\N	Valle tettonica originata dalla distensione e dall'allontanamento di blocchi litosferici.	rift	Grabenbruch	hantsana	Il sistema del Rift africano sta lentamente dividendo in due il continente.
2150	5273697	57	Périphérie	Periferia		\N	2026-02-24 13:56:59.364619	0	2026-02-25 13:56:59.364619	{géographie,humaine,urbanisme}	2.5	0	0	\N	\N	Zona esterna di una città o di un paese rispetto al centro.	Periphery	Peripherie	Périphérie	La periferia industriale si è sviluppata negli anni Sessanta.
2151	3f56019	57	Urbanisme	Urbanistica		\N	2026-02-24 13:57:11.748173	0	2026-02-25 13:57:11.748173	{géographie,humaine}	2.5	0	0	\N	\N	Disciplina che pianifica lo sviluppo e l'organizzazione delle città.	Urban planning	Stadtplanung	Urbanisme	L'urbanistica moderna tiene conto della sostenibilità ambientale.
2152	9cc13dc	57	Aménagement	Pianificazione territoriale		\N	2026-02-24 13:57:18.830985	0	2026-02-25 13:57:18.830985	{géographie,humaine,développement}	2.5	0	0	\N	\N	Organizzazione razionale del territorio per usi residenziali, produttivi e ambientali.	Spatial planning	Raumplanung	Aménagement	L'aménagement du littoral protegge le zone naturali.
1317	4a88289	32	Agir directement	Prendere il toro per le corna		\N	2026-01-12 12:49:14.759539	0	2026-01-13 12:49:14.759539	{expression,italien,animal,action}	2.5	0	0	\N	\N	\N	Take the bull by the horns	Packt den Stier bei den Hörnern	Raiso ny omby amin'ny tandroka	\N
1318	6b4bb26	32	Ne rien dire	Essere muto come un pesce		\N	2026-01-12 12:49:14.778341	0	2026-01-13 12:49:14.778341	{expression,italien,animal,communication}	2.5	0	0	\N	\N	\N	To be as dumb as a fish	So dumm wie ein Fisch sein	Ho moana toy ny trondro	\N
1319	cad693a	32	Être grognon	Essere un orso		\N	2026-01-12 12:49:14.799553	0	2026-01-13 12:49:14.799553	{expression,italien,animal,caractère}	2.5	0	0	\N	\N	\N	Being a bear	Ein Bär sein	Ny hoe orsa	\N
1668	f79c7bf	39	volant	volante		\N	2026-01-30 16:23:23.047219	0	2026-01-31 16:23:23.047219	{nom,italien,transport}	2.5	0	0	\N	\N	\N	steering wheel	Lenkrad	familiana	\N
1669	a4bcf48	39	frein	freno		\N	2026-01-30 16:23:23.067414	0	2026-01-31 16:23:23.067414	{nom,italien,transport}	2.5	0	0	\N	\N	\N	brake	Bremse	notapahiny	\N
1670	a890ce5	39	phare (véhicule)	faro		\N	2026-01-30 16:23:23.08884	0	2026-01-31 16:23:23.08884	{nom,italien,transport}	2.5	0	0	\N	\N	\N	lighthouse	Leuchtturm	tilikambo fanilon-tsambo	\N
1671	7db98c1	39	ceinture de sécurité	cintura di sicurezza		\N	2026-01-30 16:23:23.109248	0	2026-01-31 16:23:23.109248	{nom,italien,transport}	2.5	0	0	\N	\N	\N	seat belt	Sicherheitsgurt	fehin-tseza	\N
2145	abd7b5f	57	Repère	Punto di riferimento		\N	2026-02-24 13:56:12.994754	0	2026-02-25 13:56:12.994754	{géographie,cartographie,orientation}	2.5	0	0	\N	\N	Elemento visibile e riconoscibile utilizzato per orientarsi.	Landmark	Orientierungspunkt	Repère	La torre Eiffel è un importante punto di riferimento a Parigi.
1088	4af3b25	28	Habitat	Habitat		\N	2026-01-08 15:19:19.961101	1	2026-02-02 15:38:43.207691	{nom,italien,biodiversité}	2.6	1	1	\N	\N	Luogo in cui vive una popolazione o una comunità umana.	Habitat	Lebensraum	Habitat	L'habitat rurale tradizionale è formato da case isolate.
2147	c31763e	57	Village	Villaggio		\N	2026-02-24 13:56:32.894676	0	2026-02-25 13:56:32.894676	{géographie,humaine,urbanisme}	2.5	0	0	\N	\N	Piccolo agglomerato rurale di case e abitazioni.	Village	Dorf	Tanàna kely	Il villaggio di montagna conserva tradizioni antiche.
2148	533b8da	57	Agglomération	Agglomerato		\N	2026-02-24 13:56:46.53752	0	2026-02-25 13:56:46.53752	{géographie,humaine,urbanisme}	2.5	0	0	\N	\N	Insieme continuo di abitazioni e infrastrutture che formano un'entità urbana.	Urban area	Ballungsraum	Agglomération	L'agglomerato di Parigi supera i 12 milioni di abitanti.
2149	393450d	57	Métropole	Metropoli		\N	2026-02-24 13:56:53.174303	0	2026-02-25 13:56:53.174303	{géographie,humaine,urbanisme}	2.5	0	0	\N	\N	Grande città che esercita un ruolo dominante a livello nazionale o internazionale.	Metropolis	Metropole	Métropole	New York è una metropoli globale.
1678	6cb92c4	39	destination	destinazione		\N	2026-01-30 16:23:23.253521	0	2026-01-31 16:23:23.253521	{nom,italien,transport}	2.5	0	0	\N	\N	\N	destination	Ziel	toerana halehany	\N
1673	3e89545	39	Vitesse	velocità		\N	2026-01-30 16:23:23.152992	0	2026-01-31 16:23:23.152992	{nom,italien,transport}	2.5	0	0	\N	\N	Capacità di compiere un movimento o coprire una distanza in poco tempo.	Speed	Geschwindigkeit	Hafaingana	La velocità è decisiva nello sprint finale.
2157	8f3d4a9	57	Exploitation	Sfruttamento		\N	2026-02-24 13:58:03.377895	0	2026-02-25 13:58:03.377895	{géographie,économie,ressources}	2.5	0	0	\N	\N	Attività di estrazione e utilizzo economico di risorse naturali.	Exploitation	Ausbeutung	Exploitation	Lo sfruttamento sostenibile delle foreste preserva la biodiversità.
2168	c927501	57	Territoire	Territorio		\N	2026-02-24 13:59:20.373294	0	2026-02-25 13:59:20.373294	{géographie,politique}	2.5	0	0	\N	\N	Estensione di terra sottoposta alla sovranità di uno stato.	Territory	Territorium	Faritra	Il territorio nazionale italiano include isole e penisola.
1676	8b0a8e3	39	GPS	navigatore		\N	2026-01-30 16:23:23.214913	0	2026-01-31 16:23:23.214913	{nom,italien,transport}	2.5	0	0	\N	\N	\N	navigator	Navigator	tantsambo	\N
1677	4927140	39	direction	direzione		\N	2026-01-30 16:23:23.233954	0	2026-01-31 16:23:23.233954	{nom,italien,transport}	2.5	0	0	\N	\N	\N	direction	Richtung	tari-dalana	\N
1732	b515b25	40	intelligent	intelligente		\N	2026-01-31 15:19:21.507782	0	2026-02-01 15:19:21.507782	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	\N	intelligent	intelligent	manan-tsaina	\N
1674	6c61269	39	Distance	distanza		\N	2026-01-30 16:23:23.173294	0	2026-01-31 16:23:23.173294	{nom,italien,transport}	2.5	0	0	\N	\N	Spazio percorso durante un'attività.	Distance	Distanz	Distance	La distanza coperta oggi è di 10 km.
2158	1f36abf	57	Sylviculture	Selvicoltura		\N	2026-02-24 13:58:10.016632	0	2026-02-25 13:58:10.016632	{géographie,économie,ressources}	2.5	0	0	\N	\N	Gestione e coltivazione delle foreste per produrre legname.	Forestry	Forstwirtschaft	Sylviculture	La selvicoltura sostenibile garantisce il rinnovo delle risorse legnose.
2159	f5cd2fe	57	Hydroélectricité	Idroelettricità		\N	2026-02-24 13:58:23.647063	0	2026-02-25 13:58:23.647063	{géographie,économie,énergie}	2.5	0	0	\N	\N	Energia elettrica prodotta sfruttando la forza motrice dell'acqua.	Hydroelectricity	Wasserkraft	Hydroélectricité	L'idroelettricità rappresenta una quota importante dell'energia rinnovabile in Italia.
2160	9a3036e	57	Frontière	Frontiera		\N	2026-02-24 13:58:30.072935	0	2026-02-25 13:58:30.072935	{géographie,politique}	2.5	0	0	\N	\N	Linea che separa due stati o territori sovrani.	Border	Grenze	Sisin-tany	La frontiera tra Italia e Francia segue le Alpi.
2161	5d881b1	57	Zone	Zona		\N	2026-02-24 13:58:36.68682	0	2026-02-25 13:58:36.68682	{géographie,politique,aménagement}	2.5	0	0	\N	\N	Area delimitata con caratteristiche o funzioni specifiche.	Zone	Zone	Faritra	La zona industriale si trova nella periferia est della città.
2163	124d6bc	57	Péninsule	Penisola		\N	2026-02-24 13:58:49.145209	0	2026-02-25 13:58:49.145209	{géographie,physique}	2.5	0	0	\N	\N	Porzione di terra circondata dal mare su tre lati.	Peninsula	Halbinsel	Peninsula	La penisola italiana ha una forma a stivale.
2164	dc90a2f	57	Région	Regione		\N	2026-02-24 13:58:55.597981	0	2026-02-25 13:58:55.597981	{géographie,politique,aménagement}	2.5	0	0	\N	\N	Porzione di territorio con caratteristiche geografiche, economiche o amministrative comuni.	Region	Region	Faritra	La regione Lombardia è la più popolosa d'Italia.
2165	77ae494	57	Province	Provincia		\N	2026-02-24 13:59:01.71413	0	2026-02-25 13:59:01.71413	{géographie,politique}	2.5	0	0	\N	\N	Suddivisione amministrativa di uno stato o di una regione.	Province	Provinz	Faritany	La provincia di Firenze comprende molti comuni.
2166	fa18eea	57	Département	Dipartimento		\N	2026-02-24 13:59:07.61993	0	2026-02-25 13:59:07.61993	{géographie,politique}	2.5	0	0	\N	\N	Unità amministrativa territoriale in Francia e in alcuni altri paesi.	Department	Departement	Département	Il dipartimento delle Alpi Marittime confina con l'Italia.
2167	fbe33c8	57	Bassin versant	Bacino idrografico		\N	2026-02-24 13:59:13.727532	0	2026-02-25 13:59:13.727532	{géographie,hydrologie}	2.5	0	0	\N	\N	Area dalla quale tutte le acque superficiali confluiscono in un unico corso d'acqua principale.	Watershed	Einzugsgebiet	Bassin versant	Il bacino idrografico del Po è il più grande d'Italia.
2169	8f77d57	57	Littoral	Litorale		\N	2026-02-24 13:59:26.09084	0	2026-02-25 13:59:26.09084	{géographie,physique}	2.5	0	0	\N	\N	Zona di contatto tra terra e mare lungo le coste.	Coastline	Küste	Sisin-drano	Il litorale adriatico è caratterizzato da spiagge sabbiose.
1679	ca0641f	39	voyage	viaggio		\N	2026-01-30 16:23:23.275491	0	2026-01-31 16:23:23.275491	{nom,italien,transport}	2.5	0	0	\N	\N	\N	voyage	Reise	diany	\N
1680	5ccacc8	39	touriste	turista		\N	2026-01-30 16:23:23.362538	0	2026-01-31 16:23:23.362538	{nom,italien,transport}	2.5	0	0	\N	\N	\N	tourist	Tourist	mpizaha tany	\N
1681	57a92f5	39	vacances	vacanza		\N	2026-01-30 16:23:23.390867	0	2026-01-31 16:23:23.390867	{nom,italien,transport}	2.5	0	0	\N	\N	\N	vacation	Urlaub	vakansy	\N
1682	a2ff2b5	39	aller simple	andata		\N	2026-01-30 16:23:23.423561	0	2026-01-31 16:23:23.423561	{nom,italien,transport}	2.5	0	0	\N	\N	\N	gone	gegangen	lasa	\N
1683	ffd947d	39	aller-retour	andata e ritorno		\N	2026-01-30 16:23:23.444293	0	2026-01-31 16:23:23.444293	{nom,italien,transport}	2.5	0	0	\N	\N	\N	round trip	Rundfahrt	dia mandroso sy miverina	\N
1684	e204494	39	pont	ponte		\N	2026-01-30 16:23:23.468892	0	2026-01-31 16:23:23.468892	{nom,italien,transport}	2.5	0	0	\N	\N	\N	bridge	Brücke	tetezana	\N
1685	5ab3809	39	tunnel	galleria		\N	2026-01-30 16:23:23.489479	0	2026-01-31 16:23:23.489479	{nom,italien,transport}	2.5	0	0	\N	\N	\N	gallery	Galerie	galeria	\N
2050	6fa3c27	60	Développement	Sviluppo		\N	2026-02-24 13:17:57.658027	0	2026-02-25 13:17:57.658027	{économie,société}	2.5	0	0	\N	\N	Processo di crescita economica, sociale e infrastrutturale di un territorio.	Development	Entwicklung	Fandrosoana	Lo sviluppo sostenibile rispetta l'ambiente.
2170	9e4e132	57	Croissance	Crescita		\N	2026-02-24 13:59:38.420536	0	2026-02-25 13:59:38.420536	{géographie,économie}	2.5	0	0	\N	\N	Aumento della popolazione o dell'economia in un determinato periodo.	Growth	Wachstum	Fitomboana	La crescita demografica è forte nei paesi in via di sviluppo.
2171	17fb4a3	57	Pauvreté	Povertà		\N	2026-02-24 13:59:44.241771	0	2026-02-25 13:59:44.241771	{géographie,humaine,économie}	2.5	0	0	\N	\N	Condizione di mancanza di risorse economiche e sociali sufficienti.	Poverty	Armut	Fahambaniana	La povertà è concentrata nelle aree rurali di molti paesi.
2172	33d8830	57	Richesse	Ricchezza		\N	2026-02-24 13:59:50.993554	0	2026-02-25 13:59:50.993554	{géographie,humaine,économie}	2.5	0	0	\N	\N	Abbondanza di risorse economiche e materiali.	Wealth	Reichtum	Harena	La ricchezza delle nazioni petrolifere deriva dalle esportazioni.
2173	b74e4f6	57	Inégalité	Disuguaglianza		\N	2026-02-24 13:59:57.692017	0	2026-02-25 13:59:57.692017	{géographie,humaine,économie}	2.5	0	0	\N	\N	Differenza nella distribuzione della ricchezza o delle opportunità tra gruppi.	Inequality	Ungleichheit	Tsy mitovy	La disuguaglianza sociale è un problema nelle grandi città.
2174	a4d08cb	57	Indice	Indice		\N	2026-02-24 14:00:04.062983	0	2026-02-25 14:00:04.062983	{géographie,humaine,économie}	2.5	0	0	\N	\N	Valore numerico che misura un fenomeno socio-economico.	Index	Index	Indice	L'indice di sviluppo umano classifica i paesi.
2175	ee15950	57	Alphabétisation	Alfabetizzazione		\N	2026-02-24 14:00:10.610316	0	2026-02-25 14:00:10.610316	{géographie,humaine}	2.5	0	0	\N	\N	Capacità di leggere e scrivere della popolazione adulta.	Literacy	Alphabetisierung	Fahaizana mamaky teny	L'alfabetizzazione è aumentata grazie alle politiche scolastiche.
2176	8d37d65	57	Espérance de vie	Speranza di vita		\N	2026-02-24 14:00:16.894448	0	2026-02-25 14:00:16.894448	{géographie,humaine}	2.5	0	0	\N	\N	Numero medio di anni che una persona può aspettarsi di vivere.	Life expectancy	Lebenserwartung	Esperansa fiainana	La speranza di vita in Giappone supera gli 84 anni.
2177	300925d	57	Mondialisation	Globalizzazione		\N	2026-02-24 14:00:29.558459	0	2026-02-25 14:00:29.558459	{géographie,économie,humaine}	2.5	0	0	\N	\N	Processo di integrazione economica, culturale e politica a livello mondiale.	Globalization	Globalisierung	Mondialisation	La globalizzazione ha aumentato gli scambi commerciali tra i continenti.
1795	97bb863	40	Prétentieux	presuntuoso		\N	2026-01-31 15:19:22.779243	0	2026-02-01 15:19:22.779243	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che si vanta eccessivamente.	Pretentious	Anmaßend	Mibohaka	Il suo atteggiamento presuntuoso è insopportabile.
2571	58d9077	65	fusion	fusione		https://upload.wikimedia.org/wikipedia/commons/6/64/Melting_ice_thermometer.jpg	2026-03-30 16:25:48.417307	0	2026-03-31 16:25:48.417307	{pétrologie,volcanologie}	2.5	0	0	\N	\N	Passaggio dallo stato solido a quello liquido, che in profondità genera i fusi magmatici.	melting	Schmelzen	fitsonihana	L'aumento della temperatura in profondità favorisce la parziale fusione delle rocce.
2572	d29dc70	65	cristallisation	cristallizzazione		https://upload.wikimedia.org/wikipedia/commons/c/ce/Process-of-Crystallization-200px.png	2026-03-30 16:25:54.856107	0	2026-03-31 16:25:54.856107	{minéralogie,processus}	2.5	0	0	\N	\N	Processo attraverso il quale ioni o molecole si aggregano per formare una struttura solida geometricamente ordinata.	crystallization	Kristallisation	fikristaliana	La lenta cristallizzazione del fuso favorisce la crescita di grossi frammenti trasparenti.
2573	20d0f3e	65	pression	pressione		https://upload.wikimedia.org/wikipedia/commons/8/8e/Joukowsky-Pressure-Shock-01.jpg	2026-03-30 16:26:00.851972	0	2026-03-31 16:26:00.851972	{physique_du_globe,paramètre}	2.5	0	0	\N	\N	La forza per unità di area esercitata dal peso delle rocce sovrastanti in profondità.	pressure	Druck	tsindry	La forte pressione a grandi profondità favorisce la formazione di diamanti.
1686	80f08c9	39	péage	pedaggio		\N	2026-01-30 16:23:23.510179	0	2026-01-31 16:23:23.510179	{nom,italien,transport}	2.5	0	0	\N	\N	\N	toll	Maut	Peazy	\N
1687	3f38624	39	amende	multa		\N	2026-01-30 16:23:23.530861	0	2026-01-31 16:23:23.530861	{nom,italien,transport}	2.5	0	0	\N	\N	\N	fine	Bußgeld	TSARA	\N
1688	46b18f4	39	police	polizia		\N	2026-01-30 16:23:23.548864	0	2026-01-31 16:23:23.548864	{nom,italien,transport}	2.5	0	0	\N	\N	\N	police	Polizei	polisy	\N
1689	b384da3	39	ambulance	ambulanza		\N	2026-01-30 16:23:23.570011	0	2026-01-31 16:23:23.570011	{nom,italien,transport}	2.5	0	0	\N	\N	\N	ambulance	Krankenwagen	fiara mpitondra marary	\N
1690	ea46b64	39	pompier	pompiere		\N	2026-01-30 16:23:23.589085	0	2026-01-31 16:23:23.589085	{nom,italien,transport}	2.5	0	0	\N	\N	\N	firemen	Feuerwehrmänner	mpamono afo	\N
170	d1f57d7	10	Méchant	Cattivo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f44e.svg	2025-12-03 13:40:49.37182	1	2025-12-07 15:48:05.073221	{adjectif,italien,fréquent,qualité}	2.6	1	1	\N	\N	Persona che agisce con cattiveria verso gli altri.	Mean	Böse	Ratsy fanahy	È cattivo con gli animali.
199	d7fbb13	10	En colère	Arrabbiato		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f621.svg	2025-12-03 13:40:49.96834	1	2025-12-07 16:01:33.231965	{adjectif,italien,fréquent,émotion}	2.6	1	1	\N	\N	Persona che manifesta rabbia.	Angry	Wütend	Tezitra	È arrabbiato per il ritardo.
201	0289fd1	10	Nerveux	Nervoso		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f630.svg	2025-12-03 13:40:50.010083	0	2025-12-06 15:57:46.559611	{adjectif,italien,fréquent,émotion}	2.3	0	0	\N	\N	Persona facilmente agitata o tesa.	Nervous	Nervös	Mora tezitra	Diventa nervoso prima degli esami.
225	238782c	10	Gentil	Gentile		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f970.svg	2025-12-03 13:40:50.476739	1	2025-12-07 15:53:15.635175	{adjectif,italien,fréquent,politesse}	2.6	1	1	\N	\N	Persona che dimostra cortesia e benevolenza verso gli altri.	Kind	Freundlich	Tsara fanahy	È una persona gentile che aiuta sempre i vicini senza chiedere nulla in cambio.
227	d0c3cf4	10	Sympathique	Simpatico		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f60a.svg	2025-12-03 13:40:50.513563	1	2025-12-07 15:57:02.914678	{adjectif,italien,fréquent,personnalité}	2.6	1	1	\N	\N	Persona che ispira simpatia e crea un'atmosfera positiva intorno a sé.	Likeable	Sympathisch	Mahafinaritra	Il mio collega è molto simpatico e rende il lavoro più leggero.
229	69bfd7e	10	Joyeux	Allegro		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f389.svg	2025-12-03 13:40:50.548225	1	2025-12-07 15:55:57.929954	{adjectif,italien,fréquent,émotion}	2.6	1	1	\N	\N	Persona che trasmette allegria.	Cheerful	Fröhlich	Falifaly	Il suo sorriso allegro illumina la stanza.
231	b92c186	10	Intelligent	Intelligente		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f9e0.svg	2025-12-03 13:40:50.583231	1	2025-12-07 15:52:34.009782	{adjectif,italien,fréquent,intelligence}	2.6	1	1	\N	\N	Persona dotata di acutezza mentale e capacità di comprendere rapidamente.	Intelligent	Intelligent	Marenina	È un ragazzo intelligente che risolve i problemi con facilità.
236	728bcf3	10	Sincère	Sincero		\N	2025-12-03 13:40:50.675232	1	2025-12-07 15:53:33.021146	{adjectif,italien,fréquent,morale}	2.6	1	1	\N	\N	Persona che esprime i propri sentimenti in modo autentico.	Sincere	Aufrichtig	Mijoro	Le sue scuse erano sincere e hanno risolto il malinteso.
1730	6beb703	40	Agréable	piacevole		\N	2026-01-31 15:19:21.477511	0	2026-02-01 15:19:21.477511	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che rende gradevole ogni momento passato insieme.	Pleasant	Angenehm	Mahafinaritra	È sempre piacevole chiacchierare con lei.
1731	5293068	40	Fascinant	affascinante		\N	2026-01-31 15:19:21.492357	0	2026-02-01 15:19:21.492357	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che attira l'attenzione per la sua personalità unica e coinvolgente.	Fascinating	Faszinierend	Mahasarika	Il suo modo di raccontare storie è affascinante.
1733	0a29be4	40	Curieux	curioso		\N	2026-01-31 15:19:21.542248	0	2026-02-01 15:19:21.542248	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che mostra vivo interesse per il mondo e le novità.	Curious	Neugierig	Mafana an-tsaina	Il bambino curioso fa mille domande su tutto.
2587	e993716	65	cratère	cratere		https://upload.wikimedia.org/wikipedia/commons/0/01/Crater_Lake_winter_pano2.jpg	2026-03-30 16:27:34.958649	0	2026-03-31 16:27:34.958649	{volcanologie,géomorphologie}	2.5	0	0	\N	\N	Depressione circolare sulla sommità del cono eruttivo da cui vengono emessi i materiali incandescenti.	crater	Krater	vava volokano	Un lago acido e fumante occupa attualmente l'antico cratere della montagna esplosa.
2588	6c3374b	65	caldeira	caldera		https://upload.wikimedia.org/wikipedia/commons/7/71/Caldera_de_Masi%C3%A1n_-_Lanzarote.JPG	2026-03-30 16:27:41.549022	0	2026-03-31 16:27:41.549022	{volcanologie,structure}	2.5	0	0	\N	\N	Ampia e grande depressione vulcanica prodotta dal collasso della parte superiore dell'edificio montuoso.	caldera	Caldera	kalderà	Yellowstone è famoso per la sua super caldera generata da imponenti esplosioni preistoriche.
1744	0836c90	40	Généreux	generoso		\N	2026-01-31 15:19:21.836824	0	2026-02-01 15:19:21.836824	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che dona volentieri tempo, risorse o aiuto.	Generous	Großzügig	Malala-tsaina	È generoso e condivide tutto con gli amici.
1745	8b78f96	40	Loyal	leale		\N	2026-01-31 15:19:21.851708	0	2026-02-01 15:19:21.851708	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona fedele e affidabile nei rapporti.	Loyal	Loyal	Miaro	È leale e non tradisce mai la fiducia degli amici.
2574	3f7fb2b	65	température	temperatura		https://upload.wikimedia.org/wikipedia/commons/3/3f/Temperature_anomalies_1980_%2836265512256%29.png	2026-03-30 16:26:07.778232	0	2026-03-31 16:26:07.778232	{physique_du_globe,paramètre}	2.5	0	0	\N	\N	Grandezza fisica che misura lo stato termico; aumenta costantemente verso il centro del pianeta.	temperature	Temperatur	maripana	Nelle miniere molto profonde, la temperatura dell'ambiente raggiunge valori molto elevati.
2575	3d7e383	65	densité	densità		https://upload.wikimedia.org/wikipedia/commons/4/44/Global_density_vs._local_density.png	2026-03-30 16:26:15.116424	0	2026-03-31 16:26:15.116424	{physique_du_globe,paramètre}	2.5	0	0	\N	\N	Il rapporto tra massa e volume; determina l'affondamento o il galleggiamento dei materiali litosferici.	density	Dichte	hakitroka	A causa dell'elevata densità della placca oceanica, questa affonda sotto quella continentale.
2576	88533e6	65	porosité	porosità		https://upload.wikimedia.org/wikipedia/commons/e/e4/Int_Pore.png	2026-03-30 16:26:21.962837	0	2026-03-31 16:26:21.962837	{hydrogéologie,paramètre}	2.5	0	0	\N	\N	Percentuale di spazi vuoti presenti in un volume totale di deposito solido.	porosity	Porosität	havokovoka	Una buona roccia serbatoio per il petrolio deve possedere un'alta porosità.
2577	3d1d186	65	perméabilité	permeabilità		https://upload.wikimedia.org/wikipedia/commons/9/98/Magnetic_Permeability-no-caption.gif	2026-03-30 16:26:28.611581	0	2026-03-31 16:26:28.611581	{hydrogéologie,paramètre}	2.5	0	0	\N	\N	Attitudine di un materiale geologico a lasciarsi attraversare dai fluidi come acqua e idrocarburi.	permeability	Permeabilität	fahafahan-drano mandalo	I depositi argillosi hanno una permeabilità quasi nulla.
2578	96e32cc	65	dureté	durezza		https://upload.wikimedia.org/wikipedia/commons/5/58/Hardness-chart.jpg	2026-03-30 16:26:35.88018	0	2026-03-31 16:26:35.88018	{minéralogie,propriété}	2.5	0	0	\N	\N	Resistenza offerta da una specie minerale alla scalfitura o all'abrasione, misurata dalla scala di Mohs.	hardness	Härte	hamafy	Il diamante possiede la durezza massima tra tutti i materiali naturali conosciuti.
2579	3f19699	65	clivage	sfaldatura		https://upload.wikimedia.org/wikipedia/commons/3/3b/Cleavage_of_a_woman.jpg	2026-03-30 16:26:42.553262	0	2026-03-31 16:26:42.553262	{minéralogie,propriété}	2.5	0	0	\N	\N	Tendenza di un minerale a rompersi lungo piani preferenziali dove i legami chimici sono più deboli.	cleavage	Spaltbarkeit	fivakisana	La mica è famosa per la sua sfaldatura perfetta in lamine sottilissime.
2580	1afa787	65	fracture	frattura		https://upload.wikimedia.org/wikipedia/commons/1/1a/Fracturing.png	2026-03-30 16:26:49.175793	0	2026-03-31 16:26:49.175793	{géologie_structurale,déformation}	2.5	0	0	\N	\N	Rottura irregolare all'interno di un banco solido o di un minerale in assenza di piani preferenziali.	fracture	Bruch	vaky	La pressione tettonica ha causato una profonda frattura nell'ammasso roccioso.
2581	8f1ed33	65	affleurement	affioramento		https://upload.wikimedia.org/wikipedia/commons/b/bd/Outcrop_of_laminated_quartzite_-_cyclopedia_of_western_australia.jpg	2026-03-30 16:26:55.517743	0	2026-03-31 16:26:55.517743	{cartographie,terrain}	2.5	0	0	\N	\N	Esposizione diretta della componente lapidea del sottosuolo sulla superficie terrestre.	outcrop	Aufschluss	vato mipoitra	Lungo la trincea stradale c'è un interessante affioramento di depositi del Giurassico.
2582	52cf545	65	épicentre	epicentro		https://upload.wikimedia.org/wikipedia/commons/2/26/Kiss-epicenter2010.jpg	2026-03-30 16:27:02.471273	0	2026-03-31 16:27:02.471273	{sismologie,risque}	2.5	0	0	\N	\N	Il punto sulla superficie del suolo che si trova verticalmente sopra la zona di origine di un evento sismico.	epicenter	Epizentrum	ivon'ny horohorontany	I danni maggiori si sono registrati nei paesi più vicini all'epicentro del terremoto.
2583	938c2bd	65	hypocentre	ipocentro		https://upload.wikimedia.org/wikipedia/commons/1/13/Hipocentro_y_epicentro.png	2026-03-30 16:27:09.15007	0	2026-03-31 16:27:09.15007	{sismologie,dynamique}	2.5	0	0	\N	\N	Il punto di origine profondo in cui si verifica la rottura che innesca l'evento sismico.	hypocenter	Hypozentrum	fototry ny horohorontany	I sismologi hanno calcolato che l'ipocentro si trovava a venti chilometri di profondità.
2584	0892708	65	onde sismique	onda sismica		https://upload.wikimedia.org/wikipedia/commons/3/38/Pswaves.jpg	2026-03-30 16:27:15.766556	0	2026-03-31 16:27:15.766556	{sismologie,physique_du_globe}	2.5	0	0	\N	\N	Propagazione di energia elastica attraverso la terra a seguito della frattura sotterranea improvvisa.	seismic wave	seismische Welle	onjan-korohorontany	I sismografi registrano ogni minima onda sismica prodotta dai movimenti del sottosuolo.
2585	e8f377b	65	magnitude	magnitudo		https://upload.wikimedia.org/wikipedia/commons/9/9f/Earthquake_Magnitude_5.1_NEAR_WEST_COAST_OF_HONSHU%2C_JAPAN_2.png	2026-03-30 16:27:22.03066	0	2026-03-31 16:27:22.03066	{sismologie,mesure}	2.5	0	0	\N	\N	Misura quantitativa dell'energia sprigionata da una scossa tellurica alla sorgente.	magnitude	Magnitude	halehibe	La scossa principale ha registrato una magnitudo di 6.5 sulla scala Richter.
2586	a5ea3fd	65	tsunami	maremoto		https://upload.wikimedia.org/wikipedia/commons/4/47/2004_Indonesia_Tsunami_Complete.gif	2026-03-30 16:27:28.749458	0	2026-03-31 16:27:28.749458	{sismologie,océanographie,risque}	2.5	0	0	\N	\N	Serie di imponenti ondate generate dallo spostamento improvviso di grandi volumi d'acqua causato da scosse subacquee.	tsunami	Tsunami	tsunami	Il violento evento sottomarino ha generato un maremoto distruttivo sulle coste vicine.
2602	dacda8f	65	carbone	carbonio		https://upload.wikimedia.org/wikipedia/commons/0/0f/Glassy_carbon_and_a_1cm3_graphite_cube_HP68-79.jpg	2026-03-30 16:29:28.726151	0	2026-03-31 16:29:28.726151	{géochimie,élément}	2.5	0	0	\N	\N	L'elemento chimico base della materia organica e dei combustibili fossili.	carbon	Kohlenstoff	karbônina	Il diamante e la grafite sono forme pure ma cristallizzate diversamente del carbonio.
2603	09bbdec	65	oxygène	ossigeno		https://upload.wikimedia.org/wikipedia/commons/c/c3/Liquid_oxygen_in_a_beaker_4.jpg	2026-03-30 16:29:35.295511	0	2026-03-31 16:29:35.295511	{géochimie,élément}	2.5	0	0	\N	\N	Elemento gassoso fondamentale e il più abbondante in assoluto come massa nella crosta solida planetaria.	oxygen	Sauerstoff	ôksizenina	Combinandosi con il silicio, l'ossigeno forma la maggior parte dei reticoli minerali esistenti.
1760	c31c746	40	Colérique	collerico		\N	2026-01-31 15:19:22.088297	0	2026-02-01 15:19:22.088297	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che si arrabbia facilmente e in modo violento.	Hot-tempered	Jähzornig	Mora tezitra	Il suo carattere collerico crea spesso problemi.
1761	ecc9c3c	40	Agressif	aggressivo		\N	2026-01-31 15:19:22.104964	0	2026-02-01 15:19:22.104964	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che tende a comportarsi in modo ostile.	Aggressive	Aggressiv	Mora manafika	Il suo tono aggressivo spaventa i colleghi.
2589	423c8bd	65	cendre	cenere		https://upload.wikimedia.org/wikipedia/commons/e/e7/Pet%C5%99%C3%ADn_tower_05_2018.jpg	2026-03-30 16:27:47.395601	0	2026-03-31 16:27:47.395601	{volcanologie,matériaux}	2.5	0	0	\N	\N	Minuti frammenti polverizzati di magma solido proiettati nell'aria durante le fasi esplosive.	ash	Asche	lavenona	Dopo l'esplosione, l'intera città fu coperta da un sottile strato di grigia cenere vulcanica.
2590	fb1c29b	65	pôle	polo		https://upload.wikimedia.org/wikipedia/commons/f/f3/Leichtathletik_Gala_Linz_2018_pole_vault_Preiner_Katrin-5628.jpg	2026-03-30 16:27:54.821922	0	2026-03-31 16:27:54.821922	{géodésie,géographie}	2.5	0	0	\N	\N	Ciascuno dei due punti in cui l'asse di rotazione del pianeta incontra la superficie esterna.	pole	Pol	tendro	A causa dei movimenti del metallo liquido nel nucleo, il polo magnetico si sposta lentamente nel tempo.
2591	33bffe5	65	équateur	equatore		https://upload.wikimedia.org/wikipedia/commons/7/77/Cayambe_Equator_monument_02.jpg	2026-03-30 16:28:02.95355	0	2026-03-31 16:28:02.95355	{géodésie,géographie}	2.5	0	0	\N	\N	Linea immaginaria massima sulla superficie terrestre, equidistante dagli estremi dell'asse di rotazione.	equator	Äquator	ekoatera	Il clima è tipicamente molto umido e caldo vicino all'equatore.
2592	bf0172d	65	latitude	latitudine		https://upload.wikimedia.org/wikipedia/commons/0/0b/Latitude_Sydney.jpg	2026-03-30 16:28:09.226895	0	2026-03-31 16:28:09.226895	{géodésie,cartographie}	2.5	0	0	\N	\N	Distanza angolare di un punto dall'equatore verso il Nord o il Sud.	latitude	Breite	laharam-pehintany	Roma si trova a una latitudine di circa 41 gradi nord.
2593	32af4a0	65	longitude	longitudine		https://upload.wikimedia.org/wikipedia/commons/f/f4/Longitude_%28PSF%29.png	2026-03-30 16:28:16.489386	0	2026-03-31 16:28:16.489386	{géodésie,cartographie}	2.5	0	0	\N	\N	Distanza angolare di un punto calcolata dal meridiano di riferimento di Greenwich verso Est o Ovest.	longitude	Länge	laharan-jarahasina	Le coordinate GPS calcolano con precisione la posizione unendo latitudine e longitudine.
2594	58391d5	65	topographie	topografia		https://upload.wikimedia.org/wikipedia/commons/f/f7/%D9%86%D9%82%D8%B4%D9%87_%D9%85%DB%8C%D8%AF%D8%A7%D9%86_%D9%87%D8%A7%DB%8C_%DA%AF%D8%A7%D8%B2%DB%8C_%D9%88_%D9%86%D9%81%D8%AA%DB%8C_%D8%A7%D8%B3%D8%AA%D8%A7%D9%86_%D8%A8%D9%88%D8%B4%D9%87%D8%B1_%D8%A8%D9%87_%D9%87%D9%85%D8%B1%D8%A7%D9%87_%D8%A7%D8%B7%D9%84%D8%A7%D8%B9%D8%A7%D8%AA_%D8%AA%D9%88%D9%BE%D9%88%DA%AF%D8%B1%D8%A7%D9%81%DB%8C_%D9%88_%DA%98%D8%B1%D9%81%D8%A7%D8%B3%D9%86%D8%AC%DB%8C.png	2026-03-30 16:28:23.205716	0	2026-03-31 16:28:23.205716	{cartographie,géomorphologie}	2.5	0	0	\N	\N	Lo studio delle forme della superficie terrestre e la loro rappresentazione accurata su carta.	topography	Topographie	topografia	L'analisi accurata della topografia dell'area ha permesso di prevedere l'andamento del flusso dei detriti.
2595	1b02955	65	carte	mappa		https://upload.wikimedia.org/wikipedia/commons/5/5c/Araschnia_levana_caterpillar_-_Keila.jpg	2026-03-30 16:28:30.99457	0	2026-03-31 16:28:30.99457	{cartographie,outil}	2.5	0	0	\N	\N	Rappresentazione ridotta e simbolica su un piano di un'area geografica o di formazioni sottostanti.	map	Karte	saritany	Il ricercatore ha esaminato la vecchia mappa per ritrovare i filoni d'oro abbandonati.
2596	cacdf18	65	échelle	scala		https://upload.wikimedia.org/wikipedia/commons/0/0f/Keeled_scales_on_a_southern_watersnake_%2826954310414%29.jpg	2026-03-30 16:28:37.661321	0	2026-03-31 16:28:37.661321	{cartographie,mesure}	2.5	0	0	\N	\N	Il rapporto tra le distanze indicate sulla rappresentazione grafica e la loro misura reale sul terreno.	scale	Maßstab	mizana	Questa cartina è stata prodotta con una scala di 1 a 25.000.
2597	58c1dab	65	ère	era		https://upload.wikimedia.org/wikipedia/commons/1/14/Era%2C_Texas.JPG	2026-03-30 16:28:43.57577	0	2026-03-31 16:28:43.57577	{stratigraphie,temps_géologique}	2.5	0	0	\N	\N	Vasta suddivisione cronologica della storia del pianeta, che raggruppa diversi sistemi o periodi.	era	Ära	vanim-potoana	I giganteschi rettili dominarono il pianeta durante la lunga era mesozoica.
2598	5a3208d	65	période	periodo		https://upload.wikimedia.org/wikipedia/commons/d/d8/Artist%27s_impression_of_an_ultra-short-period_planet.jpg	2026-03-30 16:28:50.343127	0	2026-03-31 16:28:50.343127	{stratigraphie,temps_géologique}	2.5	0	0	\N	\N	Unità geocronologica fondamentale del tempo in cui si forma un sistema di strati sedimentari.	period	Periode	fe-potoana	Il Giurassico è il periodo centrale del Mesozoico.
2599	6c1f98a	65	datation	datazione		\N	2026-03-30 16:29:07.473711	0	2026-03-31 16:29:07.473711	{géochronologie,méthode}	2.5	0	0	\N	\N	Insieme dei metodi utilizzati per determinare l'età assoluta o relativa di minerali o eventi.	dating	Datierung	famaritana taona	Le moderne tecniche di datazione radiometrica hanno precisato l'età dei meteoriti.
2600	8a387a5	65	isotope	isotopo		https://upload.wikimedia.org/wikipedia/commons/2/27/Hydrogen-5.png	2026-03-30 16:29:14.214463	0	2026-03-31 16:29:14.214463	{géochimie,géochronologie}	2.5	0	0	\N	\N	Varianti di uno stesso elemento chimico aventi identico numero atomico ma diverso numero di massa.	isotope	Isotop	izotôpa	L'analisi della percentuale di un isotopo specifico ci aiuta a ricostruire il clima antico.
2601	25d0ed0	65	radioactivité	radioattività		https://upload.wikimedia.org/wikipedia/commons/7/73/Radioactive_decay_law_decay_constants.jpg	2026-03-30 16:29:21.939777	0	2026-03-31 16:29:21.939777	{géochimie,géochronologie}	2.5	0	0	\N	\N	Emissione spontanea di particelle da parte di nuclei atomici instabili all'interno dei minerali.	radioactivity	Radioaktivität	radiôaktivite	La fonte principale di calore interno del nostro pianeta deriva dalla lenta radioattività degli elementi nel mantello.
2351	452fc81	62	Stade	Stadio		\N	2026-02-24 15:33:10.57332	0	2026-02-25 15:33:10.57332	{sport,matériel,structures}	2.5	0	0	\N	\N	Impianto sportivo per grandi eventi.	Stadium	Stadion	Stade	Lo stadio olimpico ha 80.000 posti.
2352	6906919	62	Arène	Arena		\N	2026-02-24 15:33:23.561286	0	2026-02-25 15:33:23.561286	{sport,matériel,structures}	2.5	0	0	\N	\N	Luogo chiuso per sport di combattimento o basket.	Arena	Arena	Arena	L'arena è pronta per il match di boxe.
2353	3efb907	62	Piste	Pista		\N	2026-02-24 15:33:29.95814	0	2026-02-25 15:33:29.95814	{sport,matériel,structures}	2.5	0	0	\N	\N	Striscia per gare di corsa.	Track	Bahn	Piste	La pista ha otto corsie.
1772	f3c43aa	40	triste	triste		\N	2026-01-31 15:19:22.282567	0	2026-02-01 15:19:22.282567	{adjectif,italien,émotion}	2.5	0	0	\N	\N	\N	sad	traurig	mampalahelo	\N
1773	f8e7dfe	40	en colère	arrabbiato		\N	2026-01-31 15:19:22.32968	0	2026-02-01 15:19:22.32968	{adjectif,italien,émotion}	2.5	0	0	\N	\N	\N	angry	wütend	TEZITRA	\N
1592	bff3978	38	Casque	casco		\N	2026-01-25 06:44:10.890995	0	2026-01-26 06:44:10.890995	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	Protezione per la testa in sport di contatto.	Helmet	Helm	Casque	Indossa sempre il casco in bici.
2355	1397986	62	Gants	Guantoni		\N	2026-02-24 15:33:45.891591	0	2026-02-25 15:33:45.891591	{sport,matériel,structures}	2.5	0	0	\N	\N	Protezione per le mani nella boxe.	Gloves	Handschuhe	Gants	I guantoni proteggono le mani.
2356	00bbe33	62	Protège-tibias	Parastinchi		\N	2026-02-24 15:33:53.504117	0	2026-02-25 15:33:53.504117	{sport,matériel,structures}	2.5	0	0	\N	\N	Protezione per gli stinchi nel calcio.	Shin guards	Schienbeinschoner	Protège-tibias	I parastinchi sono obbligatori.
1767	ab0c3ed	40	Autoritaire	autoritario		\N	2026-01-31 15:19:22.20146	0	2026-02-01 15:19:22.20146	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che impone la propria volontà senza discussione.	Authoritarian	Autoritätsgläubig	Mibohaka	Il suo stile autoritario crea malcontento.
1770	6b71e39	40	Passionné	appassionato		\N	2026-01-31 15:19:22.24651	0	2026-02-01 15:19:22.24651	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che vive con grande intensità le proprie attività.	Passionate	Leidenschaftlich	Mafana fo	È appassionato di musica e suona ogni giorno.
1771	f244547	40	Romantique	romantico		\N	2026-01-31 15:19:22.263688	0	2026-02-01 15:19:22.263688	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che idealizza l'amore e i sentimenti.	Romantic	Romantisch	Romantika	Le sue sorprese romantiche sono indimenticabili.
1774	da360a0	40	Effrayé	spaventato		\N	2026-01-31 15:19:22.349512	0	2026-02-01 15:19:22.349512	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova paura.	Scared	Erschrocken	Matahotra	È spaventato dal buio.
1776	6040438	40	Déçu	deluso		\N	2026-01-31 15:19:22.389626	0	2026-02-01 15:19:22.389626	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova delusione per qualcosa.	Disappointed	Enttäuscht	Malahelo	È deluso dal risultato.
1777	5eb9b85	40	Fier	orgoglioso		\N	2026-01-31 15:19:22.409123	0	2026-02-01 15:19:22.409123	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova soddisfazione per i propri meriti.	Proud	Stolz	Mirehareha	È orgoglioso del diploma del figlio.
1778	1059f27	40	Confident	fiducioso		\N	2026-01-31 15:19:22.430332	0	2026-02-01 15:19:22.430332	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che ha fiducia in sé e nel futuro.	Confident	Zuversichtlich	Mino	È fiducioso di vincere la gara.
1802	edbbe56	40	Rigide	rigido		\N	2026-01-31 15:19:25.428369	0	2026-02-01 15:19:25.428369	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non si adatta facilmente.	Rigid	Starr	Miaraka	Il suo modo di pensare rigido crea conflitti.
1803	e65d468	40	Indépendant	indipendente		\N	2026-01-31 15:19:25.443669	0	2026-02-01 15:19:25.443669	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non dipende dagli altri.	Independent	Unabhängig	Tsy miankina	È indipendente e vive da solo da anni.
1804	79317ae	40	Autonome	autonomo		\N	2026-01-31 15:19:25.461613	0	2026-02-01 15:19:25.461613	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona capace di gestire sé stessa.	Autonomous	Autonom	Tsy miankina	È autonomo nelle scelte quotidiane.
2350	7eea206	62	Tribune	Tribuna		\N	2026-02-24 15:33:02.098789	0	2026-02-25 15:33:02.098789	{sport,matériel,structures}	2.5	0	0	\N	\N	Posto per il pubblico negli stadi.	Stand	Tribüne	Tribune	Le tribune erano piene di tifosi.
1786	204459e	40	Modeste	modesto		\N	2026-01-31 15:19:22.582074	0	2026-02-01 15:19:22.582074	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non ostenta i propri meriti.	Modest	Bescheiden	Miaraka	È modesto nonostante i suoi successi.
1787	e2c798d	40	Humble	umile		\N	2026-01-31 15:19:22.596889	0	2026-02-01 15:19:22.596889	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non si sente superiore agli altri.	Humble	Demütig	Miaraka	Rimane umile anche dopo la vittoria.
2199	9e66118	61	Stretching	Stretching		\N	2026-02-24 15:05:56.266856	0	2026-02-25 15:05:56.266856	{sport,activités,type}	2.5	0	0	\N	\N	Serie di esercizi per allungare i muscoli.	Stretching	Dehnen	Fanitarana	Lo stretching finale previene i dolori muscolari.
2200	1b03de7	61	Crossfit	Crossfit		\N	2026-02-24 15:06:02.669324	0	2026-02-25 15:06:02.669324	{sport,activités,type}	2.5	0	0	\N	\N	Allenamento ad alta intensità con esercizi variati e funzionali.	Crossfit	Crossfit	Crossfit	Il Crossfit combina forza e resistenza.
2201	543e5ee	61	Danse	Danza		\N	2026-02-24 15:06:09.231491	0	2026-02-25 15:06:09.231491	{sport,activités,type}	2.5	0	0	\N	\N	Attività ritmica che combina movimento e musica.	Dance	Tanz	Dihy	La danza è un ottimo esercizio cardiovascolare.
1790	0e61044	40	Distrait	distratto		\N	2026-01-31 15:19:22.639449	0	2026-02-01 15:19:22.639449	{adjectif,italien,comportement}	2.5	0	0	\N	\N	Persona che perde facilmente la concentrazione.	Distracted	Zerstreut	Mivadika	È distratto e dimentica sempre le chiavi.
1792	055f93f	40	Stressé	stressato		\N	2026-01-31 15:19:22.667746	0	2026-02-01 15:19:22.667746	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona sotto pressione emotiva.	Stressed	Gestresst	Mifankahita	È stressato dal troppo lavoro.
1793	bdfcd3e	40	Peur	pauroso		\N	2026-01-31 15:19:22.682914	0	2026-02-01 15:19:22.682914	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che prova paura facilmente.	Fearful	Ängstlich	Matahotra	È pauroso e non esce di notte.
2187	eea0b21	61	Agilité	Agilità		\N	2026-02-24 15:04:31.050153	0	2026-02-25 15:04:31.050153	{sport,capacités,physique}	2.5	0	0	\N	\N	Capacità di cambiare rapidamente direzione e posizione.	Agility	Beweglichkeit	Fahafahana mihetsika haingana	L'agilità è richiesta negli sport di squadra.
2188	ea8b2c5	61	Échauffement	Riscaldamento		\N	2026-02-24 15:04:39.660284	0	2026-02-25 15:04:39.660284	{sport,entraînement,préparation}	2.5	0	0	\N	\N	Serie di esercizi leggeri prima dell'attività intensa per preparare il corpo.	Warm-up	Aufwärmen	Fanafanana	Il riscaldamento previene infortuni muscolari.
2189	1629308	61	Récupération	Recupero		\N	2026-02-24 15:04:46.105814	0	2026-02-25 15:04:46.105814	{sport,récupération,bien-être}	2.5	0	0	\N	\N	Periodo necessario al corpo per ristabilirsi dopo uno sforzo.	Recovery	Erholung	Fanarenana	Il recupero attivo accelera il ritorno alla forma.
2190	20fec4b	61	Progression	Progressione		\N	2026-02-24 15:04:52.235908	0	2026-02-25 15:04:52.235908	{sport,suivi,performance}	2.5	0	0	\N	\N	Miglioramento graduale delle prestazioni attraverso l'allenamento.	Progression	Fortschritt	Fandrosoana	La progressione costante porta a risultati duraturi.
2191	31c32a8	61	Course	Corsa		\N	2026-02-24 15:05:00.539519	0	2026-02-25 15:05:00.539519	{sport,activités,type}	2.5	0	0	\N	\N	Attività di spostamento rapido a piedi.	Running	Laufen	Hazakazaka	La corsa migliora l'endurance cardiovascolare.
2192	3807817	61	Marche	Camminata		\N	2026-02-24 15:05:07.865869	0	2026-02-25 15:05:07.865869	{sport,activités,type}	2.5	0	0	\N	\N	Spostamento a piedi a ritmo moderato.	Walking	Gehen	Fandehanana	La camminata veloce è un ottimo esercizio aerobico.
2193	38e4aca	61	Natation	Nuoto		\N	2026-02-24 15:05:15.047162	0	2026-02-25 15:05:15.047162	{sport,activités,type}	2.5	0	0	\N	\N	Spostamento in acqua mediante movimenti coordinati degli arti.	Swimming	Schwimmen	Filomanosana	Il nuoto rinforza tutti i gruppi muscolari.
2194	cebe3e0	61	Cyclisme	Ciclismo		\N	2026-02-24 15:05:21.973337	0	2026-02-25 15:05:21.973337	{sport,activités,type}	2.5	0	0	\N	\N	Attività di pedalata su bicicletta.	Cycling	Radfahren	Mitaingina bisikileta	Il ciclismo è ideale per allenare le gambe.
2195	c997f28	61	Musculation	Musculation		\N	2026-02-24 15:05:28.692697	0	2026-02-25 15:05:28.692697	{sport,activités,type}	2.5	0	0	\N	\N	Allenamento con pesi per sviluppare la massa muscolare.	Weight training	Muskeltraining	Fanamafisana hozatra	La muscolazione aumenta la forza e il tono.
2196	163c44a	61	Yoga	Yoga		\N	2026-02-24 15:05:35.557907	0	2026-02-25 15:05:35.557907	{sport,activités,type}	2.5	0	0	\N	\N	Disciplina che unisce postura, respirazione e meditazione.	Yoga	Yoga	Yoga	Lo yoga migliora flessibilità e concentrazione.
2197	5951480	61	Pilates	Pilates		\N	2026-02-24 15:05:42.745304	0	2026-02-25 15:05:42.745304	{sport,activités,type}	2.5	0	0	\N	\N	Metodo di allenamento focalizzato su controllo, forza e flessibilità del core.	Pilates	Pilates	Pilates	Il Pilates rafforza il centro del corpo.
2198	a3a32f4	61	Cardio	Cardio		\N	2026-02-24 15:05:49.375069	0	2026-02-25 15:05:49.375069	{sport,activités,type}	2.5	0	0	\N	\N	Allenamento che aumenta la frequenza cardiaca per migliorare la resistenza.	Cardio	Cardio	Cardio	La sessione di cardio brucia molte calorie.
2202	a425422	61	Randonnée	Escursionismo		\N	2026-02-24 15:06:16.683879	0	2026-02-25 15:06:16.683879	{sport,activités,type}	2.5	0	0	\N	\N	Camminata in ambiente naturale su sentieri.	Hiking	Wandern	Fandehanana an-tendrombohitra	L'escursionismo rafforza gambe e polmoni.
2203	79827c1	61	Boxe	Boxe		\N	2026-02-24 15:06:23.331747	0	2026-02-25 15:06:23.331747	{sport,activités,type}	2.5	0	0	\N	\N	Sport di combattimento con pugni.	Boxing	Boxen	Boxe	La boxe sviluppa agilità e resistenza.
2204	4572100	61	Football	Calcio		\N	2026-02-24 15:06:30.414258	0	2026-02-25 15:06:30.414258	{sport,activités,type}	2.5	0	0	\N	\N	Sport di squadra con palla da calciare.	Football	Fußball	Baolina kitra	Il calcio è lo sport nazionale italiano.
2205	36852f0	61	Basketball	Pallacanestro		\N	2026-02-24 15:06:36.924218	0	2026-02-25 15:06:36.924218	{sport,activités,type}	2.5	0	0	\N	\N	Sport di squadra con palla da lanciare nel canestro.	Basketball	Basketball	Baolina basket	La pallacanestro richiede grande agilità.
418	bbf7045	13	Muscle	Muscolo		https://raw.githubusercontent.com/twitter/twemoji/master/assets/svg/1f4aa.svg	2025-12-06 14:15:36.273493	0	2025-12-07 14:15:36.273493	{nom,italien,fréquent,corps,anatomie}	2.5	0	0	\N	\N	Tessuto capace di contrarsi per produrre movimento.	Muscle	Muskel	Hozatra	Il muscolo si rinforza con la muscolazione.
2206	0bdc777	61	Articulation	Articolazione		\N	2026-02-24 15:06:43.792547	0	2026-02-25 15:06:43.792547	{sport,corps,physique}	2.5	0	0	\N	\N	Giunzione tra due ossa che permette il movimento.	Joint	Gelenk	Fifandraisana	L'articolazione del ginocchio è molto sollecitata nella corsa.
1807	bf991e3	40	Rêveur	sognatore		\N	2026-01-31 15:19:25.51332	0	2026-02-01 15:19:25.51332	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che immagina spesso un mondo ideale.	Dreamer	Träumer	Mpanonofy	È un sognatore e progetta sempre il futuro.
1808	831ae15	40	Réaliste	realista		\N	2026-01-31 15:19:25.530085	0	2026-02-01 15:19:25.530085	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che valuta le situazioni con obiettività.	Realistic	Realistisch	Miaraka	È realista e non si fa illusioni.
1809	9148d95	40	Pragmatique	pragmatico		\N	2026-01-31 15:19:25.546762	0	2026-02-01 15:19:25.546762	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che privilegia soluzioni concrete.	Pragmatic	Pragmatisch	Miaraka	Il suo approccio pragmatico ha risolto il problema.
1810	1e5462b	40	Énergique	energico		\N	2026-01-31 15:19:25.563186	0	2026-02-01 15:19:25.563186	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona piena di vitalità e iniziativa.	Energetic	Energisch	Miaraka	È energico e non sta mai fermo.
1813	f5b26c4	40	Mélancolique	malinconico		\N	2026-01-31 15:19:25.614106	0	2026-02-01 15:19:25.614106	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona incline alla tristezza riflessiva.	Melancholic	Melancholisch	Malahelo	Il suo sguardo malinconico rivela la sua sensibilità.
2207	2787905	61	Respiration	Respirazione		\N	2026-02-24 15:06:50.716123	0	2026-02-25 15:06:50.716123	{sport,corps,physique}	2.5	0	0	\N	\N	Processo di introduzione ed espulsione di aria dai polmoni.	Breathing	Atem	Fisefana	Una buona respirazione controlla lo sforzo.
2208	0f53fa9	61	Posture	Postura		\N	2026-02-24 15:06:57.100126	0	2026-02-25 15:06:57.100126	{sport,corps,physique}	2.5	0	0	\N	\N	Posizione del corpo durante l'attività fisica.	Posture	Haltung	Fipetrahana	Una postura corretta evita lesioni.
2357	ae4b307	62	Bande	Fascia		\N	2026-02-24 15:34:02.521601	0	2026-02-25 15:34:02.521601	{sport,matériel,structures}	2.5	0	0	\N	\N	Fascia per proteggere articolazioni.	Bandage	Bandage	Bande	Avvolgi la fascia al polso.
2358	10cf142	62	Chevillère	Cavigliera		\N	2026-02-24 15:34:09.666548	0	2026-02-25 15:34:09.666548	{sport,matériel,structures}	2.5	0	0	\N	\N	Supporto per la caviglia.	Ankle brace	Knöchelstütze	Chevillère	La cavigliera previene le distorsioni.
2359	3a1830a	62	Genouillère	Ginocchiera		\N	2026-02-24 15:34:17.57324	0	2026-02-25 15:34:17.57324	{sport,matériel,structures}	2.5	0	0	\N	\N	Protezione per il ginocchio.	Knee pad	Knieschoner	Genouillère	Indossa la ginocchiera durante gli squat.
1819	e05f552	40	Serein	sereno		\N	2026-01-31 15:19:25.715302	0	2026-02-01 15:19:25.715302	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che mostra tranquillità interiore.	Serene	Gelassen	Miadana	Il suo viso sereno trasmette pace.
1820	80808de	40	Positif	positivo		\N	2026-01-31 15:19:25.733279	0	2026-02-01 15:19:25.733279	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che ha un atteggiamento ottimista.	Positive	Positiv	Tsara	Il suo pensiero positivo aiuta tutti.
1821	2718a74	40	Négatif	negativo		\N	2026-01-31 15:19:25.749066	0	2026-02-01 15:19:25.749066	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che ha un atteggiamento pessimista.	Negative	Negativ	Ratsy	Il suo commento negativo ha rovinato la festa.
2360	a4de128	62	Gourde	Borraccia		\N	2026-02-24 15:34:27.41886	0	2026-02-25 15:34:27.41886	{sport,matériel,structures}	2.5	0	0	\N	\N	Contenitore portatile per bere.	Water bottle	Trinkflasche	Gourde	Riempì la borraccia prima della corsa.
1822	e3d9b74	40	Irritable	irritabile		\N	2026-01-31 15:19:25.764845	0	2026-02-01 15:19:25.764845	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che si irrita facilmente.	Irritable	Reizbar	Mora tezitra	È irritabile la mattina.
2361	1b93421	62	Maillot technique	Maglietta tecnica		\N	2026-02-24 15:34:36.690744	0	2026-02-25 15:34:36.690744	{sport,matériel,structures}	2.5	0	0	\N	\N	Maglia traspirante per lo sport.	Technical jersey	Technisches Trikot	Maillot technique	La maglietta tecnica favorisce l'evaporazione del sudore.
1540	eb99589	38	Chaussures de randonnée	scarponi		\N	2026-01-25 06:44:09.638364	0	2026-01-26 06:44:09.638364	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	Scarpe robuste per escursioni.	Hiking boots	Wanderschuhe	Kiraro an-tendrombohitra	Gli scarponi proteggono le caviglie.
2604	8e3a597	65	fer	ferro		https://upload.wikimedia.org/wikipedia/commons/a/ad/Iron_electrolytic_and_1cm3_cube.jpg	2026-03-30 16:29:42.376665	0	2026-03-31 16:29:42.376665	{géochimie,élément,ressources}	2.5	0	0	\N	\N	Metallo molto denso, principale costituente del nucleo interno terrestre e componente chiave di magmi scuri.	iron	Eisen	vy	Le grandi formazioni a bande rosse sono enormi depositi antichi ricchi di ferro.
2605	1b60ec9	65	silice	silice		https://upload.wikimedia.org/wikipedia/commons/1/14/Quartz%2C_Tibet.jpg	2026-03-30 16:29:48.730165	0	2026-03-31 16:29:48.730165	{géochimie,minéralogie}	2.5	0	0	\N	\N	Composto chimico abbondantissimo formato da biossido di silicio, che costituisce gran parte del fuso igneo.	silica	Kieselsäure	silisy	I magmi molto ricchi di silice tendono ad essere viscosi e causare eruzioni esplosive.
1827	7aa1316	41	réussir	farcela		\N	2026-02-06 15:39:11.902069	1	2026-02-14 08:08:56.013913	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Riuscire in qualcosa di difficile	to make it / to succeed	es schaffen	mahomby	Ce l'ha fatta a superare l'esame al primo tentativo.
1735	a9a9dfd	40	Courageux	coraggioso		\N	2026-01-31 15:19:21.627861	0	2026-02-01 15:19:21.627861	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che affronta le difficoltà con forza d'animo.	Courageous	Mutig	Mahery fo	È stato coraggioso a difendere la sua opinione in pubblico.
1736	9884fe7	40	Déterminé	determinato		\N	2026-01-31 15:19:21.659635	0	2026-02-01 15:19:21.659635	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che persegue i propri obiettivi con tenacia e fermezza.	Determined	Entschlossen	Miaritra	È determinato a raggiungere il suo sogno nonostante gli ostacoli.
2378	400c57e	63	Rigueur	Rigore		\N	2026-02-24 15:44:32.788991	0	2026-02-25 15:44:32.788991	{science,méthode,fondements}	2.5	0	0	\N	\N	Precisione e accuratezza nel metodo scientifico.	Rigor	Strenge	Rigueur	Il rigore è essenziale nella ricerca.
1829	fb7027d	41	s'en sortir	cavarsela		\N	2026-02-06 15:39:11.990204	0	2026-02-07 15:39:11.990204	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Uscire bene da una situazione difficile o complicata	to manage / to get by	zurechtkommen / sich durchschlagen	mahay mizaka tena amin'ny toe-javatra sarotra	L'esame era durissimo, ma alla fine me la sono cavata con 18/30.
1832	09b305a	41	se sentir capable	sentirsela		\N	2026-02-06 15:39:12.168333	0	2026-02-07 15:39:12.168333	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Sentirsi in grado di fare qualcosa	to feel up to it	sich zutrauen	mahatsiaro ho vonona hanao izany	Oggi me la sento di correre 10 km senza fermarmi.
1830	cb6b128	41	bien s'amuser	spassarsela		\N	2026-02-06 15:39:12.014181	2	2026-02-20 15:53:16.922706	{"verbo pronominale",italien,courant}	2.7	6	2	\N	\N	Divertirsi molto	to have a great time	sich amüsieren	mifaly tsara	Se la spassa in vacanza con gli amici.
1831	7b0e67b	41	vivre une situation	passarsela		\N	2026-02-06 15:39:12.104118	1	2026-02-14 08:07:51.632964	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Indica le condizioni generali di vita	to be getting on	zurechtkommen	miaina toe-javatra tsara	Se la passa bene ultimamente, ha un nuovo lavoro.
1834	7a205f7	41	en profiter	godersela		\N	2026-02-06 15:39:12.249398	1	2026-02-15 15:53:32.671633	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Godere pienamente di qualcosa	to enjoy it	es genießen	mankafy izany tsara	Goditela questa vacanza, ve la meritate!
1739	7ed7940	40	Optimiste	ottimista		\N	2026-01-31 15:19:21.761027	0	2026-02-01 15:19:21.761027	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che vede il lato positivo delle cose.	Optimistic	Optimistisch	Manantena tsara	È ottimista e crede sempre che tutto si sistemerà.
1740	a04ead3	40	Joyeux	gioioso		\N	2026-01-31 15:19:21.775284	0	2026-02-01 15:19:21.775284	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che trasmette gioia e buon umore.	Joyful	Fröhlich	Falifaly	La sua risata gioiosa contagia tutti.
2379	0c87c2a	63	Validation	Validazione		\N	2026-02-24 15:44:39.741743	0	2026-02-25 15:44:39.741743	{science,méthode,fondements}	2.5	0	0	\N	\N	Conferma della correttezza di un risultato o metodo.	Validation	Validierung	Fanamarinana	La validazione ha confermato i risultati.
2380	8a3aeeb	63	Axiome	Assioma		\N	2026-02-24 15:44:45.728287	0	2026-02-25 15:44:45.728287	{science,méthode,fondements}	2.5	0	0	\N	\N	Principio evidente che non richiede dimostrazione.	Axiom	Axiom	Axiome	Gli assiomi sono alla base della matematica.
2381	b8f144f	63	Phénomène	Fenomeno		\N	2026-02-24 15:44:52.816204	0	2026-02-25 15:44:52.816204	{science,méthode,fondements}	2.5	0	0	\N	\N	Fatto o evento osservabile in natura.	Phenomenon	Phänomen	Phenomena	Il fenomeno è stato studiato per anni.
2382	632452b	63	Loi naturelle	Legge naturale		\N	2026-02-24 15:45:00.031896	0	2026-02-25 15:45:00.031896	{science,méthode,fondements}	2.5	0	0	\N	\N	Regola costante che descrive il comportamento della natura.	Natural law	Naturgesetz	Lalàna voajanahary	La legge naturale della gravità.
2383	dbbdca2	63	Paradigme	Paradigma		\N	2026-02-24 15:45:07.348686	0	2026-02-25 15:45:07.348686	{science,méthode,fondements}	2.5	0	0	\N	\N	Modello di riferimento accettato in un campo scientifico.	Paradigm	Paradigma	Paradigma	Il paradigma scientifico è cambiato nel XX secolo.
2384	c622b09	63	Empirisme	Empirismo		\N	2026-02-24 15:45:13.935401	0	2026-02-25 15:45:13.935401	{science,méthode,fondements}	2.5	0	0	\N	\N	Corrente filosofica che basa la conoscenza sull'esperienza sensibile.	Empiricism	Empirismus	Empirisme	L'empirismo ha influenzato il metodo scientifico.
2385	7a06b02	63	Logique	Logica		\N	2026-02-24 15:45:20.562888	0	2026-02-25 15:45:20.562888	{science,méthode,fondements}	2.5	0	0	\N	\N	Scienza del ragionamento corretto e coerente.	Logic	Logik	Logique	La logica è alla base di ogni dimostrazione.
1839	4db3429	41	s'en souvenir	legarsela al dito		\N	2026-02-06 15:39:12.363546	0	2026-02-07 15:39:12.363546	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Ricordare un torto subito e non perdonare mai	to hold a grudge	sich etwas merken / nachtragen	mitana lolom-po mandrakizay	Se l'è legata al dito e non gli parlerà più.
1841	a64bbcb	41	ça en demande	volercene		\N	2026-02-06 15:39:12.406774	0	2026-02-07 15:39:12.406774	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Indicare quanta fatica o quantità serve per fare qualcosa	it takes (a lot)	es braucht / man braucht schon etwas	mila ezaka be izany	Per imparare bene l'italiano ce ne vuole di tempo!
1842	8e79760	41	s'en foutre	fottersene		\N	2026-02-06 15:39:12.428184	0	2026-02-07 15:39:12.428184	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Non curarsene affatto, indifferenza totale (volgare)	not to give a damn (vulgar)	einen Dreck darum scheren	tsy miraharaha mihitsy	Se ne fotte delle regole e fa quello che vuole.
1844	1754a51	41	rester sur place	rimanersene		\N	2026-02-06 15:39:12.469415	0	2026-02-07 15:39:12.469415	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Rimanere fermo nello stesso posto	to stay put	bleiben wo man ist	mijanona tsy mihetsika eo	Rimanitene lì e non muoverti fino al mio ritorno.
1840	fce052b	41	s'en ficher	fregarsene		\N	2026-02-06 15:39:12.385885	1	2026-02-14 08:09:43.744617	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Non curarsene	not to care	sich nicht scheren	tsy miraharaha	Se ne frega di tutto e di tutti.
1843	7e10e44	41	S'en moquer	farsene		\N	2026-02-06 15:39:12.448826	0	2026-02-14 16:03:21.786449	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Non dare importanza a qualcosa	to make nothing of it	nichts daraus machen	tsy manao na inona na inona amin'izany	Se ne fa poco delle opinioni altrui.
1845	a34bfb8	41	donner son avis	dirne		\N	2026-02-06 15:39:12.489599	1	2026-02-14 08:08:33.043304	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Dire la propria opinione	to give one's opinion	seine Meinung sagen	manome hevitra	Dimmi quattro parole su questo argomento.
1846	8953ae3	41	partir de quelque chose	andarne		\N	2026-02-06 15:39:12.508963	0	2026-02-13 08:19:49.447708	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Dipendere da qualcosa, essere in gioco	to be at stake	davon abhängen	miankina amin'izany	Ne va della tua reputazione.
1742	4580c74	40	Enthousiaste	entusiasta		\N	2026-01-31 15:19:21.8075	0	2026-02-01 15:19:21.8075	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che mostra grande passione ed energia per ciò che fa.	Enthusiastic	Enthusiastisch	Mafana fo	È entusiasta del nuovo progetto e lavora con impegno.
2387	e86fd2e	63	Démonstration	Dimostrazione		\N	2026-02-24 15:45:34.288615	0	2026-02-25 15:45:34.288615	{science,méthode,fondements}	2.5	0	0	\N	\N	Prova logica o sperimentale di una proposizione.	Demonstration	Beweis	Démonstration	La dimostrazione è stata chiara e convincente.
2388	7d2628a	63	Reproductibilité	Riproducibilità		\N	2026-02-24 15:45:40.772873	0	2026-02-25 15:45:40.772873	{science,méthode,fondements}	2.5	0	0	\N	\N	Possibilità di ottenere gli stessi risultati ripetendo un esperimento.	Reproducibility	Reproduzierbarkeit	Reproductibilité	La riproducibilità è un pilastro della scienza.
2389	c80d844	63	Épistémologie	Epistemologia		\N	2026-02-24 15:45:47.575002	0	2026-02-25 15:45:47.575002	{science,méthode,fondements}	2.5	0	0	\N	\N	Studio della natura, delle origini e dei limiti della conoscenza.	Epistemology	Erkenntnistheorie	Épistémologie	L'epistemologia analizza il metodo scientifico.
2390	7103bf0	63	Technologie	Tecnologia		\N	2026-02-24 15:45:55.112922	0	2026-02-25 15:45:55.112922	{science,technique,ingénierie}	2.5	0	0	\N	\N	Applicazione pratica della conoscenza scientifica.	Technology	Technologie	Teknolojia	La tecnologia moderna ha trasformato la società.
2391	675d4b5	63	Outil	Strumento		\N	2026-02-24 15:46:01.921938	0	2026-02-25 15:46:01.921938	{science,technique,ingénierie}	2.5	0	0	\N	\N	Oggetto utilizzato per facilitare un lavoro.	Tool	Werkzeug	Fitaovana	Lo strumento è essenziale per la precisione.
2392	1906660	63	Mécanisme	Meccanismo		\N	2026-02-24 15:46:08.318221	0	2026-02-25 15:46:08.318221	{science,technique,ingénierie}	2.5	0	0	\N	\N	Insieme di parti che trasmettono movimento.	Mechanism	Mechanismus	Mécanisme	Il meccanismo è semplice ma efficace.
2393	57a6437	63	Système	Sistema		\N	2026-02-24 15:46:16.308515	0	2026-02-25 15:46:16.308515	{science,technique,ingénierie}	2.5	0	0	\N	\N	Insieme di elementi interconnessi che funzionano insieme.	System	System	Système	Il sistema è stabile e affidabile.
2394	cc0ff3a	63	Dispositif	Dispositivo		\N	2026-02-24 15:46:23.120211	0	2026-02-25 15:46:23.120211	{science,technique,ingénierie}	2.5	0	0	\N	\N	Apparecchio progettato per una funzione specifica.	Device	Gerät	Dispositif	Il dispositivo misura la temperatura con precisione.
1847	94e4d5f	41	reprocher	volerne		\N	2026-02-06 15:39:12.528962	0	2026-02-07 15:39:12.528962	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Serbare rancore verso qualcuno per un torto subito	to hold a grudge against someone	jemandem etwas nachtragen	mitana lolom-po amin'olona	Gliene vogliono ancora a Marco per quell'errore di anni fa.
1848	83e809b	41	s'en aller	andarsene		\N	2026-02-06 15:39:12.549911	0	2026-02-07 15:39:12.549911	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Andarsene via da un luogo	to leave / to go away	weggehen	miala tsy misy teny	Se n'è andato senza salutare nessuno.
1849	ad30d6c	41	en faire un drame	farne un dramma		\N	2026-02-06 15:39:12.56951	0	2026-02-07 15:39:12.56951	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Reagire in modo esagerato a un piccolo problema	to make a big deal out of it	ein Drama daraus machen	atao olana lehibe loatra	Non farne un dramma, è solo un ritardo di cinque minuti.
1852	880bbbd	41	prendre mal	prendersela		\N	2026-02-06 15:39:12.631995	0	2026-02-07 15:39:12.631995	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Offendersi o arrabbiarsi per qualcosa	to take offense / to get upset	es übel nehmen	tohina na malahelo	Se la prende per ogni piccola critica.
1850	e0cb2e9	41	en ressentir	sentirne		\N	2026-02-06 15:39:12.591212	1	2026-02-14 08:06:23.54232	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Provare gli effetti di qualcosa	to feel the effects of it	es spüren	mahatsapa ny vokatry izany	Ne sento ancora gli effetti della stanchezza.
2386	eacc070	63	Raisonnement	Ragionamento		\N	2026-02-24 15:45:27.589558	0	2026-02-25 15:45:27.589558	{science,méthode,fondements}	2.5	0	0	\N	\N	Processo mentale per giungere a una conclusione.	Reasoning	Schlussfolgerung	Raisonnement	Il ragionamento deduttivo è molto utilizzato.
1856	7e24ed3	41	se rendre compte	vederla		\N	2026-02-06 15:39:12.711323	0	2026-02-07 15:39:12.711323	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Valutare una situazione in un certo modo	to see it (as)	es so sehen	mahita izany ho...	La vedo brutta questa situazione, meglio andare via.
1857	b2285a6	41	arrêter	smetterla		\N	2026-02-06 15:39:12.732643	0	2026-02-07 15:39:12.732643	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Smettere di fare qualcosa di fastidioso	to stop it	damit aufhören	mijanona amin'izany	Smettila di piangere, va tutto bene!
1858	0dc07fd	41	avoir une opinion	pensarla		\N	2026-02-06 15:39:12.756856	0	2026-02-07 15:39:12.756856	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Avere un'opinione su qualcosa	to think / to have an opinion	eine Meinung haben	manana hevitra	La penso diversamente da te su questo film.
1859	bb188c1	41	avoir peur	farsela sotto		\N	2026-02-06 15:39:12.778097	0	2026-02-07 15:39:12.778097	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Avere una paura fortissima	to be scared stiff (vulgar)	sich vor Angst in die Hose machen	matahotra mafy ka tsy afaka mihetsika	Durante il film horror se l'è fatta sotto dalla paura.
1868	ffb1a61	41	Avoir la capacité de voir	vederci		\N	2026-02-06 15:39:12.979726	0	2026-02-07 15:39:12.979726	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Avere la capacità visiva	to be able to see	sehen können	mahita tsara	Senza occhiali non ci vedo niente.
1743	dba9d79	40	Ambitieux	ambizioso		\N	2026-01-31 15:19:21.823333	0	2026-02-01 15:19:21.823333	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che ha grandi obiettivi e si impegna per raggiungerli.	Ambitious	Ehrgeizig	Manana tanjona	È ambizioso e vuole diventare il migliore nel suo campo.
1746	4e86f03	40	Honnête	onesto		\N	2026-01-31 15:19:21.865188	0	2026-02-01 15:19:21.865188	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che dice sempre la verità e agisce con rettitudine.	Honest	Ehrlich	Mijoro	È onesto e restituisce sempre ciò che trova.
1853	9d90d49	41	détourner une situation	buttarla sul		\N	2026-02-06 15:39:12.651344	0	2026-02-07 15:39:12.651344	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	affrontare o gestire una situazione adottando un certo atteggiamento, come ridere o prendersi sul serio.	to turn it into	es darauf anlegen	Mamadika ho	Ha buttato la conversazione sul politico.
1854	b80d263	41	comprendre	capirla		\N	2026-02-06 15:39:12.670766	0	2026-02-07 15:39:12.670766	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Capire bene una cosa o una regola	to get it / to understand it	es verstehen	mahatakatra izany	Non la capisco proprio questa regola di grammatica.
1855	aa794bc	41	placer	metterla		\N	2026-02-06 15:39:12.690529	0	2026-02-07 15:39:12.690529	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Mettere qualcosa in un certo posto	to put it / to place it	es hinlegen	mametraka azy	Mettila sul tavolo, così la vedo subito.
1864	94d1350	41	Être impliqué malgré soi	andarci di mezzo		\N	2026-02-06 15:39:12.886466	0	2026-02-13 08:18:18.819323	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Essere coinvolto involontariamente	to get caught up in it	hineingeraten	voafandrika tsy fidiny	Ci sono andato di mezzo senza aver fatto niente.
1865	8b3e668	41	s'en rendre compte	rendersene conto		\N	2026-02-06 15:39:12.912733	0	2026-02-07 15:39:12.912733	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Accorgersi di qualcosa (spesso in ritardo)	to realize it	es sich bewusst werden	mahatsapa izany farany	Se n'è reso conto solo dopo aver firmato il contratto.
1748	3a51458	40	Sociable	socievole		\N	2026-01-31 15:19:21.911634	0	2026-02-01 15:19:21.911634	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che ama stare in compagnia e crea facilmente rapporti.	Sociable	Gesellig	Miaraka amin'ny olona	È molto socievole e organizza sempre feste.
1749	768f0d8	40	Amusant	divertente		\N	2026-01-31 15:19:21.925109	0	2026-02-01 15:19:21.925109	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che fa ridere e rende piacevoli i momenti.	Funny	Lustig	Mahatsikaiky	Le sue battute sono sempre divertenti.
2395	dcfc500	63	Procédé	Procedimento		\N	2026-02-24 15:46:29.777639	0	2026-02-25 15:46:29.777639	{science,technique,ingénierie}	2.5	0	0	\N	\N	Sequenza di operazioni per ottenere un risultato.	Process	Verfahren	Procédé	Il procedimento è stato ottimizzato.
2396	82b0338	63	Automate	Automate		\N	2026-02-24 15:46:35.953789	0	2026-02-25 15:46:35.953789	{science,technique,ingénierie}	2.5	0	0	\N	\N	Dispositivo che esegue operazioni in modo automatico.	Automaton	Automat	Automate	L'automate semplifica il lavoro ripetitivo.
2397	a402926	63	Robotique	Robotica		\N	2026-02-24 15:46:42.902774	0	2026-02-25 15:46:42.902774	{science,technique,ingénierie}	2.5	0	0	\N	\N	Settore che studia e realizza robot.	Robotics	Robotik	Robotique	La robotica ha rivoluzionato l'industria.
2280	9f7158c	62	Puissance	Potenza		\N	2026-02-24 15:24:52.324484	0	2026-02-25 15:24:52.324484	{sport,capacités,physique}	2.5	0	0	\N	\N	Quantità di energia trasferita per unità di tempo.	Power	Leistung	Hery	La potenza del motore è di 200 cavalli.
2398	885f69a	63	Rendement	Rendimento		\N	2026-02-24 15:46:49.255676	0	2026-02-25 15:46:49.255676	{science,technique,ingénierie}	2.5	0	0	\N	\N	Rapporto tra energia utile e energia fornita.	Efficiency	Wirkungsgrad	Rendement	Il rendimento del motore è del 85%.
2399	5bc8a42	63	Infrastructure	Infrastruttura		\N	2026-02-24 15:46:56.483122	0	2026-02-25 15:46:56.483122	{science,technique,ingénierie}	2.5	0	0	\N	\N	Insieme di strutture di base per un sistema.	Infrastructure	Infrastruktur	Infrastructure	L'infrastruttura è moderna e funzionale.
2400	f22e5d9	63	Maintenance	Manutenzione		\N	2026-02-24 15:47:03.609262	0	2026-02-25 15:47:03.609262	{science,technique,ingénierie}	2.5	0	0	\N	\N	Insieme di operazioni per mantenere efficiente un sistema.	Maintenance	Wartung	Maintenance	La manutenzione preventiva evita guasti.
1860	eaa063c	41	en valoir la peine	valerne la pena		\N	2026-02-06 15:39:12.799927	1	2026-02-15 15:53:56.567609	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Meritare lo sforzo	to be worth it	sich lohnen	mendrika ny ezaka	Ne vale la pena lo sforzo, vedrai il risultato.
1861	fff39b5	41	être à bout	non poterne più		\N	2026-02-06 15:39:12.821346	0	2026-02-07 15:39:12.821346	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Non sopportare più una situazione	to be fed up	die Nase voll haben	tsy zaka intsony	Non ne posso più di questo rumore costante.
1862	4ba561c	41	en avoir assez	averne abbastanza		\N	2026-02-06 15:39:12.843072	0	2026-02-13 08:15:50.208392	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Essere stufo di qualcosa	to have had enough	genug haben	manana ampy	Ne ho abbastanza di queste discussioni inutili.
1863	c24bb11	41	tomber dans le piège	cascarci		\N	2026-02-06 15:39:12.864975	0	2026-02-07 15:39:12.864975	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Cadere in un inganno o trucco	to fall for it	darauf hereinfallen	voafitaka tanteraka	Ci sono cascato di nuovo con quella pubblicità falsa.
1871	4c2a483	41	tenter le coup	provarci		\N	2026-02-06 15:39:13.041435	0	2026-02-07 15:39:13.041435	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Tentare di fare qualcosa	to give it a try	es versuchen	manandrana izany	Ci provo a riparare la bicicletta da solo.
1872	375f509	41	Être d’accord	starci		\N	2026-02-06 15:39:13.064263	0	2026-02-07 15:39:13.064263	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Accettare una proposta o essere d'accordo	to be in / to agree	einverstanden sein	manaiky tanteraka	Ci sto! Andiamo al cinema stasera.
1873	b3794eb	41	savoir y faire	saperci		\N	2026-02-06 15:39:13.086476	0	2026-02-07 15:39:13.086476	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Essere bravo o esperto in qualcosa	to be good at it	sich damit auskennen	mahay manao izany tsara	Ci sa fare con i bambini, li fa ridere sempre.
1874	2ad6224	41	passer outre	passarci sopra		\N	2026-02-06 15:39:13.108023	0	2026-02-13 08:17:34.364096	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Ignorare o perdonare qualcosa	to overlook it	darüber hinwegsehen	mandalo fotsiny izany	Ci passo sopra questa volta, ma non succeda più.
1912	217a5fb	41	y tenir	tenerci		\N	2026-02-06 15:39:14.280944	1	2026-02-14 08:06:53.982733	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Tenere molto a qualcosa o qualcuno	to care a lot about it	daran gelegen sein	manome lanja lehibe amin'izany	Ci tengo moltissimo a questo progetto.
1751	8390069	40	Paresseux	pigro		\N	2026-01-31 15:19:21.953729	0	2026-02-01 15:19:21.953729	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che evita lo sforzo e preferisce l'ozio.	Lazy	Faul	Kamo	È pigro e non finisce mai i compiti.
1752	4b76639	40	Impatient	impaziente		\N	2026-01-31 15:19:21.966915	0	2026-02-01 15:19:21.966915	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non sa aspettare e si irrita facilmente.	Impatient	Ungeduldig	Tsy manam-paharetana	È impaziente e non sopporta le code.
2401	d6fead3	63	Standardisation	Standardizzazione		\N	2026-02-24 15:47:11.234424	0	2026-02-25 15:47:11.234424	{science,technique,ingénierie}	2.5	0	0	\N	\N	Processo di uniformazione di prodotti o procedure.	Standardization	Normung	Standardisation	La standardizzazione facilita la produzione.
2402	2276422	63	Prototype	Prototipo		\N	2026-02-24 15:47:18.006714	0	2026-02-25 15:47:18.006714	{science,technique,ingénierie}	2.5	0	0	\N	\N	Primo modello funzionante di un nuovo dispositivo.	Prototype	Prototyp	Prototype	Il prototipo è stato testato con successo.
2403	016c90e	63	Composant	Componente		\N	2026-02-24 15:47:24.72606	0	2026-02-25 15:47:24.72606	{science,technique,ingénierie}	2.5	0	0	\N	\N	Parte elementare di un sistema complesso.	Component	Komponente	Composant	Ogni componente è stato controllato.
2404	8b0a6ba	63	Circuit	Circuito		\N	2026-02-24 15:47:32.284873	0	2026-02-25 15:47:32.284873	{science,technique,ingénierie}	2.5	0	0	\N	\N	Percorso chiuso per il passaggio di corrente elettrica.	Circuit	Schaltung	Circuit	Il circuito è stato riparato.
2405	70e7a6a	63	Automatisme	Automatismo		\N	2026-02-24 15:47:39.153405	0	2026-02-25 15:47:39.153405	{science,technique,ingénierie}	2.5	0	0	\N	\N	Tecnica che sostituisce l'intervento umano con macchine.	Automation	Automatisierung	Automatisme	L'automatismo ha aumentato la produttività.
2406	8a2eba6	63	Atome	Atomo		\N	2026-02-24 15:47:46.522613	0	2026-02-25 15:47:46.522613	{science,matière,univers}	2.5	0	0	\N	\N	Unità fondamentale della materia.	Atom	Atom	Atòma	L'atomo è composto da nucleo e elettroni.
2407	a3220e4	63	Molécule	Molecola		\N	2026-02-24 15:47:55.271046	0	2026-02-25 15:47:55.271046	{science,matière,univers}	2.5	0	0	\N	\N	Insieme di atomi legati chimicamente.	Molecule	Molekül	Molécule	La molecola d'acqua è H2O.
2606	74705e8	65	carbonate	carbonato		https://upload.wikimedia.org/wikipedia/commons/0/0b/Carbonate-3D-balls.png	2026-03-30 16:29:56.277749	0	2026-03-31 16:29:56.277749	{minéralogie,sédimentologie}	2.5	0	0	\N	\N	Classe di composti chimici formati dall'unione di metalli con il gruppo anione CO3.	carbonate	Karbonat	karbônata	Le barriere coralline fossili sono vasti accumuli di carbonato di calcio precipitato dal mare.
1869	377b7aa	41	avoir la capacité d'entendre	sentirci		\N	2026-02-06 15:39:12.999436	0	2026-02-07 15:39:12.999436	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Avere la capacità uditiva	to be able to hear	hören können	maheno tsara	Da quest'orecchio non ci sento bene.
1870	37ccd2e	41	avoir à voir avec	entrarci		\N	2026-02-06 15:39:13.019994	0	2026-02-07 15:39:13.019994	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Avere relazione o connessione con qualcosa	to have to do with	damit zu tun haben	manana ifandraisany amin'izany	Questo non c'entra niente con il nostro problema.
1875	0e7afb0	41	mettre tout son possible	mettercela tutta		\N	2026-02-06 15:39:13.128586	0	2026-02-07 15:39:13.128586	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Impegnarsi al massimo	to give it one's all	alles geben	manao ny heriny rehetra	Ce l'ha messa tutta e ha vinto la gara.
1876	2eff755	41	s’attribuer	prendersi		\N	2026-02-06 15:39:13.150218	0	2026-02-07 15:39:13.150218	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Prendere qualcosa per sé	to take for oneself	sich nehmen	mitana ho azy	Se l'è preso tutto il merito del lavoro.
1877	cd08465	41	se mettre de côté	farsi da parte		\N	2026-02-06 15:39:13.171439	0	2026-02-07 15:39:13.171439	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Spostarsi per lasciare passare	to step aside	beiseitetreten	mitongilana	Fatti da parte, sta arrivando il treno!
1878	f93cdfa	41	s’attendre à	aspettarsi		\N	2026-02-06 15:39:13.193172	0	2026-02-07 15:39:13.193172	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Aspettarsi qualcosa	to expect	erwarten	manantena	Non me lo aspettavo da te questo comportamento.
1879	145a5c5	41	se faire frapper	prenderle		\N	2026-02-06 15:39:13.216417	0	2026-02-14 16:03:37.793438	{"verbo pronominale",italien,courant}	2.0999999999999996	0	0	\N	\N	Prendere botte	to get beaten up	Prügel beziehen	voadaroka	Le ha prese di santa ragione dal fratello maggiore.
1880	465a92f	41	les donner	darle		\N	2026-02-06 15:39:13.238286	0	2026-02-07 15:39:13.238286	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Picchiare qualcuno (espressione idiomatica)	to give it to them (a beating)	ihnen welche verpassen	manome azy ireo (kapoka)	Gliele ha date di santa ragione.
1089	df16f12	28	Écosystème	Ecosistema		\N	2026-01-08 15:19:19.983711	1	2026-02-02 15:29:24.696266	{nom,italien,écologie}	2.6	1	1	\N	\N	Insieme di organismi e ambiente che interagiscono.	Ecosystem	Ökosystem	Écosystème	L'ecosistema della foresta pluviale è molto ricco.
2315	067e02b	62	Métabolisme	Metabolismo		\N	2026-02-24 15:28:45.871013	0	2026-02-25 15:28:45.871013	{sport,corps,physiologie}	2.5	0	0	\N	\N	Insieme delle reazioni chimiche che mantengono in vita un organismo.	Metabolism	Stoffwechsel	Métabolisme	Il metabolismo accelera con l'esercizio.
2210	578fb16	61	Stamina	Stamina		\N	2026-02-24 15:07:10.115154	0	2026-02-25 15:07:10.115154	{sport,corps,physique}	2.5	0	0	\N	\N	Resistenza fisica prolungata.	Stamina	Ausdauer	Faharetana	La stamina si sviluppa con allenamenti lunghi.
2211	ef640ae	61	Tonus	Tono		\N	2026-02-24 15:07:17.070889	0	2026-02-25 15:07:17.070889	{sport,corps,physique}	2.5	0	0	\N	\N	Stato di contrazione parziale del muscolo a riposo.	Tone	Ton	Tonus	Il tono muscolare migliora l'aspetto fisico.
2212	d062067	61	Mobilité	Mobilità		\N	2026-02-24 15:07:23.788637	0	2026-02-25 15:07:23.788637	{sport,corps,physique}	2.5	0	0	\N	\N	Capacità di muoversi liberamente nelle articolazioni.	Mobility	Beweglichkeit	Fahafahana mihetsika	La mobilità articolare è essenziale per gli atleti.
2213	13cead0	61	Amplitude	Ampiezza		\N	2026-02-24 15:07:30.14126	0	2026-02-25 15:07:30.14126	{sport,corps,physique}	2.5	0	0	\N	\N	Estensione massima del movimento articolare.	Range of motion	Bewegungsweite	Ampiezza	Aumenta l'ampiezza con lo stretching.
2214	7f468a1	61	Gainage	Core training		\N	2026-02-24 15:07:36.548215	0	2026-02-25 15:07:36.548215	{sport,corps,physique}	2.5	0	0	\N	\N	Allenamento della fascia addominale e lombare.	Core stability	Rumpfstabilisation	Fanamafisana ventre	Il core training stabilizza la colonna vertebrale.
1881	71b522e	41	s'en apercevoir	accorgersene		\N	2026-02-06 15:39:13.263283	0	2026-02-07 15:39:13.263283	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Accorgersi di qualcosa	to notice it	es bemerken	mahatsikaritra izany	Se n'è accorto solo quando era troppo tardi.
1882	33d2049	41	en profiter abusivement	approfittarsene		\N	2026-02-06 15:39:13.287623	0	2026-02-07 15:39:13.287623	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Approfittare in modo scorretto di una situazione	to take advantage of it	es ausnutzen	manararaotra izany tsy ara-dalàna	Non approfittartene della mia gentilezza!
1883	f98896a	41	s'en occuper	occuparsene		\N	2026-02-06 15:39:13.309154	0	2026-02-07 15:39:13.309154	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Prendersi cura di qualcosa	to take care of it	sich darum kümmern	mikarakara izany	Non preoccuparti, me ne occupo io.
1885	a7ce299	41	oublier quelque chose	dimenticarsene		\N	2026-02-06 15:39:13.380216	0	2026-02-07 15:39:13.380216	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Dimenticarsi completamente di qualcosa	to forget about it	es vergessen	manadino tanteraka izany	Me ne sono dimenticato e ho perso l'appuntamento.
1884	6099c05	41	s'en souvenir	ricordarsene		\N	2026-02-06 15:39:13.331736	0	2026-02-13 08:18:06.986204	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Ricordarsi di qualcosa	to remember it	sich daran erinnern	mahatsiaro izany	Me ne ricordo benissimo, è successo l'anno scorso.
1886	a82bb9f	41	s'y intéresser	interessarsene		\N	2026-02-06 15:39:13.405529	0	2026-02-07 15:39:13.405529	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Interessarsi a qualcosa	to take an interest in it	sich dafür interessieren	mampiseho fahalianana amin'izany	Non se ne interessa per niente di politica.
1887	77ed2d8	41	s'en soucier	curarsene		\N	2026-02-06 15:39:13.430263	0	2026-02-07 15:39:13.430263	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Preoccuparsi o curarsi di qualcosa	to care about it	sich darum kümmern	miraharaha izany	Non se ne cura minimamente della salute.
1888	f26f078	41	s'en ficher	infischiarsene		\N	2026-02-06 15:39:13.453705	0	2026-02-13 08:19:38.024306	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Non curarsene minimamente	not to care at all	sich nicht darum scheren	tsy miraharaha akory	Se ne infischia delle regole della casa.
1889	cc44643	41	se moquer de	ridersene		\N	2026-02-06 15:39:13.595682	0	2026-02-13 08:16:31.318409	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Non curarsene e riderci sopra	to laugh it off	darüber lachen	mihomehy fotsiny izany	Se ne ride delle critiche.
1890	0b54c70	41	s'en plaindre	lamentarsene		\N	2026-02-06 15:39:13.632511	0	2026-02-13 08:17:21.264172	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Lagnarsi di qualcosa	to complain about it	sich darüber beklagen	mitaraina momba izany	Se ne lamenta sempre ma non fa niente.
2209	e97a3b0	61	Rythme	Ritmo		\N	2026-02-24 15:07:03.210508	0	2026-02-25 15:07:03.210508	{sport,corps,physique}	2.5	0	0	\N	\N	Cadenza regolare dei movimenti o del battito cardiaco.	Rhythm	Rhythmus	Ritma	Mantieni un ritmo costante durante la corsa.
2215	f398a0e	61	Abdos	Addominali		\N	2026-02-24 15:07:43.727593	0	2026-02-25 15:07:43.727593	{sport,corps,physique}	2.5	0	0	\N	\N	Muscoli della parete addominale.	Abs	Bauchmuskeln	Ventre	Gli addominali si allenano con i crunch.
2219	98b6563	61	Protéines	Proteine		\N	2026-02-24 15:08:11.059375	0	2026-02-25 15:08:11.059375	{sport,nutrition,santé}	2.5	0	0	\N	\N	Nutrienti essenziali per la costruzione e riparazione dei tessuti muscolari.	Proteins	Proteine	Protéines	Le proteine aiutano il recupero muscolare.
2220	b45f3c0	61	Glucides	Carboidrati		\N	2026-02-24 15:08:17.57252	0	2026-02-25 15:08:17.57252	{sport,nutrition,santé}	2.5	0	0	\N	\N	Principale fonte di energia rapida per l'organismo.	Carbohydrates	Kohlenhydrate	Glucides	I carboidrati sono necessari prima dell'allenamento.
2221	5d19bf3	61	Lipides	Lipidi		\N	2026-02-24 15:08:24.117868	0	2026-02-25 15:08:24.117868	{sport,nutrition,santé}	2.5	0	0	\N	\N	Nutrienti che forniscono energia a lungo termine e proteggono gli organi.	Fats	Fette	Lipides	I lipidi buoni sono presenti nell'olio d'oliva.
2222	0ffa129	61	Vitamines	Vitamine		\N	2026-02-24 15:08:30.311756	0	2026-02-25 15:08:30.311756	{sport,nutrition,santé}	2.5	0	0	\N	\N	Sostanze essenziali per il metabolismo e il benessere generale.	Vitamins	Vitamine	Vitamines	Le vitamine rafforzano il sistema immunitario.
2223	89e2954	61	Minéraux	Minerali		\N	2026-02-24 15:08:36.740871	0	2026-02-25 15:08:36.740871	{sport,nutrition,santé}	2.5	0	0	\N	\N	Elementi inorganici necessari per funzioni corporee.	Minerals	Mineralstoffe	Minéraux	I minerali aiutano il recupero dopo lo sforzo.
2224	c477f1f	61	Calories	Calorie		\N	2026-02-24 15:08:42.643149	0	2026-02-25 15:08:42.643149	{sport,nutrition,santé}	2.5	0	0	\N	\N	Unità di misura dell'energia fornita dagli alimenti.	Calories	Kalorien	Kaloria	Controlla le calorie per mantenere il peso forma.
2225	8205abd	61	Régime	Dieta		\N	2026-02-24 15:08:49.405221	0	2026-02-25 15:08:49.405221	{sport,nutrition,santé}	2.5	0	0	\N	\N	Insieme di abitudini alimentari bilanciate.	Diet	Diät	Régime	Segui una dieta equilibrata per gli sportivi.
2226	3847a0e	61	Repas	Pasto		\N	2026-02-24 15:08:56.296799	0	2026-02-25 15:08:56.296799	{sport,nutrition,santé}	2.5	0	0	\N	\N	Consumo di cibo in un determinato momento.	Meal	Mahlzeit	Sakafo	Un pasto proteico dopo l'allenamento è ideale.
2227	5d02fa8	61	Collation	Spuntino		\N	2026-02-24 15:09:02.926745	0	2026-02-25 15:09:02.926745	{sport,nutrition,santé}	2.5	0	0	\N	\N	Piccolo pasto leggero tra i pasti principali.	Snack	Imbiss	Sakafo kely	Uno spuntino prima dell'allenamento dà energia.
2228	c5fc440	61	Sommeil	Sonno		\N	2026-02-24 15:09:09.005267	0	2026-02-25 15:09:09.005267	{sport,nutrition,santé}	2.5	0	0	\N	\N	Periodo di riposo necessario per il recupero fisico e mentale.	Sleep	Schlaf	Torimaso	Il sonno di qualità accelera il recupero.
2229	80b4c9f	61	Digestion	Digestione		\N	2026-02-24 15:09:15.921933	0	2026-02-25 15:09:15.921933	{sport,nutrition,santé}	2.5	0	0	\N	\N	Processo di trasformazione del cibo in sostanze assimilabili.	Digestion	Verdauung	Fandevonana	Una buona digestione evita gonfiori dopo i pasti.
2230	37562d1	61	Immunité	Immunità		\N	2026-02-24 15:09:22.660386	0	2026-02-25 15:09:22.660386	{sport,nutrition,santé}	2.5	0	0	\N	\N	Capacità del corpo di difendersi dalle malattie.	Immunity	Immunität	Immunité	L'esercizio moderato rafforza l'immunità.
2231	f2ba5c4	61	Équilibre alimentaire	Equilibrio alimentare		\N	2026-02-24 15:09:30.287571	0	2026-02-25 15:09:30.287571	{sport,nutrition,santé}	2.5	0	0	\N	\N	Combinazione corretta di tutti i nutrienti essenziali.	Balanced diet	Ausgewogene Ernährung	Fandanjana ara-pahasalamana	L'equilibrio alimentare è alla base di ogni dieta sportiva.
1892	c3a5543	41	s'en étonner	stupirsene		\N	2026-02-06 15:39:13.703744	0	2026-02-07 15:39:13.703744	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Stupirsi di qualcosa	to be astonished by it	sich darüber wundern	gaga amin'izany	Non stupirtene, succede spesso.
1893	5a64cff	41	s'en réjouir	rallegrarsene		\N	2026-02-06 15:39:13.730525	0	2026-02-14 16:03:52.571063	{"verbo pronominale",italien,courant}	2.0999999999999996	0	0	\N	\N	Gioire di qualcosa	to rejoice in it	sich darüber freuen	mifaly amin'izany	Se ne rallegra moltissimo per il tuo successo.
1894	4aa3173	41	s'en attrister	dispiacersene		\N	2026-02-06 15:39:13.753561	0	2026-02-13 08:19:19.858114	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Rammaricarsi o dispiacersi	to be sorry about it	es bedauern	malahelo amin'izany	Me ne dispiace molto, non volevo offenderti.
1913	e01ef36	41	en sortir	uscirne		\N	2026-02-06 15:39:14.302568	0	2026-02-07 15:39:14.302568	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Uscire da una situazione difficile	to come out of it	herauskommen	mivoaka amin'izany	Ne uscirà vincitore, ne sono sicuro.
1755	4b6db37	40	Inquiet	preoccupato		\N	2026-01-31 15:19:22.017009	0	2026-02-01 15:19:22.017009	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova apprensione per qualcosa.	Worried	Besorgt	Matahotra	Sembra preoccupato per la salute della madre.
2216	4bfabd7	61	Jambes	Gambe		\N	2026-02-24 15:07:50.916019	0	2026-02-25 15:07:50.916019	{sport,corps,physique}	2.5	0	0	\N	\N	Arti inferiori del corpo umano.	Legs	Beine	Tongotra	Le gambe sono fondamentali nella corsa.
2217	e7a938a	61	Bras	Braccia		\N	2026-02-24 15:07:57.445089	0	2026-02-25 15:07:57.445089	{sport,corps,physique}	2.5	0	0	\N	\N	Arti superiori del corpo umano.	Arms	Arme	Tanana	Le braccia si rafforzano con i pesi.
2218	e569e85	61	Hydratation	Idratazione		\N	2026-02-24 15:08:04.286005	0	2026-02-25 15:08:04.286005	{sport,nutrition,santé}	2.5	0	0	\N	\N	Apporto di liquidi necessario per mantenere l'equilibrio idrico.	Hydration	Hydration	Fisotroana rano	L'idratazione è fondamentale durante l'allenamento.
2234	1c51404	61	Concentration	Concentrazione		\N	2026-02-24 15:09:48.585799	0	2026-02-25 15:09:48.585799	{sport,mental,motivation}	2.5	0	0	\N	\N	Capacità di focalizzare l'attenzione su un compito.	Concentration	Konzentration	Fifantohana	La concentrazione è decisiva nelle competizioni.
2235	5d4dcc7	61	Détermination	Determinazione		\N	2026-02-24 15:09:55.286278	0	2026-02-25 15:09:55.286278	{sport,mental,motivation}	2.5	0	0	\N	\N	Volontà ferma di perseguire un obiettivo.	Determination	Entschlossenheit	Fahamendrehana	La determinazione supera ogni ostacolo.
2236	606ae49	61	Confiance	Confidenza		\N	2026-02-24 15:10:01.738742	0	2026-02-25 15:10:01.738742	{sport,mental,motivation}	2.5	0	0	\N	\N	Fiducia nelle proprie capacità.	Confidence	Selbstvertrauen	Fahatokisana	La confidenza aiuta a dare il massimo.
1898	0e47f5a	41	s'en abstenir	astenersene		\N	2026-02-06 15:39:13.995015	0	2026-02-14 16:04:05.561931	{"verbo pronominale",italien,courant}	2.0999999999999996	0	0	\N	\N	Evitare di fare qualcosa	to abstain from it	sich dessen enthalten	miala amin'izany	Astenetevene per favore, non è il momento.
1098	fc70d81	28	Objectif	Obiettivo		\N	2026-01-08 15:19:20.190759	1	2026-02-02 15:31:27.274829	{nom,italien,plan}	2.6	1	1	\N	\N	Scopo concreto da raggiungere.	Goal	Ziel	Tanjona	Fissa obiettivi realistici per motivarti.
2237	87e4aa8	61	Mental	Mentale		\N	2026-02-24 15:10:08.351233	0	2026-02-25 15:10:08.351233	{sport,mental,motivation}	2.5	0	0	\N	\N	Aspetto psicologico legato alla prestazione sportiva.	Mental	Mental	Mental	La preparazione mentale è decisiva.
1866	ff5a285	41	il en faut	volerci		\N	2026-02-06 15:39:12.936914	0	2026-02-07 15:39:12.936914	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Essere necessario (tempo, pazienza, ecc.)	it takes	es braucht	mila izany	Ci vuole pazienza per insegnare ai bambini.
1895	8785c4b	41	le regretter	rammaricarsene		\N	2026-02-06 15:39:13.779942	0	2026-02-07 15:39:13.779942	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Rammaricarsi di qualcosa	to regret it	es bedauern	manenina izany	Se ne rammarica ancora oggi.
1896	257e17e	41	se servir de	servirsene		\N	2026-02-06 15:39:13.804036	0	2026-02-13 08:17:06.374942	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Utilizzare qualcosa	to use it	es benutzen	mampiasa izany	Servitene pure se ti serve.
1897	5c4b8c1	41	se garder de	guardarsene		\N	2026-02-06 15:39:13.958419	0	2026-02-07 15:39:13.958419	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Guardarsi bene dal fare qualcosa	to beware of it	sich davor hüten	mitandrina tsara amin'izany	Guardatene bene dal fidarti di lui.
1899	0fdbd9f	41	s'y connaître en	intendersene		\N	2026-02-06 15:39:14.015367	0	2026-02-07 15:39:14.015367	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Essere esperto in qualcosa	to know a lot about it	sich damit auskennen	mahay tsara amin'izany	Me ne intendo di vini francesi.
1900	0de84b1	41	en comprendre	capirne		\N	2026-02-06 15:39:14.034181	0	2026-02-07 15:39:14.034181	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Capire qualcosa di un argomento	to understand some of it	etwas davon verstehen	mahatakatra ampahany	Non ci capisco niente di matematica.
1901	e1e4767	41	en parler	parlarne		\N	2026-02-06 15:39:14.053711	0	2026-02-14 16:03:27.646809	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Discutere di qualcosa	to talk about it	darüber sprechen	miresaka momba izany	Ne parliamo domani con calma.
1902	436e3cf	41	reconsidérer	ripensarci		\N	2026-02-06 15:39:14.077371	0	2026-02-07 15:39:14.077371	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Cambiare idea dopo averci pensato	to think again / to change one's mind	es sich anders überlegen	mieritreritra indray	Ci ripenso, forse hai ragione tu.
1930	aefd5a6	41	Voir la réalité à sa façon	cantarsela e suonarsela		\N	2026-02-07 07:00:21.216143	0	2026-02-08 07:00:21.216143	{}	2.5	0	0	\N	\N	Illudersi o interpretare la realtà a modo proprio	to kid oneself / to see things one's own way	sich selbst etwas vormachen	mahita ny zava-misy amin'ny fombany manokana	Se la canta e se la suona da solo, non ascolta nessuno.
2232	944a603	61	Motivation	Motivazione		\N	2026-02-24 15:09:36.584483	0	2026-02-25 15:09:36.584483	{sport,mental,motivation}	2.5	0	0	\N	\N	Spinta interiore che spinge a raggiungere obiettivi.	Motivation	Motivation	Motivation	La motivazione è essenziale per continuare ad allenarsi.
2233	df2d32f	61	Discipline	Disciplina		\N	2026-02-24 15:09:42.682889	0	2026-02-25 15:09:42.682889	{sport,mental,motivation}	2.5	0	0	\N	\N	Capacità di seguire regole e programmi con costanza.	Discipline	Disziplin	Discipline	La disciplina porta a risultati duraturi.
2238	3a0d779	61	Persévérance	Perseveranza		\N	2026-02-24 15:10:15.512641	0	2026-02-25 15:10:15.512641	{sport,mental,motivation}	2.5	0	0	\N	\N	Capacità di continuare nonostante difficoltà.	Perseverance	Ausdauer	Faharetana	La perseveranza porta al successo.
2239	3647038	61	Habitude	Abitudine		\N	2026-02-24 15:10:27.607756	0	2026-02-25 15:10:27.607756	{sport,mental,motivation}	2.5	0	0	\N	\N	Comportamento ripetuto automaticamente.	Habit	Gewohnheit	Fomba	Crea l'abitudine di allenarti ogni mattina.
2240	44524dd	61	Routine	Routine		\N	2026-02-24 15:10:34.080226	0	2026-02-25 15:10:34.080226	{sport,mental,motivation}	2.5	0	0	\N	\N	Sequenza abituale di azioni.	Routine	Routine	Routine	Segui una routine di riscaldamento.
2241	6637c23	61	Volonté	Volontà		\N	2026-02-24 15:10:40.637109	0	2026-02-25 15:10:40.637109	{sport,mental,motivation}	2.5	0	0	\N	\N	Forza interiore per agire nonostante ostacoli.	Willpower	Wille	Fahavononana	La volontà ti fa alzare presto per correre.
2242	d618470	61	Focus	Focus		\N	2026-02-24 15:10:47.3266	0	2026-02-25 15:10:47.3266	{sport,mental,motivation}	2.5	0	0	\N	\N	Concentrazione totale sull'obiettivo del momento.	Focus	Fokus	Focus	Mantieni il focus durante la gara.
2243	7dfecd3	61	Engagement	Impegno		\N	2026-02-24 15:10:54.07637	0	2026-02-25 15:10:54.07637	{sport,mental,motivation}	2.5	0	0	\N	\N	Dedizione totale verso un programma.	Commitment	Engagement	Fandresena	L'impegno costante dà risultati.
2244	1845ea6	61	Résilience	Resilienza		\N	2026-02-24 15:10:59.892014	0	2026-02-25 15:10:59.892014	{sport,mental,motivation}	2.5	0	0	\N	\N	Capacità di riprendersi dopo un fallimento.	Resilience	Resilienz	Faharetana	La resilienza è la chiave del successo sportivo.
2246	49aef86	61	Haltère	Manubrio		\N	2026-02-24 15:11:11.804705	0	2026-02-25 15:11:11.804705	{sport,matériel,environnement}	2.5	0	0	\N	\N	Peso portatile usato per esercizi di forza.	Dumbbell	Hantel	Haltère	Usa i manubri per allenare le braccia.
2247	50a7833	61	Barre	Sbarra		\N	2026-02-24 15:11:18.471546	0	2026-02-25 15:11:18.471546	{sport,matériel,environnement}	2.5	0	0	\N	\N	Asta lunga con pesi alle estremità per esercizi di forza.	Barbell	Langhantel	Barre	La sbarra è usata nello squat.
1904	ceb595c	41	y croire	crederci		\N	2026-02-06 15:39:14.123215	1	2026-02-14 08:06:09.292263	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Avere fiducia in qualcosa	to believe in it	daran glauben	mino izany	Non ci credo a queste superstizioni.
1905	31fe765	41	capable de réussir à	riuscirci		\N	2026-02-06 15:39:14.141923	0	2026-02-07 15:39:14.141923	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Riuscire a fare qualcosa	to manage to do it	es schaffen	mahomby amin'izany	Ci riesci a finire il lavoro entro stasera?
1906	d080cc3	41	parvenir à faire quelque chose	arrivarci		\N	2026-02-06 15:39:14.159304	0	2026-02-13 08:18:00.511572	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Riuscire a raggiungere un risultato	to manage to do it	es schaffen	mahomby hanao izany	Ci arrivo da solo alla soluzione, grazie.
1907	b9801a0	41	subir une perte	rimetterci		\N	2026-02-06 15:39:14.178913	0	2026-02-07 15:39:14.178913	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Subire una perdita economica o di altro tipo	to lose out / to be out of pocket	verlieren / draufzahlen	very vola na zavatra	Ci ho rimesso 200 euro con quell'affare.
1908	bb0f663	41	la finir	finirla		\N	2026-02-06 15:39:14.198088	0	2026-02-07 15:39:14.198088	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Smettere definitivamente un comportamento	to finish it / to stop it	es beenden	mamita izany	Finiscila con queste storie, sono stanco!
1909	c82bdc0	41	mettre un terme	darci un taglio		\N	2026-02-06 15:39:14.218277	0	2026-02-07 15:39:14.218277	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Interrompere bruscamente qualcosa	to put an end to it	es beenden / einen Schlussstrich ziehen	mametraka farany	Dacci un taglio e andiamo avanti!
1910	bebb6f7	41	en avoir marre	averne le scatole piene		\N	2026-02-06 15:39:14.238534	1	2026-02-14 08:08:26.711459	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Essere esasperato	to be completely fed up	die Schnauze voll haben	feno hatrany	Ne ho le scatole piene del tuo atteggiamento.
1911	939b002	41	s'en passer	farne a meno		\N	2026-02-06 15:39:14.259717	0	2026-02-14 16:04:20.539183	{"verbo pronominale",italien,courant}	2.0999999999999996	0	0	\N	\N	Rinunciare a qualcosa volentieri	to do without it	darauf verzichten	manao tsy misy izany	Ne faccio a meno volentieri di quel tipo di amici.
1756	ed33174	40	Arrogant	arrogante		\N	2026-01-31 15:19:22.030757	0	2026-02-01 15:19:22.030757	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che si ritiene superiore agli altri.	Arrogant	Arrogant	Mibohaka	Il suo atteggiamento arrogante irrita tutti.
2245	359cec7	61	Dépassement	Superamento		\N	2026-02-24 15:11:05.740551	0	2026-02-25 15:11:05.740551	{sport,mental,motivation}	2.5	0	0	\N	\N	Superamento dei propri limiti personali.	Self-transcendence	Überwindung	Fandresena tena	Il superamento di sé porta a nuovi record.
2248	74a8015	61	Tapis	Tappetino		\N	2026-02-24 15:11:25.237217	0	2026-02-25 15:11:25.237217	{sport,matériel,environnement}	2.5	0	0	\N	\N	Superficie imbottita per esercizi a terra.	Mat	Matte	Tapis	Usa il tappetino per gli addominali.
1919	41025c5	41	en savoir une de plus que le diable	saperne una più del diavolo		\N	2026-02-06 15:39:14.441121	0	2026-02-07 15:39:14.441121	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Essere molto furbo e astuto	to be very cunning	schlauer sein als der Teufel	mahay mihoatra ny devoly	Ne sa una più del diavolo per evitare i problemi.
1920	5216368	41	ne pas voir l'heure	non vederne l'ora		\N	2026-02-06 15:39:14.462299	1	2026-02-15 15:54:15.039499	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Aspettare qualcosa con impazienza	to look forward to it	es kaum erwarten können	miandrandra izany amin'ny fientanana	Non vedo l'ora di partire per le vacanze.
1757	cd555b1	40	Égoïste	egoista		\N	2026-01-31 15:19:22.044254	0	2026-02-01 15:19:22.044254	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che pensa solo al proprio interesse.	Selfish	Egoistisch	Tia tena	È egoista e non condivide mai nulla.
1758	5e74196	40	Jaloux	geloso		\N	2026-01-31 15:19:22.058473	0	2026-02-01 15:19:22.058473	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova invidia verso il successo altrui.	Jealous	Eifersüchtig	Saro-aina	È geloso del successo del fratello.
1532	fd4924e	38	Chaussures	scarpe		\N	2026-01-25 06:44:09.486035	0	2026-01-26 06:44:09.486035	{nom,italien,abbigliamento}	2.5	0	0	\N	\N	Calzature specifiche per lo sport praticato.	Shoes	Schuhe	Kiraro	Scegli scarpe adatte alla corsa.
2249	3f0710e	61	Salle	Palestra		\N	2026-02-24 15:11:31.459079	0	2026-02-25 15:11:31.459079	{sport,matériel,environnement}	2.5	0	0	\N	\N	Luogo attrezzato per l'allenamento.	Gym	Fitnessstudio	Salle	Vado in palestra tre volte a settimana.
2250	4313a0a	61	Terrain	Campo		\N	2026-02-24 15:11:37.990803	0	2026-02-25 15:11:37.990803	{sport,matériel,environnement}	2.5	0	0	\N	\N	Spazio esterno per sport di squadra.	Field	Feld	Kianja	Il campo da calcio è in erba naturale.
2251	2b5dcc0	61	Piscine	Piscina		\N	2026-02-24 15:11:43.981039	0	2026-02-25 15:11:43.981039	{sport,matériel,environnement}	2.5	0	0	\N	\N	Vasca per nuoto o attività acquatiche.	Pool	Schwimmbad	Piscine	La piscina olimpionica ha 50 metri.
2252	64ea66a	61	Chronomètre	Cronometro		\N	2026-02-24 15:11:50.376832	0	2026-02-25 15:11:50.376832	{sport,matériel,environnement}	2.5	0	0	\N	\N	Strumento per misurare il tempo con precisione.	Stopwatch	Stoppuhr	Chronomètre	Usa il cronometro per gli intervalli.
2253	f2b9861	61	Balance	Bilancia		\N	2026-02-24 15:11:56.599376	0	2026-02-25 15:11:56.599376	{sport,matériel,environnement}	2.5	0	0	\N	\N	Strumento per pesare il corpo o i pesi.	Scale	Waage	Balance	Controlla il peso sulla bilancia ogni settimana.
2254	cace624	61	Sac de sport	Borsa sportiva		\N	2026-02-24 15:12:03.299409	0	2026-02-25 15:12:03.299409	{sport,matériel,environnement}	2.5	0	0	\N	\N	Borsa per trasportare attrezzatura sportiva.	Sports bag	Sporttasche	Sac de sport	Metti tutto nella borsa sportiva.
2423	bc4a055	63	Pathologie	Patologia		\N	2026-02-24 15:49:48.219486	0	2026-02-25 15:49:48.219486	{science,vivant,santé}	2.5	0	0	\N	\N	Studio delle cause e dei meccanismi delle malattie.	Pathology	Pathologie	Pathologie	La patologia studia le alterazioni dei tessuti.
2424	b1e1644	63	Traitement	Trattamento		\N	2026-02-24 15:49:55.21893	0	2026-02-25 15:49:55.21893	{science,vivant,santé}	2.5	0	0	\N	\N	Insieme di interventi per curare una malattia.	Treatment	Behandlung	Traitement	Il trattamento è stato efficace.
1915	e80d5b5	41	en voir de toutes les couleurs	vederne di tutti i colori		\N	2026-02-06 15:39:14.353855	0	2026-02-07 15:39:14.353855	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Vivere esperienze difficili di ogni tipo	to go through hell	allerhand erleben	mahita zavatra sarotra rehetra	In quel viaggio ne ho viste di tutti i colori.
1916	e70f15d	41	S'en tirer à bon compte	farla franca		\N	2026-02-06 15:39:14.375761	0	2026-02-07 15:39:14.375761	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Evitare una punizione o conseguenza negativa	to get away with it	ungeschoren davonkommen	miala tsy voasazy	L'ha fatta franca anche questa volta.
1917	599e6d1	41	en dire de toutes les couleurs	dirne di tutti i colori		\N	2026-02-06 15:39:14.39972	0	2026-02-07 15:39:14.39972	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Insultare o criticare pesantemente qualcuno	to say all sorts of things (insults)	allerhand sagen	milaza zavatra ratsy rehetra	Gliene ha dette di tutti i colori durante la lite.
1918	1fd20fa	41	prendre son temps	prendersela comoda		\N	2026-02-06 15:39:14.420309	0	2026-02-07 15:39:14.420309	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Non avere fretta, fare le cose con calma	to take one's time	sich Zeit lassen	mandany fotoana tsy maika	Se la prende comoda con i compiti.
2425	6992e0b	63	Vaccin	Vaccino		\N	2026-02-24 15:50:02.340322	0	2026-02-25 15:50:02.340322	{science,vivant,santé}	2.5	0	0	\N	\N	Preparato che stimola la risposta immunitaria.	Vaccine	Impfstoff	Vaccin	Il vaccino ha eradicato il vaiolo.
2426	7bcaa01	63	Neurone	Neurone		\N	2026-02-24 15:50:09.221224	0	2026-02-25 15:50:09.221224	{science,vivant,santé}	2.5	0	0	\N	\N	Cellula del sistema nervoso che trasmette impulsi.	Neuron	Neuron	Neurone	Il neurone comunica tramite sinapsi.
2427	f20dcd2	63	Biotechnologie	Biotecnologia		\N	2026-02-24 15:50:15.917829	0	2026-02-25 15:50:15.917829	{science,vivant,santé}	2.5	0	0	\N	\N	Uso di organismi viventi per produrre beni o servizi.	Biotechnology	Biotechnologie	Biotechnologie	La biotecnologia ha creato nuovi farmaci.
1050	98be4ff	28	Espèce	Specie		\N	2026-01-08 15:19:18.141813	1	2026-02-02 15:38:48.24908	{nom,italien,biodiversité}	2.6	1	1	\N	\N	Gruppo di organismi capaci di riprodursi tra loro.	Species	Art	Espèce	L'uomo è una specie unica.
1828	cbb6528	41	en vouloir à quelqu'un	avercela		\N	2026-02-06 15:39:11.964133	1	2026-02-14 08:07:45.133272	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Serbare rancore verso qualcuno	to have it in for someone	es auf jemanden abgesehen haben	manana lolom-po amin'olona	Ce l'ha con me senza nessun motivo.
1922	50f73c7	41	en avoir par dessus la tête	averne fin sopra i capelli		\N	2026-02-06 15:39:14.504012	0	2026-02-07 15:39:14.504012	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Essere completamente stufo	to be sick and tired of it	die Nase gestrichen voll haben	feno hatrany an-tampony	Ne ho fin sopra i capelli di queste lamentele.
1923	7a89884	41	en vouloir à mort	volerne a morte		\N	2026-02-06 15:39:14.526054	0	2026-02-07 15:39:14.526054	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Odiare profondamente qualcuno	to hate someone's guts	tödlichen Groll hegen	mitana lolom-po hatrany amin'ny fahafatesana	Gliene vuole a morte per il tradimento.
1924	6ac332e	41	s'en ficher royalement	fregarsene altamente		\N	2026-02-06 15:39:14.546245	0	2026-02-13 08:19:11.915724	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Ignorare completamente qualcosa	not to give a damn at all	einen Teufel darum scheren	tsy miraharaha mihitsy	Se ne frega altamente delle opinioni altrui.
1925	25ed4a0	41	y jeter un oeil	darci un occhio		\N	2026-02-06 15:39:14.566996	0	2026-02-13 08:17:13.615785	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Dare uno sguardo veloce	to have a look at it	einen Blick darauf werfen	mijery kely izany	Dacci un occhio al documento prima di firmare.
1926	51e775f	41	en être sûr	esserne sicuro		\N	2026-02-06 15:39:14.588482	0	2026-02-07 15:39:14.588482	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Essere assolutamente certo di qualcosa	to be sure of it	sich sicher sein	azo antoka tanteraka amin'izany	Ne sono sicuro al cento per cento.
1927	ba568e7	41	en penser	pensarne		\N	2026-02-06 15:39:14.609357	0	2026-02-07 15:39:14.609357	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Avere un'opinione su qualcosa	to think about it	darüber denken	mieritreritra momba izany	Cosa ne pensi di questo nuovo telefono?
1928	18dddec	41	en faire sans	farne senza		\N	2026-02-06 15:39:14.631341	0	2026-02-07 15:39:14.631341	{"verbo pronominale",italien,courant}	2.5	0	0	\N	\N	Rinunciare a qualcosa	to do without it	darauf verzichten	manao tsy misy izany	Ne farò senza, non è essenziale.
1929	4e96c66	41	s'en moquer	burlarsene		\N	2026-02-06 15:39:14.653154	0	2026-02-13 08:18:40.132837	{"verbo pronominale",italien,courant}	2.3	0	0	\N	\N	Deridere qualcosa o qualcuno	to make fun of it	sich darüber lustig machen	maneso izany	Se ne burla di tutti i consigli che riceve.
1765	d520f85	40	Menteur	bugiardo		\N	2026-01-31 15:19:22.170214	0	2026-02-01 15:19:22.170214	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che racconta bugie abitualmente.	Liar	Lügnerisch	Mandainga	Non fidarti, è un bugiardo cronico.
2428	195c174	63	Informatique	Informatica		\N	2026-02-24 15:50:22.521496	0	2026-02-25 15:50:22.521496	{science,numérique,information}	2.5	0	0	\N	\N	Scienza che studia l'elaborazione automatica delle informazioni.	Computer science	Informatik	Informatique	L'informatica ha cambiato il mondo.
2429	155dfea	63	Algorithme	Algoritmo		\N	2026-02-24 15:50:29.400146	0	2026-02-25 15:50:29.400146	{science,numérique,information}	2.5	0	0	\N	\N	Sequenza di istruzioni per risolvere un problema.	Algorithm	Algorithmus	Algorithme	L'algoritmo di ricerca è molto efficiente.
2430	287ebf8	63	Code	Codice		\N	2026-02-24 15:50:36.796329	0	2026-02-25 15:50:36.796329	{science,numérique,information}	2.5	0	0	\N	\N	Insieme di istruzioni scritte in un linguaggio di programmazione.	Code	Code	Code	Il codice è stato compilato senza errori.
2258	9f945e5	61	Programme	Programma		\N	2026-02-24 15:12:32.308514	0	2026-02-25 15:12:32.308514	{sport,suivi,performance}	2.5	0	0	\N	\N	Sequenza di istruzioni eseguite da un computer.	Program	Programm	Programme	Il programma funziona correttamente.
2431	a95f59c	63	Logiciel	Software		\N	2026-02-24 15:50:43.176635	0	2026-02-25 15:50:43.176635	{science,numérique,information}	2.5	0	0	\N	\N	Insieme di programmi e dati per un computer.	Software	Software	Logiciel	Il software è stato aggiornato.
2354	ec37d19	62	Réseau	Rete		\N	2026-02-24 15:33:37.360905	0	2026-02-25 15:33:37.360905	{sport,matériel,structures}	2.5	0	0	\N	\N	Insieme di computer collegati per condividere risorse.	Network	Netzwerk	Réseau	Il rete è sicuro e veloce.
2432	af076d8	63	Interface	Interfaccia		\N	2026-02-24 15:50:49.739292	0	2026-02-25 15:50:49.739292	{science,numérique,information}	2.5	0	0	\N	\N	Punto di contatto tra utente e sistema.	Interface	Schnittstelle	Interface	L'interfaccia è intuitiva.
2256	0e1820d	61	Élastique	Elastico		\N	2026-02-24 15:12:16.789095	0	2026-02-25 15:12:16.789095	{sport,matériel,environnement}	2.5	0	0	\N	\N	Striscia elastica per esercizi di resistenza.	Resistance band	Widerstandsband	Élastique	L'elastico è perfetto per il riscaldamento.
2257	d4a32a0	61	Corde	Corda		\N	2026-02-24 15:12:23.512385	0	2026-02-25 15:12:23.512385	{sport,matériel,environnement}	2.5	0	0	\N	\N	Attrezzo per saltare o per esercizi di forza.	Rope	Seil	Corde	Salta alla corda per il cardio.
2259	638b19c	61	Série	Serie		\N	2026-02-24 15:12:38.622844	0	2026-02-25 15:12:38.622844	{sport,suivi,performance}	2.5	0	0	\N	\N	Gruppo di ripetizioni consecutive di un esercizio.	Set	Satz	Série	Fai tre serie da dieci ripetizioni.
2260	0bf981b	61	Répétition	Ripetizione		\N	2026-02-24 15:12:45.058632	0	2026-02-25 15:12:45.058632	{sport,suivi,performance}	2.5	0	0	\N	\N	Esecuzione singola di un movimento.	Repetition	Wiederholung	Répétition	Aumenta il numero di ripetizioni progressivamente.
2261	870880d	61	Charge	Carico		\N	2026-02-24 15:12:51.321101	0	2026-02-25 15:12:51.321101	{sport,suivi,performance}	2.5	0	0	\N	\N	Peso o resistenza applicata durante l'esercizio.	Load	Gewicht	Charge	Aumenta il carico ogni due settimane.
2262	1261eee	61	Temps	Tempo		\N	2026-02-24 15:12:58.443072	0	2026-02-25 15:12:58.443072	{sport,suivi,performance}	2.5	0	0	\N	\N	Durata di un esercizio o di una sessione.	Time	Zeit	Fotoana	Registra il tempo di ogni sessione.
2263	cf240b3	61	Fréquence	Frequenza		\N	2026-02-24 15:13:05.19032	0	2026-02-25 15:13:05.19032	{sport,suivi,performance}	2.5	0	0	\N	\N	Numero di sessioni per settimana.	Frequency	Frequenz	Fréquence	Allenati con frequenza di tre volte a settimana.
1838	2241cc5	41	frôler le danger	vedersela brutta		\N	2026-02-06 15:39:12.338771	2	2026-02-19 08:09:28.905981	{"verbo pronominale",italien,courant}	2.7	6	2	\N	\N	Rischiar grosso	to have a close call	knapp davongekommen	akaiky ny loza	Se l'è vista brutta nell'incidente d'auto.
1851	ab52afb	41	se faire avoir	bersela		\N	2026-02-06 15:39:12.611501	1	2026-02-14 08:06:37.842247	{"verbo pronominale",italien,courant}	2.6	1	1	\N	\N	Farsi ingannare (da 'bersi' = bere)	to be taken in / to fall for it	hereingelegt werden	voafitaka tanteraka	Se l'è bevuta tutta la storia falsa.
1766	49286c8	40	Têtu	testardo		\N	2026-01-31 15:19:22.185132	0	2026-02-01 15:19:22.185132	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non cambia idea nonostante le ragioni contrarie.	Stubborn	Stur	Mibohaka	È testardo e non ascolta mai consigli.
1768	0c1e21f	40	Sensible	sensibile		\N	2026-01-31 15:19:22.217527	0	2026-02-01 15:19:22.217527	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che percepisce profondamente le emozioni.	Sensitive	Sensibel	Mora voakasika	È sensibile e capisce subito quando qualcuno soffre.
2255	7a6fca0	61	Banc	Panca		\N	2026-02-24 15:12:09.819741	0	2026-02-25 15:12:09.819741	{sport,matériel,environnement}	2.5	0	0	\N	\N	Attrezzo per esercizi di forza in posizione distesa o seduta.	Bench	Bank	Banc	Usa la panca per i piegamenti.
1796	b104789	40	Envieux	invidioso		\N	2026-01-31 15:19:22.792505	0	2026-02-01 15:19:22.792505	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova invidia per il successo altrui.	Envious	Neidisch	Saro-aina	È invidioso del nuovo lavoro del collega.
1797	215af50	40	Cynique	cinico		\N	2026-01-31 15:19:22.805496	0	2026-02-01 15:19:22.805496	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non crede nella bontà umana.	Cynical	Zynisch	Tsy mino ny tsara	Il suo commento cinico ha rovinato l'atmosfera.
1799	ed020dd	40	Manipulateur	manipolatore		\N	2026-01-31 15:19:22.833483	0	2026-02-01 15:19:22.833483	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che influenza gli altri per il proprio vantaggio.	Manipulative	Manipulativ	Mpanodina	È manipolatore e ottiene sempre ciò che vuole.
1800	382997d	40	Rancunier	rancoroso		\N	2026-01-31 15:19:22.848948	0	2026-02-01 15:19:22.848948	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che conserva rancore a lungo.	Rancorous	Grollend	Miaro	È rancoroso e non perdona facilmente.
1801	a0ceade	40	Obstiné	ostinato		\N	2026-01-31 15:19:22.898528	0	2026-02-01 15:19:22.898528	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che insiste ostinatamente sulle proprie idee.	Stubborn	Hartnäckig	Mibohaka	È ostinato e non cambia mai opinione.
2264	9f4e75c	61	Intensité	Intensità		\N	2026-02-24 15:13:11.071141	0	2026-02-25 15:13:11.071141	{sport,suivi,performance}	2.5	0	0	\N	\N	Livello di sforzo durante l'allenamento.	Intensity	Intensität	Intensité	Aumenta l'intensità gradualmente.
1805	9200ff6	40	Adaptable	adattabile		\N	2026-01-31 15:19:25.481053	0	2026-02-01 15:19:25.481053	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che si adatta facilmente ai cambiamenti.	Adaptable	Anpassungsfähig	Mora mifanaraka	È adattabile e si trova bene ovunque.
1806	948d521	40	Flexible	flessibile		\N	2026-01-31 15:19:25.497477	0	2026-02-01 15:19:25.497477	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che cambia facilmente piano.	Flexible	Flexibel	Mora mifanaraka	È flessibile e accetta modifiche al programma.
1811	a010522	40	Dynamique	dinamico		\N	2026-01-31 15:19:25.581375	0	2026-02-01 15:19:25.581375	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona attiva e piena di iniziativa.	Dynamic	Dynamisch	Miaraka	È dinamico e porta sempre nuove idee.
1814	30975c2	40	Amoureux	innamorato		\N	2026-01-31 15:19:25.632039	0	2026-02-01 15:19:25.632039	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che prova amore intenso.	In love	Verliebt	Miaraka	È innamorato e pensa solo a lei.
1815	2725483	40	Détendu	rilassato		\N	2026-01-31 15:19:25.648659	0	2026-02-01 15:19:25.648659	{adjectif,italien,émotion}	2.5	0	0	\N	\N	Persona che mostra calma e assenza di tensione.	Relaxed	Entspannt	Miadana	Sembra sempre rilassato anche sotto pressione.
2266	564d85f	61	Statistiques	Statistiche		\N	2026-02-24 15:13:23.976411	0	2026-02-25 15:13:23.976411	{sport,suivi,performance}	2.5	0	0	\N	\N	Dati numerici che misurano i progressi.	Statistics	Statistiken	Statistiques	Analizza le statistiche per migliorare.
2267	76d8abe	61	Relaxation	Rilassamento		\N	2026-02-24 15:13:30.542586	0	2026-02-25 15:13:30.542586	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Tecnica per ridurre tensione fisica e mentale.	Relaxation	Entspannung	Relaxation	Pratica il rilassamento dopo ogni sessione.
2268	1a7f8a8	61	Respiration profonde	Respirazione profonda		\N	2026-02-24 15:13:37.167817	0	2026-02-25 15:13:37.167817	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Tecnica di inspirazione ed espirazione lenta e profonda.	Deep breathing	Tiefes Atmen	Fisefana lalina	La respirazione profonda calma il battito cardiaco.
1816	9191ffb	40	Motivé	motivato		\N	2026-01-31 15:19:25.669407	0	2026-02-01 15:19:25.669407	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona spinta da forte volontà.	Motivated	Motiviert	Miaraka	È motivato e studia ogni sera.
1817	9fa3acc	40	Persévérant	perseverante		\N	2026-01-31 15:19:25.685334	0	2026-02-01 15:19:25.685334	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che continua nonostante le difficoltà.	Persevering	Ausdauernd	Miaraka	È perseverante e ha raggiunto il suo obiettivo.
1818	9beea9c	40	Audacieux	audace		\N	2026-01-31 15:19:25.699762	0	2026-02-01 15:19:25.699762	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che osa e prende rischi.	Bold	Kühn	Mahery fo	È audace e ha viaggiato solo.
1823	8e4a98b	40	Vaniteux	vanitoso		\N	2026-01-31 15:19:25.780864	0	2026-02-01 15:19:25.780864	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona eccessivamente orgogliosa del proprio aspetto.	Vain	Eitel	Mibohaka	È vanitoso e si guarda sempre allo specchio.
2269	4d4a64f	61	Méditation	Meditazione		\N	2026-02-24 15:13:43.24631	0	2026-02-25 15:13:43.24631	{sport,bien-être,récupération}	2.5	0	0	\N	\N	Pratica di concentrazione mentale per ridurre stress.	Meditation	Meditation	Méditation	La meditazione migliora il focus sportivo.
1824	35ea4ab	40	Méfiant	diffidente		\N	2026-01-31 15:19:25.797354	0	2026-02-01 15:19:25.797354	{adjectif,italien,personnalité}	2.5	0	0	\N	\N	Persona che non si fida facilmente.	Distrustful	Misstrauisch	Matahotra	È diffidente verso gli sconosciuti.
2178	f1a0a15	61	Sport	Sport		\N	2026-02-24 15:03:34.389329	0	2026-02-25 15:03:34.389329	{sport,entraînement,général}	2.5	0	0	\N	\N	Attività fisica organizzata e regolamentata che coinvolge competizione o divertimento.	Sport	Sport	Fanatanjahan-tsaina	Il calcio è lo sport più popolare in Italia.
2179	1a5d738	61	Entraînement	Allenamento		\N	2026-02-24 15:03:40.877614	0	2026-02-25 15:03:40.877614	{sport,entraînement,performance}	2.5	0	0	\N	\N	Attività sistematica finalizzata al miglioramento delle capacità fisiche o tecniche.	Training	Training	Fanofanana	L'allenamento quotidiano è essenziale per migliorare la resistenza.
2180	11fb6eb	61	Exercice	Esercizio		\N	2026-02-24 15:03:47.299308	0	2026-02-25 15:03:47.299308	{sport,entraînement,général}	2.5	0	0	\N	\N	Movimento fisico mirato a sviluppare forza, resistenza o flessibilità.	Exercise	Übung	Fanatanjahan-tsaina	Fare esercizio regolare aiuta a mantenere la forma fisica.
2181	2c9dd80	61	Mouvement	Movimento		\N	2026-02-24 15:03:53.313738	0	2026-02-25 15:03:53.313738	{sport,corps,physique}	2.5	0	0	\N	\N	Spostamento del corpo o di una sua parte durante l'attività fisica.	Movement	Bewegung	Fihetsehana	Ogni movimento deve essere controllato durante l'esercizio.
2031	9e4cf08	60	Endurance	Resistenza		\N	2026-02-24 13:15:37.810248	0	2026-02-25 13:15:37.810248	{conflit,société}	2.5	0	0	\N	\N	Capacità di sostenere uno sforzo prolungato senza affaticarsi eccessivamente.	Endurance	Ausdauer	Faharetana	L'allenamento di resistenza migliora la capacità polmonare.
2183	4f2eb3a	61	Force	Forza		\N	2026-02-24 15:04:05.681391	0	2026-02-25 15:04:05.681391	{sport,capacités,physique}	2.5	0	0	\N	\N	Capacità muscolare di esercitare una tensione o sollevare pesi.	Strength	Kraft	Hery	La forza delle gambe è fondamentale nel ciclismo.
2184	322733e	61	Souplesse	Flessibilità		\N	2026-02-24 15:04:12.386846	0	2026-02-25 15:04:12.386846	{sport,capacités,physique}	2.5	0	0	\N	\N	Ampiezza di movimento delle articolazioni e dei muscoli.	Flexibility	Flexibilität	Fahafahana mihetsika	La flessibilità si migliora con lo stretching quotidiano.
2185	67733ad	61	Coordination	Coordinazione		\N	2026-02-24 15:04:18.295607	0	2026-02-25 15:04:18.295607	{sport,capacités,physique}	2.5	0	0	\N	\N	Armonia tra movimenti di diverse parti del corpo.	Coordination	Koordination	Fifandimbiasana	La coordinazione occhio-mano è essenziale nel tennis.
2325	6e99aeb	62	Apport	Apporto		\N	2026-02-24 15:29:55.238921	0	2026-02-25 15:29:55.238921	{sport,alimentation}	2.5	0	0	\N	\N	Quantità di nutrienti introdotti con l'alimentazione.	Intake	Zufuhr	Fidirana	L'apporto proteico deve essere adeguato.
2326	47c1a9a	62	Petit-déjeuner	Colazione		\N	2026-02-24 15:30:02.305149	0	2026-02-25 15:30:02.305149	{sport,alimentation}	2.5	0	0	\N	\N	Primo pasto della giornata.	Breakfast	Frühstück	Sakafo maraina	Una colazione equilibrata dà energia per l'allenamento.
2327	b1905c7	62	Déjeuner	Pranzo		\N	2026-02-24 15:30:08.701414	0	2026-02-25 15:30:08.701414	{sport,alimentation}	2.5	0	0	\N	\N	Pasto principale di mezzogiorno.	Lunch	Mittagessen	Sakafo antoandro	Il pranzo post-allenamento deve essere ricco di proteine.
2328	3458abf	62	Dîner	Cena		\N	2026-02-24 15:30:15.923945	0	2026-02-25 15:30:15.923945	{sport,alimentation}	2.5	0	0	\N	\N	Ultimo pasto della giornata.	Dinner	Abendessen	Sakafo hariva	Una cena leggera favorisce il recupero notturno.
2329	73e1682	62	Compléments alimentaires	Integratori		\N	2026-02-24 15:30:25.604107	0	2026-02-25 15:30:25.604107	{sport,alimentation}	2.5	0	0	\N	\N	Prodotti che integrano la dieta.	Supplements	Nahrungsergänzungsmittel	Fanampiana sakafo	Gli integratori aiutano in caso di carenze.
2330	128cbf8	62	Sels minéraux	Sali minerali		\N	2026-02-24 15:30:35.483761	0	2026-02-25 15:30:35.483761	{sport,alimentation}	2.5	0	0	\N	\N	Minerali essenziali per il bilancio idro-salino.	Mineral salts	Mineralstoffe	Sira mineraly	I sali minerali si perdono con il sudore.
2331	f57781e	62	Sucres	Zuccheri		\N	2026-02-24 15:30:41.419897	0	2026-02-25 15:30:41.419897	{sport,alimentation}	2.5	0	0	\N	\N	Carboidrati semplici per energia immediata.	Sugars	Zucker	Siramamy	Gli zuccheri rapidi aiutano durante lo sforzo.
2332	8700531	62	Fibres	Fibre		\N	2026-02-24 15:30:47.68977	0	2026-02-25 15:30:47.68977	{sport,alimentation}	2.5	0	0	\N	\N	Sostanze che regolano la digestione.	Fibers	Ballaststoffe	Fibres	Le fibre favoriscono il transito intestinale.
2333	b36dd27	62	Antioxydants	Antiossidanti		\N	2026-02-24 15:30:59.786917	0	2026-02-25 15:30:59.786917	{sport,alimentation}	2.5	0	0	\N	\N	Sostanze che combattono i radicali liberi.	Antioxidants	Antioxidantien	Antioxydants	Gli antiossidanti aiutano il recupero dopo lo sforzo.
2334	027441a	62	Estime de soi	Autostima		\N	2026-02-24 15:31:06.634422	0	2026-02-25 15:31:06.634422	{sport,mental}	2.5	0	0	\N	\N	Valutazione positiva di sé stessi.	Self-esteem	Selbstwertgefühl	Fahatokisana tena	Lo sport aumenta l'autostima.
2335	db084cc	62	Détermination	Grinta		\N	2026-02-24 15:31:22.016379	0	2026-02-25 15:31:22.016379	{sport,mental}	2.5	0	0	\N	\N	Forza di volontà nel perseguire obiettivi difficili.	Grit	Durchhaltevermögen	Fahamendrehana	La grinta è ciò che distingue i campioni.
2336	ed97ccc	62	Constance	Costanza		\N	2026-02-24 15:31:28.27613	0	2026-02-25 15:31:28.27613	{sport,mental}	2.5	0	0	\N	\N	Regolarità nell'allenamento.	Consistency	Konstanz	Faharetana	La costanza porta risultati a lungo termine.
2337	fc9b02f	62	Sacrifice	Sacrificio		\N	2026-02-24 15:31:35.481427	0	2026-02-25 15:31:35.481427	{sport,mental}	2.5	0	0	\N	\N	Rinuncia a qualcosa per raggiungere un obiettivo.	Sacrifice	Opfer	Fanahy	Il sacrificio è parte della vita dell'atleta.
2338	020a0df	62	Dévouement	Dedizione		\N	2026-02-24 15:31:41.928376	0	2026-02-25 15:31:41.928376	{sport,mental}	2.5	0	0	\N	\N	Impegno totale verso lo sport.	Dedication	Hingabe	Fandresena	Il suo devouement è ammirevole.
2339	6cfe334	62	Maîtrise de soi	Autocontrollo		\N	2026-02-24 15:31:48.087134	0	2026-02-25 15:31:48.087134	{sport,mental}	2.5	0	0	\N	\N	Capacità di gestire emozioni e impulsi.	Self-control	Selbstbeherrschung	Fifehezana tena	L'autocontrollo è essenziale sotto pressione.
2340	d36c8f4	62	Détermination personnelle	Determinazione personale		\N	2026-02-24 15:31:54.310583	0	2026-02-25 15:31:54.310583	{sport,mental}	2.5	0	0	\N	\N	Volontà individuale di migliorare.	Personal determination	Persönliche Entschlossenheit	Fahamendrehana manokana	La determinazione personale lo ha portato al successo.
2341	f1abfa8	62	Esprit	Spirito		\N	2026-02-24 15:32:00.819028	0	2026-02-25 15:32:00.819028	{sport,mental}	2.5	0	0	\N	\N	Atteggiamento mentale positivo.	Spirit	Geist	Fanahy	Ha uno spirito combattivo.
2342	9791874	62	Caractère	Carattere		\N	2026-02-24 15:32:07.455885	0	2026-02-25 15:32:07.455885	{sport,mental}	2.5	0	0	\N	\N	Insieme di qualità morali di una persona.	Character	Charakter	Toetra	Il carattere si forgia nello sport.
2343	f06d8ed	62	Mentalité gagnante	Mentalità vincente		\N	2026-02-24 15:32:14.441624	0	2026-02-25 15:32:14.441624	{sport,mental}	2.5	0	0	\N	\N	Atteggiamento orientato al successo.	Winning mentality	Siegermentalität	Mentalité gagnante	La mentalità vincente fa la differenza.
2362	fc3eb1b	62	Classement	Classifica		\N	2026-02-24 15:34:44.493273	0	2026-02-25 15:34:44.493273	{sport,résultats}	2.5	0	0	\N	\N	Ordine di merito degli atleti o squadre.	Ranking	Rangliste	Classement	È primo in classifica.
2363	fea846d	62	Score	Punteggio		\N	2026-02-24 15:34:51.502478	0	2026-02-25 15:34:51.502478	{sport,résultats}	2.5	0	0	\N	\N	Risultato numerico di una partita.	Score	Punktestand	Score	Il punteggio finale è 3 a 1.
2364	6abccb6	62	Record	Record		\N	2026-02-24 15:34:58.270753	0	2026-02-25 15:34:58.270753	{sport,résultats}	2.5	0	0	\N	\N	Miglior risultato mai raggiunto.	Record	Rekord	Record	Ha battuto il record mondiale.
2365	cae4d71	62	Victoire	Vittoria		\N	2026-02-24 15:35:05.43149	0	2026-02-25 15:35:05.43149	{sport,résultats}	2.5	0	0	\N	\N	Esito positivo di una competizione.	Victory	Sieg	Fandresena	La vittoria è stata meritata.
2366	c1cb395	62	Défaite	Sconfitta		\N	2026-02-24 15:35:12.860767	0	2026-02-25 15:35:12.860767	{sport,résultats}	2.5	0	0	\N	\N	Esito negativo di una competizione.	Defeat	Niederlage	Fahaverezana	Dopo la sconfitta ha analizzato gli errori.
2367	2acb267	62	Match nul	Pareggio		\N	2026-02-24 15:35:21.287649	0	2026-02-25 15:35:21.287649	{sport,résultats}	2.5	0	0	\N	\N	Risultato di parità tra due squadre.	Draw	Unentschieden	Match nul	La partita è finita in pareggio.
2368	c6979be	62	Championnat	Campionato		\N	2026-02-24 15:35:28.203733	0	2026-02-25 15:35:28.203733	{sport,résultats}	2.5	0	0	\N	\N	Competizione ufficiale per il titolo di campione.	Championship	Meisterschaft	Championnat	Il campionato italiano è molto seguito.
2369	815729b	62	Tournoi	Torneo		\N	2026-02-24 15:35:35.651074	0	2026-02-25 15:35:35.651074	{sport,résultats}	2.5	0	0	\N	\N	Serie di incontri a eliminazione.	Tournament	Turnier	Tournoi	Il torneo di tennis è iniziato oggi.
2370	a3f7231	62	Médaille	Medaglia		\N	2026-02-24 15:35:43.969046	0	2026-02-25 15:35:43.969046	{sport,résultats}	2.5	0	0	\N	\N	Premio per i primi classificati.	Medal	Medaille	Médaille	Ha vinto la medaglia d'oro.
2371	71b2526	62	Podium	Podio		\N	2026-02-24 15:35:51.542766	0	2026-02-25 15:35:51.542766	{sport,résultats}	2.5	0	0	\N	\N	Pedana per i primi tre classificati.	Podium	Podest	Podium	È salito sul podio per la premiazione.
2372	edff38f	63	Science	Scienza		\N	2026-02-24 15:43:53.469281	0	2026-02-25 15:43:53.469281	{science,méthode,fondements}	2.5	0	0	\N	\N	Insieme sistematico di conoscenze ottenute attraverso osservazione, sperimentazione e ragionamento.	Science	Wissenschaft	Siansa	La scienza ha rivoluzionato la nostra comprensione del mondo.
2373	0dd46d4	63	Théorie	Teoria		\N	2026-02-24 15:44:00.936237	0	2026-02-25 15:44:00.936237	{science,méthode,fondements}	2.5	0	0	\N	\N	Spiegazione generale e verificabile di fenomeni naturali basata su prove.	Theory	Theorie	Teoria	La teoria della relatività ha cambiato la fisica moderna.
2374	fd6b228	63	Expérience	Esperimento		\N	2026-02-24 15:44:08.154804	0	2026-02-25 15:44:08.154804	{science,méthode,fondements}	2.5	0	0	\N	\N	Procedura controllata per verificare un'ipotesi.	Experiment	Experiment	Fanandramana	L'esperimento ha confermato l'ipotesi iniziale.
2375	799ba4e	63	Observation	Osservazione		\N	2026-02-24 15:44:15.511348	0	2026-02-25 15:44:15.511348	{science,méthode,fondements}	2.5	0	0	\N	\N	Esame attento e registrazione di un fenomeno.	Observation	Beobachtung	Fanarahana	L'osservazione del cielo ha portato alla scoperta di nuovi pianeti.
2077	a855fad	60	Hypothèse	Ipotesi		\N	2026-02-24 13:20:49.867732	0	2026-02-25 13:20:49.867732	{histoire,méthodologie}	2.5	0	0	\N	\N	Supposizione provvisoria da verificare con prove.	Hypothesis	Hypothese	Hipotesy	L'ipotesi è stata confermata dai risultati.
2376	88bd1be	63	Protocole	Protocollo		\N	2026-02-24 15:44:20.846223	0	2026-02-25 15:44:20.846223	{science,méthode,fondements}	2.5	0	0	\N	\N	Sequenza dettagliata di operazioni in un esperimento.	Protocol	Protokoll	Protokoly	Il protocollo deve essere seguito con precisione.
2377	99c1f9f	63	Donnée	Dato		\N	2026-02-24 15:44:27.021806	0	2026-02-25 15:44:27.021806	{science,méthode,fondements}	2.5	0	0	\N	\N	Informazione raccolta durante un'osservazione o esperimento.	Data	Daten	Donnée	I dati sono stati analizzati con attenzione.
2408	f83e1a3	63	Matière	Materia		\N	2026-02-24 15:48:01.760917	0	2026-02-25 15:48:01.760917	{science,matière,univers}	2.5	0	0	\N	\N	Tutto ciò che occupa spazio e ha massa.	Matter	Materie	Matière	La materia esiste in diversi stati.
2409	7a0a012	63	Particule	Particella		\N	2026-02-24 15:48:08.539136	0	2026-02-25 15:48:08.539136	{science,matière,univers}	2.5	0	0	\N	\N	Piccolissima porzione di materia.	Particle	Teilchen	Particule	Le particelle subatomiche sono studiate in fisica.
2410	2c9aaee	63	Gravité	Gravità		\N	2026-02-24 15:48:15.860553	0	2026-02-25 15:48:15.860553	{science,matière,univers}	2.5	0	0	\N	\N	Forza di attrazione tra corpi dotati di massa.	Gravity	Schwerkraft	Gravité	La gravità tiene i pianeti in orbita.
2411	c9805fb	63	Masse	Massa		\N	2026-02-24 15:48:22.549083	0	2026-02-25 15:48:22.549083	{science,matière,univers}	2.5	0	0	\N	\N	Quantità di materia contenuta in un corpo.	Mass	Masse	Masse	La massa rimane costante ovunque.
2265	c32615b	61	Volume	Volume		\N	2026-02-24 15:13:17.216294	0	2026-02-25 15:13:17.216294	{sport,suivi,performance}	2.5	0	0	\N	\N	Spazio occupato da un corpo.	Volume	Volumen	Volume	Il volume del cubo è di 8 cm³.
2412	d42ce9c	63	Réaction	Reazione		\N	2026-02-24 15:48:29.532539	0	2026-02-25 15:48:29.532539	{science,matière,univers}	2.5	0	0	\N	\N	Trasformazione chimica di sostanze.	Reaction	Reaktion	Réaction	La reazione è esotermica.
2413	c48b74c	63	Synthèse	Sintesi		\N	2026-02-24 15:48:40.112647	0	2026-02-25 15:48:40.112647	{science,matière,univers}	2.5	0	0	\N	\N	Formazione di una sostanza complessa da elementi più semplici.	Synthesis	Synthese	Synthèse	La sintesi è avvenuta in laboratorio.
2186	8e20f55	61	Équilibre	Equilibrio		\N	2026-02-24 15:04:24.994854	0	2026-02-25 15:04:24.994854	{sport,capacités,physique}	2.5	0	0	\N	\N	Stato in cui le forze o le concentrazioni sono bilanciate.	Equilibrium	Gleichgewicht	Fifandanjana	L'equilibrio chimico è dinamico.
2414	1836c3e	63	Onde	Onda		\N	2026-02-24 15:48:47.316692	0	2026-02-25 15:48:47.316692	{science,matière,univers}	2.5	0	0	\N	\N	Propagazione di energia senza trasporto di materia.	Wave	Welle	Onde	L'onda elettromagnetica viaggia alla velocità della luce.
2415	80dfb09	63	Espace-temps	Spazio-tempo		\N	2026-02-24 15:48:54.018348	0	2026-02-25 15:48:54.018348	{science,matière,univers}	2.5	0	0	\N	\N	Continuum quadridimensionale della relatività.	Space-time	Raumzeit	Espace-temps	Lo spazio-tempo è curvo vicino alle masse.
2416	a00e37b	63	Entropie	Entropia		\N	2026-02-24 15:49:00.370701	0	2026-02-25 15:49:00.370701	{science,matière,univers}	2.5	0	0	\N	\N	Misura del disordine in un sistema.	Entropy	Entropie	Entropie	L'entropia dell'universo aumenta sempre.
2417	5ac8072	63	Biologie	Biologia		\N	2026-02-24 15:49:07.24716	0	2026-02-25 15:49:07.24716	{science,vivant,santé}	2.5	0	0	\N	\N	Scienza che studia gli esseri viventi.	Biology	Biologie	Biolojia	La biologia molecolare è in grande sviluppo.
2418	ffff777	63	Organisme	Organismo		\N	2026-02-24 15:49:14.276161	0	2026-02-25 15:49:14.276161	{science,vivant,santé}	2.5	0	0	\N	\N	Essere vivente capace di svolgere funzioni vitali.	Organism	Organismus	Organisme	L'organismo si adatta all'ambiente.
2419	3f8ea61	63	Cellule	Cellula		\N	2026-02-24 15:49:21.208241	0	2026-02-25 15:49:21.208241	{science,vivant,santé}	2.5	0	0	\N	\N	Unità fondamentale della vita.	Cell	Zelle	Cellule	La cellula è la base di ogni organismo.
2420	00e3531	63	Génétique	Genetica		\N	2026-02-24 15:49:27.671062	0	2026-02-25 15:49:27.671062	{science,vivant,santé}	2.5	0	0	\N	\N	Studio dell'ereditarietà e dei geni.	Genetics	Genetik	Génétique	La genetica ha permesso di decifrare il genoma umano.
2421	89147de	63	ADN	DNA		\N	2026-02-24 15:49:34.458245	0	2026-02-25 15:49:34.458245	{science,vivant,santé}	2.5	0	0	\N	\N	Acido desossiribonucleico, portatore dell'informazione genetica.	DNA	DNA	ADN	Il DNA contiene le istruzioni per la vita.
2422	883f9d5	63	Évolution biologique	Evoluzione biologica		\N	2026-02-24 15:49:41.235008	0	2026-02-25 15:49:41.235008	{science,vivant,santé}	2.5	0	0	\N	\N	Processo di cambiamento delle specie nel tempo.	Biological evolution	Biologische Evolution	Évolution biologique	L'evoluzione biologica spiega la diversità della vita.
2451	eacf6f0	63	Transfert	Trasferimento		\N	2026-02-24 15:53:07.218868	0	2026-02-25 15:53:07.218868	{science,innovation,recherche}	2.5	0	0	\N	\N	Passaggio di conoscenze dalla ricerca all'industria.	Transfer	Transfer	Transfert	Il trasferimento tecnologico accelera l'innovazione.
2452	d84280e	63	Prospective	Prospettiva		\N	2026-02-24 15:53:13.657365	0	2026-02-25 15:53:13.657365	{science,innovation,recherche}	2.5	0	0	\N	\N	Studio delle evoluzioni possibili del futuro.	Foresight	Zukunftsforschung	Prospective	La prospettiva tecnologica è ottimista.
2453	59b4d2e	63	Éthique	Etica		\N	2026-02-24 15:53:20.556977	0	2026-02-25 15:53:20.556977	{science,enjeux,impact}	2.5	0	0	\N	\N	Studio dei principi morali che guidano le azioni.	Ethics	Ethik	Éthique	L'etica della ricerca è fondamentale.
2454	e033008	63	Risque	Rischio		\N	2026-02-24 15:53:26.938678	0	2026-02-25 15:53:26.938678	{science,enjeux,impact}	2.5	0	0	\N	\N	Possibilità di un evento negativo.	Risk	Risiko	Risque	Il rischio è stato valutato con attenzione.
2455	7ca9650	63	Écologie	Ecologia		\N	2026-02-24 15:53:33.948053	0	2026-02-25 15:53:33.948053	{science,enjeux,impact}	2.5	0	0	\N	\N	Studio delle relazioni tra organismi e ambiente.	Ecology	Ökologie	Écologie	L'ecologia studia gli impatti umani.
1041	160b32a	28	Climat	Clima		\N	2026-01-08 15:19:17.800625	1	2026-02-02 15:34:54.367912	{nom,italien,climat}	2.6	1	1	\N	\N	Condizioni atmosferiche medie di una regione.	Climate	Klima	Toetrandro	Il cambiamento climatico è una sfida urgente.
1045	177f4f6	28	Pollution	Inquinamento		\N	2026-01-08 15:19:17.907869	1	2026-02-02 15:26:56.651572	{nom,italien,pollution}	2.6	1	1	\N	\N	Introduzione di sostanze nocive nell'ambiente.	Pollution	Verschmutzung	Pollution	L'inquinamento atmosferico è un problema globale.
2456	b3f6f0d	63	Sécurité	Sicurezza		\N	2026-02-24 15:53:41.269623	0	2026-02-25 15:53:41.269623	{science,enjeux,impact}	2.5	0	0	\N	\N	Stato di protezione da pericoli.	Security	Sicherheit	Sécurité	La sicurezza informatica è prioritaria.
2457	d18aef5	63	Progrès	Progresso		\N	2026-02-24 15:53:47.424957	0	2026-02-25 15:53:47.424957	{science,enjeux,impact}	2.5	0	0	\N	\N	Miglioramento delle condizioni umane grazie alla scienza.	Progress	Fortschritt	Progrès	Il progresso tecnologico è costante.
2458	ede214f	63	Nanotechnologie	Nanotecnologia		\N	2026-02-24 15:53:54.00168	0	2026-02-25 15:53:54.00168	{science,enjeux,impact}	2.5	0	0	\N	\N	Manipolazione della materia a scala nanometrica.	Nanotechnology	Nanotechnologie	Nanotechnologie	La nanotecnologia rivoluzionerà la medicina.
2624	3fb2d41	65	géomorphologie	geomorfologia		https://upload.wikimedia.org/wikipedia/commons/a/a9/Geomorphology._Coasts_of_Sihanoukville.jpg	2026-03-30 16:31:58.338468	0	2026-03-31 16:31:58.338468	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Lo studio sistematico dell'evoluzione cronologica dei rilievi e delle forme create dagli agenti esogeni sulla superficie solida attuale.	geomorphology	Geomorphologie	geomorfôlôjia	L'esperto insegnante di geomorfologia descrisse come il fiume sinuoso avesse profondamente scolpito la dura roccia circostante nei millenni precedenti creando affascinanti gole naturali visibili oggi.
2625	b44b419	65	géodésie	geodesia		https://upload.wikimedia.org/wikipedia/commons/3/38/Industrial_Geodesy.png	2026-03-30 16:32:06.615276	0	2026-03-31 16:32:06.615276	{discipline,science_de_la_terre}	2.5	0	0	\N	\N	Complessa misurazione matematica della vera forma tridimensionale e dell'esatto campo gravitazionale associato al pianeta intero considerato spazialmente e temporalmente con le sue piccole alterazioni continue.	geodesy	Geodäsie	jeodezia	Le moderne tecniche satellitari utilizzate in geodesia permettono oggi il tracciamento millimetrico dei lenti movimenti orizzontali e verticali relativi dovuti direttamente allo scorrimento continuo causato fisicamente dalla tettonica superficiale.
\.


--
-- Data for Name: deck_cards; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.deck_cards (deck_pk, card_pk) FROM stdin;
10	255
10	256
10	258
8	13
8	18
18	627
18	628
18	629
28	1076
28	1078
28	1080
28	1077
28	1079
10	263
10	264
10	265
10	266
8	32
8	37
8	38
8	15
8	19
8	29
8	31
17	558
8	11
8	14
8	43
8	44
8	47
8	49
9	55
9	58
9	66
41	1891
41	1931
19	644
8	40
8	41
8	45
8	46
8	48
9	57
9	59
9	63
9	65
9	67
8	16
8	20
17	574
22	808
9	89
9	97
41	1903
41	1932
9	77
9	78
9	81
9	82
9	83
9	84
9	88
9	68
9	75
9	79
9	80
9	86
9	90
9	92
9	93
9	95
20	697
9	112
9	116
9	121
9	98
9	104
9	105
9	106
9	109
9	110
9	107
9	108
9	119
9	120
9	122
9	123
9	124
9	125
9	126
23	847
8	28
8	30
9	137
28	1035
28	1101
9	138
9	139
9	142
9	143
9	144
9	146
9	133
9	134
9	140
9	141
9	145
9	148
9	149
9	150
9	151
19	648
8	33
8	34
12	283
12	288
12	290
12	295
12	297
9	165
12	296
10	168
10	169
10	172
10	176
10	177
10	178
10	179
10	180
28	1036
41	1914
41	1933
9	163
9	164
9	166
10	167
10	171
10	173
10	174
10	181
10	182
10	183
12	302
10	189
12	348
10	191
12	372
12	381
41	1921
41	1934
10	188
10	193
10	195
10	198
10	199
10	205
10	207
10	208
10	202
10	204
10	210
28	1110
10	187
10	190
10	194
10	192
10	196
10	197
10	223
10	225
12	324
12	333
12	342
12	366
12	369
12	375
12	363
12	346
10	218
10	219
10	221
10	222
10	229
10	235
10	237
10	240
10	224
10	232
10	236
10	239
28	1132
28	1137
30	1186
10	217
10	226
10	206
10	227
10	248
10	249
10	251
10	252
10	253
10	254
10	257
10	260
28	1052
28	1133
12	361
12	370
12	373
12	319
12	322
12	331
12	334
10	247
10	250
10	262
12	340
12	364
12	376
8	42
12	326
22	809
22	810
22	811
22	813
22	815
8	10
8	12
8	17
8	21
8	22
8	23
10	186
17	543
12	299
28	1037
30	1194
22	822
22	825
37	1497
12	287
8	36
8	39
12	282
12	284
12	285
10	201
12	289
12	292
12	294
8	24
8	25
8	26
8	27
8	35
12	293
12	298
10	220
12	291
37	1498
37	1499
12	286
22	826
12	303
12	309
12	315
28	1144
12	300
12	306
12	318
12	330
12	336
12	345
12	354
12	357
12	378
12	312
12	321
12	327
12	351
12	360
36	1392
12	339
22	827
12	301
12	304
12	310
12	313
12	307
12	316
12	325
12	337
12	343
12	349
12	355
12	358
12	367
9	50
12	352
9	51
12	379
9	52
12	328
12	314
22	828
12	323
12	329
12	332
12	335
12	338
12	362
12	305
12	308
12	311
12	320
9	53
12	344
12	350
12	356
12	359
12	365
9	54
9	56
12	317
22	829
13	407
13	408
13	410
13	411
13	414
13	416
28	1081
28	1082
12	341
12	347
12	353
12	377
13	382
13	383
13	384
13	386
13	393
13	395
13	396
13	398
13	402
13	404
13	405
25	965
39	1696
22	831
22	832
40	1731
13	406
13	409
13	415
35	1367
35	1369
35	1370
35	1372
10	170
13	385
13	388
35	1373
35	1374
35	1375
40	1734
28	1045
28	1046
28	1050
35	1376
35	1377
35	1378
9	60
35	1381
35	1382
35	1379
35	1380
35	1383
35	1385
35	1387
35	1384
35	1386
22	833
36	1395
36	1396
36	1397
9	61
9	62
9	64
9	69
9	70
9	71
9	72
9	73
9	74
9	76
12	368
12	371
12	374
36	1398
36	1399
36	1400
36	1401
22	834
22	837
22	838
22	839
12	380
13	387
13	389
24	883
35	1366
36	1402
36	1403
36	1404
24	890
36	1405
36	1406
9	85
9	91
9	94
9	96
9	99
9	100
9	101
9	102
9	103
13	390
13	392
13	399
13	401
13	413
13	417
13	419
36	1407
36	1408
36	1409
23	856
23	859
25	967
37	1501
17	546
17	548
17	549
17	550
17	551
17	552
35	1389
23	843
23	844
23	845
23	846
25	968
9	111
9	113
17	557
18	593
32	1300
32	1303
37	1502
37	1503
37	1504
37	1505
37	1506
23	848
17	561
23	850
13	420
13	391
13	400
23	851
23	852
25	970
25	971
25	972
37	1508
37	1509
23	855
23	858
25	976
23	860
23	862
23	863
23	865
37	1513
39	1700
39	1701
39	1702
23	854
23	866
37	1444
39	1703
39	1704
23	857
25	1005
25	1006
25	1007
25	1008
25	1009
38	1528
38	1524
38	1525
38	1526
38	1527
38	1529
38	1532
38	1535
38	1536
38	1537
38	1538
28	1040
13	394
30	1197
30	1198
31	1209
28	1044
38	1547
38	1548
13	397
13	403
13	412
13	418
17	570
18	583
18	584
18	585
18	586
18	587
18	588
18	589
18	590
18	592
30	1196
38	1549
38	1550
38	1552
38	1553
38	1555
38	1556
38	1557
28	1062
38	1554
38	1558
40	1735
40	1743
36	1391
36	1393
36	1410
39	1695
40	1740
40	1742
28	1067
28	1069
28	1070
38	1560
38	1561
18	604
18	621
31	1201
31	1390
37	1415
37	1416
38	1562
38	1563
38	1564
37	1417
40	1751
40	1753
38	1568
38	1569
38	1570
38	1572
28	1088
31	1239
31	1241
38	1573
31	1242
31	1243
31	1244
9	115
38	1574
38	1576
18	612
37	1419
37	1418
38	1577
38	1578
38	1579
38	1587
38	1588
38	1589
38	1590
38	1591
23	853
24	867
35	1368
18	605
18	606
18	607
18	608
18	609
18	610
18	611
37	1420
37	1421
37	1422
37	1427
37	1428
37	1429
40	1804
38	1592
38	1599
38	1600
38	1601
38	1602
28	1142
38	1603
9	117
9	118
19	645
24	868
24	869
24	871
24	872
24	873
28	1049
28	1051
18	615
18	616
18	618
18	619
18	620
37	1423
37	1424
37	1425
38	1604
38	1605
37	1432
37	1433
37	1434
37	1435
38	1606
38	1607
38	1613
37	1436
38	1614
9	127
9	128
9	130
9	131
9	132
9	135
9	136
9	147
9	152
9	154
9	155
9	156
9	157
9	158
9	159
9	160
18	623
18	624
18	625
28	1148
38	1615
18	632
18	634
38	1616
39	1719
39	1720
9	161
10	175
10	184
10	185
10	203
10	211
10	200
24	874
24	876
24	878
36	1394
18	630
37	1439
37	1440
37	1441
37	1442
37	1443
39	1722
24	879
39	1723
18	637
30	1153
18	638
40	1746
24	881
24	882
24	885
18	640
37	1446
30	1154
30	1155
30	1156
40	1747
24	886
24	887
24	891
24	892
19	649
19	667
19	670
19	673
40	1736
40	1739
30	1160
30	1161
10	209
10	213
10	215
30	1162
30	1163
30	1164
30	1165
30	1167
10	216
10	212
10	214
19	654
19	657
30	1168
30	1169
30	1170
30	1171
30	1172
30	1176
30	1177
30	1178
30	1179
30	1180
30	1181
10	228
10	230
10	245
17	544
19	679
30	1187
30	1188
30	1190
30	1191
30	1150
30	1151
9	129
19	684
19	687
20	691
20	694
40	1825
40	1826
20	695
30	1192
28	1095
28	1149
30	1193
31	1207
31	1208
31	1271
31	1212
31	1213
10	231
10	233
10	234
10	238
10	242
10	243
20	690
20	701
20	704
24	897
35	1371
37	1449
37	1450
31	1214
20	708
31	1285
39	1617
39	1618
41	1835
41	1836
41	1837
31	1216
32	1301
32	1302
31	1220
31	1221
31	1222
17	545
31	1223
20	705
31	1224
31	1225
10	246
20	699
20	711
24	899
24	900
39	1621
32	1305
31	1233
31	1234
31	1235
31	1237
39	1626
31	1250
20	703
24	905
31	1251
31	1252
31	1253
17	547
31	1254
9	87
37	1454
32	1307
32	1308
41	1867
17	553
18	1027
18	1029
18	1031
18	1033
40	1748
18	591
18	614
24	906
28	1053
28	1055
24	907
24	908
18	1025
37	1456
37	1457
37	1459
40	1749
40	1756
40	1757
24	893
25	940
18	1026
10	241
10	244
10	259
10	261
24	910
24	912
24	914
18	1024
18	1028
18	1030
18	1032
37	1460
40	1758
17	554
17	555
17	556
24	921
24	915
24	917
24	919
24	920
25	984
37	1461
37	1462
37	1463
24	928
37	1470
37	1471
37	1472
40	1759
40	1762
40	1763
17	559
17	560
24	924
24	925
24	926
24	927
37	1464
37	1465
37	1466
40	1764
40	1765
40	1766
24	934
25	997
25	1004
17	564
24	929
24	930
24	931
24	933
37	1474
40	1768
40	1769
40	1775
37	1478
37	1479
37	1480
17	565
37	1475
37	1476
37	1477
37	1481
37	1482
25	941
25	942
17	566
37	1487
25	945
17	567
17	568
24	875
24	877
24	880
24	884
24	902
25	943
25	944
25	946
40	1779
40	1780
40	1781
37	1492
37	1493
37	1489
17	569
17	571
17	572
17	573
31	1205
32	1306
17	575
40	1782
40	1783
40	1784
40	1785
40	1788
40	1789
22	778
40	1791
40	1794
40	1795
23	841
25	951
25	952
22	784
22	782
22	783
22	785
22	787
40	1796
40	1797
40	1798
40	1799
40	1800
17	576
22	793
22	798
22	800
22	803
25	955
40	1801
40	1802
40	1803
40	1805
22	799
22	802
40	1806
40	1816
22	812
17	577
17	578
17	579
17	580
22	814
25	956
25	957
25	958
25	959
37	1495
37	1496
40	1817
17	581
22	819
22	818
22	820
22	821
22	823
25	960
40	1818
40	1823
40	1824
17	582
22	824
30	1195
22	830
18	594
18	595
18	596
18	597
18	598
18	613
22	835
22	840
37	1500
30	1199
20	698
25	966
37	1507
36	1411
36	1412
36	1413
39	1692
39	1693
39	1694
18	599
18	600
18	601
18	602
18	603
37	1510
37	1511
40	1741
40	1750
31	1202
31	1203
31	1204
25	979
25	980
28	1071
28	1072
37	1512
31	1238
37	1414
40	1752
40	1754
25	973
25	974
25	975
39	1697
39	1698
40	1755
37	1426
18	626
37	1430
37	1431
18	631
23	861
23	849
19	662
37	1437
37	1438
18	635
25	982
25	983
37	1455
37	1473
19	643
37	1445
23	864
37	1447
37	1483
39	1705
39	1706
39	1707
39	1708
25	986
25	987
19	646
23	842
37	1494
25	988
39	1710
39	1711
38	1514
38	1515
38	1518
19	652
19	655
19	658
19	661
19	664
25	1000
25	1002
25	1003
25	1012
38	1516
38	1519
38	1520
38	1521
38	1522
38	1523
38	1530
39	1712
39	1713
39	1714
39	1715
39	1716
39	1717
39	1718
19	647
19	650
19	651
38	1533
38	1534
19	653
19	656
19	659
19	660
19	663
25	1017
38	1543
38	1544
38	1545
38	1546
19	666
19	669
19	672
19	675
20	693
31	1270
19	665
38	1539
38	1540
38	1541
38	1542
28	1038
19	668
19	671
19	674
19	676
28	1039
19	677
28	1041
28	1042
28	1043
19	680
19	683
19	686
40	1814
19	678
19	682
19	685
28	1056
20	689
28	1059
20	692
20	696
24	894
37	1448
40	1815
19	681
24	895
24	896
30	1152
28	1063
28	1065
28	1066
28	1068
38	1559
28	1064
38	1571
20	707
24	898
31	1206
20	702
38	1566
38	1567
28	1084
28	1085
28	1086
28	1087
24	901
37	1451
37	1452
37	1453
9	114
9	153
28	1089
28	1093
28	1091
28	1092
20	709
31	1240
24	903
24	904
25	969
37	1458
28	1106
38	1581
28	1094
28	1096
28	1097
28	1098
38	1582
38	1583
38	1584
38	1585
38	1586
28	1099
28	1102
24	909
24	911
24	913
24	918
28	1103
28	1127
28	1104
24	922
37	1467
37	1468
38	1596
37	1469
38	1597
28	1107
28	1109
28	1108
28	1111
28	1113
28	1114
28	1128
38	1593
38	1594
38	1595
24	932
24	935
24	936
28	1116
28	1121
28	1123
28	1125
38	1598
28	1117
28	1118
28	1119
28	1120
28	1122
28	1124
28	1126
24	937
28	1129
28	1130
24	938
24	939
28	1143
25	992
37	1484
37	1485
37	1486
24	923
25	947
25	948
25	949
28	1131
37	1488
37	1490
37	1491
38	1608
38	1609
38	1610
28	1138
28	1139
28	1140
28	1135
28	1134
28	1136
28	1141
38	1611
38	1612
20	712
28	1146
28	1147
28	1145
40	1737
40	1738
30	1157
30	1158
30	1159
38	1531
30	1166
38	1580
39	1691
39	1699
30	1173
30	1174
30	1175
30	1185
30	1182
30	1183
30	1184
30	1189
39	1709
39	1619
39	1620
39	1724
39	1726
40	1727
40	1728
40	1729
22	777
22	780
22	781
22	806
31	1210
31	1211
31	1217
31	1218
39	1622
39	1623
39	1624
39	1625
39	1725
22	786
22	788
22	789
22	790
22	816
22	817
31	1229
31	1230
31	1231
31	1232
31	1236
39	1627
39	1628
39	1629
22	791
22	792
22	794
31	1226
31	1227
31	1228
32	1304
22	795
22	796
22	807
31	1247
31	1248
31	1267
39	1630
39	1631
39	1632
39	1633
39	1634
39	1635
31	1268
39	1636
39	1637
39	1638
39	1639
22	797
22	801
22	805
31	1249
31	1255
31	1256
31	1257
31	1258
31	1259
31	1260
31	1261
31	1269
39	1640
39	1641
39	1642
31	1262
31	1263
31	1264
31	1265
31	1266
39	1644
39	1645
39	1646
39	1647
31	1272
31	1273
31	1274
31	1275
31	1276
31	1277
31	1278
39	1648
39	1649
39	1650
39	1651
39	1652
31	1279
31	1280
31	1281
31	1282
31	1283
31	1284
39	1653
39	1654
39	1655
39	1656
39	1657
31	1288
31	1289
31	1290
31	1293
31	1294
31	1295
31	1296
31	1297
31	1298
31	1299
39	1662
39	1663
39	1664
39	1665
39	1666
39	1667
32	1309
32	1310
32	1311
32	1312
32	1313
32	1314
32	1315
32	1316
39	1658
39	1659
39	1660
39	1661
32	1317
32	1318
32	1319
39	1668
39	1669
39	1670
39	1671
39	1678
40	1730
39	1673
39	1674
39	1676
39	1677
40	1732
40	1733
39	1679
39	1680
39	1681
39	1682
39	1683
39	1684
39	1685
39	1686
39	1687
39	1688
39	1689
39	1690
40	1744
40	1745
40	1760
40	1761
40	1767
40	1770
40	1771
40	1772
40	1773
40	1774
40	1776
40	1777
40	1778
40	1786
40	1787
40	1790
40	1792
40	1793
40	1807
40	1808
40	1809
40	1810
40	1811
40	1813
40	1819
40	1820
40	1821
40	1822
41	1827
41	1829
41	1832
41	1833
41	1831
41	1830
41	1834
41	1841
41	1842
41	1844
41	1839
41	1845
41	1840
41	1846
41	1843
41	1847
41	1848
41	1849
41	1852
41	1850
41	1853
41	1854
41	1855
41	1856
41	1857
41	1858
41	1859
41	1868
41	1861
41	1863
41	1865
41	1862
41	1864
41	1860
41	1869
41	1870
41	1871
41	1872
41	1873
41	1912
41	1874
41	1875
41	1876
41	1877
41	1878
41	1880
41	1879
41	1881
41	1882
41	1883
41	1885
41	1886
41	1887
41	1889
41	1890
41	1884
41	1888
41	1892
41	1913
41	1894
41	1893
41	1895
41	1930
41	1866
41	1897
41	1899
41	1900
41	1902
41	1896
41	1901
41	1898
41	1907
41	1905
41	1908
41	1909
41	1904
41	1906
41	1910
41	1911
41	1915
41	1916
41	1917
41	1918
41	1919
41	1920
41	1922
41	1923
41	1926
41	1927
41	1928
41	1925
41	1828
41	1929
41	1924
41	1851
41	1838
31	646
28	918
20	166
25	893
25	886
35	1302
25	892
20	157
24	790
25	890
22	257
25	891
22	244
28	195
39	1425
28	922
22	245
25	894
25	885
25	895
31	645
39	1592
20	110
39	1576
25	896
28	263
60	1987
60	1989
60	1990
60	1991
60	1992
60	1993
60	1994
60	1995
60	1996
60	1997
60	1998
60	1999
60	2000
60	2001
60	2002
60	2003
60	792
60	2004
60	777
60	2005
60	2006
60	2007
60	2008
60	2009
60	2010
60	2011
60	2012
60	2013
60	2014
60	1094
60	2015
60	2016
60	2017
60	2018
60	2019
60	2020
60	2021
60	2022
60	2023
60	2024
60	2025
60	2026
60	2027
60	2028
60	2029
60	2030
60	2031
60	2032
60	2033
60	2034
60	2035
60	2036
60	2037
60	2038
60	2039
60	2040
60	1108
60	2041
60	2042
60	2043
60	2044
60	2045
60	2046
60	2047
60	2048
60	2049
60	2050
60	2051
60	2052
60	2053
60	2054
60	2055
60	2056
60	2057
60	2058
60	2059
60	2060
60	2061
60	2062
60	2063
60	2064
60	2065
60	2066
60	2067
60	2068
60	2069
60	2070
60	2071
60	2072
60	2073
60	2074
60	2075
60	2076
60	2077
60	2078
60	2079
60	2080
60	2081
60	2082
60	2083
60	2084
60	2085
60	2086
60	2087
60	2088
60	2089
60	2090
57	2091
57	2095
57	2097
57	2098
57	2099
57	2100
57	2101
57	2103
57	2104
57	393
57	2105
57	2106
57	2107
57	1285
57	2108
57	1059
57	2109
57	2110
57	2111
57	2112
57	1041
57	2113
57	2114
57	2115
57	2116
57	2117
57	2118
57	2119
57	2120
57	1053
57	2121
57	2122
57	2123
57	2124
57	2125
57	1266
57	2126
57	2127
57	2128
57	2129
57	2131
57	2133
57	2134
57	2135
57	2136
57	2137
57	1263
57	2138
57	2139
57	2140
57	1055
57	2141
57	2142
57	2143
57	2144
57	2145
57	1088
57	2147
57	1121
57	2148
57	2149
57	2150
57	2151
57	2152
57	2157
57	2158
57	1464
57	2159
57	2160
57	2161
57	2163
57	2164
57	2165
57	2166
57	2167
57	2168
57	2169
57	2050
57	2170
57	2171
57	2172
57	2173
57	2174
57	2175
57	2176
57	2035
57	2177
40	225
40	227
40	231
40	200
40	197
40	236
40	201
40	170
40	198
40	199
40	230
40	229
61	2178
61	2179
61	2180
61	2181
61	2182
61	2031
61	2183
61	2184
61	1673
61	2185
61	2186
61	2187
61	2188
61	2189
61	2190
61	2191
61	2192
61	2193
61	2194
61	2195
61	2196
61	2197
61	2198
61	2199
61	2200
61	2201
61	2202
61	2203
61	2204
61	2205
61	418
61	2206
61	2207
61	2208
61	2209
61	398
61	1069
61	2210
61	2211
61	2212
61	2213
61	2214
61	2215
61	2216
61	2217
61	2218
61	2219
61	2220
61	2221
61	2222
61	2223
61	2224
61	2225
61	2226
61	2227
61	2228
61	2229
61	2230
61	1124
61	2231
61	2232
61	2233
61	2234
61	2235
61	2236
61	1098
61	2237
61	2238
61	2239
61	2240
61	2241
61	2242
61	2243
61	2244
61	2245
61	2246
61	2247
61	2248
61	1532
61	1514
61	2249
61	2250
61	2251
61	2252
61	2253
61	946
61	2254
61	2255
61	2256
61	2257
61	2258
61	2259
61	2260
61	2261
61	2262
61	1674
61	2263
61	2264
61	2265
61	2266
61	2267
61	2268
61	2269
61	2270
61	2271
61	2272
61	2273
61	2274
61	2275
61	2276
62	2277
62	2278
62	2279
62	2280
62	2281
62	2282
62	2283
62	2284
62	2285
62	638
62	2286
62	2287
62	2288
62	2289
62	2290
62	2291
62	2292
62	2293
62	2294
62	2295
62	2296
62	2297
62	2298
62	2299
62	2300
62	2301
62	2302
62	2303
62	2304
62	2305
62	2306
62	2307
62	2308
62	2309
62	2310
62	2311
62	2312
62	2313
62	2314
62	2315
62	2316
62	2317
62	2318
62	2319
62	403
62	2320
62	2321
62	2322
62	2323
62	2324
62	2325
62	2326
62	2327
62	2328
62	2329
62	1421
62	2330
62	2331
62	2332
62	2333
62	2334
62	2335
62	2336
62	2337
62	2338
62	2339
62	2340
62	2341
62	2342
62	2343
62	2344
62	2345
62	2346
62	2347
62	2348
62	2349
62	2350
62	2351
62	2352
62	2353
62	2354
62	1592
62	2355
62	2356
62	2357
62	2358
62	2359
62	2360
62	2361
62	1540
62	2362
62	2363
62	2364
62	2365
62	2366
62	2367
62	2368
62	2369
62	2370
62	2371
63	2372
63	2373
63	2374
63	2375
63	2077
63	2376
63	2377
63	1093
63	2378
63	2379
63	2380
63	2381
63	2382
63	2383
63	2384
63	2385
63	2386
63	2387
63	2388
63	2389
63	2390
63	1617
63	2391
63	2392
63	2393
63	2394
63	2395
63	2396
63	2397
63	1069
63	2280
63	2398
63	1665
63	2399
63	2400
63	2401
63	2402
63	2403
63	2404
63	2405
63	2406
63	2407
63	2408
63	2409
63	2410
63	2411
63	2265
63	2412
63	2413
63	2186
63	1260
63	2414
63	2415
63	2416
63	2417
63	2418
63	2419
63	2420
63	2421
63	2422
63	1049
63	1089
63	2315
63	2423
63	2424
63	2425
63	2426
63	2427
63	1050
63	2428
63	2429
63	2430
63	2258
63	2431
63	2354
63	2432
63	2433
63	2434
63	2435
63	2436
63	2437
63	2438
63	2439
63	2440
63	2441
63	2442
63	1134
63	2443
63	2444
63	1135
63	2445
63	2446
63	2447
63	2182
63	2448
63	2449
63	2450
63	2451
63	2452
63	2453
63	2454
63	1221
63	2455
63	1045
63	1041
63	2456
63	2457
63	2458
41	2459
65	2527
65	2528
65	2529
65	2530
65	2531
65	2532
65	2533
65	2534
65	2535
65	2536
65	2537
65	2538
65	2539
65	2540
65	2541
65	2542
65	2543
65	2544
65	2545
65	2546
65	2547
65	2548
65	2549
65	2550
65	2551
65	2552
65	1421
65	2553
65	2554
65	2555
65	2556
65	2557
65	2558
65	2559
65	2560
65	2561
65	2562
65	2563
65	2564
65	2565
65	2566
65	2567
65	2568
65	2569
65	2570
65	2571
65	2572
65	2573
65	2574
65	2575
65	2576
65	2577
65	2578
65	2579
65	2580
65	2581
65	2582
65	2583
65	2584
65	2585
65	2586
65	2587
65	2588
65	2589
65	2590
65	2591
65	2592
65	2593
65	2594
65	2595
65	2596
65	2597
65	2598
65	2599
65	2600
65	2601
65	2602
65	2603
65	2604
65	2605
65	2606
65	2607
65	2608
65	2609
65	2610
65	2611
65	2612
65	2613
65	2614
65	2615
65	2616
65	2617
65	2618
65	2619
65	2620
65	2621
65	2622
65	2623
65	2624
65	2625
\.


--
-- Data for Name: decks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.decks (deck_pk, id_json, name, total_correct, total_attempts) FROM stdin;
8	deck_1764768456010	Verbi riflessivi	0	0
9	deck_1764768788608	verbi italiani cento	0	0
10	deck_1764769146118	Aggetivi italiani	0	0
12	deck_1765029900624	Adverbi	0	0
13	deck_1765030516843	Corpo	0	0
17	deck_1765087697005	La famiglia	0	0
18	deck_1765088414575	I mestieri	0	0
19	deck_1765088786252	Gli animali	0	0
20	deck_1765089028883	I verbi della cucina	0	0
22	deck_1765210773476	Participio passato	0	0
23	deck_1765356062733	Roberto Begnini	0	0
24	deck_1765381114109	La casa	0	0
25	deck_1765466682966	Ustensili da cucina	0	0
28	deck_1767885486835	Ambiente	0	0
30	deck_1767974980110	Verbi frasali	0	0
31	deck_1768145784271	Ambiente 2	0	0
32	deck_1768222123839	Espressioni con animali	0	0
35	deck_1768223979569	Espressioni con corpo	0	0
36	deck_1768920453232	Espressioni idiomatiche comuni	0	0
37	deck_1769006952151	Cibo e bevande	0	0
38	deck_1769323414340	Vestiti	0	0
39	deck_1769790165446	Mezzi di trasporto	0	0
40	deck_1769872570083	Aggettivi per le persone	0	0
41	deck_1770392295747	Verbi pronominali	0	0
57	deck_1771754856857	Geografia	0	0
60	deck_1771860286858	Storia	0	0
61	deck_1771944833419	Sport	0	0
62	deck_1771946648654	sports 2	0	0
63	deck_1771947815492	Scienza	0	0
65	deck_1774876755825	Geologia	0	0
\.


--
-- Data for Name: definition_cache; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.definition_cache (id, term, definition, source, confidence, fetched_at) FROM stdin;
1	grande	Definizione non disponibile per 'Grande'	fallback	0.3	2025-12-02 13:02:51.7533
2	arrabbiato	Definizione non disponibile per 'Arrabbiato'	fallback	0.3	2025-12-02 13:05:46.281919
3	frutti	Definizione non disponibile per 'frutti'	fallback	0.3	2025-12-02 13:06:35.640382
4	test back	Definizione non disponibile per 'Test Back'	fallback	0.3	2025-12-02 13:08:37.399297
5	contabile	Definizione non disponibile per 'Contabile'	fallback	0.3	2025-12-02 13:09:14.775675
6	segretario	Definizione non disponibile per 'Segretario'	fallback	0.3	2025-12-02 13:09:45.882857
7	veterinario	Definizione non disponibile per 'veterinario'	fallback	0.3	2025-12-02 13:10:12.193149
8	elettricista	Definizione non disponibile per 'Elettricista'	fallback	0.3	2025-12-02 13:10:12.758133
9	ottobre	Definizione non disponibile per 'Ottobre'	fallback	0.3	2025-12-02 13:10:13.327171
10	gennaio	Definizione non disponibile per 'Gennaio'	fallback	0.3	2025-12-02 13:10:13.901057
11	medico	Definizione non disponibile per 'Medico'	fallback	0.3	2025-12-02 13:10:14.447866
12	ragione	Definizione non disponibile per 'ragione'	fallback	0.3	2025-12-02 13:10:15.057695
13	péroquet	Definizione non disponibile per 'péroquet'	fallback	0.3	2025-12-02 13:10:15.623647
14	buona giornata	Definizione non disponibile per 'Buona giornata'	fallback	0.3	2025-12-02 13:10:16.221344
15	 mercoledì	Definizione non disponibile per ' Mercoledì'	fallback	0.3	2025-12-02 13:10:16.801606
16	alzarsi	Definizione non disponibile per 'Alzarsi'	fallback	0.3	2025-12-02 13:10:17.368859
17	buon pomeriggio	Definizione non disponibile per 'buon pomeriggio'	fallback	0.3	2025-12-02 13:10:17.948838
18	sempre	Definizione non disponibile per 'Sempre'	fallback	0.3	2025-12-02 13:10:18.51334
19	enne	Definizione non disponibile per 'enne'	fallback	0.3	2025-12-02 13:10:19.078892
20	ricordare	Definizione non disponibile per 'Ricordare'	fallback	0.3	2025-12-02 13:10:19.621436
21	basso	Definizione non disponibile per 'Basso'	fallback	0.3	2025-12-02 13:10:20.189545
22	lentamente	Definizione non disponibile per 'Lentamente'	fallback	0.3	2025-12-02 13:10:20.832925
23	updated back	Definizione non disponibile per 'Updated Back'	fallback	0.3	2025-12-02 13:10:21.398615
24	naturale	Definizione non disponibile per 'naturale'	fallback	0.3	2025-12-02 13:10:21.948543
25	campana	Definizione non disponibile per 'campana'	fallback	0.3	2025-12-02 13:10:22.516046
26	elle	Definizione non disponibile per 'elle'	fallback	0.3	2025-12-02 13:10:23.070378
27	ecco	Definizione non disponibile per 'ecco'	fallback	0.3	2025-12-02 13:10:23.64056
28	emme	Definizione non disponibile per 'emme'	fallback	0.3	2025-12-02 13:10:24.253147
29	mango	Definizione non disponibile per 'mango'	fallback	0.3	2025-12-02 13:10:26.00184
30	ananas	Definizione non disponibile per 'ananas'	fallback	0.3	2025-12-02 13:10:26.700015
31	parrucchiere	Definizione non disponibile per 'Parrucchiere'	fallback	0.3	2025-12-02 13:10:27.280621
32	poliziotto	Definizione non disponibile per 'Poliziotto'	fallback	0.3	2025-12-02 13:10:27.85867
33	meccanico	Definizione non disponibile per 'Meccanico'	fallback	0.3	2025-12-02 13:10:28.43016
34	tassista	Definizione non disponibile per 'Tassista'	fallback	0.3	2025-12-02 13:10:29.003066
35	a	Definizione non disponibile per 'a'	fallback	0.3	2025-12-02 13:10:29.570136
36	bi	Definizione non disponibile per 'bi'	fallback	0.3	2025-12-02 13:10:30.121952
37	tchi	Definizione non disponibile per 'tchi'	fallback	0.3	2025-12-02 13:10:30.679664
38	di	Definizione non disponibile per 'di'	fallback	0.3	2025-12-02 13:10:31.264328
39	e	Definizione non disponibile per 'e'	fallback	0.3	2025-12-02 13:10:31.832909
40	effe	Definizione non disponibile per 'effe'	fallback	0.3	2025-12-02 13:10:32.391563
41	dji	Definizione non disponibile per 'dji'	fallback	0.3	2025-12-02 13:10:32.966864
42	ô	Definizione non disponibile per 'ô'	fallback	0.3	2025-12-02 13:10:33.594525
43	pi	Definizione non disponibile per 'pi'	fallback	0.3	2025-12-02 13:10:34.147595
44	kou	Definizione non disponibile per 'kou'	fallback	0.3	2025-12-02 13:10:34.706663
45	erre	Definizione non disponibile per 'erre'	fallback	0.3	2025-12-02 13:10:35.262577
46	esse	Definizione non disponibile per 'esse'	fallback	0.3	2025-12-02 13:10:35.819077
47	ti	Definizione non disponibile per 'ti'	fallback	0.3	2025-12-02 13:10:36.382094
48	ou	Definizione non disponibile per 'ou'	fallback	0.3	2025-12-02 13:10:36.942053
49	vi/vou	Definizione non disponibile per 'vi/vou'	fallback	0.3	2025-12-02 13:10:37.489749
50	i lunga	Definizione non disponibile per 'i lunga'	fallback	0.3	2025-12-02 13:10:38.18246
51	kappa	Definizione non disponibile per 'kappa'	fallback	0.3	2025-12-02 13:10:38.752677
52	doppia vou	Definizione non disponibile per 'doppia vou'	fallback	0.3	2025-12-02 13:10:39.301048
53	iks	Definizione non disponibile per 'iks'	fallback	0.3	2025-12-02 13:10:39.858093
54	ipsilon	Definizione non disponibile per 'ipsilon'	fallback	0.3	2025-12-02 13:10:42.0571
55	acca	Definizione non disponibile per 'acca'	fallback	0.3	2025-12-02 13:10:42.610594
56	i	Definizione non disponibile per 'i'	fallback	0.3	2025-12-02 13:10:43.179793
57	buonasera	Definizione non disponibile per 'Buonasera'	fallback	0.3	2025-12-02 13:10:43.739873
58	come va?	Definizione non disponibile per 'Come va?'	fallback	0.3	2025-12-02 13:10:44.288872
59	come stai?	Definizione non disponibile per 'Come stai?'	fallback	0.3	2025-12-02 13:10:44.861946
60	comme state?	Definizione non disponibile per 'Comme state?'	fallback	0.3	2025-12-02 13:10:45.494439
61	come sta?	Definizione non disponibile per 'Come sta?'	fallback	0.3	2025-12-02 13:10:46.162683
62	sto bene	Definizione non disponibile per 'Sto bene'	fallback	0.3	2025-12-02 13:10:46.904694
63	molto bene	Definizione non disponibile per 'Molto bene'	fallback	0.3	2025-12-02 13:10:47.48871
64	benissimo	Definizione non disponibile per 'Benissimo'	fallback	0.3	2025-12-02 13:10:48.128082
65	alla grande	Definizione non disponibile per 'Alla grande'	fallback	0.3	2025-12-02 13:10:48.958244
66	non sto bene	Definizione non disponibile per 'Non sto bene'	fallback	0.3	2025-12-02 13:10:49.573994
67	non sto molto bene	Definizione non disponibile per 'Non sto molto bene'	fallback	0.3	2025-12-02 13:10:50.19592
68	sono malato(a)	Definizione non disponibile per 'Sono malato(a)'	fallback	0.3	2025-12-02 13:10:50.818191
69	non c'è male / così così	Definizione non disponibile per 'Non c'è male / Così così'	fallback	0.3	2025-12-02 13:10:51.393049
70	novità?	Definizione non disponibile per 'Novità?'	fallback	0.3	2025-12-02 13:10:51.960352
71	che c'è nuovo?	Definizione non disponibile per 'Che c'è nuovo?'	fallback	0.3	2025-12-02 13:10:52.53325
72	nulla di speciale	Definizione non disponibile per 'Nulla di speciale'	fallback	0.3	2025-12-02 13:10:53.125139
73	nulla di particolare	Definizione non disponibile per 'Nulla di particolare'	fallback	0.3	2025-12-02 13:10:53.861949
74	niente da dire	Definizione non disponibile per 'Niente da dire'	fallback	0.3	2025-12-02 13:10:54.459866
75	arrivederci	Definizione non disponibile per 'Arrivederci'	fallback	0.3	2025-12-02 13:10:55.068976
76	ci vediamo	Definizione non disponibile per 'Ci vediamo'	fallback	0.3	2025-12-02 13:10:55.667586
77	a presto	Definizione non disponibile per 'A presto'	fallback	0.3	2025-12-02 13:10:56.222876
78	a più tardi	Definizione non disponibile per 'A più tardi'	fallback	0.3	2025-12-02 13:10:56.794695
79	arrivederla 	Definizione non disponibile per 'ArrivederLa '	fallback	0.3	2025-12-02 13:10:57.348989
80	signora	Definizione non disponibile per 'Signora'	fallback	0.3	2025-12-02 13:10:57.906369
81	signorina	Definizione non disponibile per 'Signorina'	fallback	0.3	2025-12-02 13:10:58.468461
82	grazie	Definizione non disponibile per 'Grazie'	fallback	0.3	2025-12-02 13:10:59.05159
83	di niente	Definizione non disponibile per 'Di niente'	fallback	0.3	2025-12-02 13:10:59.608135
84	prego	Definizione non disponibile per 'Prego'	fallback	0.3	2025-12-02 13:11:00.157619
85	non preoccuparti	Definizione non disponibile per 'Non preoccuparti'	fallback	0.3	2025-12-02 13:11:00.734459
86	posso uscire?	Definizione non disponibile per 'Posso uscire?'	fallback	0.3	2025-12-02 13:11:01.303784
87	posso cancellare?	Definizione non disponibile per 'Posso cancellare?'	fallback	0.3	2025-12-02 13:11:01.858281
88	può repetere?	Definizione non disponibile per 'Può repetere?'	fallback	0.3	2025-12-02 13:11:02.418863
89	può parlare un po' più forte?	Definizione non disponibile per 'Può parlare un po' più forte?'	fallback	0.3	2025-12-02 13:11:02.998494
90	a d'alta voce	Definizione non disponibile per 'A d'alta voce'	fallback	0.3	2025-12-02 13:11:03.602864
91	può parlare lentamente?	Definizione non disponibile per 'Può parlare lentamente?'	fallback	0.3	2025-12-02 13:11:04.243358
92	può muovere?	Definizione non disponibile per 'Può muovere?'	fallback	0.3	2025-12-02 13:11:04.819047
93	tutto bene?	Definizione non disponibile per 'Tutto bene?'	fallback	0.3	2025-12-02 13:11:05.38737
94	signore	Definizione non disponibile per 'Signore'	fallback	0.3	2025-12-02 13:11:05.945631
95	zeta	Definizione non disponibile per 'zeta'	fallback	0.3	2025-12-02 13:11:06.520526
96	tutt'a posto?	Definizione non disponibile per 'Tutt'a posto?'	fallback	0.3	2025-12-02 13:11:07.085744
97	tutto chiaro?	Definizione non disponibile per 'Tutto chiaro?'	fallback	0.3	2025-12-02 13:11:07.675813
98	finito?	Definizione non disponibile per 'Finito?'	fallback	0.3	2025-12-02 13:11:08.24904
99	quasi finito	Definizione non disponibile per 'Quasi finito'	fallback	0.3	2025-12-02 13:11:08.88048
100	che cosa vuol dire?	Definizione non disponibile per 'Che cosa vuol dire?'	fallback	0.3	2025-12-02 13:11:09.568683
101	cosa significa	Definizione non disponibile per 'Cosa significa'	fallback	0.3	2025-12-02 13:11:10.168387
102	comme si dice ... in francese	Definizione non disponibile per 'Comme si dice ... in francese'	fallback	0.3	2025-12-02 13:11:10.726934
103	come si scrive il tuo nome?	Definizione non disponibile per 'Come si scrive il tuo nome?'	fallback	0.3	2025-12-02 13:11:11.301658
104	come si prononcia il tuo nome?	Definizione non disponibile per 'Come si prononcia il tuo nome?'	fallback	0.3	2025-12-02 13:11:11.866827
105	ho una domanda	Definizione non disponibile per 'Ho una domanda'	fallback	0.3	2025-12-02 13:11:12.534777
106	casa	Definizione non disponibile per 'Casa'	fallback	0.3	2025-12-02 13:11:13.110097
107	carta	Definizione non disponibile per 'Carta'	fallback	0.3	2025-12-02 13:11:13.680464
108	accanto	Definizione non disponibile per 'Accanto'	fallback	0.3	2025-12-02 13:11:14.272275
109	corpo	Definizione non disponibile per 'Corpo'	fallback	0.3	2025-12-02 13:11:14.864833
110	poco	Definizione non disponibile per 'Poco'	fallback	0.3	2025-12-02 13:11:15.48385
111	piccolo	Definizione non disponibile per 'Piccolo'	fallback	0.3	2025-12-02 13:11:16.146901
112	cura	Definizione non disponibile per 'Cura'	fallback	0.3	2025-12-02 13:11:16.73829
113	cui	Definizione non disponibile per 'cui'	fallback	0.3	2025-12-02 13:11:17.303594
114	che	Definizione non disponibile per 'Che'	fallback	0.3	2025-12-02 13:11:17.887423
115	chiamare	Definizione non disponibile per 'Chiamare'	fallback	0.3	2025-12-02 13:11:18.450875
116	parchi	Definizione non disponibile per 'parchi'	fallback	0.3	2025-12-02 13:11:19.043063
117	pochino	Definizione non disponibile per 'pochino'	fallback	0.3	2025-12-02 13:11:19.614322
118	cena	Definizione non disponibile per 'Cena'	fallback	0.3	2025-12-02 13:11:20.200648
119	accettare	Definizione non disponibile per 'Accettare'	fallback	0.3	2025-12-02 13:11:20.770767
120	cibo	Definizione non disponibile per 'Cibo'	fallback	0.3	2025-12-02 13:11:21.354259
121	scala	Definizione non disponibile per 'Scala'	fallback	0.3	2025-12-02 13:11:21.925129
122	pagare	Definizione non disponibile per 'Pagare'	fallback	0.3	2025-12-02 13:11:22.501493
123	gola	Definizione non disponibile per 'Gola'	fallback	0.3	2025-12-02 13:11:23.087852
124	gonna	Definizione non disponibile per 'Gonna'	fallback	0.3	2025-12-02 13:11:23.648922
125	lago	Definizione non disponibile per 'Lago'	fallback	0.3	2025-12-02 13:11:24.258832
126	febraio	Definizione non disponibile per 'Febraio'	fallback	0.3	2025-12-02 13:11:24.988046
127	marzo	Definizione non disponibile per 'Marzo'	fallback	0.3	2025-12-02 13:11:25.58102
128	aprile	Definizione non disponibile per 'Aprile'	fallback	0.3	2025-12-02 13:11:26.245425
129	giugno	Definizione non disponibile per 'Giugno'	fallback	0.3	2025-12-02 13:11:27.26813
130	maggio	Definizione non disponibile per 'Maggio'	fallback	0.3	2025-12-02 13:11:27.85629
131	cattivo	Definizione non disponibile per 'cattivo'	fallback	0.3	2025-12-02 13:11:28.430315
132	fretta	Definizione non disponibile per 'fretta'	fallback	0.3	2025-12-02 13:11:29.039223
133	paura	Definizione non disponibile per 'paura'	fallback	0.3	2025-12-02 13:11:29.671267
134	sete	Definizione non disponibile per 'sete'	fallback	0.3	2025-12-02 13:11:30.303862
135	timido	Definizione non disponibile per 'timido'	fallback	0.3	2025-12-02 13:11:30.888254
136	impazzire	Definizione non disponibile per 'impazzire'	fallback	0.3	2025-12-02 13:11:31.481459
137	arrabiatto	Definizione non disponibile per 'arrabiatto'	fallback	0.3	2025-12-02 13:11:32.119222
138	felice	Definizione non disponibile per 'felice'	fallback	0.3	2025-12-02 13:11:32.777582
139	socievole	Definizione non disponibile per 'socievole'	fallback	0.3	2025-12-02 13:11:33.376095
140	anniato	Definizione non disponibile per 'anniato'	fallback	0.3	2025-12-02 13:11:33.956326
141	fame	Definizione non disponibile per 'fame'	fallback	0.3	2025-12-02 13:11:34.559966
142	confuso	Definizione non disponibile per 'confuso'	fallback	0.3	2025-12-02 13:11:35.148064
143	aereo	Definizione non disponibile per 'aereo'	fallback	0.3	2025-12-02 13:11:35.769868
144	bicicletta	Definizione non disponibile per 'bicicletta'	fallback	0.3	2025-12-02 13:11:36.349335
145	treno	Definizione non disponibile per 'treno'	fallback	0.3	2025-12-02 13:11:36.949777
146	macchina	Definizione non disponibile per 'macchina'	fallback	0.3	2025-12-02 13:11:37.512152
147	pulmino	Definizione non disponibile per 'pulmino'	fallback	0.3	2025-12-02 13:11:38.094585
148	autobus	Definizione non disponibile per 'autobus'	fallback	0.3	2025-12-02 13:11:38.654568
149	barca	Definizione non disponibile per 'barca'	fallback	0.3	2025-12-02 13:11:39.227046
150	camio	Definizione non disponibile per 'camio'	fallback	0.3	2025-12-02 13:11:39.802211
151	elicottero	Definizione non disponibile per 'elicottero'	fallback	0.3	2025-12-02 13:11:40.375298
152	gondole	Definizione non disponibile per 'gondole'	fallback	0.3	2025-12-02 13:11:40.93241
153	sottomarino	Definizione non disponibile per 'sottomarino'	fallback	0.3	2025-12-02 13:11:41.525493
154	a piedi	Definizione non disponibile per 'a piedi'	fallback	0.3	2025-12-02 13:11:42.126084
155	a cavallo	Definizione non disponibile per 'a cavallo'	fallback	0.3	2025-12-02 13:11:42.716488
156	in	Definizione non disponibile per 'in'	fallback	0.3	2025-12-02 13:11:43.318488
157	riso	Definizione non disponibile per 'riso'	fallback	0.3	2025-12-02 13:11:43.904896
158	pane	Definizione non disponibile per 'pane'	fallback	0.3	2025-12-02 13:11:44.510129
159	farina	Definizione non disponibile per 'farina'	fallback	0.3	2025-12-02 13:11:45.089903
160	tè	Definizione non disponibile per 'tè'	fallback	0.3	2025-12-02 13:11:45.720134
161	caffè	Definizione non disponibile per 'caffè'	fallback	0.3	2025-12-02 13:11:46.307202
162	cioccolato	Definizione non disponibile per 'cioccolato'	fallback	0.3	2025-12-02 13:11:46.966265
163	caramello	Definizione non disponibile per 'caramello'	fallback	0.3	2025-12-02 13:11:47.561609
164	caramella	Definizione non disponibile per 'caramella'	fallback	0.3	2025-12-02 13:11:48.15517
165	burro	Definizione non disponibile per 'burro'	fallback	0.3	2025-12-02 13:11:48.717425
166	panino	Definizione non disponibile per 'panino'	fallback	0.3	2025-12-02 13:11:49.279105
167	sale	Definizione non disponibile per 'sale'	fallback	0.3	2025-12-02 13:11:49.939066
168	lievito	Definizione non disponibile per 'lievito'	fallback	0.3	2025-12-02 13:11:50.543118
169	carota	Definizione non disponibile per 'carota'	fallback	0.3	2025-12-02 13:11:51.177245
170	settembre	Definizione non disponibile per 'Settembre'	fallback	0.3	2025-12-02 13:11:51.746715
171	luglio	Definizione non disponibile per 'Luglio'	fallback	0.3	2025-12-02 13:11:52.312117
172	dicembre	Definizione non disponibile per 'Dicembre'	fallback	0.3	2025-12-02 13:11:52.891625
173	agosto	Definizione non disponibile per 'Agosto'	fallback	0.3	2025-12-02 13:11:53.524634
174	novembre	Definizione non disponibile per 'Novembre'	fallback	0.3	2025-12-02 13:11:54.130745
175	estate	Definizione non disponibile per 'estate'	fallback	0.3	2025-12-02 13:11:54.691522
176	inverno	Definizione non disponibile per 'inverno'	fallback	0.3	2025-12-02 13:11:55.260663
177	primavera	Definizione non disponibile per 'primavera'	fallback	0.3	2025-12-02 13:11:55.840552
178	autunmo	Definizione non disponibile per 'autunmo'	fallback	0.3	2025-12-02 13:11:56.415665
179	pesce	Definizione non disponibile per 'pesce'	fallback	0.3	2025-12-02 13:11:57.019346
180	gamberi	Definizione non disponibile per 'gamberi'	fallback	0.3	2025-12-02 13:11:57.604884
181	ganberetti	Definizione non disponibile per 'ganberetti'	fallback	0.3	2025-12-02 13:11:58.193233
182	tono	Definizione non disponibile per 'tono'	fallback	0.3	2025-12-02 13:11:58.775635
183	granchio	Definizione non disponibile per 'granchio'	fallback	0.3	2025-12-02 13:11:59.364809
184	polpo	Definizione non disponibile per 'polpo'	fallback	0.3	2025-12-02 13:11:59.952341
185	squalo	Definizione non disponibile per 'squalo'	fallback	0.3	2025-12-02 13:12:00.574983
186	ostrica	Definizione non disponibile per 'ostrica'	fallback	0.3	2025-12-02 13:12:01.195437
187	patata	Definizione non disponibile per 'patata'	fallback	0.3	2025-12-02 13:12:01.810651
188	patata americana	Definizione non disponibile per 'patata americana'	fallback	0.3	2025-12-02 13:12:02.403397
189	barbabietola	Definizione non disponibile per 'barbabietola'	fallback	0.3	2025-12-02 13:12:03.004751
190	pomodoro	Definizione non disponibile per 'pomodoro'	fallback	0.3	2025-12-02 13:12:03.563277
191	cipolla	Definizione non disponibile per 'cipolla'	fallback	0.3	2025-12-02 13:12:04.134754
192	erba cipollina	Definizione non disponibile per 'erba cipollina'	fallback	0.3	2025-12-02 13:12:04.705515
193	porro	Definizione non disponibile per 'porro'	fallback	0.3	2025-12-02 13:12:06.571485
194	coriandolo	Definizione non disponibile per 'coriandolo'	fallback	0.3	2025-12-02 13:12:07.177584
195	sedano	Definizione non disponibile per 'sedano'	fallback	0.3	2025-12-02 13:12:07.741881
196	cetriolo	Definizione non disponibile per 'cetriolo'	fallback	0.3	2025-12-02 13:12:08.321586
197	zucca	Definizione non disponibile per 'zucca'	fallback	0.3	2025-12-02 13:12:09.644126
198	zucchino	Definizione non disponibile per 'zucchino'	fallback	0.3	2025-12-02 13:12:10.741658
199	fagioli	Definizione non disponibile per 'fagioli'	fallback	0.3	2025-12-02 13:12:11.461593
200	ceci	Definizione non disponibile per 'ceci'	fallback	0.3	2025-12-02 13:12:12.6819
201	melanzana	Definizione non disponibile per 'melanzana'	fallback	0.3	2025-12-02 13:12:13.267066
202	prezzemolo	Definizione non disponibile per 'prezzemolo'	fallback	0.3	2025-12-02 13:12:13.838008
203	fungo	Definizione non disponibile per 'fungo'	fallback	0.3	2025-12-02 13:12:14.393417
204	finocchi	Definizione non disponibile per 'finocchi'	fallback	0.3	2025-12-02 13:12:14.975455
205	oliva	Definizione non disponibile per 'oliva'	fallback	0.3	2025-12-02 13:12:15.532352
206	aspargi	Definizione non disponibile per 'aspargi'	fallback	0.3	2025-12-02 13:12:16.104745
207	carcioli	Definizione non disponibile per 'carcioli'	fallback	0.3	2025-12-02 13:12:16.720154
208	tasca	Definizione non disponibile per 'tasca'	fallback	0.3	2025-12-02 13:12:17.301154
209	scivoloso	Definizione non disponibile per 'scivoloso'	fallback	0.3	2025-12-02 13:12:17.863354
210	scuola	Definizione non disponibile per 'scuola'	fallback	0.3	2025-12-02 13:12:18.436394
211	scuolo	Definizione non disponibile per 'scuolo'	fallback	0.3	2025-12-02 13:12:19.007733
212	scherzare	Definizione non disponibile per 'scherzare'	fallback	0.3	2025-12-02 13:12:19.578515
213	scena	Definizione non disponibile per 'scena'	fallback	0.3	2025-12-02 13:12:20.154993
214	gliaccio	Definizione non disponibile per 'gliaccio'	fallback	0.3	2025-12-02 13:12:20.740492
215	torta	Definizione non disponibile per 'torta'	fallback	0.3	2025-12-02 13:12:21.3153
216	gatte	Definizione non disponibile per 'gatte'	fallback	0.3	2025-12-02 13:12:21.882927
217	giro	Definizione non disponibile per 'giro'	fallback	0.3	2025-12-02 13:12:22.451429
218	montagna	Definizione non disponibile per 'montagna'	fallback	0.3	2025-12-02 13:12:23.532093
219	agire	Definizione non disponibile per 'agire'	fallback	0.3	2025-12-02 13:12:24.146582
220	gelato	Definizione non disponibile per 'gelato'	fallback	0.3	2025-12-02 13:12:24.713724
221	oggi	Definizione non disponibile per 'Oggi'	fallback	0.3	2025-12-02 13:12:25.413991
222	giovedì	Definizione non disponibile per 'Giovedì'	fallback	0.3	2025-12-02 13:12:26.107501
223	lunedi	Definizione non disponibile per 'Lunedi'	fallback	0.3	2025-12-02 13:12:26.667231
224	 ieri	Definizione non disponibile per ' Ieri'	fallback	0.3	2025-12-02 13:12:27.230409
225	domenica	Definizione non disponibile per 'Domenica'	fallback	0.3	2025-12-02 13:12:27.788411
226	venerdì	Definizione non disponibile per 'Venerdì'	fallback	0.3	2025-12-02 13:12:28.334257
227	sabato	Definizione non disponibile per 'Sabato'	fallback	0.3	2025-12-02 13:12:28.904329
228	 martedì	Definizione non disponibile per ' Martedì'	fallback	0.3	2025-12-02 13:12:29.498557
229	domani	Definizione non disponibile per 'Domani'	fallback	0.3	2025-12-02 13:12:30.075625
230	settimana	Definizione non disponibile per 'Settimana'	fallback	0.3	2025-12-02 13:12:30.656845
231	bisogno	Definizione non disponibile per 'bisogno'	fallback	0.3	2025-12-02 13:12:31.246039
232	leggere	Definizione non disponibile per 'leggere'	fallback	0.3	2025-12-02 13:12:31.807716
233	aglio	Definizione non disponibile per 'aglio'	fallback	0.3	2025-12-02 13:12:32.374183
234	ogni	Definizione non disponibile per 'ogni'	fallback	0.3	2025-12-02 13:12:32.936674
235	buon viaggio	Definizione non disponibile per 'buon viaggio'	fallback	0.3	2025-12-02 13:12:33.501292
236	buon reccupero	Definizione non disponibile per 'buon reccupero'	fallback	0.3	2025-12-02 13:12:34.06262
237	buona vacanza	Definizione non disponibile per 'buona vacanza'	fallback	0.3	2025-12-02 13:12:34.624454
238	buon compleano	Definizione non disponibile per 'buon compleano'	fallback	0.3	2025-12-02 13:12:35.207024
239	buon volo	Definizione non disponibile per 'buon volo'	fallback	0.3	2025-12-02 13:12:35.772249
240	il locca al lupo	Definizione non disponibile per 'il locca al lupo'	fallback	0.3	2025-12-02 13:12:36.375794
241	buon appetito	Definizione non disponibile per 'buon appetito'	fallback	0.3	2025-12-02 13:12:36.966862
242	ciao	Definizione non disponibile per 'Ciao'	fallback	0.3	2025-12-02 13:12:37.559907
243	mi scusi	Definizione non disponibile per 'Mi scusi'	fallback	0.3	2025-12-02 13:12:38.13581
244	sì	Definizione non disponibile per 'Sì'	fallback	0.3	2025-12-02 13:12:38.754589
245	no	Definizione non disponibile per 'No'	fallback	0.3	2025-12-02 13:12:39.311673
246	non capisco	Definizione non disponibile per 'Non capisco'	fallback	0.3	2025-12-02 13:12:39.904803
247	un caffè	Definizione non disponibile per 'Un caffè'	fallback	0.3	2025-12-02 13:12:40.482563
248	l'acqua	Definizione non disponibile per 'L'acqua'	fallback	0.3	2025-12-02 13:12:41.065602
249	il pane	Definizione non disponibile per 'Il pane'	fallback	0.3	2025-12-02 13:12:41.666285
250	quanto costa?	Definizione non disponibile per 'Quanto costa?'	fallback	0.3	2025-12-02 13:12:42.223584
251	la casa	Definizione non disponibile per 'La casa'	fallback	0.3	2025-12-02 13:12:42.828119
252	il gatto	Definizione non disponibile per 'Il gatto'	fallback	0.3	2025-12-02 13:12:43.376565
253	tagliare	Definizione non disponibile per 'Tagliare'	fallback	0.3	2025-12-02 13:12:43.952169
254	mettere	Definizione non disponibile per 'Mettere'	fallback	0.3	2025-12-02 13:12:44.5056
255	versare	Definizione non disponibile per 'Versare'	fallback	0.3	2025-12-02 13:12:45.074898
256	unire	Definizione non disponibile per 'Unire'	fallback	0.3	2025-12-02 13:12:45.791079
257	lasciare	Definizione non disponibile per 'Lasciare'	fallback	0.3	2025-12-02 13:12:46.408791
258	aggiungere	Definizione non disponibile per 'Aggiungere'	fallback	0.3	2025-12-02 13:12:47.052031
259	mescolare	Definizione non disponibile per 'Mescolare'	fallback	0.3	2025-12-02 13:12:47.609482
260	bagnare	Definizione non disponibile per 'Bagnare'	fallback	0.3	2025-12-02 13:12:48.215094
261	insaporire	Definizione non disponibile per 'Insaporire'	fallback	0.3	2025-12-02 13:12:48.76978
262	coprire	Definizione non disponibile per 'Coprire'	fallback	0.3	2025-12-02 13:12:49.361484
263	cuocere	Definizione non disponibile per 'Cuocere'	fallback	0.3	2025-12-02 13:12:49.9633
264	buon sevata	Definizione non disponibile per 'buon sevata'	fallback	0.3	2025-12-02 13:12:50.631631
265	buon lezione	Definizione non disponibile per 'buon lezione'	fallback	0.3	2025-12-02 13:12:51.6889
266	buon divertimento	Definizione non disponibile per 'buon divertimento'	fallback	0.3	2025-12-02 13:12:52.275412
267	smorzare	Definizione non disponibile per 'Smorzare'	fallback	0.3	2025-12-02 13:12:53.248609
268	aggiustare	Definizione non disponibile per 'Aggiustare'	fallback	0.3	2025-12-02 13:12:53.867421
269	spegnere	Definizione non disponibile per 'Spegnere'	fallback	0.3	2025-12-02 13:12:54.466567
270	essere	Definizione non disponibile per 'Essere'	fallback	0.3	2025-12-02 13:12:55.094618
271	avere	Definizione non disponibile per 'Avere'	fallback	0.3	2025-12-02 13:12:55.680441
272	fare	Definizione non disponibile per 'Fare'	fallback	0.3	2025-12-02 13:12:56.25419
273	dire	Definizione non disponibile per 'Dire'	fallback	0.3	2025-12-02 13:12:56.87999
274	potere	Definizione non disponibile per 'Potere'	fallback	0.3	2025-12-02 13:12:57.44899
275	andare	Definizione non disponibile per 'Andare'	fallback	0.3	2025-12-02 13:12:58.059269
276	vedere	Definizione non disponibile per 'Vedere'	fallback	0.3	2025-12-02 13:12:59.666991
277	dare	Definizione non disponibile per 'Dare'	fallback	0.3	2025-12-02 13:13:00.241614
278	sapere	Definizione non disponibile per 'Sapere'	fallback	0.3	2025-12-02 13:13:00.798915
279	stare	Definizione non disponibile per 'Stare'	fallback	0.3	2025-12-02 13:13:01.452044
280	volere	Definizione non disponibile per 'Volere'	fallback	0.3	2025-12-02 13:13:02.056896
281	venire	Definizione non disponibile per 'Venire'	fallback	0.3	2025-12-02 13:13:02.630016
282	dovere	Definizione non disponibile per 'Dovere'	fallback	0.3	2025-12-02 13:13:03.212614
283	parlare	Definizione non disponibile per 'Parlare'	fallback	0.3	2025-12-02 13:13:03.784791
284	trovare	Definizione non disponibile per 'Trovare'	fallback	0.3	2025-12-02 13:13:04.345449
285	pensare	Definizione non disponibile per 'Pensare'	fallback	0.3	2025-12-02 13:13:04.923664
286	prendere	Definizione non disponibile per 'Prendere'	fallback	0.3	2025-12-02 13:13:05.476162
287	uscire	Definizione non disponibile per 'Uscire'	fallback	0.3	2025-12-02 13:13:06.076272
288	capire	Definizione non disponibile per 'Capire'	fallback	0.3	2025-12-02 13:13:06.656265
289	sentire	Definizione non disponibile per 'Sentire'	fallback	0.3	2025-12-02 13:13:07.214664
290	guardare	Definizione non disponibile per 'Guardare'	fallback	0.3	2025-12-02 13:13:07.805339
291	arrivare	Definizione non disponibile per 'Arrivare'	fallback	0.3	2025-12-02 13:13:09.447508
292	chiedere	Definizione non disponibile per 'Chiedere'	fallback	0.3	2025-12-02 13:13:10.022973
293	credere	Definizione non disponibile per 'Credere'	fallback	0.3	2025-12-02 13:13:10.622795
294	lavorare	Definizione non disponibile per 'Lavorare'	fallback	0.3	2025-12-02 13:13:11.279002
295	vivere	Definizione non disponibile per 'Vivere'	fallback	0.3	2025-12-02 13:13:11.841526
296	portare	Definizione non disponibile per 'Portare'	fallback	0.3	2025-12-02 13:13:12.427177
297	usare	Definizione non disponibile per 'Usare'	fallback	0.3	2025-12-02 13:13:12.992517
298	entrare	Definizione non disponibile per 'Entrare'	fallback	0.3	2025-12-02 13:13:13.5784
299	scrivere	Definizione non disponibile per 'Scrivere'	fallback	0.3	2025-12-02 13:13:14.600304
300	mangiare	Definizione non disponibile per 'Mangiare'	fallback	0.3	2025-12-02 13:13:15.82303
301	dormire	Definizione non disponibile per 'Dormire'	fallback	0.3	2025-12-02 13:13:16.649134
302	comprare	Definizione non disponibile per 'Comprare'	fallback	0.3	2025-12-02 13:13:17.23835
303	aspettare	Definizione non disponibile per 'Aspettare'	fallback	0.3	2025-12-02 13:13:17.836603
304	conoscere	Definizione non disponibile per 'Conoscere'	fallback	0.3	2025-12-02 13:13:18.417096
305	tornare	Definizione non disponibile per 'Tornare'	fallback	0.3	2025-12-02 13:13:18.966463
306	tenere	Definizione non disponibile per 'Tenere'	fallback	0.3	2025-12-02 13:13:19.60533
307	ridere	Definizione non disponibile per 'Ridere'	fallback	0.3	2025-12-02 13:13:20.206558
308	piangere	Definizione non disponibile per 'Piangere'	fallback	0.3	2025-12-02 13:13:20.801331
309	cucinare	Definizione non disponibile per 'Cucinare'	fallback	0.3	2025-12-02 13:13:21.402082
310	bere	Definizione non disponibile per 'Bere'	fallback	0.3	2025-12-02 13:13:22.014412
311	cominciare	Definizione non disponibile per 'Cominciare'	fallback	0.3	2025-12-02 13:13:22.696218
312	finire	Definizione non disponibile per 'Finire'	fallback	0.3	2025-12-02 13:13:24.019918
313	camminare	Definizione non disponibile per 'Camminare'	fallback	0.3	2025-12-02 13:13:24.586834
314	correre	Definizione non disponibile per 'Correre'	fallback	0.3	2025-12-02 13:13:25.152219
315	aprire	Definizione non disponibile per 'Aprire'	fallback	0.3	2025-12-02 13:13:25.724094
316	chiudere	Definizione non disponibile per 'Chiudere'	fallback	0.3	2025-12-02 13:13:26.302852
317	giocare	Definizione non disponibile per 'Giocare'	fallback	0.3	2025-12-02 13:13:26.914279
318	studiare	Definizione non disponibile per 'Studiare'	fallback	0.3	2025-12-02 13:13:27.487422
319	seguire	Definizione non disponibile per 'Seguire'	fallback	0.3	2025-12-02 13:13:28.128344
320	cercare	Definizione non disponibile per 'Cercare'	fallback	0.3	2025-12-02 13:13:28.940275
321	osservare	Definizione non disponibile per 'Osservare'	fallback	0.3	2025-12-02 13:13:29.502751
322	mostrare	Definizione non disponibile per 'Mostrare'	fallback	0.3	2025-12-02 13:13:30.055689
323	lavarsi	Definizione non disponibile per 'Lavarsi'	fallback	0.3	2025-12-02 13:13:30.615055
324	vestirsi	Definizione non disponibile per 'Vestirsi'	fallback	0.3	2025-12-02 13:13:31.166628
325	divertirsi	Definizione non disponibile per 'Divertirsi'	fallback	0.3	2025-12-02 13:13:31.741795
326	sposarsi	Definizione non disponibile per 'Sposarsi'	fallback	0.3	2025-12-02 13:13:32.309329
327	incontrare	Definizione non disponibile per 'Incontrare'	fallback	0.3	2025-12-02 13:13:32.867868
328	mandare	Definizione non disponibile per 'Mandare'	fallback	0.3	2025-12-02 13:13:33.438075
329	rispondere	Definizione non disponibile per 'Rispondere'	fallback	0.3	2025-12-02 13:13:35.049492
330	scegliere	Definizione non disponibile per 'Scegliere'	fallback	0.3	2025-12-02 13:13:35.611051
331	spiegare	Definizione non disponibile per 'Spiegare'	fallback	0.3	2025-12-02 13:13:36.147734
332	decidere	Definizione non disponibile per 'Decidere'	fallback	0.3	2025-12-02 13:13:36.722046
333	cambiare	Definizione non disponibile per 'Cambiare'	fallback	0.3	2025-12-02 13:13:37.271568
334	restare	Definizione non disponibile per 'Restare'	fallback	0.3	2025-12-02 13:13:37.81629
335	servire	Definizione non disponibile per 'Servire'	fallback	0.3	2025-12-02 13:13:38.369964
336	bastare	Definizione non disponibile per 'Bastare'	fallback	0.3	2025-12-02 13:13:38.924076
337	piacere	Definizione non disponibile per 'Piacere'	fallback	0.3	2025-12-02 13:13:39.52262
338	togliere	Definizione non disponibile per 'Togliere'	fallback	0.3	2025-12-02 13:13:40.068282
339	succedere	Definizione non disponibile per 'Succedere'	fallback	0.3	2025-12-02 13:13:40.640662
340	accadere	Definizione non disponibile per 'Accadere'	fallback	0.3	2025-12-02 13:13:41.569791
341	aiutare	Definizione non disponibile per 'Aiutare'	fallback	0.3	2025-12-02 13:13:43.176062
342	costruire	Definizione non disponibile per 'Costruire'	fallback	0.3	2025-12-02 13:13:43.751588
343	distruggere	Definizione non disponibile per 'Distruggere'	fallback	0.3	2025-12-02 13:13:44.316967
344	dimenticare	Definizione non disponibile per 'Dimenticare'	fallback	0.3	2025-12-02 13:13:44.901972
345	chiamarsi	Definizione non disponibile per 'Chiamarsi'	fallback	0.3	2025-12-02 13:13:45.465847
346	sedere	Definizione non disponibile per 'Sedere'	fallback	0.3	2025-12-02 13:13:46.07596
347	imparare	Definizione non disponibile per 'Imparare'	fallback	0.3	2025-12-02 13:13:46.62901
348	insegnare	Definizione non disponibile per 'Insegnare'	fallback	0.3	2025-12-02 13:13:47.211773
349	viaggiare	Definizione non disponibile per 'Viaggiare'	fallback	0.3	2025-12-02 13:13:48.211602
350	ottenere	Definizione non disponibile per 'Ottenere'	fallback	0.3	2025-12-02 13:13:50.03984
351	sperare	Definizione non disponibile per 'Sperare'	fallback	0.3	2025-12-02 13:13:50.632469
352	temere	Definizione non disponibile per 'Temere'	fallback	0.3	2025-12-02 13:13:51.228454
353	migliorare	Definizione non disponibile per 'Migliorare'	fallback	0.3	2025-12-02 13:13:51.791218
354	vincere	Definizione non disponibile per 'Vincere'	fallback	0.3	2025-12-02 13:13:52.356206
355	condividere	Definizione non disponibile per 'Condividere'	fallback	0.3	2025-12-02 13:13:52.917238
356	buono	Definizione non disponibile per 'Buono'	fallback	0.3	2025-12-02 13:13:53.508367
357	bello	Definizione non disponibile per 'Bello'	fallback	0.3	2025-12-02 13:13:54.065151
358	giovane	Definizione non disponibile per 'Giovane'	fallback	0.3	2025-12-02 13:13:54.621713
359	vecchio	Definizione non disponibile per 'Vecchio'	fallback	0.3	2025-12-02 13:13:55.222463
360	triste	Definizione non disponibile per 'Triste'	fallback	0.3	2025-12-02 13:13:55.795107
361	forte	Definizione non disponibile per 'Forte'	fallback	0.3	2025-12-02 13:13:56.4028
362	debole	Definizione non disponibile per 'Debole'	fallback	0.3	2025-12-02 13:13:57.869488
363	lungo	Definizione non disponibile per 'Lungo'	fallback	0.3	2025-12-02 13:13:58.872731
364	corto	Definizione non disponibile per 'Corto'	fallback	0.3	2025-12-02 13:13:59.479694
365	veloce	Definizione non disponibile per 'Veloce'	fallback	0.3	2025-12-02 13:14:00.109724
366	lento	Definizione non disponibile per 'Lento'	fallback	0.3	2025-12-02 13:14:00.667703
367	calmo	Definizione non disponibile per 'Calmo'	fallback	0.3	2025-12-02 13:14:01.259888
368	stanco	Definizione non disponibile per 'Stanco'	fallback	0.3	2025-12-02 13:14:01.865727
369	eccitato	Definizione non disponibile per 'Eccitato'	fallback	0.3	2025-12-02 13:14:02.44522
370	contento	Definizione non disponibile per 'Contento'	fallback	0.3	2025-12-02 13:14:03.272507
371	simpatico	Definizione non disponibile per 'Simpatico'	fallback	0.3	2025-12-02 13:14:04.249506
372	intelligente	Definizione non disponibile per 'Intelligente'	fallback	0.3	2025-12-02 13:14:04.83217
373	stupido	Definizione non disponibile per 'Stupido'	fallback	0.3	2025-12-02 13:14:05.429703
374	pulito	Definizione non disponibile per 'Pulito'	fallback	0.3	2025-12-02 13:14:06.04754
375	sporco	Definizione non disponibile per 'Sporco'	fallback	0.3	2025-12-02 13:14:07.631737
376	facile	Definizione non disponibile per 'Facile'	fallback	0.3	2025-12-02 13:14:08.210729
377	difficile	Definizione non disponibile per 'Difficile'	fallback	0.3	2025-12-02 13:14:08.788514
378	caro	Definizione non disponibile per 'Caro'	fallback	0.3	2025-12-02 13:14:09.353811
379	economico	Definizione non disponibile per 'Economico'	fallback	0.3	2025-12-02 13:14:09.966521
380	importante	Definizione non disponibile per 'Importante'	fallback	0.3	2025-12-02 13:14:10.577419
381	inutile	Definizione non disponibile per 'Inutile'	fallback	0.3	2025-12-02 13:14:11.141328
382	interessante	Definizione non disponibile per 'Interessante'	fallback	0.3	2025-12-02 13:14:11.708341
383	noioso	Definizione non disponibile per 'Noioso'	fallback	0.3	2025-12-02 13:14:12.281773
384	ricco	Definizione non disponibile per 'Ricco'	fallback	0.3	2025-12-02 13:14:12.879768
385	povero	Definizione non disponibile per 'Povero'	fallback	0.3	2025-12-02 13:14:14.621749
386	serio	Definizione non disponibile per 'Serio'	fallback	0.3	2025-12-02 13:14:15.224725
387	gentile	Definizione non disponibile per 'Gentile'	fallback	0.3	2025-12-02 13:14:15.772913
388	divertente	Definizione non disponibile per 'Divertente'	fallback	0.3	2025-12-02 13:14:16.330978
389	freddo	Definizione non disponibile per 'Freddo'	fallback	0.3	2025-12-02 13:14:17.528083
390	caldo	Definizione non disponibile per 'Caldo'	fallback	0.3	2025-12-02 13:14:18.836731
391	umido	Definizione non disponibile per 'Umido'	fallback	0.3	2025-12-02 13:14:19.780141
392	secco	Definizione non disponibile per 'Secco'	fallback	0.3	2025-12-02 13:14:20.355609
393	luminoso	Definizione non disponibile per 'Luminoso'	fallback	0.3	2025-12-02 13:14:20.918994
394	scuro	Definizione non disponibile per 'Scuro'	fallback	0.3	2025-12-02 13:14:21.483345
395	vicino	Definizione non disponibile per 'Vicino'	fallback	0.3	2025-12-02 13:14:22.040231
396	lontano	Definizione non disponibile per 'Lontano'	fallback	0.3	2025-12-02 13:14:22.684477
397	libero	Definizione non disponibile per 'Libero'	fallback	0.3	2025-12-02 13:14:23.254705
398	occupato	Definizione non disponibile per 'Occupato'	fallback	0.3	2025-12-02 13:14:23.80522
399	sano	Definizione non disponibile per 'Sano'	fallback	0.3	2025-12-02 13:14:24.392828
400	malato	Definizione non disponibile per 'Malato'	fallback	0.3	2025-12-02 13:14:24.956029
401	vero	Definizione non disponibile per 'Vero'	fallback	0.3	2025-12-02 13:14:25.53342
402	falso	Definizione non disponibile per 'Falso'	fallback	0.3	2025-12-02 13:14:26.399021
403	largo	Definizione non disponibile per 'Largo'	fallback	0.3	2025-12-02 13:14:26.964727
404	stretto	Definizione non disponibile per 'Stretto'	fallback	0.3	2025-12-02 13:14:27.521902
405	pesante	Definizione non disponibile per 'Pesante'	fallback	0.3	2025-12-02 13:14:28.097437
406	leggero	Definizione non disponibile per 'Leggero'	fallback	0.3	2025-12-02 13:14:28.667873
407	rotondo	Definizione non disponibile per 'Rotondo'	fallback	0.3	2025-12-02 13:14:29.213034
408	quadrato	Definizione non disponibile per 'Quadrato'	fallback	0.3	2025-12-02 13:14:29.78043
409	flessibile	Definizione non disponibile per 'Flessibile'	fallback	0.3	2025-12-02 13:14:30.349642
410	rigido	Definizione non disponibile per 'Rigido'	fallback	0.3	2025-12-02 13:14:30.964202
411	vivo	Definizione non disponibile per 'Vivo'	fallback	0.3	2025-12-02 13:14:31.563587
412	morto	Definizione non disponibile per 'Morto'	fallback	0.3	2025-12-02 13:14:32.11101
413	alto	Definizione non disponibile per 'Alto'	fallback	0.3	2025-12-02 13:14:34.167098
414	saggio	Definizione non disponibile per 'Saggio'	fallback	0.3	2025-12-02 13:14:34.756338
415	pazzo	Definizione non disponibile per 'Pazzo'	fallback	0.3	2025-12-02 13:14:35.30495
416	male	Definizione non disponibile per 'Male'	fallback	0.3	2025-12-02 13:14:35.908037
417	sotto	Definizione non disponibile per 'Sotto'	fallback	0.3	2025-12-02 13:14:36.457233
418	sopra	Definizione non disponibile per 'Sopra'	fallback	0.3	2025-12-02 13:14:37.014026
419	a sinistra	Definizione non disponibile per 'A sinistra'	fallback	0.3	2025-12-02 13:14:37.585389
420	presto	Definizione non disponibile per 'Presto'	fallback	0.3	2025-12-02 13:14:38.135607
421	ovunque	Definizione non disponibile per 'Ovunque'	fallback	0.3	2025-12-02 13:14:38.749114
422	da nessuna parte	Definizione non disponibile per 'Da nessuna parte'	fallback	0.3	2025-12-02 13:14:39.347926
423	velocemente	Definizione non disponibile per 'Velocemente'	fallback	0.3	2025-12-02 13:14:40.021966
424	mai	Definizione non disponibile per 'Mai'	fallback	0.3	2025-12-02 13:14:40.59066
425	spesso	Definizione non disponibile per 'Spesso'	fallback	0.3	2025-12-02 13:14:41.191108
426	bene	Definizione non disponibile per 'Bene'	fallback	0.3	2025-12-02 13:14:41.762304
427	già	Definizione non disponibile per 'Già'	fallback	0.3	2025-12-02 13:14:42.370596
428	qualche volta	Definizione non disponibile per 'Qualche volta'	fallback	0.3	2025-12-02 13:14:42.924775
429	ancora	Definizione non disponibile per 'Ancora'	fallback	0.3	2025-12-02 13:14:43.488743
430	qui	Definizione non disponibile per 'Qui'	fallback	0.3	2025-12-02 13:14:44.053961
431	tardi	Definizione non disponibile per 'Tardi'	fallback	0.3	2025-12-02 13:14:44.718876
432	lì	Definizione non disponibile per 'Lì'	fallback	0.3	2025-12-02 13:14:45.303652
433	a destra	Definizione non disponibile per 'A destra'	fallback	0.3	2025-12-02 13:14:45.848836
434	rapidamente	Definizione non disponibile per 'Rapidamente'	fallback	0.3	2025-12-02 13:14:46.395398
435	dolcemente	Definizione non disponibile per 'Dolcemente'	fallback	0.3	2025-12-02 13:14:46.943359
436	fortemente	Definizione non disponibile per 'Fortemente'	fallback	0.3	2025-12-02 13:14:47.512556
437	facilmente	Definizione non disponibile per 'Facilmente'	fallback	0.3	2025-12-02 13:14:48.066733
438	davvero	Definizione non disponibile per 'Davvero'	fallback	0.3	2025-12-02 13:14:48.646319
439	solo	Definizione non disponibile per 'Solo'	fallback	0.3	2025-12-02 13:14:49.23608
440	anche	Definizione non disponibile per 'Anche'	fallback	0.3	2025-12-02 13:14:49.809035
441	certo	Definizione non disponibile per 'Certo'	fallback	0.3	2025-12-02 13:14:50.362808
442	forse	Definizione non disponibile per 'Forse'	fallback	0.3	2025-12-02 13:14:50.927757
443	finalmente	Definizione non disponibile per 'Finalmente'	fallback	0.3	2025-12-02 13:14:51.523825
444	subito	Definizione non disponibile per 'Subito'	fallback	0.3	2025-12-02 13:14:52.07761
445	calmamente	Definizione non disponibile per 'Calmamente'	fallback	0.3	2025-12-02 13:14:52.670707
446	gentilmente	Definizione non disponibile per 'Gentilmente'	fallback	0.3	2025-12-02 13:14:53.245579
447	fortunatamente	Definizione non disponibile per 'Fortunatamente'	fallback	0.3	2025-12-02 13:14:53.80386
448	sfortunatamente	Definizione non disponibile per 'Sfortunatamente'	fallback	0.3	2025-12-02 13:14:54.40782
449	precisamente	Definizione non disponibile per 'Precisamente'	fallback	0.3	2025-12-02 13:14:54.966891
450	improvvisamente	Definizione non disponibile per 'Improvvisamente'	fallback	0.3	2025-12-02 13:14:55.54702
451	deliziosamente	Definizione non disponibile per 'Deliziosamente'	fallback	0.3	2025-12-02 13:14:56.099694
452	ovviamente	Definizione non disponibile per 'Ovviamente'	fallback	0.3	2025-12-02 13:14:56.718898
453	immediatamente	Definizione non disponibile per 'Immediatamente'	fallback	0.3	2025-12-02 13:14:57.295257
454	esattamente	Definizione non disponibile per 'Esattamente'	fallback	0.3	2025-12-02 13:14:57.849949
455	seriamente	Definizione non disponibile per 'Seriamente'	fallback	0.3	2025-12-02 13:14:58.43499
456	vivamente	Definizione non disponibile per 'Vivamente'	fallback	0.3	2025-12-02 13:14:59.171707
457	precipitamment	Definizione non disponibile per 'Precipitamment'	fallback	0.3	2025-12-02 13:14:59.745731
458	frequentemente	Definizione non disponibile per 'Frequentemente'	fallback	0.3	2025-12-02 13:15:00.336101
459	raramente	Definizione non disponibile per 'Raramente'	fallback	0.3	2025-12-02 13:15:00.913082
460	alla fine	Definizione non disponibile per 'Alla fine'	fallback	0.3	2025-12-02 13:15:01.477169
461	dappertutto	Definizione non disponibile per 'Dappertutto'	fallback	0.3	2025-12-02 13:15:02.050325
462	magari	Definizione non disponibile per 'Magari'	fallback	0.3	2025-12-02 13:15:02.65771
463	veramente	Definizione non disponibile per 'Veramente'	fallback	0.3	2025-12-02 13:15:03.227349
464	inoltre	Definizione non disponibile per 'Inoltre'	fallback	0.3	2025-12-02 13:15:04.545465
465	ma	Definizione non disponibile per 'Ma'	fallback	0.3	2025-12-02 13:15:05.125235
466	quindi	Definizione non disponibile per 'Quindi'	fallback	0.3	2025-12-02 13:15:05.680915
467	perché	Definizione non disponibile per 'Perché'	fallback	0.3	2025-12-02 13:15:06.238323
468	tuttavia	Definizione non disponibile per 'Tuttavia'	fallback	0.3	2025-12-02 13:15:06.798923
469	poi	Definizione non disponibile per 'Poi'	fallback	0.3	2025-12-02 13:15:07.370585
470	prima di tutto	Definizione non disponibile per 'Prima di tutto'	fallback	0.3	2025-12-02 13:15:07.929006
471	infine	Definizione non disponibile per 'Infine'	fallback	0.3	2025-12-02 13:15:08.542826
472	per esempio	Definizione non disponibile per 'Per esempio'	fallback	0.3	2025-12-02 13:15:09.099167
473	così	Definizione non disponibile per 'Così'	fallback	0.3	2025-12-02 13:15:09.644103
474	infatti	Definizione non disponibile per 'Infatti'	fallback	0.3	2025-12-02 13:15:10.18512
475	altrimenti	Definizione non disponibile per 'Altrimenti'	fallback	0.3	2025-12-02 13:15:10.775343
476	nonostante	Definizione non disponibile per 'Nonostante'	fallback	0.3	2025-12-02 13:15:11.356625
477	mentre	Definizione non disponibile per 'Mentre'	fallback	0.3	2025-12-02 13:15:11.896692
478	come	Definizione non disponibile per 'Come'	fallback	0.3	2025-12-02 13:15:12.468862
479	finché	Definizione non disponibile per 'Finché'	fallback	0.3	2025-12-02 13:15:13.044866
480	quando	Definizione non disponibile per 'Quando'	fallback	0.3	2025-12-02 13:15:13.595506
481	in aggiunta	Definizione non disponibile per 'In aggiunta'	fallback	0.3	2025-12-02 13:15:14.158023
482	insomma	Definizione non disponibile per 'Insomma'	fallback	0.3	2025-12-02 13:15:14.745966
483	testa	Definizione non disponibile per 'Testa'	fallback	0.3	2025-12-02 13:15:15.327697
484	capelli	Definizione non disponibile per 'Capelli'	fallback	0.3	2025-12-02 13:15:15.886389
485	faccia	Definizione non disponibile per 'Faccia'	fallback	0.3	2025-12-02 13:15:16.492993
486	occhio	Definizione non disponibile per 'Occhio'	fallback	0.3	2025-12-02 13:15:17.06015
487	orecchio	Definizione non disponibile per 'Orecchio'	fallback	0.3	2025-12-02 13:15:17.61382
488	naso	Definizione non disponibile per 'Naso'	fallback	0.3	2025-12-02 13:15:18.166526
489	bocca	Definizione non disponibile per 'Bocca'	fallback	0.3	2025-12-02 13:15:18.730426
490	dente	Definizione non disponibile per 'Dente'	fallback	0.3	2025-12-02 13:15:19.299521
491	collo	Definizione non disponibile per 'Collo'	fallback	0.3	2025-12-02 13:15:19.894147
492	spalla	Definizione non disponibile per 'Spalla'	fallback	0.3	2025-12-02 13:15:20.467011
493	braccio	Definizione non disponibile per 'Braccio'	fallback	0.3	2025-12-02 13:15:21.037162
494	mano	Definizione non disponibile per 'Mano'	fallback	0.3	2025-12-02 13:15:21.631221
495	dito	Definizione non disponibile per 'Dito'	fallback	0.3	2025-12-02 13:15:22.192058
496	petto	Definizione non disponibile per 'Petto'	fallback	0.3	2025-12-02 13:15:22.816531
497	pancia	Definizione non disponibile per 'Pancia'	fallback	0.3	2025-12-02 13:15:23.375579
498	schiena	Definizione non disponibile per 'Schiena'	fallback	0.3	2025-12-02 13:15:23.942119
499	gamba	Definizione non disponibile per 'Gamba'	fallback	0.3	2025-12-02 13:15:24.497381
500	ginocchio	Definizione non disponibile per 'Ginocchio'	fallback	0.3	2025-12-02 13:15:26.053009
501	piede	Definizione non disponibile per 'Piede'	fallback	0.3	2025-12-02 13:15:26.606037
502	caviglia	Definizione non disponibile per 'Caviglia'	fallback	0.3	2025-12-02 13:15:27.165094
503	poule	Definizione non disponibile per 'poule'	fallback	0.3	2025-12-02 13:15:27.718831
504	poisson	Definizione non disponibile per 'poisson'	fallback	0.3	2025-12-02 13:15:28.278368
505	hamster	Definizione non disponibile per 'hamster'	fallback	0.3	2025-12-02 13:15:28.827274
506	tortue	Definizione non disponibile per 'tortue'	fallback	0.3	2025-12-02 13:15:29.393575
507	chien	Definizione non disponibile per 'chien'	fallback	0.3	2025-12-02 13:15:29.948238
508	chat	Definizione non disponibile per 'chat'	fallback	0.3	2025-12-02 13:15:30.544091
509	mouton	Definizione non disponibile per 'mouton'	fallback	0.3	2025-12-02 13:15:31.127264
510	cochon	Definizione non disponibile per 'cochon'	fallback	0.3	2025-12-02 13:15:31.684185
511	cheval	Definizione non disponibile per 'cheval'	fallback	0.3	2025-12-02 13:15:32.24569
512	serpent	Definizione non disponibile per 'serpent'	fallback	0.3	2025-12-02 13:15:32.824706
513	âne	Definizione non disponibile per 'âne'	fallback	0.3	2025-12-02 13:15:33.387985
514	oiseau	Definizione non disponibile per 'oiseau'	fallback	0.3	2025-12-02 13:15:33.965372
515	lapin	Definizione non disponibile per 'lapin'	fallback	0.3	2025-12-02 13:15:34.554057
516	vache	Definizione non disponibile per 'vache'	fallback	0.3	2025-12-02 13:15:35.136084
517	tigre	Definizione non disponibile per 'tigre'	fallback	0.3	2025-12-02 13:15:35.711211
518	canard	Definizione non disponibile per 'canard'	fallback	0.3	2025-12-02 13:15:36.311501
519	inspido	Definizione non disponibile per 'inspido'	fallback	0.3	2025-12-02 13:15:36.882176
520	zuccherato	Definizione non disponibile per 'zuccherato'	fallback	0.3	2025-12-02 13:15:37.477693
521	piccante	Definizione non disponibile per 'piccante'	fallback	0.3	2025-12-02 13:15:38.032699
522	affumicato	Definizione non disponibile per 'affumicato'	fallback	0.3	2025-12-02 13:15:38.628655
523	cremoso	Definizione non disponibile per 'cremoso'	fallback	0.3	2025-12-02 13:15:39.230665
524	gusto	Definizione non disponibile per 'gusto'	fallback	0.3	2025-12-02 13:15:39.7933
525	lion	Definizione non disponibile per 'lion'	fallback	0.3	2025-12-02 13:15:40.360346
526	éléphant	Definizione non disponibile per 'éléphant'	fallback	0.3	2025-12-02 13:15:40.915815
527	pistacchio	Definizione non disponibile per 'pistacchio'	fallback	0.3	2025-12-02 13:15:41.483688
528	mora	Definizione non disponibile per 'mora'	fallback	0.3	2025-12-02 13:15:42.053478
529	pesca	Definizione non disponibile per 'pesca'	fallback	0.3	2025-12-02 13:15:42.605115
530	frutta della passione	Definizione non disponibile per 'frutta della passione'	fallback	0.3	2025-12-02 13:15:43.166727
531	singe	Definizione non disponibile per 'singe'	fallback	0.3	2025-12-02 13:15:43.749353
532	amaro	Definizione non disponibile per 'amaro'	fallback	0.3	2025-12-02 13:15:44.328155
533	dolce	Definizione non disponibile per 'dolce'	fallback	0.3	2025-12-02 13:15:44.883499
534	salato	Definizione non disponibile per 'salato'	fallback	0.3	2025-12-02 13:15:45.447769
535	aceto	Definizione non disponibile per 'aceto'	fallback	0.3	2025-12-02 13:15:46.013937
536	kiwi	Definizione non disponibile per 'kiwi'	fallback	0.3	2025-12-02 13:15:46.584946
537	noce di coco	Definizione non disponibile per 'noce di coco'	fallback	0.3	2025-12-02 13:15:47.146089
538	mandarino	Definizione non disponibile per 'mandarino'	fallback	0.3	2025-12-02 13:15:47.70508
539	limone	Definizione non disponibile per 'limone'	fallback	0.3	2025-12-02 13:15:48.304766
540	ciliegia	Definizione non disponibile per 'ciliegia'	fallback	0.3	2025-12-02 13:15:48.861386
541	lampone	Definizione non disponibile per 'lampone'	fallback	0.3	2025-12-02 13:15:49.420229
542	albicocca	Definizione non disponibile per 'albicocca'	fallback	0.3	2025-12-02 13:15:49.984671
543	fragola	Definizione non disponibile per 'fragola'	fallback	0.3	2025-12-02 13:15:50.583672
544	arancia	Definizione non disponibile per 'arancia'	fallback	0.3	2025-12-02 13:15:51.140976
545	anguria	Definizione non disponibile per 'anguria'	fallback	0.3	2025-12-02 13:15:51.713006
546	uva	Definizione non disponibile per 'uva'	fallback	0.3	2025-12-02 13:15:52.274648
547	pera	Definizione non disponibile per 'pera'	fallback	0.3	2025-12-02 13:15:52.831001
548	mela	Definizione non disponibile per 'mela'	fallback	0.3	2025-12-02 13:15:53.396693
549	acidulo	Definizione non disponibile per 'acidulo'	fallback	0.3	2025-12-02 13:15:53.991067
550	arrostito	Definizione non disponibile per 'arrostito'	fallback	0.3	2025-12-02 13:15:54.558202
551	grigliato	Definizione non disponibile per 'grigliato'	fallback	0.3	2025-12-02 13:15:55.148816
552	erbaceo	Definizione non disponibile per 'erbaceo'	fallback	0.3	2025-12-02 13:15:55.725303
553	fruttato	Definizione non disponibile per 'fruttato'	fallback	0.3	2025-12-02 13:15:56.321354
554	nocciolato	Definizione non disponibile per 'nocciolato'	fallback	0.3	2025-12-02 13:15:56.878713
555	lattiginoso	Definizione non disponibile per 'lattiginoso'	fallback	0.3	2025-12-02 13:15:57.445888
556	cioccolatoso	Definizione non disponibile per 'cioccolatoso'	fallback	0.3	2025-12-02 13:15:58.035675
557	nociato	Definizione non disponibile per 'nociato'	fallback	0.3	2025-12-02 13:15:58.605701
558	caramellato	Definizione non disponibile per 'caramellato'	fallback	0.3	2025-12-02 13:15:59.204477
559	padre	Definizione non disponibile per 'Padre'	fallback	0.3	2025-12-02 13:15:59.801789
560	madre	Definizione non disponibile per 'Madre'	fallback	0.3	2025-12-02 13:16:00.391715
561	figlio	Definizione non disponibile per 'Figlio'	fallback	0.3	2025-12-02 13:16:01.009236
562	figlia	Definizione non disponibile per 'Figlia'	fallback	0.3	2025-12-02 13:16:01.606159
563	ingegnere	Definizione non disponibile per 'Ingegnere'	fallback	0.3	2025-12-02 13:16:02.17271
564	avvocato	Definizione non disponibile per 'Avvocato'	fallback	0.3	2025-12-02 13:16:02.768777
565	cuoco	Definizione non disponibile per 'Cuoco'	fallback	0.3	2025-12-02 13:16:03.323432
566	commesso	Definizione non disponibile per 'Commesso'	fallback	0.3	2025-12-02 13:16:03.884283
567	impiegato	Definizione non disponibile per 'Impiegato'	fallback	0.3	2025-12-02 13:16:04.46475
568	cameriere	Definizione non disponibile per 'Cameriere'	fallback	0.3	2025-12-02 13:16:05.050624
569	fotografo	Definizione non disponibile per 'Fotografo'	fallback	0.3	2025-12-02 13:16:05.628458
570	giornalista	Definizione non disponibile per 'Giornalista'	fallback	0.3	2025-12-02 13:16:06.21467
571	operaio	Definizione non disponibile per 'Operaio'	fallback	0.3	2025-12-02 13:16:06.80362
572	artista	Definizione non disponibile per 'Artista'	fallback	0.3	2025-12-02 13:16:07.361279
573	vigile del fuoco	Definizione non disponibile per 'Vigile del fuoco'	fallback	0.3	2025-12-02 13:16:07.943882
574	direttore	Definizione non disponibile per 'Direttore'	fallback	0.3	2025-12-02 13:16:08.50732
575	psicologo	Definizione non disponibile per 'Psicologo'	fallback	0.3	2025-12-02 13:16:09.100369
576	insegnante	Definizione non disponibile per 'Insegnante'	fallback	0.3	2025-12-02 13:16:09.725432
577	netturbino	Definizione non disponibile per 'Netturbino'	fallback	0.3	2025-12-02 13:16:10.305926
578	fioraio	Definizione non disponibile per 'Fioraio'	fallback	0.3	2025-12-02 13:16:10.906398
579	autista	Definizione non disponibile per 'Autista'	fallback	0.3	2025-12-02 13:16:11.483898
580	infermiere	Definizione non disponibile per 'Infermiere'	fallback	0.3	2025-12-02 13:16:12.073341
581	fratello	Definizione non disponibile per 'Fratello'	fallback	0.3	2025-12-02 13:16:12.653404
582	sorella	Definizione non disponibile per 'Sorella'	fallback	0.3	2025-12-02 13:16:13.247501
583	nonno	Definizione non disponibile per 'Nonno'	fallback	0.3	2025-12-02 13:16:13.828737
584	nonna	Definizione non disponibile per 'Nonna'	fallback	0.3	2025-12-02 13:16:14.444294
585	zio	Definizione non disponibile per 'Zio'	fallback	0.3	2025-12-02 13:16:15.06634
586	zia	Definizione non disponibile per 'Zia'	fallback	0.3	2025-12-02 13:16:15.671917
587	cugino	Definizione non disponibile per 'Cugino'	fallback	0.3	2025-12-02 13:16:16.256918
588	cugina	Definizione non disponibile per 'Cugina'	fallback	0.3	2025-12-02 13:16:16.835049
589	nipote	Definizione non disponibile per 'Nipote'	fallback	0.3	2025-12-02 13:16:17.435015
590	marito	Definizione non disponibile per 'Marito'	fallback	0.3	2025-12-02 13:16:18.0702
591	moglie	Definizione non disponibile per 'Moglie'	fallback	0.3	2025-12-02 13:16:18.655282
592	suocero	Definizione non disponibile per 'Suocero'	fallback	0.3	2025-12-02 13:16:19.223509
593	suocera	Definizione non disponibile per 'Suocera'	fallback	0.3	2025-12-02 13:16:19.802525
594	cognato	Definizione non disponibile per 'Cognato'	fallback	0.3	2025-12-02 13:16:20.389531
595	cognata	Definizione non disponibile per 'Cognata'	fallback	0.3	2025-12-02 13:16:20.989189
596	dentista	Definizione non disponibile per 'Dentista'	fallback	0.3	2025-12-02 13:16:21.564791
597	architetto	Definizione non disponibile per 'Architetto'	fallback	0.3	2025-12-02 13:16:22.139258
598	panettiere	Definizione non disponibile per 'Panettiere'	fallback	0.3	2025-12-02 13:16:22.703489
599	contadino	Definizione non disponibile per 'Contadino'	fallback	0.3	2025-12-02 13:16:23.321265
600	traduttore	Definizione non disponibile per 'Traduttore'	fallback	0.3	2025-12-02 13:16:23.881416
601	musicista	Definizione non disponibile per 'Musicista'	fallback	0.3	2025-12-02 13:16:24.497052
602	falegname	Definizione non disponibile per 'Falegname'	fallback	0.3	2025-12-02 13:16:25.070197
603	macellaio	Definizione non disponibile per 'Macellaio'	fallback	0.3	2025-12-02 13:16:25.681746
604	postino	Definizione non disponibile per 'Postino'	fallback	0.3	2025-12-02 13:16:26.354972
605	informatico	Definizione non disponibile per 'Informatico'	fallback	0.3	2025-12-02 13:16:26.942954
606	farmacista	Definizione non disponibile per 'Farmacista'	fallback	0.3	2025-12-02 13:16:27.506841
607	bibliotecario	Definizione non disponibile per 'Bibliotecario'	fallback	0.3	2025-12-02 13:16:28.118516
608	bancario	Definizione non disponibile per 'Bancario'	fallback	0.3	2025-12-02 13:16:28.670605
609	stilista	Definizione non disponibile per 'Stilista'	fallback	0.3	2025-12-02 13:16:29.222807
610	idraulico	Definizione non disponibile per 'Idraulico'	fallback	0.3	2025-12-02 13:16:29.791615
611	nuora	Definizione non disponibile per 'Nuora'	fallback	0.3	2025-12-02 13:16:30.342013
612	padrino	Definizione non disponibile per 'Padrino'	fallback	0.3	2025-12-02 13:16:30.905981
613	madrina	Definizione non disponibile per 'Madrina'	fallback	0.3	2025-12-02 13:16:31.48757
614	figlioccio	Definizione non disponibile per 'Figlioccio'	fallback	0.3	2025-12-02 13:16:32.03298
615	figlioccia	Definizione non disponibile per 'Figlioccia'	fallback	0.3	2025-12-02 13:16:32.589698
616	genitori	Definizione non disponibile per 'Genitori'	fallback	0.3	2025-12-02 13:16:33.141534
617	figli	Definizione non disponibile per 'Figli'	fallback	0.3	2025-12-02 13:16:33.704837
618	gemelli	Definizione non disponibile per 'Gemelli'	fallback	0.3	2025-12-02 13:16:34.279314
619	gemelle	Definizione non disponibile per 'Gemelle'	fallback	0.3	2025-12-02 13:16:34.834903
620	bebè	Definizione non disponibile per 'Bebè'	fallback	0.3	2025-12-02 13:16:35.38739
621	bisnonno	Definizione non disponibile per 'Bisnonno'	fallback	0.3	2025-12-02 13:16:35.947972
622	bisnonna	Definizione non disponibile per 'Bisnonna'	fallback	0.3	2025-12-02 13:16:36.492874
623	pronipote	Definizione non disponibile per 'Pronipote'	fallback	0.3	2025-12-02 13:16:37.061864
624	fratellastro	Definizione non disponibile per 'Fratellastro'	fallback	0.3	2025-12-02 13:16:37.652335
625	sorellastra	Definizione non disponibile per 'Sorellastra'	fallback	0.3	2025-12-02 13:16:38.218427
626	famiglia	Definizione non disponibile per 'Famiglia'	fallback	0.3	2025-12-02 13:16:38.785658
627	ambulanziata	Definizione non disponibile per 'Ambulanziata'	fallback	0.3	2025-12-02 13:16:39.34306
628	svegliarsi	Definizione non disponibile per 'Svegliarsi'	fallback	0.3	2025-12-02 13:16:39.916368
629	sedersi	Definizione non disponibile per 'Sedersi'	fallback	0.3	2025-12-02 13:16:40.482287
630	coricarsi	Definizione non disponibile per 'Coricarsi'	fallback	0.3	2025-12-02 13:16:41.044016
631	trovarsi	Definizione non disponibile per 'Trovarsi'	fallback	0.3	2025-12-02 13:16:41.626207
632	ricordarsi	Definizione non disponibile per 'Ricordarsi'	fallback	0.3	2025-12-02 13:16:42.192556
633	prepararsi	Definizione non disponibile per 'Prepararsi'	fallback	0.3	2025-12-02 13:16:42.754783
634	sentirsi	Definizione non disponibile per 'Sentirsi'	fallback	0.3	2025-12-02 13:16:43.318851
635	chiedersi	Definizione non disponibile per 'Chiedersi'	fallback	0.3	2025-12-02 13:16:43.880756
636	sbagliarsi	Definizione non disponibile per 'Sbagliarsi'	fallback	0.3	2025-12-02 13:16:44.441718
637	rilassarsi	Definizione non disponibile per 'Rilassarsi'	fallback	0.3	2025-12-02 13:16:45.033515
638	riposarsi	Definizione non disponibile per 'Riposarsi'	fallback	0.3	2025-12-02 13:16:45.600072
639	pettinarsi	Definizione non disponibile per 'Pettinarsi'	fallback	0.3	2025-12-02 13:16:46.163904
640	spazzolarsi	Definizione non disponibile per 'Spazzolarsi'	fallback	0.3	2025-12-02 13:16:46.7146
641	sbrigarsi	Definizione non disponibile per 'Sbrigarsi'	fallback	0.3	2025-12-02 13:16:47.27841
642	allenarsi	Definizione non disponibile per 'Allenarsi'	fallback	0.3	2025-12-02 13:16:47.833864
643	fermarsi	Definizione non disponibile per 'Fermarsi'	fallback	0.3	2025-12-02 13:16:48.397594
644	sdraiarsi	Definizione non disponibile per 'sdraiarsi'	fallback	0.3	2025-12-02 13:16:48.948067
645	calmarsi	Definizione non disponibile per 'Calmarsi'	fallback	0.3	2025-12-02 13:16:49.500847
646	barista	Definizione non disponibile per 'Barista'	fallback	0.3	2025-12-02 13:16:50.085384
647	muratore	Definizione non disponibile per 'Muratore'	fallback	0.3	2025-12-02 13:16:50.665855
648	pilota	Definizione non disponibile per 'Pilota'	fallback	0.3	2025-12-02 13:16:51.216678
649	incontrarsi	Definizione non disponibile per 'Incontrarsi'	fallback	0.3	2025-12-02 13:16:51.801811
650	arrabbiarsi	Definizione non disponibile per 'Arrabbiarsi'	fallback	0.3	2025-12-02 13:16:52.383465
651	addormentarsi	Definizione non disponibile per 'Addormentarsi'	fallback	0.3	2025-12-02 13:16:52.921998
\.


--
-- Data for Name: quiz_sessions; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.quiz_sessions (session_pk, user_pk, deck_pk, card_count, quiz_type, cycle_number, used_card_pks, correct_count, total_questions, started_at, completed_at) FROM stdin;
129	2	9	10	frappe	1	[55, 151, 90, 75, 116, 112, 145, 129, 148, 150]	8	10	2025-12-07 07:05:00.007826	2025-12-07 07:06:22.937181
133	2	12	10	frappe	1	[302, 321, 344, 290, 325, 338, 291, 364, 339, 337]	7	10	2025-12-09 12:51:07.270747	2025-12-09 12:52:07.815335
3	2	10	10	frappe	1	[232, 255, 185, 209, 230, 186, 215, 242, 191, 175]	0	0	2025-12-04 13:03:09.491775	\N
4	2	10	10	frappe	1	[220, 228, 251, 243, 201, 208, 250, 202, 247, 194]	0	0	2025-12-04 13:03:15.107116	\N
5	2	10	10	frappe	1	[252, 237, 204, 173, 262, 227, 197, 248, 229, 192]	0	0	2025-12-04 13:06:30.701832	\N
6	11	10	10	frappe	1	[227, 216, 245, 256, 199, 178, 253, 257, 195, 228]	0	0	2025-12-04 14:10:11.091188	\N
7	11	10	5	frappe	1	[255, 213, 183, 185, 191]	0	0	2025-12-04 14:11:19.382294	\N
8	11	10	5	frappe	1	[265, 200, 249, 235, 205]	0	0	2025-12-04 14:15:56.140181	\N
9	2	10	10	frappe	1	[213, 187, 180, 221, 176, 258, 260, 225, 226, 256]	0	0	2025-12-04 14:44:40.848025	\N
34	13	10	42	classique	1	[245, 236, 244, 209, 196, 218, 188, 193, 243, 200, 203, 250, 197, 170, 217, 210, 263, 181, 194, 229, 251, 198, 235, 219, 225, 178, 230, 185, 214, 237, 199, 172, 246, 228, 207, 252, 240, 212, 184, 195, 257, 226]	30	42	2025-12-05 14:24:45.23643	2025-12-05 14:24:45.56485
15	12	10	20	classique	1	[210, 187, 212, 255, 215, 191, 252, 263, 234, 218, 236, 169, 231, 201, 178, 180, 203, 241, 181, 226]	13	20	2025-12-05 14:08:36.946748	2025-12-05 14:08:37.105705
16	12	10	30	classique	1	[179, 176, 230, 168, 243, 245, 204, 184, 246, 266, 167, 197, 211, 261, 177, 262, 208, 198, 213, 238, 258, 219, 237, 264, 185, 260, 170, 173, 242, 206]	17	30	2025-12-05 14:08:37.132395	2025-12-05 14:08:37.341703
17	12	10	40	classique	1	[244, 228, 247, 190, 235, 200, 250, 207, 199, 257, 224, 217, 259, 248, 229, 227, 239, 194, 174, 195, 182, 188, 193, 220, 256, 222, 251, 249, 240, 171, 172, 192, 265, 196, 214, 205, 186, 225, 175, 209]	26	40	2025-12-05 14:08:37.35732	2025-12-05 14:08:37.634507
18	12	10	15	classique	1	[183, 189, 202, 216, 221, 223, 232, 233, 253, 254]	7	10	2025-12-05 14:08:37.649059	2025-12-05 14:08:37.730347
19	12	10	25	classique	2	[189, 212, 216, 222, 201, 249, 207, 233, 256, 177, 221, 171, 202, 226, 178, 193, 258, 252, 172, 228, 260, 266, 170, 254, 241]	21	25	2025-12-05 14:08:37.760312	2025-12-05 14:08:37.89592
20	12	10	35	classique	3	[233, 168, 170, 197, 202, 231, 232, 263, 167, 227, 171, 182, 173, 191, 176, 235, 181, 209, 195, 203, 219, 257, 226, 266, 187, 208, 244, 198, 246, 212, 248, 265, 223, 217, 229]	30	35	2025-12-05 14:08:37.926609	2025-12-05 14:08:38.165629
35	13	10	19	classique	1	[253, 204, 258, 205, 231, 202, 266, 223, 169, 249, 260, 238, 221, 262, 216, 211, 191, 186, 222]	10	19	2025-12-05 14:24:45.579612	2025-12-05 14:24:45.704298
36	13	10	50	classique	1	[168, 171, 173, 174, 175, 176, 177, 179, 180, 182, 183, 187, 189, 190, 192, 201, 208, 215, 220, 227, 232, 233, 239, 241, 242, 247, 248, 255, 259, 261, 264, 265]	21	32	2025-12-05 14:24:45.723036	2025-12-05 14:24:46.007245
37	13	10	12	classique	2	[186, 266, 232, 169, 215, 176, 193, 222, 179, 174, 210, 253]	7	12	2025-12-05 14:24:46.027591	2025-12-05 14:24:46.087986
38	13	10	63	classique	3	[199, 239, 232, 198, 258, 171, 253, 264, 247, 206, 214, 196, 186, 210, 218, 227, 213, 224, 240, 259, 228, 252, 168, 235, 170, 211, 207, 251, 231, 254, 226, 265, 234, 223, 183, 225, 236, 212, 179, 261, 180, 190, 248, 222, 216, 243, 189, 209, 255, 178, 250, 169, 262, 203, 256, 246, 172, 257, 167, 185, 177, 174, 204]	57	63	2025-12-05 14:24:46.116048	2025-12-05 14:24:46.352658
39	13	10	8	classique	4	[237, 168, 233, 183, 201, 229, 265, 266]	7	8	2025-12-05 14:24:46.382765	2025-12-05 14:24:46.436023
33	13	10	7	classique	1	[234, 213, 256, 167, 224, 206, 254]	5	7	2025-12-05 14:24:45.146779	2025-12-05 14:24:45.212793
40	13	10	30	classique	5	[202, 196, 262, 175, 168, 240, 183, 176, 266, 216, 178, 241, 207, 206, 239, 220, 221, 203, 258, 210, 184, 188, 257, 230, 245, 211, 190, 264, 227, 232]	25	30	2025-12-05 14:24:46.455835	2025-12-05 14:24:46.583501
41	13	10	5	classique	6	[176, 200, 226, 181, 244]	5	5	2025-12-05 14:24:46.610237	2025-12-05 14:24:46.636891
42	13	10	91	classique	7	[260, 237, 200, 218, 214, 221, 259, 233, 251, 234, 210, 223, 266, 189, 177, 204, 182, 213, 192, 183, 225, 228, 202, 222, 238, 203, 244, 249, 239, 206, 243, 185, 208, 187, 191, 195, 240, 178, 231, 246, 254, 248, 245, 167, 168, 229, 175, 196, 207, 173, 224, 169, 262, 256, 258, 205, 265, 250, 247, 257, 215, 186, 226, 253, 209, 227, 261, 212, 264, 217, 252, 220, 190, 172, 198, 193, 184, 176, 211, 242, 194, 174, 219, 216, 171, 188, 201, 263, 170, 180, 199]	79	91	2025-12-05 14:24:46.660734	2025-12-05 14:24:47.068787
43	13	10	10	classique	8	[175, 242, 177, 234, 220, 255, 208, 265, 207, 256]	7	10	2025-12-05 14:24:47.090671	2025-12-05 14:24:47.13798
44	14	10	7	classique	1	[260, 235, 167, 207, 244, 237, 230]	4	7	2025-12-05 14:30:44.931631	2025-12-05 14:30:44.99357
45	14	10	88	classique	1	[182, 191, 179, 216, 245, 236, 251, 229, 234, 233, 189, 202, 170, 266, 192, 193, 247, 257, 221, 181, 232, 223, 187, 227, 222, 250, 175, 217, 180, 174, 218, 242, 238, 188, 186, 190, 208, 215, 228, 168, 201, 256, 240, 226, 197, 261, 177, 253, 241, 173, 205, 213, 231, 254, 172, 210, 200, 195, 171, 225, 249, 204, 203, 214, 262, 199, 211, 183, 196, 239, 184, 224, 255, 252, 248, 265, 258, 212, 243, 219, 178, 198, 194, 185, 263, 220, 259, 209]	62	88	2025-12-05 14:30:45.010359	2025-12-05 14:30:45.532965
46	14	10	23	classique	1	[169, 176, 206, 246, 264]	2	5	2025-12-05 14:30:45.545927	2025-12-05 14:30:45.577535
47	14	10	45	classique	2	[176, 264, 174, 195, 251, 196, 202, 183, 259, 192, 179, 167, 177, 225, 211, 258, 241, 238, 197, 198, 230, 236, 209, 187, 240, 207, 257, 243, 185, 214, 229, 263, 250, 205, 191, 249, 244, 227, 184, 265, 172, 224, 266, 188, 260]	38	45	2025-12-05 14:30:45.594793	2025-12-05 14:30:45.727829
48	15	8	5	classique	1	[44, 22, 33, 16, 30]	3	5	2025-12-05 14:37:15.588154	2025-12-05 14:37:15.665564
49	15	8	20	classique	1	[14, 21, 13, 47, 20, 15, 17, 11, 48, 32, 34, 37, 24, 23, 35, 46, 43, 26, 49, 42]	13	20	2025-12-05 14:37:15.703435	2025-12-05 14:37:15.909671
50	15	8	25	classique	1	[10, 12, 18, 19, 25, 27, 28, 29, 31, 36, 38, 39, 40, 41, 45]	8	15	2025-12-05 14:37:15.935426	2025-12-05 14:37:16.064979
51	15	8	30	classique	2	[23, 10, 19, 20, 28, 37, 36, 26, 14, 46, 47, 16, 33, 12, 38, 24, 39, 18, 48, 17, 29, 32, 15, 40, 35, 27, 30, 44, 11, 25]	23	30	2025-12-05 14:37:16.088489	2025-12-05 14:37:16.207146
52	15	8	15	classique	3	[16, 20, 31, 35, 43, 28, 49, 48, 29, 26, 10, 42, 13, 11, 27]	14	15	2025-12-05 14:37:16.224637	2025-12-05 14:37:16.294285
53	15	8	40	classique	4	[36, 26, 31, 43, 25, 10, 21, 38, 46, 28, 39, 17, 32, 48, 16, 18, 47, 37, 44, 41, 27, 15, 11, 23, 12, 42, 35, 13, 30, 19, 33, 45, 40, 24, 14, 34, 29, 49, 22, 20]	35	40	2025-12-05 14:37:16.32317	2025-12-05 14:37:16.513152
54	15	8	10	classique	5	[28, 25, 26, 22, 35, 41, 38, 17, 45, 34]	9	10	2025-12-05 14:37:16.540655	2025-12-05 14:37:16.601906
55	15	8	35	classique	6	[40, 45, 46, 44, 41, 20, 21, 38, 29, 31, 23, 13, 25, 39, 33, 26, 48, 27, 19, 47, 37, 36, 49, 30, 17, 11, 12, 16, 43, 24, 18, 10, 34, 15, 14]	29	35	2025-12-05 14:37:16.620812	2025-12-05 14:37:16.779762
56	15	8	25	classique	7	[23, 13, 43, 49, 36, 29, 46, 40, 10, 15, 31, 24, 32, 34, 25, 11, 47, 20, 16, 26, 27, 33, 17, 41, 21]	20	25	2025-12-05 14:37:16.803082	2025-12-05 14:37:16.927093
57	15	8	20	classique	8	[23, 44, 38, 24, 31, 40, 41, 30, 18, 28, 20, 11, 47, 35, 34, 45, 26, 46, 17, 33]	15	20	2025-12-05 14:37:16.94332	2025-12-05 14:37:17.046926
130	2	20	10	frappe	1	[689, 712, 692, 706, 704, 699, 696, 709, 711]	4	10	2025-12-07 07:17:14.844501	2025-12-07 07:18:21.505765
75	16	8	15	classique	2	[15, 33, 36, 46, 28, 45, 30, 22, 14, 12, 21, 11, 20, 25, 44]	9	15	2025-12-05 14:43:49.100713	2025-12-05 14:43:49.160156
134	2	12	10	frappe	1	[345, 295, 287, 351, 294, 306, 347, 310, 333, 334]	7	10	2025-12-09 12:52:18.94132	2025-12-09 12:53:49.528173
76	16	10	150	classique	1	[186, 167, 168, 170, 171, 172, 173, 174, 175, 176, 177, 178, 179, 180, 181, 182, 183, 184, 185, 187, 188, 189, 190, 191, 192, 193, 194, 195, 196, 197, 198, 199, 200, 201, 202, 203, 204, 205, 206, 207, 208, 209, 210, 211, 212, 213, 214, 215, 216, 217, 218, 220, 221, 222, 223, 224, 225, 226, 227, 228, 229, 230, 231, 232, 233, 234, 235, 236, 237, 238, 239, 240, 241, 242, 243, 244, 245, 246, 247, 248, 249, 250, 251, 252, 253, 254, 255, 256, 258, 259, 260, 261, 262, 263, 264, 265, 266]	55	97	2025-12-05 14:43:49.170433	2025-12-05 14:43:49.711678
135	2	12	10	frappe	1	[296, 368, 377, 292, 315, 303, 319, 308, 371, 363]	7	10	2025-12-09 12:54:02.66109	2025-12-09 12:55:02.27733
77	16	10	42	classique	2	[237, 211, 227, 264, 200, 167, 266, 184, 223, 173, 170, 205, 183, 197, 180, 260, 194, 190, 233, 245, 263, 232, 212, 213, 171, 250, 251, 199, 179, 256, 204, 185, 254, 265, 226, 168, 214, 219, 257, 225, 208, 193]	31	42	2025-12-05 14:43:49.725368	2025-12-05 14:43:49.854254
140	2	12	20	frappe	1	[307, 380, 338, 332, 360, 329, 359, 322, 348, 298, 282, 294, 304, 299, 373, 342, 355, 364, 353, 333]	11	21	2025-12-09 13:04:03.934561	2025-12-09 13:06:48.576942
78	16	8	2	classique	3	[48, 14]	1	2	2025-12-05 14:43:49.871645	2025-12-05 14:43:49.886543
142	2	12	10	frappe	1	[370, 293, 363, 351, 349, 381, 362, 378, 379, 354]	5	10	2025-12-09 13:08:35.678554	2025-12-09 13:09:47.721719
79	16	8	30	classique	4	[16, 18, 20, 12, 44, 27, 42, 45, 41, 21, 32, 17, 25, 30, 46, 13, 34, 48, 11, 19, 26, 38, 33, 15, 28, 24, 40, 36, 22, 31]	26	30	2025-12-05 14:43:49.903902	2025-12-05 14:43:50.017308
148	2	23	10	qcm	1	[851, 846, 853, 857, 845, 843, 852, 862, 865]	0	0	2025-12-10 08:48:11.584394	\N
149	2	23	10	frappe	1	[853, 865, 846, 862, 863, 866, 855, 860]	0	0	2025-12-10 08:53:30.989737	\N
80	16	10	1	classique	3	[207]	0	1	2025-12-05 14:43:50.032083	2025-12-05 14:43:50.038506
151	2	23	10	qcm	1	[843, 865, 852, 850, 859, 864, 862, 853, 849]	9	9	2025-12-10 08:53:58.089358	2025-12-10 08:55:31.073255
81	16	8	40	classique	5	[28, 15, 49, 40, 22, 46, 33, 35, 29, 19, 30, 11, 39, 21, 20, 37, 24, 12, 41, 14, 16, 42, 13, 32, 45, 44, 47, 38, 23, 18, 34, 17, 31, 26, 43, 25, 48, 27, 10, 36]	35	40	2025-12-05 14:43:50.052004	2025-12-05 14:43:50.174557
72	16	8	7	classique	1	[25, 24, 35, 37, 29, 46, 47]	5	7	2025-12-05 14:43:48.760073	2025-12-05 14:43:48.821786
73	16	10	3	classique	1	[257, 169, 219]	1	3	2025-12-05 14:43:48.839121	2025-12-05 14:43:48.862133
74	16	8	83	classique	1	[10, 11, 12, 13, 14, 15, 16, 17, 18, 19, 20, 21, 22, 23, 26, 27, 28, 30, 31, 32, 33, 34, 36, 38, 39, 40, 41, 42, 43, 44, 45, 48, 49]	15	33	2025-12-05 14:43:48.879168	2025-12-05 14:43:49.083502
82	16	10	99	classique	4	[218, 188, 266, 232, 195, 249, 226, 178, 176, 219, 169, 170, 263, 183, 236, 253, 242, 168, 223, 205, 201, 191, 213, 206, 202, 200, 167, 254, 173, 204, 184, 193, 217, 246, 181, 189, 210, 186, 208, 244, 197, 237, 257, 251, 196, 199, 192, 198, 265, 180, 256, 179, 224, 225, 190, 255, 261, 194, 235, 248, 215, 264, 241, 260, 245, 185, 203, 220, 172, 258, 252, 207, 229, 247, 250, 216, 222, 259, 214, 240, 230, 221, 174, 231, 211, 187, 177, 233, 228, 234, 262, 238, 212, 239, 227, 175, 171, 243, 209]	81	99	2025-12-05 14:43:50.186584	2025-12-05 14:43:50.519363
83	16	8	5	classique	6	[14, 22, 12, 13, 15]	5	5	2025-12-05 14:43:50.531857	2025-12-05 14:43:50.54911
84	16	10	88	classique	5	[234, 172, 177, 191, 204, 240, 183, 210, 238, 222, 201, 227, 188, 212, 262, 217, 223, 205, 248, 184, 208, 206, 256, 220, 173, 200, 192, 198, 218, 231, 244, 178, 252, 235, 199, 246, 224, 242, 232, 266, 174, 264, 249, 228, 170, 237, 254, 259, 169, 168, 190, 245, 243, 180, 250, 215, 258, 251, 236, 202, 196, 175, 233, 241, 216, 229, 181, 171, 186, 239, 219, 261, 209, 247, 226, 221, 213, 194, 214, 225, 176, 195, 255, 187, 265, 203, 207, 179]	75	88	2025-12-05 14:43:50.562952	2025-12-05 14:43:50.899895
85	16	10	15	classique	6	[254, 196, 210, 248, 219, 184, 255, 197, 204, 177, 260, 179, 188, 183, 172]	14	15	2025-12-05 14:43:50.926614	2025-12-05 14:43:50.986379
86	16	8	1	classique	7	[19]	1	1	2025-12-05 14:43:50.998682	2025-12-05 14:43:51.004707
87	16	10	100	classique	7	[229, 224, 220, 205, 181, 196, 193, 194, 197, 179, 200, 188, 213, 191, 180, 198, 190, 266, 256, 195, 265, 245, 219, 172, 169, 212, 254, 236, 206, 264, 223, 225, 208, 253, 230, 182, 262, 203, 244, 218, 263, 222, 233, 175, 235, 255, 209, 173, 234, 251, 184, 211, 183, 177, 257, 202, 243, 204, 239, 241, 186, 240, 214, 242, 185, 167, 231, 258, 238, 171, 221, 227, 252, 232, 170, 187, 260, 178, 248, 189, 192, 217, 201, 237, 228, 210, 246, 174, 176, 199, 215, 226, 249, 168, 259, 207, 261, 250, 216, 247]	89	100	2025-12-05 14:43:51.020183	2025-12-05 14:43:51.337619
88	16	8	33	classique	8	[41, 21, 14, 32, 48, 30, 39, 28, 36, 12, 29, 20, 49, 37, 17, 16, 35, 22, 25, 34, 45, 10, 38, 27, 15, 42, 11, 46, 26, 18, 33, 19, 23]	30	33	2025-12-05 14:43:51.348466	2025-12-05 14:43:51.453618
89	16	8	1	classique	9	[20]	1	1	2025-12-05 14:43:51.463767	2025-12-05 14:43:51.469949
90	16	10	7	classique	8	[213, 208, 188, 197, 212, 219, 256]	6	7	2025-12-05 14:43:51.48326	2025-12-05 14:43:51.509804
91	16	8	40	classique	10	[28, 19, 12, 41, 39, 42, 30, 21, 40, 47, 22, 14, 16, 35, 37, 36, 11, 43, 45, 44, 38, 20, 13, 24, 27, 26, 32, 46, 18, 48, 29, 34, 33, 17, 15, 31, 49, 10, 25, 23]	36	40	2025-12-05 14:43:51.522734	2025-12-05 14:43:51.646024
92	16	10	55	classique	9	[235, 236, 264, 186, 190, 214, 245, 196, 187, 262, 198, 211, 240, 197, 205, 251, 226, 175, 202, 219, 181, 188, 172, 224, 228, 193, 256, 259, 176, 208, 263, 243, 220, 209, 204, 201, 174, 242, 178, 260, 249, 215, 232, 199, 171, 213, 233, 244, 261, 168, 246, 257, 192, 167, 203]	48	55	2025-12-05 14:43:51.661111	2025-12-05 14:43:51.851383
93	16	8	20	classique	11	[19, 16, 30, 14, 45, 12, 49, 23, 28, 24, 21, 32, 37, 42, 26, 36, 11, 44, 38, 34]	20	20	2025-12-05 14:43:51.867107	2025-12-05 14:43:51.939592
94	16	10	3	classique	10	[197, 196, 262]	3	3	2025-12-05 14:43:51.955084	2025-12-05 14:43:51.970644
95	2	8	5	frappe	1	[41, 32, 31, 29, 18]	0	0	2025-12-05 14:52:47.436471	\N
96	2	8	6	frappe	1	[23, 12, 34, 33, 19, 27]	5	6	2025-12-05 15:13:17.754095	2025-12-05 15:13:58.37642
97	2	8	10	frappe	1	[42, 28, 46, 17, 36, 35, 48, 13, 25, 43]	6	10	2025-12-05 15:14:58.959666	2025-12-05 15:16:24.561416
159	2	23	10	frappe	1	[856, 855, 854, 862, 857, 846, 842, 860, 845]	9	9	2025-12-10 13:49:59.804555	2025-12-10 13:51:53.545592
160	2	23	10	frappe	1	[855, 846, 850, 862, 847, 853, 845, 861, 866, 857]	5	10	2025-12-10 13:57:41.239497	2025-12-10 13:59:34.205325
161	2	20	10	frappe	2	[698, 712, 695, 701, 692, 690, 711, 707, 708, 697]	3	10	2025-12-10 13:59:49.74315	2025-12-10 14:01:09.525712
164	2	23	10	frappe	1	[843, 864, 853, 850, 847, 844, 859, 854]	0	0	2025-12-10 14:12:13.815182	\N
108	2	8	7	frappe	1	[26, 45, 39, 21, 20, 40, 37]	3	7	2025-12-05 15:34:48.424953	2025-12-05 15:35:44.184611
109	2	8	9	frappe	1	[16, 11, 10, 14, 49, 44, 22, 24, 47]	6	9	2025-12-05 15:36:03.897265	2025-12-05 15:37:01.290215
136	2	12	10	frappe	1	[376, 297, 305, 370, 369, 361, 354, 309, 341, 323]	7	10	2025-12-09 12:55:23.730389	2025-12-09 12:56:26.733911
137	2	12	10	frappe	1	[324, 335, 381, 378, 349, 285, 379, 331, 300, 362]	5	10	2025-12-09 12:57:05.023952	2025-12-09 12:58:21.829053
138	2	12	10	frappe	1	[328, 284, 358, 289, 367, 352, 357, 330, 375, 365]	4	10	2025-12-09 12:58:34.285838	2025-12-09 12:59:55.020761
139	2	12	20	frappe	1	[346, 314, 320, 343, 311, 356, 372, 336, 301, 286, 316, 326, 366, 327, 312, 283, 318, 374, 350, 317]	11	20	2025-12-09 13:00:04.783174	2025-12-09 13:02:17.719389
141	2	12	6	frappe	1	[361, 296, 313, 288, 371, 337]	5	6	2025-12-09 13:07:37.906624	2025-12-09 13:08:17.432018
143	2	12	7	frappe	1	[328, 358, 357, 340, 330, 367, 365]	1	7	2025-12-09 13:10:15.791826	2025-12-09 13:11:01.849563
156	2	23	10	frappe	1	[866, 846, 856, 859, 857, 862, 854, 865, 850]	0	0	2025-12-10 12:26:42.802983	\N
157	2	23	10	frappe	1	[862, 846, 842, 854, 861, 851, 857, 859, 856]	0	0	2025-12-10 12:59:46.842332	\N
162	2	23	10	frappe	1	[841, 846, 861, 848, 844, 864, 843, 849, 866]	0	0	2025-12-10 14:02:24.770479	\N
163	2	23	10	frappe	1	[844, 861, 863, 848, 855, 841, 846, 850, 857]	4	9	2025-12-10 14:08:39.893164	2025-12-10 14:11:33.23623
165	2	23	10	frappe	1	[856, 848, 861, 860, 864, 841, 863, 852, 847]	0	0	2025-12-10 14:20:53.473255	\N
166	2	23	10	frappe	1	[848, 863, 861, 858, 841, 846, 853, 864, 847, 844]	6	10	2025-12-10 15:14:48.668026	2025-12-10 15:18:50.951808
170	2	12	10	frappe	2	[371, 327, 305, 359, 319, 287, 297, 312, 314, 293]	0	0	2025-12-11 08:31:32.180984	\N
172	2	23	10	frappe	2	[863, 865, 858, 844, 856, 842, 841, 848, 862, 853]	4	10	2025-12-11 08:32:03.978917	2025-12-11 08:34:53.331286
176	2	8	10	frappe	11	[18, 25, 48, 45, 33, 10, 13, 37, 47]	8	9	2025-12-11 08:39:32.648655	2025-12-11 08:40:39.360581
180	2	12	26	frappe	6	[365, 304, 286, 370, 358, 325, 352, 333, 293, 290, 374, 335, 367, 321, 302, 337, 369, 343, 341, 307, 319, 318, 287, 303, 344, 288]	20	27	2026-01-03 15:43:14.269699	2026-01-03 15:45:59.98322
181	2	12	26	frappe	7	[361, 349, 320, 342, 350, 317, 301, 368, 336, 311, 345, 364, 377, 372, 314, 283, 373, 355, 359, 346, 378, 379, 285, 353, 380, 351]	12	26	2026-01-03 15:46:12.844738	2026-01-03 15:49:34.731402
186	2	35	10	frappe	1	[1382, 1384, 1378, 1380, 1385, 1374, 1366, 1379, 1371, 1377]	11	11	2026-02-01 15:16:34.819523	2026-02-01 15:19:36.551187
189	2	28	10	frappe	1	[1066, 1107, 1053, 1083, 1071, 1076, 1112, 1136, 1143, 1119]	7	10	2026-02-01 15:23:13.759547	2026-02-01 15:24:21.744157
190	2	28	10	frappe	1	[1109, 1134, 1144, 1054, 1146, 1096, 1049, 1073, 1123, 1115]	5	10	2026-02-01 15:24:25.827371	2026-02-01 15:25:49.17042
191	2	28	10	frappe	1	[1127, 1080, 1072, 1113, 1104, 1121, 1045, 1102, 1133, 1110]	8	10	2026-02-01 15:25:54.210696	2026-02-01 15:27:04.967604
192	2	28	10	frappe	1	[1120, 1129, 1067, 1047, 1059, 1060, 1068, 1055, 1125, 1078]	7	10	2026-02-01 15:27:25.031757	2026-02-01 15:28:53.967551
193	2	28	10	frappe	1	[1111, 1042, 1124, 1148, 1089, 1069, 1091, 1122, 1084, 1052]	7	10	2026-02-01 15:28:58.000288	2026-02-01 15:30:39.680494
194	2	28	10	frappe	1	[1070, 1046, 1044, 1132, 1085, 1099, 1103, 1098, 1126, 1101]	5	10	2026-02-01 15:30:44.300659	2026-02-01 15:32:15.441479
195	2	28	10	frappe	1	[1074, 1035, 1077, 1040, 1075, 1039, 1061, 1100, 1130, 1081]	8	10	2026-02-01 15:32:21.175491	2026-02-01 15:33:19.278433
197	2	28	10	frappe	1	[1145, 1092, 1048, 1135, 1064, 1062, 1066, 1141, 1117, 1118]	7	10	2026-02-01 15:35:20.940937	2026-02-01 15:36:23.169924
200	2	41	10	frappe	1	[1898, 1893, 1879, 1843, 1860, 1920, 1901, 1830, 1834, 1911]	5	11	2026-02-14 15:53:09.480375	2026-02-14 15:54:22.543834
110	2	8	3	frappe	1	[38, 15, 30]	1	3	2025-12-05 15:37:22.592558	2025-12-05 15:37:51.158439
111	17	8	7	classique	1	[10, 25, 43, 12, 22, 24, 42]	6	7	2025-12-05 16:03:52.424498	2025-12-05 16:03:52.496511
112	2	8	10	frappe	2	[43, 28, 45, 37, 14, 49, 26, 16, 10, 25]	1	10	2025-12-05 16:10:27.054455	2025-12-05 16:11:06.642558
113	2	8	10	frappe	3	[49, 42, 47, 43, 40, 18, 48, 38, 15, 30]	6	10	2025-12-06 09:01:02.900823	2025-12-06 09:02:17.140423
114	2	8	5	frappe	4	[18, 44, 32, 47, 19]	2	5	2025-12-06 09:08:14.560539	2025-12-06 09:08:51.287159
115	2	8	10	frappe	5	[47, 23, 48, 44, 45, 42, 28, 43, 49, 37]	5	10	2025-12-06 12:46:47.070985	2025-12-06 12:48:00.798423
116	2	8	10	frappe	6	[46, 49, 40, 31, 18, 29, 48, 39, 13, 41]	5	10	2025-12-06 13:43:46.803395	2025-12-06 13:45:03.490251
117	2	8	10	frappe	7	[39, 41, 43, 18, 48, 37, 31, 45, 42, 44]	7	10	2025-12-06 14:08:57.957638	2025-12-06 14:10:21.007677
118	18	8	10	frappe	1	[39, 43, 45, 25, 48, 23, 41, 35, 37]	0	0	2025-12-06 15:45:27.818363	\N
119	18	10	10	frappe	1	[266, 184, 170, 201, 173, 220, 200, 171, 196, 205]	8	10	2025-12-06 15:47:01.397972	2025-12-06 15:48:33.888638
120	18	10	10	frappe	1	[223, 255, 191, 231, 243, 219, 189, 185, 224, 242]	4	10	2025-12-06 15:51:14.407856	2025-12-06 15:52:47.083502
121	18	10	10	frappe	1	[251, 236, 210, 216, 234, 238, 197, 204, 263, 225]	8	10	2025-12-06 15:53:11.640593	2025-12-06 15:54:13.100383
122	18	10	10	frappe	1	[256, 229, 237, 233, 240, 209, 213, 264, 174, 226]	6	10	2025-12-06 15:54:39.813664	2025-12-06 15:55:59.922917
123	18	10	10	frappe	1	[258, 167, 227, 169, 250, 192, 244, 179, 222, 181]	9	10	2025-12-06 15:56:18.796006	2025-12-06 15:57:13.278354
124	18	10	10	frappe	1	[182, 186, 260, 177, 249, 193, 235, 218, 241, 198]	6	10	2025-12-06 15:57:37.812604	2025-12-06 15:58:40.649188
125	18	10	10	frappe	1	[168, 221, 214, 248, 183, 188, 254, 252, 253, 176]	5	10	2025-12-06 15:59:17.427874	2025-12-06 16:00:15.483807
126	18	10	10	frappe	1	[207, 199, 220, 257, 172, 262, 208, 206, 239, 212]	6	10	2025-12-06 16:00:44.224604	2025-12-06 16:01:46.56595
127	2	9	10	frappe	1	[96, 165, 87, 114, 65, 153, 123, 133, 86, 64]	8	10	2025-12-07 06:58:01.793318	2025-12-07 07:01:41.829504
128	2	9	10	frappe	1	[141, 149, 108, 107, 124, 80, 140, 93, 126, 92]	9	10	2025-12-07 07:03:07.291352	2025-12-07 07:04:04.966855
132	2	22	10	frappe	1	[811, 799, 838, 787, 798, 780, 827, 802, 782]	0	0	2025-12-08 16:20:15.419488	\N
144	2	20	10	frappe	1	[695, 709, 700, 692, 698, 697, 711, 712, 689, 705]	4	10	2025-12-10 07:46:55.297689	2025-12-10 07:47:55.073311
145	2	20	10	frappe	1	[693, 690, 699, 688, 703, 701, 696, 706, 707, 704]	4	10	2025-12-10 07:48:08.07244	2025-12-10 07:49:16.159557
146	2	20	10	frappe	1	[694, 698, 711, 704, 702, 703, 693, 691, 708]	6	9	2025-12-10 07:49:35.709423	2025-12-10 07:50:27.443363
147	2	23	10	frappe	1	[846, 842, 862, 852, 849, 865, 860, 859, 851]	0	9	2025-12-10 08:43:24.520568	2025-12-10 08:47:56.524752
150	2	23	10	frappe	1	[852, 853, 842, 865, 862, 859, 860, 844, 846, 863]	0	0	2025-12-10 08:53:46.508778	\N
152	2	23	10	association	1	[852, 856, 861, 851, 860, 842, 849]	7	7	2025-12-10 08:56:07.152531	2025-12-10 08:57:05.554791
153	2	23	16	association	1	[856, 864, 854, 860, 851, 842, 857, 845, 846]	9	9	2025-12-10 08:57:21.441687	2025-12-10 08:58:47.863422
154	2	23	19	association	1	[859, 842, 844, 855, 841, 856, 864, 849, 862, 861, 845, 847, 850, 863]	14	14	2025-12-10 08:59:58.233084	2025-12-10 09:02:39.84688
155	2	23	10	frappe	1	[841, 862, 848, 857, 861, 850, 846, 863, 864]	0	0	2025-12-10 09:20:27.036967	\N
158	2	23	10	frappe	1	[845, 862, 856, 846, 854, 864, 843, 857, 842]	0	0	2025-12-10 13:25:20.09109	\N
167	2	20	10	frappe	3	[705, 712, 692, 688, 699, 693, 702, 697, 708, 704]	7	10	2025-12-11 08:28:12.925985	2025-12-11 08:29:10.879793
168	2	20	10	frappe	4	[694, 701, 697, 700, 698, 692, 703, 691, 711]	5	9	2025-12-11 08:29:22.816367	2025-12-11 08:30:14.157158
169	2	20	10	frappe	5	[711, 692, 698, 704, 697, 708, 701]	6	7	2025-12-11 08:30:23.873886	2025-12-11 08:31:12.489078
171	2	9	10	frappe	1	[122, 128, 105, 154, 79, 86, 109, 92, 147, 115]	0	0	2025-12-11 08:31:53.213151	\N
173	2	8	10	frappe	8	[25, 20, 14, 48, 19, 32, 16, 43, 11, 22]	8	10	2025-12-11 08:35:08.866838	2025-12-11 08:36:18.916068
174	2	8	10	frappe	9	[38, 12, 34, 27, 47, 36, 39, 29, 41, 31]	9	10	2025-12-11 08:36:31.815996	2025-12-11 08:37:36.562481
175	2	8	10	frappe	10	[21, 40, 49, 35, 15, 46, 24, 45, 26, 17]	7	10	2025-12-11 08:37:51.440939	2025-12-11 08:39:21.669123
177	2	12	10	frappe	3	[381, 313, 315, 357, 338, 297, 289, 329, 366, 326]	6	10	2026-01-03 15:36:01.693256	2026-01-03 15:37:08.078383
178	2	12	10	frappe	4	[328, 305, 330, 292, 339, 334, 375, 299, 295, 316]	7	10	2026-01-03 15:37:12.604284	2026-01-03 15:38:23.161455
179	2	12	10	frappe	5	[291, 312, 323, 327, 356, 363, 371, 294, 362, 322]	6	10	2026-01-03 15:38:27.501226	2026-01-03 15:39:39.21955
182	2	12	15	frappe	8	[381, 365, 282, 328, 317, 349, 356, 362, 296, 359, 379, 332, 299, 284, 375]	10	17	2026-01-07 16:26:34.821234	2026-01-07 16:28:22.727638
183	2	12	10	frappe	9	[294, 354, 369, 360, 312, 308, 364, 348, 331, 306]	5	10	2026-01-07 16:32:41.361032	2026-01-07 16:33:47.778472
184	2	35	10	frappe	1	[1367, 1380, 1386, 1368, 1376, 1371, 1387, 1372, 1381, 1383]	9	11	2026-01-13 14:24:10.414444	2026-01-13 14:31:54.783578
185	2	35	10	frappe	1	[1370, 1376, 1369, 1383, 1388, 1372, 1368, 1375, 1387, 1373]	9	11	2026-02-01 15:14:43.065811	2026-02-01 15:16:28.177269
187	2	28	10	frappe	1	[1058, 1048, 1036, 1087, 1147, 1086, 1137, 1063, 1081, 1139]	8	10	2026-02-01 15:20:09.202555	2026-02-01 15:21:20.090669
188	2	28	15	frappe	1	[1051, 1095, 1093, 1037, 1105, 1116, 1038, 1138, 1106, 1114, 1065, 1140, 1128, 1108, 1082]	13	15	2026-02-01 15:21:28.319713	2026-02-01 15:23:09.025916
196	2	28	10	frappe	1	[1142, 1056, 1097, 1131, 1107, 1057, 1149, 1094, 1041, 1079]	7	10	2026-02-01 15:34:11.994579	2026-02-01 15:35:14.450816
198	2	28	10	frappe	1	[1043, 1110, 1068, 1050, 1104, 1119, 1049, 1090, 1088, 1065]	6	10	2026-02-01 15:37:47.728337	2026-02-01 15:39:21.669129
199	2	41	32	frappe	1	[1850, 1828, 1906, 1911, 1896, 1890, 1884, 1845, 1888, 1898, 1851, 1862, 1904, 1840, 1925, 1827, 1894, 1864, 1934, 1910, 1879, 1929, 1874, 1893, 1846, 1867, 1838, 1912, 1831, 1921, 1889, 1924]	14	33	2026-02-13 08:05:43.912138	2026-02-13 08:09:51.149561
\.


--
-- Data for Name: user_audio; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_audio (audio_pk, user_pk, card_pk, filename, audio_url, duration, quality_score, notes, created_at) FROM stdin;
\.


--
-- Data for Name: user_decks; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_decks (user_deck_pk, user_pk, deck_pk, correct_count, attempt_count, cards_mastered, added_at, last_studied, mastered_cards, learning_cards, review_cards, total_points, total_attempts, successful_attempts, points_frappe, points_association, points_qcm, points_classique) FROM stdin;
45	2	57	0	0	0	2026-02-22 10:07:37.211545	\N	0	0	0	0	0	0	0	0	0	0
46	2	60	0	0	0	2026-02-23 15:24:46.984992	\N	0	0	0	0	0	0	0	0	0	0
5	2	10	0	0	0	2025-12-03 13:39:06.460835	\N	0	0	0	0	0	0	0	0	0	0
25	2	22	0	0	0	2025-12-08 16:19:33.51513	\N	0	0	0	0	0	0	0	0	0	0
36	2	36	0	0	0	2026-01-20 14:47:33.61903	\N	0	0	0	0	0	0	0	0	0	0
37	2	37	0	0	0	2026-01-21 14:49:12.210539	\N	0	0	0	0	0	0	0	0	0	0
3	2	8	58	94	0	2025-12-03 13:27:36.05682	2025-12-11 08:40:39.364475	1	30	9	580	94	58	0	0	0	0
38	2	38	0	0	0	2026-01-25 06:43:34.39397	\N	0	0	0	0	0	0	0	0	0	0
39	2	39	0	0	0	2026-01-30 16:22:45.820479	\N	0	0	0	0	0	0	0	0	0	0
40	2	40	0	0	0	2026-01-31 15:16:10.436046	\N	0	0	0	0	0	0	0	0	0	0
16	2	13	0	0	0	2025-12-06 14:15:17.18574	\N	0	0	0	0	0	0	0	0	0	0
47	2	61	0	0	0	2026-02-24 14:53:53.559741	\N	0	0	0	0	0	0	0	0	0	0
48	2	62	0	0	0	2026-02-24 15:24:08.99905	\N	0	0	0	0	0	0	0	0	0	0
23	2	20	39	75	0	2025-12-07 06:30:29.241034	2025-12-11 08:31:12.495924	0	0	0	390	75	39	0	0	0	0
49	2	63	0	0	0	2026-02-24 15:43:35.934678	\N	0	0	0	0	0	0	0	0	0	0
14	17	10	0	0	0	2025-12-05 15:22:27.19808	2025-12-05 15:22:28.743682	0	0	0	0	0	0	0	0	0	0
51	2	65	0	0	0	2026-03-30 13:19:16.179059	\N	0	0	0	0	0	0	0	0	0	0
18	18	10	53	81	0	2025-12-06 15:47:38.611982	2025-12-06 16:01:46.569472	0	0	0	520	81	53	0	0	0	0
20	2	17	0	0	0	2025-12-07 06:08:17.045691	\N	0	0	0	0	0	0	0	0	0	0
21	2	18	0	0	0	2025-12-07 06:20:14.924947	\N	0	0	0	0	0	0	0	0	0	0
22	2	19	0	0	0	2025-12-07 06:26:26.613561	\N	0	0	0	0	0	0	0	0	0	0
26	2	23	67	96	0	2025-12-10 08:41:02.797833	2025-12-11 08:34:53.335687	0	0	0	730	96	67	0	0	0	0
41	2	28	89	126	0	2026-02-01 15:20:20.847433	2026-02-01 15:39:21.671658	0	0	0	880	126	89	0	0	0	0
7	12	10	114	160	0	2025-12-05 14:07:42.792888	2025-12-05 14:08:38.172068	0	0	0	1140	160	114	0	0	0	0
8	13	10	253	319	0	2025-12-05 14:22:42.412667	2025-12-05 14:24:47.141933	0	0	0	2530	319	253	0	0	0	0
9	14	10	106	145	0	2025-12-05 14:30:44.912899	2025-12-05 14:30:45.73078	0	0	0	1060	145	106	0	0	0	0
10	15	8	169	215	0	2025-12-05 14:37:15.548955	2025-12-05 14:37:17.053897	0	0	0	1690	215	169	0	0	0	0
11	16	8	184	227	0	2025-12-05 14:42:18.881784	2025-12-05 14:43:51.942649	0	0	0	1840	227	184	0	0	0	0
12	16	10	403	510	0	2025-12-05 14:42:18.889293	2025-12-05 14:43:51.974163	0	0	0	4030	510	403	0	0	0	0
13	17	8	12	14	0	2025-12-05 15:22:27.179358	2025-12-05 16:03:52.507642	0	0	0	120	14	12	0	0	0	0
35	2	35	39	43	0	2026-01-12 13:19:39.910148	2026-02-01 15:19:36.553956	0	0	0	290	43	39	0	0	0	0
15	2	12	136	234	0	2025-12-06 14:05:00.676856	2026-01-07 16:33:47.781965	0	0	0	1360	234	136	0	0	0	0
30	2	30	0	0	0	2026-01-09 16:09:40.165874	\N	0	0	0	0	0	0	0	0	0	0
31	2	31	0	0	0	2026-01-11 15:36:24.629387	\N	0	0	0	0	0	0	0	0	0	0
32	2	32	0	0	0	2026-01-12 12:48:44.205086	\N	0	0	0	0	0	0	0	0	0	0
27	2	24	0	0	0	2025-12-10 15:38:34.159872	\N	0	0	0	0	0	0	0	0	0	0
4	2	9	25	30	0	2025-12-03 13:33:08.942275	2025-12-07 07:06:22.940244	0	0	0	250	30	25	0	0	0	0
42	2	41	19	44	0	2026-02-06 15:38:15.810953	2026-02-14 15:54:22.553121	0	0	0	190	44	19	0	0	0	0
\.


--
-- Data for Name: user_scores; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.user_scores (score_pk, user_pk, deck_pk, card_pk, score, is_correct, time_spent, created_at, quiz_type) FROM stdin;
\.


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

COPY public.users (user_pk, email, username, hashed_password, google_id, google_email, google_picture, first_name, last_name, profile_picture, bio, is_active, is_verified, verification_token, total_score, total_cards_learned, total_cards_reviewed, created_at, updated_at, last_login) FROM stdin;
1	uvicon@gmail.com	uvicon	$2b$12$Q911XwzjE1prFvVkTsS4YOt4ctJpt6y76qhjOfS4j/dm41sCDgaFO	\N	\N	\N	uvicorn		\N	\N	t	f	\N	0	0	0	2025-12-02 14:20:07.326841	2025-12-02 14:20:07.344562	2025-12-02 14:20:07.344133
13	quiz_realistic_test@example.com	quiz_realistic_tester	$2b$12$yw2h1.a7YEcYknU9yRDhOus2hU.bObKaOqWQiHB.sFZPvYiOvaVOO	\N	\N	\N	Quiz	Realistic	\N	\N	t	f	\N	0	0	0	2025-12-05 14:22:42.339001	2025-12-05 14:22:42.339011	\N
14	quiz_ultimate_test@example.com	quiz_ultimate_tester	$2b$12$nZmTTu/Yfot5oTJaRRTVnu.v9PM.zloe8OfuYYvT/lxFEdx3h6tXm	\N	\N	\N	Quiz	Ultimate	\N	\N	t	f	\N	0	0	0	2025-12-05 14:30:44.861682	2025-12-05 14:30:44.861688	\N
3	rindra@gmail.com	rindra	$2b$12$O/FoXRENXRZxSxDr4S.VeuaKdFvcD3to3ekPo9NvdhUYyVf4wK5TK	\N	\N	\N	rindra		\N	\N	t	f	\N	0	0	0	2025-12-03 08:30:27.652392	2025-12-03 08:30:27.671205	2025-12-03 08:30:27.669725
15	quiz_deck8_test@example.com	quiz_deck8_tester	$2b$12$PdLv.zTjpvuz4sq9zMSXnOtQE0INR5GmmuBUtHIJcmtY608Y850vC	\N	\N	\N	Deck8	Tester	\N	\N	t	f	\N	0	0	0	2025-12-05 14:37:15.501879	2025-12-05 14:37:15.501885	\N
16	quiz_marathon_test@example.com	quiz_marathon_tester	$2b$12$khObn8UrzQ1EhGAuqI9Z3Ovy3bHKzQwOuhMSnEq0ql0xwzBKtdoka	\N	\N	\N	Marathon	Tester	\N	\N	t	f	\N	0	0	0	2025-12-05 14:42:18.842558	2025-12-05 14:42:18.842564	\N
4	test_user_szbTobotwB@example.com	test_user_szbTobotwB	$2b$12$o.fLF5dtJ0umhOuATIZuzOwbXKXFnzqGmVZY3I2wrHjx/5b.r.e7a	\N	\N	\N	Test	User	\N	\N	t	f	\N	0	0	0	2025-12-03 12:46:51.128318	2025-12-03 12:46:51.451105	2025-12-03 12:46:51.450513
17	quiz_marathon_enhanced@example.com	marathon_enhanced	$2b$12$7EIiDDJhl74TUPt.0r0OyeE62pA45BNdXj2NBLejJTbbJU89LgIYW	\N	\N	\N	Marathon	Enhanced	\N	\N	t	f	\N	0	0	0	2025-12-05 15:22:27.132071	2025-12-05 15:22:27.132077	\N
5	test_user_GV8KRQ7pvX@example.com	test_user_GV8KRQ7pvX	$2b$12$NOa0Xs3c5M3AvzzvixooKuOU54MUR/RRPcNOwm0FvyMWJILZTOS5i	\N	\N	\N	Test	User	\N	\N	t	f	\N	0	0	0	2025-12-03 12:48:31.141327	2025-12-03 12:48:31.450729	2025-12-03 12:48:31.449979
6	test_user_CBCU46WgY6@example.com	test_user_CBCU46WgY6	$2b$12$fX9em4oi7x4SL.07YbPoNubc.xqZFjcagCeE.i6S5wQ3LBros1wVa	\N	\N	\N	Test	User	\N	\N	t	f	\N	0	0	0	2025-12-03 12:49:04.744927	2025-12-03 12:49:05.054442	2025-12-03 12:49:05.053898
7	test_user_Ak1zatEhqT@example.com	test_user_Ak1zatEhqT	$2b$12$YG8Y3PIcZ4ELetKaTYqv4ORk7Bqr9Wa47s0iyaDaLi9Cu8l10NJfG	\N	\N	\N	Test	User	\N	\N	t	f	\N	0	0	0	2025-12-03 12:50:27.32393	2025-12-03 12:50:27.63335	2025-12-03 12:50:27.632781
8	test_user_LRU5rjcALe@example.com	test_user_LRU5rjcALe	$2b$12$jPoR.ixQGdYc3q7C55EqaeCfGSv4eeaO43iGHoVs1PO1K/FGUvgwu	\N	\N	\N	Test	User	\N	\N	t	f	\N	0	0	0	2025-12-03 12:58:17.888475	2025-12-03 12:58:18.218533	2025-12-03 12:58:18.217989
9	test_user_7SARhcQCqX@example.com	test_user_7SARhcQCqX	$2b$12$y5AcxI.J6cHUNzD5375Hg.rzhqOn.rPEypbw0/1UV/Fu0PVK.NJb6	\N	\N	\N	Test	User	\N	\N	t	f	\N	0	0	0	2025-12-03 13:00:39.898457	2025-12-03 13:00:40.214476	2025-12-03 13:00:40.213731
2	jean@gmail.com	jean	$2b$12$ECs0YpqYfSleMuoeu/HuvegjipGYgMeuBxVjiQGSATnaPFLAkRPzO	\N	\N	\N	jean		\N	\N	t	f	\N	0	0	32	2025-12-02 15:49:15.717636	2026-03-30 13:16:58.997998	2026-03-30 13:16:58.995931
10	test_quiz@example.com	test_quiz_user	$2b$12$vawDIGOVYhCufeuqPLK41uW6lCQ9gc0J65iYi50kd6ZreWdOOQKo.	\N	\N	\N	Test	Quiz	\N	\N	t	f	\N	0	0	0	2025-12-04 08:48:54.015403	2025-12-04 08:48:54.015414	\N
11	quizuser@example.com	quizuser	$2b$12$yIQ/RGKkCBVXUMlBzQ1xDuOXKuiIiXCen7sVeiOLSpsfVIWHbSHZu	\N	\N	\N	Quiz	User	\N	\N	t	f	\N	0	0	0	2025-12-04 14:10:10.61172	2025-12-10 13:41:07.221575	2025-12-10 13:41:07.219605
18	ava@gmail.com	ava	$2b$12$PzlhLqb7fxWVTGvjk5.cj.UfHZcz3fnJA27rAtsNrEwfghRjBHWn2	\N	\N	\N	ava		\N	\N	t	f	\N	0	0	0	2025-12-06 15:45:01.29272	2025-12-06 15:45:01.376555	2025-12-06 15:45:01.375073
12	quiz_flex_test@example.com	quiz_flex_tester	$2b$12$8UE.bnP2x2fH3/s7F5rSeOcX8EGmVM67ZxGfC5QOM/fk1MuFZB4Um	\N	\N	\N	Quiz	Flexible	\N	\N	t	f	\N	0	0	0	2025-12-05 14:07:42.738034	2025-12-05 14:07:42.738039	\N
\.


--
-- Name: audio_items_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.audio_items_id_seq', 22, true);


--
-- Name: card_performance_performance_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.card_performance_performance_pk_seq', 1688, true);


--
-- Name: cards_card_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.cards_card_pk_seq', 2625, true);


--
-- Name: decks_deck_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.decks_deck_pk_seq', 65, true);


--
-- Name: definition_cache_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.definition_cache_id_seq', 651, true);


--
-- Name: quiz_sessions_session_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.quiz_sessions_session_pk_seq', 200, true);


--
-- Name: user_audio_audio_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_audio_audio_pk_seq', 1, false);


--
-- Name: user_decks_user_deck_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_decks_user_deck_pk_seq', 51, true);


--
-- Name: user_scores_score_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.user_scores_score_pk_seq', 32, true);


--
-- Name: users_user_pk_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_user_pk_seq', 18, true);


--
-- Name: alembic_version alembic_version_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.alembic_version
    ADD CONSTRAINT alembic_version_pkey PRIMARY KEY (version_num);


--
-- Name: audio_items audio_items_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audio_items
    ADD CONSTRAINT audio_items_pkey PRIMARY KEY (id);


--
-- Name: card_performance card_performance_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_performance
    ADD CONSTRAINT card_performance_pkey PRIMARY KEY (performance_pk);


--
-- Name: cards cards_id_json_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_id_json_key UNIQUE (id_json);


--
-- Name: cards cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_pkey PRIMARY KEY (card_pk);


--
-- Name: deck_cards deck_cards_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_cards
    ADD CONSTRAINT deck_cards_pkey PRIMARY KEY (deck_pk, card_pk);


--
-- Name: decks decks_id_json_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_id_json_key UNIQUE (id_json);


--
-- Name: decks decks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.decks
    ADD CONSTRAINT decks_pkey PRIMARY KEY (deck_pk);


--
-- Name: definition_cache definition_cache_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.definition_cache
    ADD CONSTRAINT definition_cache_pkey PRIMARY KEY (id);


--
-- Name: quiz_sessions quiz_sessions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_pkey PRIMARY KEY (session_pk);


--
-- Name: user_audio user_audio_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_audio
    ADD CONSTRAINT user_audio_pkey PRIMARY KEY (audio_pk);


--
-- Name: user_decks user_decks_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_decks
    ADD CONSTRAINT user_decks_pkey PRIMARY KEY (user_deck_pk);


--
-- Name: user_scores user_scores_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_scores
    ADD CONSTRAINT user_scores_pkey PRIMARY KEY (score_pk);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (user_pk);


--
-- Name: ix_card_performance_card_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_card_performance_card_pk ON public.card_performance USING btree (card_pk);


--
-- Name: ix_card_performance_deck_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_card_performance_deck_pk ON public.card_performance USING btree (deck_pk);


--
-- Name: ix_card_performance_performance_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_card_performance_performance_pk ON public.card_performance USING btree (performance_pk);


--
-- Name: ix_card_performance_user_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_card_performance_user_pk ON public.card_performance USING btree (user_pk);


--
-- Name: ix_definition_cache_term; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_definition_cache_term ON public.definition_cache USING btree (term);


--
-- Name: ix_quiz_sessions_deck_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quiz_sessions_deck_pk ON public.quiz_sessions USING btree (deck_pk);


--
-- Name: ix_quiz_sessions_session_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quiz_sessions_session_pk ON public.quiz_sessions USING btree (session_pk);


--
-- Name: ix_quiz_sessions_user_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_quiz_sessions_user_pk ON public.quiz_sessions USING btree (user_pk);


--
-- Name: ix_user_audio_audio_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_audio_audio_pk ON public.user_audio USING btree (audio_pk);


--
-- Name: ix_user_audio_card_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_audio_card_pk ON public.user_audio USING btree (card_pk);


--
-- Name: ix_user_audio_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_audio_created_at ON public.user_audio USING btree (created_at);


--
-- Name: ix_user_audio_user_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_audio_user_pk ON public.user_audio USING btree (user_pk);


--
-- Name: ix_user_decks_deck_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_decks_deck_pk ON public.user_decks USING btree (deck_pk);


--
-- Name: ix_user_decks_user_deck_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_decks_user_deck_pk ON public.user_decks USING btree (user_deck_pk);


--
-- Name: ix_user_decks_user_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_decks_user_pk ON public.user_decks USING btree (user_pk);


--
-- Name: ix_user_scores_card_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_scores_card_pk ON public.user_scores USING btree (card_pk);


--
-- Name: ix_user_scores_created_at; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_scores_created_at ON public.user_scores USING btree (created_at);


--
-- Name: ix_user_scores_deck_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_scores_deck_pk ON public.user_scores USING btree (deck_pk);


--
-- Name: ix_user_scores_score_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_scores_score_pk ON public.user_scores USING btree (score_pk);


--
-- Name: ix_user_scores_user_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_user_scores_user_pk ON public.user_scores USING btree (user_pk);


--
-- Name: ix_users_email; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_email ON public.users USING btree (email);


--
-- Name: ix_users_google_id; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_google_id ON public.users USING btree (google_id);


--
-- Name: ix_users_is_active; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_is_active ON public.users USING btree (is_active);


--
-- Name: ix_users_user_pk; Type: INDEX; Schema: public; Owner: -
--

CREATE INDEX ix_users_user_pk ON public.users USING btree (user_pk);


--
-- Name: ix_users_username; Type: INDEX; Schema: public; Owner: -
--

CREATE UNIQUE INDEX ix_users_username ON public.users USING btree (username);


--
-- Name: audio_items audio_items_user_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.audio_items
    ADD CONSTRAINT audio_items_user_pk_fkey FOREIGN KEY (user_pk) REFERENCES public.users(user_pk) ON DELETE CASCADE;


--
-- Name: card_performance card_performance_card_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_performance
    ADD CONSTRAINT card_performance_card_pk_fkey FOREIGN KEY (card_pk) REFERENCES public.cards(card_pk) ON DELETE CASCADE;


--
-- Name: card_performance card_performance_deck_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_performance
    ADD CONSTRAINT card_performance_deck_pk_fkey FOREIGN KEY (deck_pk) REFERENCES public.decks(deck_pk) ON DELETE CASCADE;


--
-- Name: card_performance card_performance_user_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.card_performance
    ADD CONSTRAINT card_performance_user_pk_fkey FOREIGN KEY (user_pk) REFERENCES public.users(user_pk) ON DELETE CASCADE;


--
-- Name: cards cards_deck_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.cards
    ADD CONSTRAINT cards_deck_pk_fkey FOREIGN KEY (deck_pk) REFERENCES public.decks(deck_pk) ON DELETE CASCADE;


--
-- Name: deck_cards deck_cards_card_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_cards
    ADD CONSTRAINT deck_cards_card_pk_fkey FOREIGN KEY (card_pk) REFERENCES public.cards(card_pk) ON DELETE CASCADE;


--
-- Name: deck_cards deck_cards_deck_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.deck_cards
    ADD CONSTRAINT deck_cards_deck_pk_fkey FOREIGN KEY (deck_pk) REFERENCES public.decks(deck_pk) ON DELETE CASCADE;


--
-- Name: quiz_sessions quiz_sessions_deck_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_deck_pk_fkey FOREIGN KEY (deck_pk) REFERENCES public.decks(deck_pk) ON DELETE CASCADE;


--
-- Name: quiz_sessions quiz_sessions_user_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.quiz_sessions
    ADD CONSTRAINT quiz_sessions_user_pk_fkey FOREIGN KEY (user_pk) REFERENCES public.users(user_pk) ON DELETE CASCADE;


--
-- Name: user_audio user_audio_card_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_audio
    ADD CONSTRAINT user_audio_card_pk_fkey FOREIGN KEY (card_pk) REFERENCES public.cards(card_pk) ON DELETE CASCADE;


--
-- Name: user_audio user_audio_user_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_audio
    ADD CONSTRAINT user_audio_user_pk_fkey FOREIGN KEY (user_pk) REFERENCES public.users(user_pk) ON DELETE CASCADE;


--
-- Name: user_decks user_decks_deck_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_decks
    ADD CONSTRAINT user_decks_deck_pk_fkey FOREIGN KEY (deck_pk) REFERENCES public.decks(deck_pk) ON DELETE CASCADE;


--
-- Name: user_decks user_decks_user_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_decks
    ADD CONSTRAINT user_decks_user_pk_fkey FOREIGN KEY (user_pk) REFERENCES public.users(user_pk) ON DELETE CASCADE;


--
-- Name: user_scores user_scores_card_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_scores
    ADD CONSTRAINT user_scores_card_pk_fkey FOREIGN KEY (card_pk) REFERENCES public.cards(card_pk) ON DELETE CASCADE;


--
-- Name: user_scores user_scores_deck_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_scores
    ADD CONSTRAINT user_scores_deck_pk_fkey FOREIGN KEY (deck_pk) REFERENCES public.decks(deck_pk) ON DELETE CASCADE;


--
-- Name: user_scores user_scores_user_pk_fkey; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.user_scores
    ADD CONSTRAINT user_scores_user_pk_fkey FOREIGN KEY (user_pk) REFERENCES public.users(user_pk) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict TPaaHppuITgaSsnTgkAQGPvFsb1kcVhHA4KevFtG9LOskTXgaFhNycX4S5I66HK

