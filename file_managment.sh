#! /bin/bash

#bool variable that runs welcome function only once
first_time_runs=true
#function with paramenters to create an error message
#depending on case ->
#message() "col" "mes" "dest" "semicolons"
message () {
clear
tput setaf $1; echo -e "$2"
tput sgr0; $3$4
}

#welcomes user to program 
welcome() {
user=$(whoami)
day=$(date +%A)
echo "Hello $user!"
echo -e "Date: $day!\n"
first_time_runs=false
}

#function that runs first
entry () {
#if it the first time this menu is displayed, run welcome
if [[ $first_time_runs == true ]]; then
welcome
fi
echo "1) Find files/folders located in your computer."
echo "2) File empty files/folders."
echo "3) Find dublicated files."
echo "4) Make a backup."
echo "5) Update your computer."
echo "6) Exit program."
echo -e "\n\nEnter your choice..\c"
read firstchoice

#reads user's option and runs functions accordingly
case $firstchoice in
 "1" )
 clear
 filefinder;;
 "2" )
 clear
 findempty;;
 "3" )
 clear
 find_dub;;
 "4" )
 backup
 echo ""
 tput sgr0; entry;;
 "5" )
 update ;;
 "6" )
 exit 1;;
 * )
 clear
 tput sgr0; entry;;
esac
}

#user's option 3: "Find dublicated files"
find_dub () {

echo "1) Search whole drive for dublicated files"
echo "2) Search a specific folder for dublicated files"
echo -e "Enter your choice: \c"
read lchoice
echo -e "\n"

case $lchoice in
"1" )
  dubwhole=$(find ~/ -not -path '*/\.*' ! -empty -type f -exec md5sum {} + | sort | uniq -w32 -dD)
  if [ ! -z "$dubwhole" ]; then
    echo -e "\n-MD5 Hash Value-                  -path to folder-"
    tput setaf 2; find ~/ -not -path '*/\.*' ! -empty -type f -exec md5sum {} + | sort | uniq -w32 -dD
    tput setaf 3; echo -e "\nFiles with the same MD5 value are dublicated!\n"
    tput sgr0; entry
  else
    message "3" "No dublicated files in this drive!\n" "entry"
  fi;;
"2" )
  echo -e "Enter the name of the folder you want to search for dublicated files: \c"
  read dubfol
  searchfol=$(find ~/ -not -path '*/\.*' -type d -name "$dubfol" -print)

  #search if directory exists
  if [ -d "$searchfol" ]; then
  checkdub=$(find $searchfol -not -path '*/\.*' ! -empty -type f -exec md5sum {} + | sort | uniq -w32 -dD)
    if [ -z "$checkdub" ]; then
      message "3" "No dublicated files in this folder!.\n" "entry"
    else
      #print MD5 hash and the path of file 
      echo -e "\n-MD5 Hash Value-                  -path to folder-"
      tput setaf 2; find $searchfol -not -path '*/\.*' ! -empty -type f -exec md5sum {} + | sort | uniq -w32 -dD
      tput setaf 3; echo -e "\nFiles with the same MD5 value are dublicated!\n"
      tput sgr0; entry
    fi
  else 
  message "1" "Folder not found, try again.\n" "entry"
  fi;;
* )
echo "Wrong input, try again!"
find_dub
esac
}

#user's option 5: "Update your computer"
update() {
tput setaf 2; echo "Enter the password for root user!"
tput sgr0; 
sudo apt-get update -y
sudo apt-get upgrade -y
sudo apt-get dist-upgrade -y
notify-send "Your system is Up-to-date!"
clear
entry
}

