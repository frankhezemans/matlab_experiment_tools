# MATLAB experiment tools
Functions that may be useful for running psychological experiments in MATLAB using Psychtoolbox.

## List of functions
* `getChoice.m` records which of two keys was pressed, and determines whether this was the appropriate response. Useful in the context of two-alternative forced choices.
* `screenSetup.m` creates an on-screen window for presenting stimuli, and if necessary prepares image files to be drawn to the screen.
* `quitExperiment.m` in case a specified key (e.g. escape) has been pressed, draws text to the screen, and returns a logical index in case this key is pressed once more.

## License
Use this software at your own risk - I'm not liable for damages :innocent:. See `LICENSE.txt` for details.
