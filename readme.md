# WP (and PHP) Coding standards CLI tool

## How to install

* Clone this repo to a decent location.
* Include the path to this repo in your PATH, for example, add the following to your `.bashrc` or `.zshrc` file.

```
PATH="/path/to/this/repo:$PATH"
```

## How to use

* In the project you want to scan for WP (or PHP) coding standards, type `phpcw` (or `phpcs`) and watch the magic happen.
* Use `phpcw watch` (or `phpcs watch`) to keep a window on auto-refresh during your work
* You can use `phpcw fix` (or `phpcs fix`) to auto-fix the issues that can be automatically fixed.

## PHP Compatibility

PHPCS and the WordPress coding standards are NOT compatible with PHP 8 or higher. You need PHP 7.4 for this to run.
If php 8.x is detected, the software will try to use 7.4, if installed.

## Final note

This is experimental software that has only been proven to work on the computers of myself and two coworkers. If you have problems, try to fix them yourself and issue a pull-request.
If you cannot fix yourself, provide as much detail as possible and ask for help.
