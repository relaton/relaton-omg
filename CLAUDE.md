# CLAUDE.md

This file provides guidance to Claude Code (claude.ai/code) when working with code in this repository.

## Project Overview

relaton-omg is a Ruby gem that searches and fetches standards from The Object Management Group (OMG) at https://www.omg.org. It is part of the larger Relaton family of bibliographic data gems (v2.0.0-alpha.1).

## Commands

- **Run all tests:** `bundle exec rspec`
- **Run a single test:** `bundle exec rspec spec/relaton/omg/item_spec.rb`
- **Lint:** `bundle exec rubocop` (follows Ribose OSS style guide)
- **Lint with autofix:** `bundle exec rubocop -a`
- **Install deps:** `bundle install`

## Architecture

### Module structure

All source lives under `lib/relaton/omg/`. The main entry point is `lib/relaton/omg.rb` which loads everything under the `Relaton::Omg` module namespace.

### Class hierarchy

The gem extends `relaton-bib` (~> 2.0.0-alpha.1), the core Relaton bibliographic data library:

- `Relaton::Omg::Item` < `Bib::Item` — base item class, uses `Omg::ItemData` model (subclass of `Bib::ItemData`)
- `Relaton::Omg::Ext` < `Bib::Ext` — overrides `get_schema_version` to return the OMG model version
- `Relaton::Omg::Bibitem` < `Item` — includes `Bib::BibitemShared`, for `<bibitem>` XML
- `Relaton::Omg::Bibdata` < `Item` — includes `Bib::BibdataShared`, for `<bibdata>` XML
- `Relaton::Omg::Processor` < `Core::Processor` — relaton-core integration, delegates to `Bibliography`, `Bibitem`, `Item`
- `Relaton::Omg::Bibliography` — fetches standards via `Scraper`
- `Relaton::Omg::Scraper` — scrapes https://www.omg.org/spec for bibliographic data

### Serialization formats

Items can be serialized to/from YAML and XML. Tests verify round-trip fidelity for all three classes. XML output is validated against RELAX NG schemas in `grammars/`.

### Test patterns

- RSpec with `expect` syntax (monkey patching disabled)
- `equivalent-xml` for XML comparison
- `ruby-jing` for RELAX NG schema validation against `grammars/relaton-omg-compile.rng`
- VCR cassettes in `spec/vcr_cassettes/` for HTTP interaction recording
- Fixtures in `spec/fixtures/` (YAML and XML reference files)
- Tests follow a round-trip pattern: load fixture → parse → serialize → compare to fixture

## Style

- Ruby >= 3.1.0
- Rubocop inherits from Ribose OSS guide with `rubocop-rails` required but Rails cops disabled
- OMG document reference format: `OMG {ACRONYM} {VERSION}` (e.g., `OMG AMI4CCM 1.0`)