#user's option 1: "File files/folders located in your computer"
filefinder() {
echo "1) Find file by name"
echo "2) Find folder by name"
echo "3) Find all hidden files"
echo "4) Find file by extension"
echo "5) Go back."
echo -e "Choose number..\c"
read num

case $num in
#1) Find file by name
"1" )
clear
echo -e "Enter the name of the file you want to find: \c"
read file_name
#creating variable with the name of the file after searching fot it
dir_path+=$(find ~/ -not -path '*/\.*' -name "$file_name" -type f -print)
#if variable is empty, search for the name+extension
ext=".*"
if [ -z "$dir_path" ]; then 
dir_path+=$(find ~/ -not -path '*/\.*' -name "$file_name${ext}" -type f -print)
  if [[ "$dir_path" ]]; then
   tput setaf 3; echo "$file_name found, Directory: "
   tput setaf 2; echo "$dir_path"
  else
   tput setaf 1; echo "$file_name not found.."
   #if variable still empty, find a file with similar name
   #and print it "Maybe you ment something like this:"
   maybefile=$(find ~/ -not -path '*/\.*' -type f -iname $file_name*)
   if [ -n "$maybefile" ]; then
   tput setaf 6; echo "Maybe you ment something like this:"
   tput setaf 2; find ~/ -not -path '*/\.*' -type f -iname $file_name*
   fi
  fi
else
  dir_path_ext=$(find ~/ -not -path '*/\.*' -name "$file_name${ext}" -type f -print)
  if [ -z "$dir_path_ext" ]; then
    echo "$file_name found, Directory: "
    tput setaf 2; echo "$dir_path"
  else
    echo "$file_name found, Directory: "
    tput setaf 2; echo "$(find ~/ -not -path '*/\.*' -name "$file_name" -type f -print)"
    tput setaf 2; echo "$(find ~/ -not -path '*/\.*' -name "$file_name${ext}" -type f -print)"
  fi
fi
#empties variables and diplay previous menu
echo ""
file_name=""
dir_path_ext=""
dir_path=""
maybefile=""
tput sgr0; filefinder;;

"2" )
#2) Find folder by name
clear
echo -e "Enter the name of the folder you want to find: \c"
read fold_name
#search for directory by name and stores path to variable
fold_path=$(find ~/ -not -path '*/\.*' -name "$fold_name" -type d -print)
fold_hidden=$(find ~/ -name ".$fold_name" -type d -print)

#checks if variable fold_name is empty and acts accordingly
if [ ! -z "$fold_path" ]; then
 tput setaf 2; find ~/ -not -path '*/\.*' -name "$fold_name" -type d -print
    #if hidden folders under the same name exists, print them too
    if [ ! -z "$fold_hidden" ]; then
    tput setaf 3; echo "--hidden folders with $fold_name name--"
    tput setaf 2; find ~/ -name ".$fold_name" -type d
    fi
else
 maybefolder=$(find ~/ -not -path '*/\.*' -type d -iname $fold_name*)
 tput setaf 1; echo "Folder not found, try again!"
 if [ "$maybefolder" ]; then
  tput setaf 6; echo "Maybe you ment something like this:"
  tput setaf 2; find ~/ -not -path '*/\.*' -type d -iname $fold_name*
 fi
fi
echo ""
maybefolder=""
fold_hidden=""
fold_path=""
fold_name=""
tput sgr0; filefinder;;

#3) Find all hidden files
"3" )
clear
#search for hidden files and if exists, display their path
hidden_gen=$(find ~/ -name ".*.*" -type f -print)
if [ -z "$hidden_gen" ]; then
clear
tput setaf 3; echo "No hidden files found.."
echo ""
tput sgr0; filefinder
else
clear
tput setaf 3; echo "--hidden files--"
tput setaf 2; find ~/ -name ".*.*" -type f -print
echo ""
tput sgr0; filefinder
fi;;

