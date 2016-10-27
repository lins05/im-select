# What is this?

A replacement for [fcitx-remote](https://github.com/CodeFalling/fcitx-remote-for-osx) and [fcitx-remote.el](https://github.com/CodeFalling/fcitx-remote-for-osx) with Emacs dynamic modules, based on https://github.com/ybian/smartim

It is Mac-only for now, and requires Emacs 25 and later, since the dynamic modules feature is only avaiable in Emacs 25+.

# Installation

## Compile the Module

```
git clone git@github.com:lins05/im-select.git
cd im-select
make
```

## Update Your .emacs

```lisp
(setq load-path (cons "/path/to/im-select" load-path))
(module-load "/path/to/im-select/im-select-module.so")
(require 'im-select)
```

# About Emacs Dynamic Modules

It's a cool new feature added in Emacs 25. There is an [excellent tutorial](http://diobla.info/blog-archive/modules-tut.html) for it.
