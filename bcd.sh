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
 
  esc=$( printf "\033" )
  cursor_blink_on()   { printf "$esc[?25h"; }
  cursor_blink_off()  { printf "$esc[?25l"; }
  cursor_to()         { printf "$esc[$1;${2:-1}H"; }
  print_option()      { printf "   $1 "; }
  print_selected()    { printf "  $esc[7m $1 $esc[27m${NC}"; }
  get_cursor_row()    { IFS=';' read -sdR -p $'\E[6n' ROW COL; echo ${ROW#*[}; }
  key_input() {
    local key
    for ((i=0; i < 3; ++i)); do
      read -s -n1 input 2>/dev/null >&2
      key+="$input"
      if [[ $input =~ ^[1-9]$ ]]; then
        echo $input; return;
      elif [[ $input = "" ]]; then
        echo enter; return;
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
	
  for opt in "${options[@]}"; do printf "\n"; done
  
  local lastrow=`get_cursor_row`
  local startrow=$(($lastrow - $#))
 
  trap "cursor_blink_on; stty echo; printf '\n'; exit" 2
  cursor_blink_off

  local selected=$start_idx
  while true; do
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
 
    local input=$(key_input)
    case $input in
    [1-9])
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
