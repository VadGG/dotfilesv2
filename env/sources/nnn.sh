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
else
  echo "nnn is not installed."
fi
