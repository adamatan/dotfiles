# .zshrc re-sources the shared exports, which puts /opt/homebrew/bin back in
# front. Re-apply the Studio exports so our own tools win again.
. "$HOME/.config/shell/exports.mac-studio.sh"

# The OMZ aws plugin (loaded later, with `wait`) puts '$(aws_prompt_info)' in
# RPROMPT, but nothing sets prompt_subst here, so it shows as literal text.
SHOW_AWS_PROMPT=false
