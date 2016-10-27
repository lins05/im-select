# What is this?

A replacement for fcitx-remote.el with Emacs dynamic modules.

It is Mac-only for now and requires Emacs 25 and later.

# Installation

## Compile the module

```
git clone git@github.com:lins05/im-select.git
cd im-select
make
```

## Update your .emacs

```lisp
(setq load-path (cons "/path/to/im-select" load-path))
(module-load "/path/to/im-select/im-select-module.so")
(require 'im-select)
```
