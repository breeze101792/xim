# Note about using VIM

## Binary Editor
Convert binary to hex mode
```
:%!xxd
```

Convert back binary from hex mode
! -> represent fileter command
```
:%!xxd -r
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
