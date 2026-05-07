function fish_greeting
    if not status is-interactive
        return
    end

    # fastfetch can occasionally block terminal startup while probing system state.
    if test "$DOTFILES_FASTFETCH_ON_STARTUP" = 1
        fastfetch
    end
end
