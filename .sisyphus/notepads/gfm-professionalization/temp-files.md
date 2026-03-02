Temp files management notes
- Replaced PID-based temp files in scripts with mktemp-based approach.
- Added trap cleanup for generated temp files.
- Audited all /tmp usage in scripts; updated primary target to mktemp.
