set -l _bob_env "$HOME/.local/share/bob/env/env.fish"
if test -f "$_bob_env"
    source "$_bob_env"
end
