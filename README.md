# mermaid-ts-mode.el

<a href="https://melpa.org/#/mermaid-ts-mode"><img alt="MELPA" src="https://melpa.org/packages/mermaid-ts-mode-badge.svg"/></a>

Major mode for working with [mermaid](http://mermaid.js.org). It's built on tree sitter, and thus requires Emacs 29 or better.

![](mermaid-ts-mode.png)

## Installation

You can install `mermaid-ts-mode` from [MELPA](https://melpa.org/#/mermaid-ts-mode).

Alternatively you can install it with straight:

``` elisp
(use-package mermaid-ts-mode
  :defer t
  :straight (:type git :host github :repo "JonathanHope/mermaid-ts-mode" :branch "main" :files ("mermaid-ts-mode.el")))
```

You will also need the following tree sitter grammar: <https://github.com/monaqa/tree-sitter-mermaid>.

## Features

- [x] Syntax highlighting
- [x] Indentation
- [ ] imenu

# Customize Variables

- **mermaid-ts-indent-level (default 2):** Indentation level

# Diagram Support

Mermaid is huge and not all of it is perfectly supported by this mode.

## Flowchart

Flowchart support should be pretty solid.

## Class Diagram

Some of the class diagram stuff isn't well supported by the treesitter grammar.

- [ ] class notes
- [ ] class labels
- [ ] namepace
- [ ] link
- [ ] click
- [ ] callback

For some reason class members with parntheses don't indent properly.

##  Sequence Diagram

A lot of sequence diagram stuff isn't well supported by the treesitter grammar.

- [ ] create/destroy
- [ ] box
- [ ] activate/deactivate
- [ ] loops
- [ ] alt
- [ ] parallel
- [ ] critical
- [ ] break
- [ ] rect

##  State Diagram

State diagram support should be pretty solid. Only one thing wasn't supported by treesitter grammar:

- [ ] note block

## Entity Relation Diagram

Entity Relation Diagram support should be pretty solid.

##  User Journey

User Journeys are not supported at this time by the treesitter grammar, or this mode.

##  Gantt

Gantt chart support should be pretty solid. Only a couple of things weren't supported by treesitter grammar:

- [ ] tick interval
- [ ] weekday

## Quadrant Chart

Quadrant charts are not supported at this time by the treesitter grammar, or this mode.

## Requirement Diagram

Requirement diagrams are not supported at this time by the treesitter grammar, or this mode.

## Gitgraph Diagrams

Gitgraph diagrams are not supported at this time by the treesitter grammar, or this mode.

## C4 Diagrams

C4 diagrams are not supported at this time by the treesitter grammar, or this mode.

## Mindmap Diagrams

Mindmap are not supported at this time by the treesitter grammar, or this mode.

## Timeline Diagrams

Timeline diagrams are not supported at this time by the treesitter grammar, or this mode.

## ZenUML

ZenUML not supported at this time by the treesitter grammar, or this mode.

## Sankey

Sankey diagrams are not supported at this time by the treesitter grammar, or this mode.