#4) Find file by extension
"4" )
esc=1
clear
#Find and display all files with the extension variable
while [[ "$esc" -eq 1 ]]; do
tput setaf 6; echo -e "Enter extension: \c"
read extension
#read extension variable from user
extfiles=$(find ~/ -not -path "*/\.*" -name "*.${extension}" -print)
hidden_ext=$(find ~/ -name ".*.${extension}" -print)
#display files with this extension
if [ -n "$extfiles" -o -n "$hidden_ext" ]; then
  tput setaf 3; echo -e "\n--files with .$extension extention--"
  tput setaf 2; find ~/ -not -path "*/\.*" -name "*.${extension}" -print
#display hidden files with this extension
 if [ -n "$hidden_ext" ]; then
   tput setaf 3; echo "--hidden files with ${extension} extension--"
   tput setaf 5; find ~/ -name ".*.${extension}" -print
 fi 
else
 tput setaf 1; echo -e "\nNo files with .$extension extension!"
fi
#if user enter E,e,B,b, break the loop and act accordingly
#any other letter, search again
tput sgr0; echo -e "\nEnter [E/e] to Exit."
tput sgr0; echo -e "Enter [B/b] to go back."
echo -e "Enter any letter to search again"
echo -e "Enter option: \c"
read option

case $option in
"E"|"e" )
exit 1
break;;
"B"|"b" )
clear
filefinder
break;;
esac
done;;
"5" )
clear
entry;;
* )
message "1" "Unknown number, try again.\n" "filefinder"
esac
}

#user's option 4: "Make a backup"
backup() {
clear
num=0
#diplay all directories and files
tree ~/

#reads directory name from user
tput setaf 6; echo "This works properly only with unique folder names!"
echo "If 2 or more folders have the same name, program will backup the first folder will match the name!"
echo "Go to folder search to check if you have multiple folders under the same name!"
tput sgr0; echo -e "Enter the name of the folder you want to backup: \c"
read foldername
foldpath=$(find ~/ -not -path "/home/$(whoami)/Backups*" -not -path '*/\.*' -type d -name "$foldername" -print -quit)
tput setaf 2; echo $foldpath
destname="/home/$(whoami)/Backups"

#ask user if he wants to compress backup and acts accordingly
if [ "$foldpath" ]; then
  tput setaf 1; read -r -p "Do you want to compress backup? [y/n] " response
  response=${response,,}
  tput sgr0; 
  if [[ "$response" =~ ^(yes|y)$ ]]; then
    if [ ! -d "$destname" ]; then
      #create a "Backup" directory to ~/home
      mkdir ~/Backups
      notify-send "\""Backups\"" folder has been created at $destname!"
    fi
    nameappears=$foldername
    #loop that changes the name of the file if exists
    while [ -f "/home/$(whoami)/Backups/$nameappears.zip" ]; do
      num=$((num+1))
      nameappears="$foldername($num)"
    done
    cd "$foldpath" 
    zip -r ~/Backups/$nameappears.zip ./* 
    #Display a message to inform user that a backup was made
    #show path and name
    message "3" "Backup saved at $destname/$nameappears.zip\n" "entry"
  elif [[ "$response" =~ ^(no|n)$ ]]; then
    if [ ! -d "$destname" ]; then
      mkdir ~/Backups
      notify-send "\""Backups\"" folder has been created at $destname!"
    fi
    nameappears=$foldername
    #if a backup with the same name at "Backups" change the name
    #name = name + number ascending for every file
    while [ -d "/home/$(whoami)/Backups/$nameappears" ]; do
      num=$((num+1))
      nameappears="$foldername($num)"
    done
      cd "$foldpath" 
      cd ..
      find ~/ -not -path '~/Backups' -type d -name "$foldername" | cp -r ./$foldername ~/Backups/$nameappears
      message "3" "Backup saved at $destname/$nameappears\n" "entry"

  else
  message "1" "Not correct input!\n" "entry"
  fi
else
    message "1" "This folder does not exist, try again\n" "entry"
fi
}

#user's option 2: "File empty files/folders"
findempty() {
echo "1) Find all empty files."
echo "2) Find all empty folders."
echo "3) Go back."
echo -e "Choose number..\c"
read num

case $num in
#1) Search for empty files and diplay their paths if any
"1" )
 filepath=$(find ~/ -not -path '*/\.*' -type f -empty )
 if [ -n "$filepath" ]; then
  tput setaf 3; echo -e "\nEmpty files:\n" 
  tput setaf 2; find ~/ -not -path '*/\.*' -type f -empty
  tput setaf 1; echo -e "\n1) !!Delete all empty files!!"
  echo "2) Delete a chosen empty file."
  echo "3) Go back."
  tput sgr0; echo -e "Choose number..\c"
  read num2
    case $num2 in
    #confirm and delete all empty files
    "1" )
    tput setaf 1; read -r -p "Are you sure? [y/n] " response
    response=${response,,}
    if [[ "$response" =~ ^(yes|y)$ ]]; then
      find ~/ -not -path '*/\.*' -type f -empty -delete
      message "3" "All empty files are deleted!" "entry"
    elif [[ "$response" =~ ^(no|n)$ ]]; then
      tput sgr0; findempty
    else
      message "1" "Not correct input, try again!" "findempty"
    fi ;;
    #read name from user and delete empty files with this name
    "2" )
    tput setaf 1; echo "If multiple empty files exists under the same name, they will be all deleted!"
    tput sgr0; echo -e "Enter the name of the file you want to delete:"
    echo -e "Enter the extension of file too, if any! \c"
    read filename
    filepath2=$(find ~/ -not -path '*/\.*' -type f -name "$filename" -empty)
    if [ -z "$filepath2" ]; then
      message "1" "File not exists or not empty!\n" "findempty"
    else     
      find ~/ -not -path '*/\.*' -type f -name "$filename" -type f -empty -delete
      message "2" "File $filename deleted\n" "entry"
    fi ;;
    #go to previous menu
    "3" )
      clear
      findempty ;;
    * )
      message "1" "Unknown number, try again." "entry" ";;"
    esac 
  else
    message "3" "No empty files!\n" "findempty"
  fi ;;

