# MATLAB experiment tools
Functions that may be useful for running psychological experiments in MATLAB using [Psychtoolbox](http://psychtoolbox.org).

## List of functions
* `getChoice.m` records which of two keys was pressed, and determines whether this was the appropriate response. Useful in the context of two-alternative forced choices.
* `likertScale.m` draws a Likert scale and statement to the screen, and returns the selected level of (dis)agreement, reaction time, and a logical element indicating whether or not a response was made.
* `screenSetup.m` creates an on-screen window for presenting stimuli, and if necessary prepares image files to be drawn to the screen.
* `slideScale.m` draws a continuous scale and statement to the screen, and returns the level of (dis)agreement, reaction time, and a logical element indicating whether or not a response was made. The scale itself has a ‘banded’ design (alternating filled segments of black and grey) to minimise response bias. Example:

![slideScale](https://github.com/frankhezemans/matlab_experiment_tools/blob/master/for_README/slideScale.gif)
* `quitExperiment.m` in case a specified key (e.g. escape) has been pressed, draws text to the screen, and returns a logical index in case this key is pressed once more.

## Dependencies
These functions were written in MATLAB R2014a on a Windows 7 PC using Psychtoolbox version 3.0.13. I haven't checked the compatibility with other operating systems and/or software versions.

## License
Use this software at your own risk - I'm not liable for damages :innocent:. See `LICENSE.txt` for details.
