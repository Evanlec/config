
#!/bin/bash

# USAGE:
#
#    rename this script to XXX-newterminal to start new terminal window
#    with cmd=XXX and args=as passed (e.g., XXX=mutt)
#    when cmd completes, terminal window will close.

GEOMETRY="-g 120x40"
TERMINAL="urxvtc"

CMD=$(mutt "$0")
CMD="${CMD%*-newterminal}"
exec $TERMINAL $GEOMETRY -e "$CMD" "$@"
