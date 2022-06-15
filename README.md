# zsh-pg [![Build Status](https://travis-ci.org/caarlos0/zsh-pg.svg?branch=master)](https://travis-ci.org/caarlos0/zsh-pg)

A ZSH plugin with utility functions to work with PostgreSQL.

# Commands

- `pg create <name>`: create a database
- `pg drop <name>`: drop a database
- `pg ls`: list databases
- `pg cp <origin> <target>`: make a copy of a database
- `pg mv <origin> <target>`: rename a database
- `pg kill-connections <database>`: kill all connections to a database
- `pg dump-table <database> <table> > file.sql`: dump table data (in form of
inserts) into the `file.sql`

# Install

### Using antibody:

```sh
$ antibody bundle caarlos0/zsh-pg
```

### Using antigen:

```sh
$ antigen bundle caarlos0/zsh-pg
```

### Using Fig:


[Fig](https://fig.io) adds apps, shortcuts, and autocomplete to your existing terminal.

Install `zsh-pg` in just one click.

<a href="https://fig.io/plugins/zsh-pg_caarlos0-graveyard" target="_blank"><img src="https://fig.io/badges/install-with-fig.svg" /></a>

# Thanks to

- [original idea](https://github.com/juanibiapina/pg)
