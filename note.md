# Note about using VIM

## Userfull commands
Search with copied text


Searching for a selection:
if you want to first yank a section of a line, then use "v" and move with cursors until you have marked what you want, then press y for yank and now the selection is in register 0

```
/Ctrl-R 0
```

## vim script note
http://vimdoc.sourceforge.net/htmldoc/usr_41.html

## add subproject
```
git submodule add [url] [folder]
```

## update subproject
```
git submodule foreach git pull origin master
git submodule foreach git reset --hard origin/master
```
## Remove subproject
1. Delete the relevant section from the .gitmodules file.
2. Stage the .gitmodules changes:
```
git add .gitmodules
```
3. Delete the relevant section from .git/config.
4. Remove the submodule files from the working tree and index:
```
git rm --cached path_to_submodule (no trailing slash).
```
5. Remove the submodule's .git directory:
```
rm -rf .git/modules/path_to_submodule
```
6. Commit the changes:
```
git commit -m "Removed submodule <name>"
```
7. Delete the now untracked submodule files:
```
rm -rf path_to_submodule
```


## Debug
Starup time measure
```
vim -X --startuptime startup.log
```

## Filter command
Convert binary to hex mode
```
:%!xxd
```

Convert back binary from hex mode
! -> represent fileter command
```
:%!xxd -r
```

Do shell command as new input file
```
:r[ead]! ls -al
```

## Profiling
Get in to vim
```
:profile start profile.log
:profile func *
:profile file *
```
At this point do slow actions
```
:profile pause
:noautocmd qall!
```

get syntime report
```
syntime on
```
do scroll
```
syntime report
```
## Plugins
for tag prototype hilight
```
git clone https://github.com/vim-scripts/TagHighlight.git -b master
```
grep string, not really usefull
```
https://github.com/dkprice/vim-easygrep.git
```

keep color consistency in different terms
```
git clone https://github.com/vim-scripts/colorsupport.vim.git -b master
```
Theme
```
git clone https://github.com/vim-airline/vim-airline-themes.git
git clone https://github.com/rafi/awesome-vim-colorschemes.git
```
Others
```
git clone https://github.com/vim-syntastic/syntastic.git
git clone https://github.com/vim-scripts/colorsupport.vim.git
git clone https://github.com/wesleyche/Trinity.git
git clone https://github.com/zefei/vim-wintabs.git -b master
```
