#!/bin/bash
# Ekkoh 2-Line Minimal

input=$(cat)

eval "$(printf '%s' "$input" | jq -r '
  (.context_window // {}) as $c |
  @sh "cwd=\(.cwd // .workspace.current_dir // "")
    ctx_pct=\(($c.used_percentage // 0) | floor)
    model_id=\(.model.id // "")
    effort=\(.effort.level // "")
    h5=\((.rate_limits.five_hour.used_percentage // "") | if . == "" then "" else (floor|tostring) end)
    d7=\((.rate_limits.seven_day.used_percentage // "") | if . == "" then "" else (floor|tostring) end)"
')"

case "$model_id" in
  *opus*) model=Opus ;; *sonnet*) model=Sonnet ;; *haiku*) model=Haiku ;; *fable*) model=Fable ;;
  *) model="${model_id:-?}" ;;
esac

# Catppuccin Latte (light background)
mauve=$'\033[38;2;136;57;239m'
yellow=$'\033[38;2;223;142;29m'
peach=$'\033[1;38;2;254;100;11m'
dim=$'\033[38;2;108;111;133m'
green=$'\033[38;2;64;160;43m'
red=$'\033[38;2;210;15;57m'
reset=$'\033[0m'
sep="${dim} · ${reset}"

# colorMode: percentage — green < 50, yellow < 80, red above
pct_color() {
  if   [ "$1" -lt 50 ]; then printf '%s' "$green"
  elif [ "$1" -lt 80 ]; then printf '%s' "$yellow"
  else printf '%s' "$red"
  fi
}

bar() { # pct width
  local filled=$(( $1 * $2 / 100 )) i out=''
  [ "$filled" -gt "$2" ] && filled=$2
  [ "$filled" -lt 0 ] && filled=0
  for ((i=0; i<$2; i++)); do [ $i -lt $filled ] && out+='━' || out+='─'; done
  printf '%s' "$out"
}

# ── line 1 ──
printf '%s[%s]%s' "$mauve" "$(basename "${cwd:-?}")" "$reset"
if [ -n "$cwd" ] && git -C "$cwd" rev-parse --git-dir >/dev/null 2>&1; then
  b=$(git -C "$cwd" symbolic-ref --short HEAD 2>/dev/null || git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$b" ] && printf '%s:%s%s' "$yellow" "$b" "$reset"
fi
printf '%s%s%s%s' "$sep" "$peach" "$model" "$reset"
[ -n "$effort" ] && printf '%s / %s%s' "$dim" "$effort" "$reset"
printf '\n'

# ── line 2 ──
c=$(pct_color "$ctx_pct")
printf '%sctx %s%s %s%d%%%s' "$c" "$(bar "$ctx_pct" 20)" "$reset" "$c" "$ctx_pct" "$reset"
[ -n "$h5" ] && printf '%s%s5h %s %s%%%s' "$sep" "$(pct_color "$h5")" "$(bar "$h5" 10)" "$h5" "$reset"
[ -n "$d7" ] && printf '%s%s7d %s %s%%%s' "$sep" "$(pct_color "$d7")" "$(bar "$d7" 10)" "$d7" "$reset"
printf '\n'
