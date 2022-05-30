#!/usr/bin/env bash

function ls_dir {
	ls -al | sed -n "2,$ p" | grep '^d' | grep -wv "[.][a-zA-Z].*" \
	| awk '{print $9}' | xargs -I {} printf "%s " "{}"
}

function select_option {
  start_idx=0
  local header="Current directory: "
  printf "$header %s\n" "$(pwd)"
  options=("$@")
 
  # helpers for terminal print control and key input
  esc=$( printf "\033" )
  cursor_blink_on()   { printf "$esc[?25h"; }
  cursor_blink_off()  { printf "$esc[?25l"; }
  cursor_to()         { printf "$esc[$1;${2:-1}H"; }
  print_option()      { printf "   $1 "; }
  print_selected()    { printf "  $esc[7m $1 $esc[27m${NC}"; }
  get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
  key_input() {
    local key
    # read 3 chars, 1 at a time
    for ((i=0; i < 3; ++i)); do
      read -s -n1 input 2>/dev/null >&2
      # concatenate chars together
      key+="$input"
      # if a number is encountered, echo it back
      if [[ $input =~ ^[1-9]$ ]]; then
        echo $input; return;
      # if enter, early return
      elif [[ $input = "" ]]; then
        echo enter; return;
      # if we encounter something other than [1-9] or "" or the escape sequence
      # then consider it an invalid input and exit without echoing back
      elif [[ ! $input = $esc && i -eq 0 ]]; then
        return
      fi
    done

    if [[ $key =~ $esc$ ]]; then echo esc; fi;
    if [[ $key = $esc[A ]]; then echo up; fi;
    if [[ $key = $esc[B ]]; then echo down; fi;
  }
  cursorUp()			{ printf "$esc[A"; }
  clearRow()			{ printf "$esc[2K\r"; }
  eraseMenu() {
    cursor_to $lastrow
    clearRow
    numHeaderRows=$(echo "$header" | wc -l)
    numOptions=${#options[@]}
    numRows=$(($numHeaderRows + $numOptions))
    for ((i=0; i<$numRows; ++i)); do
      cursorUp; clearRow;
    done
  }
	
  # initially print empty new lines (scroll down if at bottom of screen)
  for opt in "${options[@]}"; do printf "\n"; done
  
  # determine current screen position for overwriting the options
  local lastrow=`get_cursor_row`
  local startrow=$(($lastrow - $#))
 
  # ensure cursor and input echoing back on upon a ctrl+c during read -s
  trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
  cursor_blink_off

  local selected=$start_idx
  while true; do
    # print options by overwriting the last lines
    local idx=0
    local label
    for opt in "${options[@]}"; do
      cursor_to $(($startrow + $idx))
      label="$(($idx + 1)). $opt"
      if [ $idx -eq $selected ]; then
        print_selected "$label"
          else
        print_option "$label"
      fi
      ((idx++))
    done
 
    # user key control
    local input=$(key_input)
    case $input in
		[1-9])
		# '$#': number of parameters
		  if [ $input -lt $(($# + 1)) ]; then
        selected=$(($input - 1))
					  break
		  fi;;
    enter) break;;
    esc) break;;
    up) ((selected--));
      if [ $selected -lt 0 ]; then selected=$(($# - 1)); fi;;
    down)  ((selected++));
      if [ $selected -ge $# ]; then selected=0; fi;;
		esac
	done
 
  # cursor position back to normal
  eraseMenu
  cursor_blink_on
 
  return $selected
}

export dirname=""
export targets=""
while true; do
	if [ $1 ]; then
		cd "$1"
		targets=($(ls_dir))
		select_option "${targets[@]}"
		dirname="${options[$?]}"
		if [ "$dirname" = "." ]; then
			cd "$(pwd)"; break;
		fi
		set -- "."
		cd "$dirname"
	else
		targets=($(ls_dir))
		select_option "${targets[@]}"
		dirname="${options[$?]}"
		if [ "$dirname" = "." ]; then
			cd "$(pwd)"; break;
		fi
		cd "$dirname"
	fi
done
