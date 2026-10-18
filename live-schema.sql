-- D1-schema för klarsprak, läst från sqlite_master 2026-10-16. Endast struktur, ingen data.

CREATE TABLE "d1_migrations"(
		id         INTEGER PRIMARY KEY AUTOINCREMENT,
		name       TEXT UNIQUE,
		applied_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE published_terms (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  submission_id INTEGER UNIQUE,
  term TEXT NOT NULL,
  rattsomrade TEXT NOT NULL DEFAULT 'Annat',
  allmansprak TEXT NOT NULL,
  sprak_kalla_namn TEXT NOT NULL,
  sprak_kalla_url TEXT NOT NULL,
  institution TEXT NOT NULL,
  institution_kalla_namn TEXT NOT NULL,
  institution_kalla_url TEXT NOT NULL,
  skillnad TEXT NOT NULL,
  notering TEXT,
  status TEXT NOT NULL DEFAULT 'published' CHECK (status IN ('published', 'archived')),
  published_at TEXT NOT NULL DEFAULT (datetime('now')),
  updated_at TEXT NOT NULL DEFAULT (datetime('now')),
  FOREIGN KEY (submission_id) REFERENCES submissions(id) ON DELETE SET NULL
);

CREATE TABLE submissions (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  term TEXT NOT NULL,
  foreslagen_juridisk_definition TEXT,
  foreslagen_vardagsbetydelse TEXT,
  foreslagen_exempel TEXT,
  inskickare_namn TEXT,
  inskickare_kommentar TEXT,
  status TEXT NOT NULL DEFAULT 'pending' CHECK (status IN ('pending', 'approved', 'rejected')),
  created_at TEXT NOT NULL DEFAULT (datetime('now')),
  reviewed_at TEXT,
  reviewer_note TEXT
, submitter_ip TEXT, foreslaget_rattsomrade TEXT);

CREATE UNIQUE INDEX idx_published_terms_normalized_term
  ON published_terms(LOWER(TRIM(term)));

CREATE INDEX idx_published_terms_status_term
  ON published_terms(status, LOWER(term));

CREATE INDEX idx_submissions_ip_created ON submissions(submitter_ip, created_at);

CREATE INDEX idx_submissions_status ON submissions(status);
