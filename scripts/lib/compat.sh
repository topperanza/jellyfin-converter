#!/usr/bin/env bash

to_lower() {
  printf '%s' "$1" | tr '[:upper:]' '[:lower:]'
}

to_upper() {
  printf '%s' "$1" | tr '[:lower:]' '[:upper:]'
}

have_bash_ge_4() {
  (( BASH_VERSINFO[0] >= 4 ))
}
