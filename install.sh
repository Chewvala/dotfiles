#!/bin/bash

#the absolute path of this script
source_path="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

if [[ $(uname) = "Darwin" ]]; then #this is for OSX Machines
    md5_bin="md5"
    customize_target=".profile"
fi
if [[ $(uname) = "Linux" ]]; then #this is for Linux
    md5_bin="md5sum"
    customize_target=".bashrc"
fi

#link the files in the confs dir to dest_conf_dir
for i in $source_path/confs/*; do 
    basename_file="$(basename $i)"
    dest_conf_dir="$HOME"
    dest_path="$dest_conf_dir/${basename_file/_/.}"
    source_file="$i"
    if [[ -f $dest_path ]]; then #if the dest_path exists then
        if [[ $(cat "$dest_path" | "$md5_bin") = $(cat "$source_file" | "$md5_bin") ]]; then #if the file is the same
            echo "$dest_path is already the same"
        else
            echo backing up ${dest_path} to ${dest_path}.bak
            mv ${dest_path} ${dest_path}.bak
            ln -s $i "$dest_conf_dir"/${basename_file/_/.}
        fi
    else
        ln -s $i "$dest_conf_dir"/${basename_file/_/.}
    fi
done
#make sure the .customize script is sourced into the target (either .bashrc or .profile)
if grep '^source $HOME/.customize.sh' ~/${customize_target} ; then
    echo '.customize already sourced in'${customize_target}
else
    echo 'source $HOME/.customize.sh' >> ~/${customize_target}
fi
#make sure the bin dir is added to the PATH
if echo $PATH | grep "${source_path}/bin"; then
    echo '$PATH already has the dotfiles bin dir'
else
    echo 'PATH=$PATH:'"${source_path}/bin" >> ~/${customize_target}
    echo added the bin dir to the PATH var
fi
echo "Create a ~/logs directory to have all your screen output logged to files"
#Special Installation Steps
