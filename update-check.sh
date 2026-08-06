#!/usr/bin/env bash

# Poor-man's update checker. Sourced by phpcs/phpcw; expects MYCWD to point to the installation directory.
# Checks at most once per week. Disable entirely with PHPCW_NO_UPDATE_CHECK=1.

phpcw_update_check() {
	local REPO_URL="https://github.com/rmpel/wordpress-coding-standards-global-cli-tool.git"
	local CHECK_INTERVAL=$((7 * 24 * 3600))
	local STATE_FILE="${MYCWD}/.update-check-state"
	local NOW LAST_CHECK LAST_SEEN REMOTE_HASH REPLY

	[ "1" = "$PHPCW_NO_UPDATE_CHECK" ] && return 0

	NOW=$(date +%s)
	LAST_CHECK=$(grep '^last_check=' "$STATE_FILE" 2>/dev/null | cut -d= -f2)
	case "$LAST_CHECK" in ''|*[!0-9]*) LAST_CHECK=0 ;; esac
	[ $((NOW - LAST_CHECK)) -lt $CHECK_INTERVAL ] && return 0

	LAST_SEEN=$(grep '^remote_hash=' "$STATE_FILE" 2>/dev/null | cut -d= -f2)

	if [ -d "${MYCWD}/.git" ]; then
		phpcw_update_check_git
	else
		phpcw_update_check_nongit
	fi
	# Keep the previous baseline if this check could not reach the remote.
	[ -z "$REMOTE_HASH" ] && REMOTE_HASH="$LAST_SEEN"
	printf 'last_check=%s\nremote_hash=%s\n' "$NOW" "$REMOTE_HASH" > "$STATE_FILE" 2>/dev/null
}

# Prompt on the terminal; returns 0 on yes. Never prompts (returns 1) when there is no terminal.
phpcw_update_ask() {
	local REPLY
	[ -t 1 ] && [ -e /dev/tty ] || return 1
	read -r -p "$1 [y/N] " REPLY < /dev/tty
	[ "y" = "$REPLY" ] || [ "Y" = "$REPLY" ]
}

phpcw_update_check_git() {
	local LOCAL LOCKSUM
	GIT_TERMINAL_PROMPT=0 git -C "$MYCWD" fetch --quiet 2>/dev/null || return 0
	LOCAL=$(git -C "$MYCWD" rev-parse HEAD 2>/dev/null)
	REMOTE_HASH=$(git -C "$MYCWD" rev-parse '@{u}' 2>/dev/null)
	[ -z "$LOCAL" ] || [ -z "$REMOTE_HASH" ] || [ "$LOCAL" = "$REMOTE_HASH" ] && return 0
	# Only offer a pull when we are strictly behind; ahead or diverged is up to the user.
	git -C "$MYCWD" merge-base --is-ancestor "$LOCAL" "$REMOTE_HASH" 2>/dev/null || return 0

	{
		echo ""
		echo "phpcw: an update is available:"
		git -C "$MYCWD" log --oneline "${LOCAL}..${REMOTE_HASH}" | sed 's/^/  /'
	} >&2
	if phpcw_update_ask "phpcw: pull the update now?"; then
		LOCKSUM=$(cksum "${MYCWD}/composer.lock" 2>/dev/null)
		if git -C "$MYCWD" pull --ff-only --quiet; then
			[ "$LOCKSUM" != "$(cksum "${MYCWD}/composer.lock" 2>/dev/null)" ] && (cd "$MYCWD" && composer install)
			echo "phpcw: updated." >&2
		else
			echo "phpcw: git pull failed; update manually in ${MYCWD}" >&2
		fi
	else
		echo "phpcw: skipped; update manually with: git -C \"${MYCWD}\" pull" >&2
	fi
}

phpcw_update_check_nongit() {
	# No .git folder (zip download / plain copy): we can still ask the remote what its
	# current HEAD is and compare it to the hash we saw last time.
	if command -v git >/dev/null 2>&1; then
		REMOTE_HASH=$(GIT_TERMINAL_PROMPT=0 git ls-remote "$REPO_URL" HEAD 2>/dev/null | cut -f1)
	elif command -v curl >/dev/null 2>&1; then
		REMOTE_HASH=$(curl -fsSL --max-time 5 "https://api.github.com/repos/rmpel/wordpress-coding-standards-global-cli-tool/commits/HEAD" 2>/dev/null | grep -m1 '"sha"' | cut -d'"' -f4)
	fi
	[ -z "$REMOTE_HASH" ] && return 0

	if [ -z "$LAST_SEEN" ]; then
		# First run: just record a baseline, and mention once how to get real updates.
		echo "phpcw: this copy was not installed with git, so it cannot update itself. Consider converting it to a git clone (you will be offered this when an update is published)." >&2
		return 0
	fi
	[ "$REMOTE_HASH" = "$LAST_SEEN" ] && return 0

	{
		echo ""
		echo "phpcw: a new version has been published on ${REPO_URL}"
		echo "phpcw: this copy was not installed with git, so it cannot be updated automatically."
	} >&2
	if command -v git >/dev/null 2>&1 && phpcw_update_ask "phpcw: convert this installation to a git clone and update now? (local modifications to the tool will be LOST)"; then
		if git -C "$MYCWD" init --quiet &&
			git -C "$MYCWD" remote add origin "$REPO_URL" &&
			git -C "$MYCWD" fetch --quiet origin &&
			git -C "$MYCWD" checkout --force -B master origin/master; then
			(cd "$MYCWD" && composer install)
			echo "phpcw: converted to a git clone and updated. Future updates will be a simple git pull." >&2
		else
			echo "phpcw: conversion failed. Re-download manually from ${REPO_URL}" >&2
		fi
	else
		echo "phpcw: to update, re-download from ${REPO_URL} or reinstall with: git clone ${REPO_URL}" >&2
	fi
}
