# ~/.config/nushell/modules/theme.nu

export def get_theme [] {
    $env.NU_THEME? | default "dark"
}

export def --env set_theme [name: string] {
    $env.NU_THEME = $name

    if $name == "dark" {
        # 'ansi theme' is not a valid command. 
        # For a full theme, this should be a record of colors.
        # We default to empty (system default) for now to prevent errors.
        $env.config.color_config = {} 
        $env.BAT_THEME = "gruvbox-dark"
    } else {
        $env.config.color_config = {}
        $env.BAT_THEME = "gruvbox-light"
    }
}

export def --env init_theme [] {
    set_theme (get_theme)
}
