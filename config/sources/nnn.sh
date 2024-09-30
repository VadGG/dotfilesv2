if command -v nnn &> /dev/null; then

  NNN_PLUG_FZCD='f:fzcd'
  NNN_PLUG_RENAMER='r:renamer'
  NNN_OPEN_IN_HELIX='e:-!hx "$nnn"*'
  NNN_PREVIEW='p:preview-tui'
  NNN_BULKNEW='n:bulknew'
  NNN_CDPATH='b:cdpath'
  NNN_CLONE='C:!cp -rv "$nnn" "$nnn".cp	'

  NNN_PLUG="$NNN_PLUG_FZCD;$NNN_PLUG_RENAMER;$NNN_OPEN_IN_HELIX;$NNN_PREVIEW;$NNN_BULKNEW;$NNN_CDPATH;$NNN_CLONE"
  export NNN_PLUG

  export NNN_FIFO=/tmp/nnn.fifo

# https://umaranis.com/2023/09/07/setup-nnn-terminal-file-manager-on-macos/
  n()
  {
      # Block nesting of nnn in subshells
      [ "${NNNLVL:-0}" -eq 0 ] || {
          echo "nnn is already running"
          return
      }

      # The behaviour is set to cd on quit (nnn checks if NNN_TMPFILE is set)
      # If NNN_TMPFILE is set to a custom path, it must be exported for nnn to
      # see. To cd on quit only on ^G, remove the "export" and make sure not to
      # use a custom path, i.e. set NNN_TMPFILE *exactly* as follows:
      #      NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"
      export NNN_TMPFILE="${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd"

      # Unmask ^Q (, ^V etc.) (if required, see `stty -a`) to Quit nnn
      # stty start undef
      # stty stop undef
      # stty lwrap undef
      # stty lnext undef

      # The command builtin allows one to alias nnn to n, if desired, without
      # making an infinitely recursive alias
      command nnn "$@"

      [ ! -f "$NNN_TMPFILE" ] || {
          . "$NNN_TMPFILE"
          rm -f "$NNN_TMPFILE" > /dev/null
      }
  }
  
# else
#   echo "nnn is not installed."
fi
