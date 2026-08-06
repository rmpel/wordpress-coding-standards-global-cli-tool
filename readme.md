# WP (and PHP) Coding standards CLI tool

## How to install

* Clone this repo to a decent location.
* Include the path to this repo in your PATH, for example, add the following to your `.bashrc` or `.zshrc` file.

```
PATH="/path/to/this/repo:$PATH"
```

Alternatively, symlink the tools into a directory that is already in your PATH, for example `~/.local/bin`.
The scripts resolve symlinks to find their actual installation directory, so this works fine.

```
ln -s /path/to/this/repo/phpcw ~/.local/bin/phpcw
ln -s /path/to/this/repo/phpcwf ~/.local/bin/phpcwf
ln -s /path/to/this/repo/phpcs ~/.local/bin/phpcs
```

Note: only symlink `phpcs` if you don't have another `phpcs` installed that you want to keep using.

## How to use

* In the project you want to scan for WP (or PHP) coding standards, type `phpcw` (or `phpcs`) and watch the magic happen.
* Use `phpcw watch` (or `phpcs watch`) to keep a window on auto-refresh during your work
* You can use `phpcw fix` (or `phpcs fix`) to auto-fix the issues that can be automatically fixed.

## Updating

The tools check for updates once a week (a "poor-man's updater").

* Installed with `git clone`: when the remote has new commits, you will be shown the changes and offered to `git pull` right there. If `composer.lock` changed, `composer install` runs automatically after the pull.
* Installed without git (zip download, plain copy): there is no `.git` folder, so the tools can't tell exactly which version you have. Instead, they remember the remote HEAD commit they saw on the first check, and when a new version is published, you get notified and offered to convert the installation to a proper git clone in place (note: this overwrites any local modifications you made to the tool). After conversion, updates work via `git pull` like a normal git install.

The check is silent when nothing changed, at most weekly, and never prompts when not running in a terminal. To disable it completely:

```
export PHPCW_NO_UPDATE_CHECK=1
```

## PHP Compatibility

PHPCS and the WordPress coding standards are NOT compatible with PHP 8 or higher. You need PHP 7.4 for this to run.
If php 8.x is detected, the software will try to use 7.4, if installed.

## Related project

[Here is a .editorconfig file](https://gist.github.com/rmpel/a54ffc349ecdba57c5dd7f33b81263dd) that contains nearly everything you need for auto-formatting by WordPress coding standards. It contains rules for IntelliJ editors (phpStorm, webStorm) as well. Request to Visual Studio Code users; please augment this file with rules for VSCode by pull-request.

## Final note

This is experimental software that has only been proven to work on the computers of myself and two coworkers. If you have problems, try to fix them yourself and issue a pull-request.
If you cannot fix yourself, provide as much detail as possible and ask for help.
