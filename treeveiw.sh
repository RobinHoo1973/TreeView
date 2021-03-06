#!/bin/bash

################################################################################
#  Function Name:    HELP_USAGE
#  Description:      Function to display the usage of the script
#  Parameters:       None
#  Return:           Help messages
#  Called By:        Script Main Loop->Script Parameters' Handler
#  History:          2013-Oct-15    Initial Edition              RobinHoo
################################################################################
function help_usage(){
cat <<EOF
Usage: $PROGNAME [OPTION]... [DIRECTORY_NAME]
Display directories and/or files in tree view instead of binary tree command.

  -d, --dir      Display only the director tree
  -r, --reverse  De-Tree of the directory tree view to find . -print layout
  -h, --help     Show current help message of the script usages
  
  
Example:
  $PROGNAME              Display the tree view from current folder
  $PROGNAME --dir        Display the directory tree view from current folder
  $PROGNAME -d /usr      Show the directory tree view for /usr
  $PROGNAME /etc         Show the tree view of /etc with files listed
  
Please Report Script Bugs to $AUTHOR_MAIL


EOF
exit 1
}

################################################################################
#  Function Name:    DUMP_FOLDER
#  Description:      Function to display the tree view of given folder
#  Parameters:       Folder Name,Prefix Tree
#  Return:           None
#  Called By:        Script Main Loop->Folder Tree View Drawing
#  History:          2013-Oct-15    Initial Edition              RobinHoo
################################################################################
function dump_folder(){
    local dir_name="$1"
    local dir_tree="$2"
    local dir_item=""
    local dir_nbr=0
    local dir_idx=2
    local dir_ifs=$IFS
    IFS=\n'
    if [ $FOLDER -eq 0 ]; then
        dir_nbr=$(find "$dir_name" -maxdepth 1 -print|wc -l)
        for dir_item in $(find "$dir_name" -maxdepth 1 -print|awk 'NR>1{n=split($0,a,"/");if (system("[ -d \"" $0 "\" ]") == 0) {printf "[D]"} else printf "[F]"; printf "%s\n",a[n]}'|sort); do
            echo "$dir_tree|___$dir_item"
            [ "$dir_name" == "/" ] && dir_name=""
            if [ "${dir_item:0:3}" == "[D]" ] ; then
                dir_item="${dir_item:3}"
                [ $dir_idx -eq $dir_nbr ] && dump_folder "$dir_name/$dir_item" "$dir_tree  " || dump_folder "$dir_name/$dir_item" "$dir_tree| "
            fi
            dir_idx=$(($dir_idx+1))
        done;
    else
        dir_nbr=$(find "$dir_name" -maxdepth 1 -type d -print|wc -l)
        for dir_item in $(find "$dir_name" -maxdepth 1 -type d -print|awk 'NR>1{n=split($0,a,"/");printf "[D]%s\n",a[n]}'|sort); do
            echo "$dir_tree|___$dir_item"
            [ "$dir_name" == "/" ] && dir_name=""
            dir_item="${dir_item:3}"
            [ $dir_idx -eq $dir_nbr ] && dump_folder "$dir_name/$dir_item" "$dir_tree  " || dump_folder "$dir_name/$dir_item" "$dir_tree| "
            dir_idx=$(($dir_idx+1))
        done;    
    fi
    IFS=$dir_ifs
}



################################################################################
#  Function Name:    Script Main Loop 
#  History:          2012-Jun-06    Initial Edition              RobinHoo
################################################################################
TREE_DIR="$(pwd)"
BASE_DIR=$(cd "$(dirname "$0")" && pwd)
PROGNAME=$(basename "$0")
AUTHOR_MAIL="robin.hoo(at)outlook.com"
FOLDER=0
HELP=0
REVERSE=0
while [ $# -gt 0 ]
do
    case "$1" in
    (-d)            FOLDER=1;;
    (-r)            REVERSE=1;TREE_DIR="/dev/stdin";;
    (-h)            HELP=1;shift;break;;
    (--dir)         FOLDER=1;;
    (--reverse)     REVERSE=1;TREE_DIR="/dev/stdin";;
    (--help)        HELP=1;shift;break;;
    (-*)            echo "$PROGNAME: error - unrecognized option or parameter $1" 1>&2; HELP=1;break;;
    (*)             TREE_DIR="$1";shift;break;;
    esac
    shift
done
[ $# -gt 0 ] && HELP=1
[ $REVERSE -eq 0 ] && [ ! -d "$TREE_DIR" ] && HELP=1
[ $REVERSE -eq 1 ] && [ "$TREE_DIR" != "/dev/stdin" ] && [ ! -f "$TREE_DIR" ] && HELP=1
[ $HELP -eq 1 ] && help_usage

[ $REVERSE -eq 0 ] && echo "$TREE_DIR" && dump_folder "$TREE_DIR" ""
[ $REVERSE -eq 1 ] && cat <"$TREE_DIR"|awk 'NR==1{if ($0!="/") base=$0;folders="";print base"/"}NR>1{gsub(/^   /,"  |");while (gsub(/\|  /,"| |"));if (gsub(/___\[D\]/,"___[D]")) $0=$0"/";sub(/___\[[D|F]\]/,"");n=split($0,a,"|");split(folders,b,"/");folders="";for(i=2;i<n;i++)folders=folders"/"b[i];folders=folders"/"a[n]; print base""folders}'
