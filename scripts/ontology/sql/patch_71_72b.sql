-- Adding alt_id table, contains alternative ids for a given term --

CREATE TABLE alt_id (
  alt_id        INT UNSIGNED NOT NULL AUTO_INCREMENT,
  term_id       INT UNSIGNED NOT NULL,
  accession     VARCHAR(64) NOT NULL,

  PRIMARY KEY (alt_id),
  UNIQUE INDEX term_alt_idx (term_id, alt_id),
  INDEX accession_idx (accession(50))
);


