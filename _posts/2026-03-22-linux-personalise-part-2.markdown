---
layout: post
title:  "Personalising a Linux command line (part 2)"
date:   2026-03-22 12:00:00 +1100
categories: general
---

In my last post, [I customised my Linux command line with 4 dotfiles]({% post_url 2026-03-12-linux-personalise-part-1 %}). Putting the time into finding my way around the command line, and learning Linux commands, becomes more important on a Linux server because there's no GUI.

I'll continue tweaking in this post by modernising two classic commands I use daily, and adding two helper packages.

In [part 3]({% post_url 2026-03-28-linux-personalise-part-3 %}) I'll tackle the big one: a super-powered prompt.

## highlight

The `highlight` package prints the contents of a file to the command line, with automatic syntax coloring. Install `highlight` by running `sudo apt install highlight`. Then, add the below to the end of `.bashrc` to replace calls to `cat` with `highlight`:

```bash
# replace cat with highlight as per https://stackoverflow.com/a/27501509 (needs "highlight" installed)
if [ -f /usr/bin/highlight ]; then
  alias cat="highlight -O xterm256 --force"
fi
```

Make the change take effect immediately by running `source ~/.bashrc`.

Now, when I view a file with `cat`, I get colored syntax.

<div markdown="1" class="note">
You can still run commands you've aliased on Linux by starting the command with a backslash "\\" - for example, to run the original <code>cat</code>, type <code>\cat</code>.
</div>
<br/>

## eza

`eza` is a better directory listing. Following the directions at <https://github.com/eza-community/eza/blob/main/INSTALL.md>, I download from <https://github.com/eza-community/eza/releases> (ensuring the right architecture, in my case `aarch64`), unzip the download, copy the unzipped `eza` executable to my home directory, then run from my home directory:

<div markdown="1" class="note">
To copy files, I use an SCP program, either WinSCP <a href="https://winscp.net/eng/download.php">https://winscp.net/eng/download.php</a> for Windows or MacSCP <a href="https://github.com/macnev2013/macSCP">https://github.com/macnev2013/macSCP</a> on Mac.
</div>
<br/>

```bash
# make the downloaded file executable
chmod +x eza
# create the directory ~/.local/bin
mkdir -p ~/.local/bin
# move eza executable to ~/.local/bin
mv eza ~/.local/bin/eza
```

Lastly, I add to my `.bashrc`, below everything else:

```bash
# replace ls with eza, expects eza installed at below location
# change the parameters to suit - the set below shows hidden files, in long format,
# with color for different file types and icons too
if [ -f ~/.local/bin/eza ]; then
  alias ls='eza -lhag --color=always --group-directories-first --icons'
fi
```

As a result, when I list the contents of a directory with `ls`, I see the following output from `eza`:

![Running ls, seeing output from eza on Ubuntu 25.04 server command line](/images/linux-command-line-eza-mar-2026.png)

The alias parts above are entirely optional, I use them as it saves me remembering another command.

Something else I like to do - as I come from Windows - is make directory navigation with `cd` case-insensitive. I do this by adding the line below to the bottom of `.inputrc` in my home directory, adapted from <https://askubuntu.com/a/87066>:

```bash
set completion-ignore-case On
```

## fastfetch

`fastfetch` (<https://github.com/fastfetch-cli/fastfetch>) is a utility that does one thing - shows system information. I install it with `sudo apt install fastfetch`, then run it with `fastfetch`. On my Linux VM, I get the following:

![fastfetch output in Ubuntu 25.04 server VM on an M1 Mac](/images/linux-command-line-fastfetch-mar-2026.png)

I've found it helpful to have all this information in one place.

## ncdu

`ncdu` is slightly different than the other packages in this post, as it's an interactive console for file/directory sizes, similar to Treesize or WinDirStat on Windows.

Either download the right version from <https://dev.yorhel.nl/ncdu>, or install with `sudo apt install ncdu`. Run, showing percents, in KB/MB/GB (rather than KiB/MiB/GiB), and in dark mode:

```bash
ncdu --show-itemcount --show-percent --si --color=dark /
```

I use `ncdu` to identify space used. With `ncdu` running, browse the file system using the arrow keys and enter to move between directories; show help with "?", and finally quit with "q".

That's it for part 2 - [part 3]({% post_url 2026-03-28-linux-personalise-part-3 %}), next, is where I power up my prompt.
