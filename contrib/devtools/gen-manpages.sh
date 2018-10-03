#!/bin/bash

TOPDIR=${TOPDIR:-$(git rev-parse --show-toplevel)}
SRCDIR=${SRCDIR:-$TOPDIR/src}
MANDIR=${MANDIR:-$TOPDIR/doc/man}

HYPOTHESIZED=${HYPOTHESIZED:-$SRCDIR/hypothesized}
HYPOTHESIZECLI=${HYPOTHESIZECLI:-$SRCDIR/hypothesize-cli}
HYPOTHESIZETX=${HYPOTHESIZETX:-$SRCDIR/hypothesize-tx}
HYPOTHESIZEQT=${HYPOTHESIZEQT:-$SRCDIR/qt/hypothesize-qt}

[ ! -x $HYPOTHESIZED ] && echo "$HYPOTHESIZED not found or not executable." && exit 1

# The autodetected version git tag can screw up manpage output a little bit
IZEVER=($($HYPOTHESIZECLI --version | head -n1 | awk -F'[ -]' '{ print $6, $7 }'))

# Create a footer file with copyright content.
# This gets autodetected fine for bitcoind if --version-string is not set,
# but has different outcomes for bitcoin-qt and bitcoin-cli.
echo "[COPYRIGHT]" > footer.h2m
$HYPOTHESIZED --version | sed -n '1!p' >> footer.h2m

for cmd in $HYPOTHESIZED $HYPOTHESIZECLI $HYPOTHESIZETX $HYPOTHESIZEQT; do
  cmdname="${cmd##*/}"
  help2man -N --version-string=${IZEVER[0]} --include=footer.h2m -o ${MANDIR}/${cmdname}.1 ${cmd}
  sed -i "s/\\\-${IZEVER[1]}//g" ${MANDIR}/${cmdname}.1
done

rm -f footer.h2m
