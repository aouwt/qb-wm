# wm
This is a very crude window manager, written in QB64. Due to QB64 restrictions, it does not currently support X/Wayland/etc. However, I do intend to make a *thing* that can interface to programs using QB64's TCP functionality, but that would be in the far future. As it stands now, it's merely a proof-of-concept, and not practical by any means.

## Usage
Simply run `wm` on Linux, or `wm.exe` on Windows. I cannot provide precompiled binaries for OSX, as I do not own a Mac, but you can compile it on a Mac.

<br />

`back.png` is the background, and `image2.jpg` is the image displayed on the "Test" window. You can change these out with whatever you want.

*Disclaimer: I do **NOT** own the rights to these images. They're simply placeholders for now.*

<br />

Controls are:

- Click and drag to move a window.
- Click a window to get it's focus.
- Right click and drag to resize.
- Space adds a new window.
- Escape removes the current focused window.


## Compiling
It requires using at least version 1.4 of [QB64](https://qb64.org) to compile, because it uses `$NOPREFIX`. However, if you remove `$NOPREFIX` and add the prefixes to the source, you could thoretically run it on an older version.
