CREATE SCHEMA IF NOT EXISTS content;

CREATE TABLE IF NOT EXISTS content.person (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(), 
	full_name varchar(100),
	created date default current_date,
	modified timestamp with time zone default current_timestamp
);

CREATE TABLE IF NOT EXISTS content.genre (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	name varchar(100),
	description text,
	created date default current_date,
	modified timestamp with time zone default current_timestamp
);

CREATE TABLE IF NOT EXISTS content.film_work (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	title varchar(100),
	description text,
	creation_date date,
	rating float,
	type varchar(100),
	created date default current_date,
	modified timestamp with time zone default current_timestamp
);

CREATE TABLE IF NOT EXISTS content.person_film_work (
	id uuid PRIMARY KEY DEFAULT gen_random_uuid(),
	person_id uuid,
	film_work_id uuid,
	role varchar(100),
	created date default current_date,
	constraint fk_person foreign key (person_id) references content.person(id),
	constraint fk_film_work foreign key (film_work_id) references content.film_work(id)
);

CREATE TABLE IF NOT EXISTS content.genre_film_work(
	id uuid primary key default gen_random_uuid(),
	genre_id uuid,
	film_work_id uuid,
	created date default current_date,
	constraint fk_genre foreign key (genre_id) references content.genre(id),
	constraint fk_film_work foreign key (film_work_id) references content.film_work(id)
);

CREATE INDEX film_work_creation_date_idx ON content.film_work(creation_date);

CREATE INDEX genre_film_work_film_work_id_idx ON content.genre_film_work(film_work_id);

CREATE INDEX person_film_work_film_work_id_idx ON content.person_film_work(film_work_id);