# bcd
small bash script for directory browsing  

<img width="60%" src="/capture(1).gif"/>

## Install
```sh
mkdir ~/.local/share/bcd

git clone https://github.com/Typiespectre/bcd.git ~/.local/share/bcd

## add alias to ~/.bashrc

alias bcd='source $HOME/.local/share/bcd/bcd.sh'

## then, resource the terminal and have fun!
```

## Usage

You can browse current directories with `arrow(Up and Down)` keys.  

- If you want to go inside next directory(child directory), move cursor and press `Enter` key.  
- You can stay current directory cursor to `single dot(.)` and press `Enter`.
- Also, you can go back to Parent directory with cursor to `doubld dot(..)` and press `Enter`.

## Notes

**This is Beta version!** (It means, this function has some buggy things.)  
So I need to change, fix and add some functions to improve this small project.  
You can use it freely and make it better for yourself!  
And I got a lot of help here:  

[https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu](https://unix.stackexchange.com/questions/146570/arrow-key-enter-menu)  
[https://gist.github.com/RobertMcReed/05b2dad13e20bb5648e4d8ba356aa60e](https://gist.github.com/RobertMcReed/05b2dad13e20bb5648e4d8ba356aa60e)  
