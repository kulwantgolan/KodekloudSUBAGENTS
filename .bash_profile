termwidth="$(tput cols)"

# Adjust the spacing for the "Welcome to ..." and "All rights ..." lines.

left_align() {
  local padding="$(printf '%0.1s' \ {1..500})"
  local padding_percentage="$1"
  local padding_width=$((termwidth*padding_percentage/100))
  printf '%*.*s %s %*.*s\n' "$padding_width" "$padding_width" "$padding" "$2" 0 "$((termwidth-1-${#2}-padding_width))" "$padding"
}

left_align 6 "Welcome to the KodeKloud Hands-On lab"
figlet -w ${termwidth} -f slant KODEKLOUD | lolcat
left_align 10 "All rights reserved"
source /root/.bashrc 2>/dev/null
export CLAUDE_API_KEY=Sk-kkAI-3ad2f01d9939303ef9ccb490c48cbcc585c34cbb22256452edd06329066f1c1bkk_mu53kf2imo2jkvt2-kk2fb33cf9
export GROQ_API_KEY=Sk-kkAI-3ad2f01d9939303ef9ccb490c48cbcc585c34cbb22256452edd06329066f1c1bkk_mu53kf2imo2jkvt2-kk2fb33cf9
export ALLOWED_MODELS=x-ai/grok-code-fast-1
export OPENAI_API_BASE=https://kodekey.ai.kodekloud.com/v1
export AZURE_OPENAI_ENDPOINT=https://kodekey.ai.kodekloud.com/openai
export OPENAI_API_KEY=Sk-kkAI-3ad2f01d9939303ef9ccb490c48cbcc585c34cbb22256452edd06329066f1c1bkk_mu53kf2imo2jkvt2-kk2fb33cf9
export GROQ_API_BASE=https://kodekey.ai.kodekloud.com
export AZURE_OPENAI_API_KEY=Sk-kkAI-3ad2f01d9939303ef9ccb490c48cbcc585c34cbb22256452edd06329066f1c1bkk_mu53kf2imo2jkvt2-kk2fb33cf9
export CLAUDE_API_BASE=https://kodekey.ai.kodekloud.com
export OPENAI_MODEL="x-ai/grok-code-fast-1"
export OPENAI_BASE_URL="$OPENAI_API_BASE"