#1) Search for empty directories and diplay their paths if any
"2" )
  direpath=$(find ~/ -not -path '*/\.*' -type d -empty )
  if [ -n "$direpath" ]; then
    tput setaf 3; echo -e "\nEmpty folders:\n" 
    tput setaf 2; find ~/ -not -path '*/\.*' -type d -empty 
    tput setaf 1; echo -e "\n1) Delete an empty folder"
    echo "2) Go back."
    tput sgr0; echo -e "\nEnter a number:\c"
    read num3
    case $num3 in
    #read name from user and delete empty directories with this name
    "1" )
      echo -e "Enter the name of the folder:\c"
      read foldername 
      #store default directories names to array
      not_folders=("Desktop" "Documents" "Downloads" "Music"
      "Pictures" "Public" "Templates" "Videos")
      folderpath=$(find ~/ -not -path '*/\.*' -type d -name "$foldername" -empty -print)
      if [ "$folderpath" ]; then
        #check if name is a default directory
        #if yes: error message 
        #if no: delete empty directory with this name
        if [[ "${not_folders[*]}" =~ "${foldername}" ]]; then
          message "1" "You cant delete default folders, try again\n" "findempty"
        else
          find ~/ -not -path '*/\.*' -type d -name "$foldername" -empty -delete
          message "2" "$foldername has been deleted!\n" "entry"
        fi
      else
        message "1" "Folder not exists or not empty!\n" "findempty"
      fi;;
    "2" )
      clear
      findempty;;
    * )
    message "1" "Unknown number, try again.\n" "findempty"
    esac 
  else
    message "3" "No empty folders!\n" "findempty"
  fi ;;

#go to previous menu
"3" )
 clear
 entry;;
* )
 message "1" "Unknown number, try again.\n" "findempty"
esac
}
clear
entry
