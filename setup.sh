#!/bin/sh

# setup development environment for new mahcine

if [ -f ~/bin/.setup.log ]; then
    echo "Already setup for you"
    exit 1
else
    echo "Starting setup machine"
fi

# check apt available
APT=apt
apt -v
if [ "$?" = "0" ]; then
    APT=apt
else
    APT=apt-get
fi

update_system()
{
    sudo $APT -y update
    sudo $APT -y upgrade
}

setup_broswer()
{
    # chromium-browser installation
    sudo $APT -y install chromium
}


setup_github()
{
    sudo $APT -y install git
    git config --global user.name jinqiang
    git config --global user.email jinqiang.zeng@leiainc.com
}

setup_oh_my_zsh()
{
    sudo $APT -y install zsh
    sh -c "$(curl -fsSL https://raw.githubusercontent.com/robbyrussell/oh-my-zsh/master/tools/install.sh)"
}

setup_vim()
{
    sudo $APT -y install vim
    curl https://j.mp/spf13-vim3 -L > spf13-vim.sh && sh spf13-vim.sh
    customize_vim
}

setup_solarized()
{
    # fix color issue for 'ls' command
    pushd  ~
    wget --no-check-certificate https://raw.github.com/seebi/dircolors-solarized/master/dircolors.ansi-dark
    mv dircolors.ansi-dark .dircolors
    eval `dircolors ~/.dircolors`
    git clone https://github.com/sigurdga/gnome-terminal-colors-solarized.git
    cd gnome-terminal-colors-solarized
    sh set_dark.sh
    # fix 'ls' no color issue
    echo eval `dircolors ~/.dircolors` >> ~/.zshrc
    popd
}


customize_vim()
{
    cat <<EOF >>~/.bashrc
alias vim="stty stop '' -ixoff ; vim
vim()
{
    local STTYOPTS="$(stty --save)"
    stty stop '' -ixoff
    command vim "$@"
    stty "$STTYOPTS"
}
EOF
    cat <<EOF >>~/.vimrc.local
set clipboard=unnamed
let g:pymode_rope = 1
set nospell

noremap <silent> <C-S>          :update<CR>
vnoremap <silent> <C-S>         <C-C>:update<CR>
inoremap <silent> <C-S>         <C-O>:update<CR>
EOF
}


setup_pycharm()
{
    sudo add-apt-repository ppa:mystic-mirage/pycharm
    sudo apt update
    sudo apt install pycharm-community
}

setup_protobuf()
{
    dir=$PWD
    cd ~/workspace
    git clone  https://github.com/google/protobuf
    cd protobuf
    git checkout 3.2.x
    sudo $APT install autoconf make g++
    sh autogen.sh
    ./configure
    make
    make check
    sudo make install
    sudo ldconfig
    cd $dir
}

setup_vlc_build()
{
    if [ -f ~/Downloads/android-studio-ide* ]; then
        sudo unzip ~/Downloads/android-studio-ide*.zip -d /opt/
    else
        echo "please download android-studio https://developer.android.com/studio/index.html"
        exit 1
    fi
    cat <<EOF >>~/.bashrc
export PATH=$PATH:/opt/android-studio/bin/
export JAVA_HOME=/opt/android-studio/jre/
export ANDROID_NDK=/home/jinqiang/Android/Sdk/ndk-bundle
export ANDROID_SDK=/home/jinqiang/Android/Sdk/
EOF
    source ~/.bashrc
    pv=`protoc --version | awk '{ print $2 }' | grep -E -o "([0-9][\.][0-9])"`
    if [ ! $(echo "$pv > 3.0" | bc) -ne 0 ]; then
        setup_protobuf
    fi
    sudo $APT install automake ant autopoint cmake build-essential \
        libtool patch pkg-config ragel subversion
    sudo $APT install lib32z1 lib32ncurses5 lib32stdc++6
    dir=$PWD
    cd ~/workspace/
    git clone git@github.com:LeiaInc/LeiaVLC-android.git
    cd LeiaVLC-android
    sh compile.sh -a arm64
    cd $dir
}

# setup_vim
# setup_pycharm
#setup_vlc_build
# setup_protobuf
