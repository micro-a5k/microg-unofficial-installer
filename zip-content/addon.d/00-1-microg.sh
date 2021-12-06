#!/sbin/sh
# ADDOND_VERSION=2

# SPDX-FileCopyrightText: (c) 2016-2019, 2021 ale5000
# SPDX-License-Identifier: GPL-3.0-or-later
# SPDX-FileType: SOURCE
# INFO: This script backup and restore microG during ROM upgrades

# shellcheck source=/dev/null
. '/tmp/backuptool.functions'

list_files()
{
cat <<'EOF'
%PLACEHOLDER-1%
EOF
}

case "$1" in
  backup)
    echo 'Backup of microG unofficial installer in progress...'
    list_files | while read -r FILE _; do
      if test -z "${FILE}"; then continue; fi
      echo " ${S:?ERROR}/${FILE}"
      backup_file "${S:?ERROR}/${FILE}"
    done
    echo 'Done.'
  ;;
  restore)
    echo 'Restore of microG unofficial installer in progress...'
    list_files | while read -r FILE REPLACEMENT; do
      if test -z "${FILE}"; then continue; fi
      R=""
      [ -n "${REPLACEMENT}" ] && R="${S:?ERROR}/${REPLACEMENT}"
      [ -f "${C:?ERROR}/${S:?ERROR}/${FILE}" ] && restore_file "${S:?ERROR}/${FILE}" "${R}"
    done
    echo 'Done.'
  ;;
  pre-backup)
    # Stub
  ;;
  post-backup)
    # Stub
  ;;
  pre-restore)
    # Stub
  ;;
  post-restore)
    # Stub
  ;;
  *)
esac
