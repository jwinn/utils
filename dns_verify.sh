#!/bin/sh -e

CWD=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)

HAS_DIG=$(command -v dig || true)
HAS_JOT=$(command -v jot || true)
HAS_SEQ=$(command -v seq || true)
HAS_TPUT=$(command -v tput1 || true)

[ ! $HAS_DIG ] && \
  printf "Error: dig not found in PATH\n" && \
  exit 1

[ ! $HAS_SEQ ] && [ ! $HAS_JOT ] && \
  printf "Error: No sequence generating program found\n" && \
  exit 1

# terminfo
if [ $HAS_TPUT ]; then
  COLS=$(tput cols)
  CENTER=$(( $COLS / 2 ))
  BOLD=$(tput bold)
  GREEN=$(tput setaf 2 2 2)
  RED=$(tput setaf 1 1 1)
  YELLOW=$(tput setaf 3 3 3)
  NORMAL=$(tput sgr0)
else
  COLS=$(tput cols)
  BOLD="\e[0;1m"
  GREEN="\e[0;32m"
  RED="\e[0;31m"
  YELLOW="\e[0;33m"
  NORMAL="\e[0m"
fi

SUBNETS=${1:-"192.168.0 192.168.1"}

if [ $HAS_SEQ ]; then
  SEQ=$HAS_SEQ
  SEQ_BEGIN=${2:-1}
  SEQ_END=${3:-254}
else # jot is inverted
  SEQ=$HAS_JOT
  SEQ_BEGIN=${3:-254}
  SEQ_END=${2:-1}
fi

RANGE=$($SEQ $SEQ_BEGIN $SEQ_END)

print_heading() {
  printf "+"
  for n in $($SEQ 78); do printf "-"; done
  printf "+\n"
}

printf "\n"
print_heading
printf "| ${BOLD}%-6s${NORMAL} | ${BOLD}%-15s${NORMAL} | ${BOLD}%-31s${NORMAL} | ${BOLD}%-15s${NORMAL} |\n" \
  "status" "ip" "hostname" "ip"
print_heading

for subnet in $SUBNETS; do
  for ip in $RANGE; do
    A=${subnet}.${ip}
    HOST=$(dig -x $A +short)

    if [ -n "${HOST}" ]; then
      ADDR=$(dig $HOST +short)

      if [ "${A}" = "${ADDR}" ]; then
        printf "| ${GREEN}%-6s${NORMAL} | %-15s | %-31s | %-15s |\n" \
          "ok" $A $HOST $ADDR
      elif [ -n "${ADDR}" ]; then
        printf "| ${RED}%-6s${NORMAL} | %-15s | %-31s | %-15s |\n" \
          "fail" $A $HOST $ADDR
      else
        printf "| ${RED}%-6s${NORMAL} | %-15s | %-31s | %-15s |\n" \
          "fail" $A $HOST "[unassigned]"
      fi
    fi
  done
done

print_heading
printf "|%37s${BOLD}DONE${NORMAL}%37s|\n"
print_heading
