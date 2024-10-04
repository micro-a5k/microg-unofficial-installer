#!/usr/bin/env bash

# SPDX-FileCopyrightText: (c) 2016 ale5000
# SPDX-License-Identifier: GPL-3.0-or-later
# shellcheck enable=all

if test "${A5K_FUNCTIONS_INCLUDED:-false}" = 'false'; then
  main()
  {
    local _newline _main_dir

    # Execute only if the first initialization has not already been done
    if test -z "${MAIN_DIR-}" || test -z "${USER_HOME-}"; then

      # Avoid picturesque bugs on Bash under Windows
      if test -e '/usr/bin' && test "$(/usr/bin/uname 2> /dev/null -o || :)" = 'Msys'; then PATH="/usr/bin:${PATH:-/usr/bin}"; fi

      if test -z "${MAIN_DIR-}"; then
        # shellcheck disable=SC3028 # Ignore: In POSIX sh, BASH_SOURCE is undefined.
        if test -n "${BASH_SOURCE-}" && MAIN_DIR="$(dirname "${BASH_SOURCE:?}")" && MAIN_DIR="$(realpath "${MAIN_DIR:?}")"; then
          export MAIN_DIR
        else
          unset MAIN_DIR
        fi
      fi

      if test -n "${MAIN_DIR-}" && test -z "${USER_HOME-}"; then
        if test "${TERM_PROGRAM-}" = 'mintty'; then unset TERM_PROGRAM; fi
        export USER_HOME="${HOME-}"
        export HOME="${MAIN_DIR:?}"
      fi

    fi

    export DO_INIT_CMDLINE=1
    unset STARTED_FROM_BATCH_FILE
    unset IS_PATH_INITIALIZED
    unset __QUOTED_PARAMS

    if test -n "${MAIN_DIR-}"; then _main_dir="${MAIN_DIR:?}"; else _main_dir='.'; fi

    if test "${PLATFORM-}" = 'win' && test "${IS_BUSYBOX-}" = 'true'; then
      exec ash -s -c ". '${_main_dir:?}/includes/common.sh' || exit \${?}" 'ash' "${@}"
    else
      get_shell_exe()
      {
        local _gse_shell_exe _gse_tmp_var

        if _gse_shell_exe="$(readlink 2> /dev/null "/proc/${$}/exe")" && test -n "${_gse_shell_exe?}"; then
          # On Linux / Android / Windows (on Windows only some shells support it)
          :
        elif _gse_tmp_var="$(ps 2> /dev/null -p "${$}" -o 'comm=')" && test -n "${_gse_tmp_var?}" && _gse_tmp_var="$(command 2> /dev/null -v "${_gse_tmp_var:?}")"; then
          # On Linux / macOS
          _gse_shell_exe="$(readlink 2> /dev/null -f "${_gse_tmp_var:?}" || realpath 2> /dev/null "${_gse_tmp_var:?}")" || _gse_shell_exe="${_gse_tmp_var:?}"
        elif _gse_tmp_var="${BASH:-${SHELL-}}" && test -n "${_gse_tmp_var?}"; then
          if test ! -e "${_gse_tmp_var:?}" && test -e "${_gse_tmp_var:?}.exe"; then _gse_tmp_var="${_gse_tmp_var:?}.exe"; fi # Special fix for broken versions of Bash under Windows
          _gse_shell_exe="$(readlink 2> /dev/null -f "${_gse_tmp_var:?}" || realpath 2> /dev/null "${_gse_tmp_var:?}")" || _gse_shell_exe="${_gse_tmp_var:?}"
          _gse_shell_exe="$(command 2> /dev/null -v "${_gse_shell_exe:?}")" || return 1
        else
          return 1
        fi

        printf '%s\n' "${_gse_shell_exe:?}"
      }

      if test "${#}" -gt 0; then
        _newline='
'

        case "${*}" in
          *"${_newline:?}"*)
            printf 'WARNING: Newline character found, parameters dropped\n'
            ;;
          *)
            __QUOTED_PARAMS="$(printf '%s\n' "${@}")"
            export __QUOTED_PARAMS
            ;;
        esac
      fi

      __SHELL_EXE="$(get_shell_exe)" || __SHELL_EXE='bash'
      export __SHELL_EXE

      exec "${__SHELL_EXE:?}" --init-file "${_main_dir:?}/includes/common.sh"
    fi
  }

  if test "${#}" -gt 0; then
    main "${@}"
  else
    main
  fi
fi
