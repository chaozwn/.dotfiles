# tokyonight

set style moon
set theme tokyonight_{$style}

if status is-interactive; and test "$fish_color_theme" != "$theme"
    fish_config theme choose $theme
    set -U fish_color_theme $theme
end
