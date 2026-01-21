# The minimal watchface for Garmin MIP screens
This is my attempt to make an analog watchface that is as minimal as possible while still being easily **readable**.

I've noticed a lot of watchfaces render poorly on my Tactix 7 due the limitations of its Transflective MIP screen. This severely limits the number of colors that can be used on the watch with many non-primary / secondary colors appearing washed out on many of the already uploaded watchfaces on ConnectIQ.
Also many of the ultra minimal analog watchfaces turn out to be entirely non-practical for reading the time, and I was bugged at how many useless hour numbers were on screen.
Furthermore, many of the watchfaces downloaded from ConnectIQ are rather resource heavy, inducing lag on the efficiency-focused Tactix 7.

This project attempts to remedy the above issues by drawing only the active hour, and minute ticks up to the current minute, with very few colors. It does not do any other operations in the background to keep resources as free as possible.

![Preview of the watchface](images/preview.png)  
End note:  
This was a practice project to get familiar with MonkeyC.  
And also a good brush up on utilizing trigonometric functions!
