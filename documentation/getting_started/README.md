[\[Top\]](../README.md)

# Getting Started

## Prerequisites

In order to develop code chef cookbooks for API Platform, you will need to have a host-system that is running either OSX or Linux. 

Please follow the instructions below for your OS and continue on with the all OS instructions.

Some of the software below may require workstation administrator access to install. To obtain adminstrator access :

### OSX Setup 

* Download and install 
    * `Xcode` from the [App Store](https://itunes.apple.com/us/app/xcode/id497799835?mt=12#)
    * [Command Line Tools for Xcode install] (xcode-select --install)
* Install [`homebrew`](http://brew.sh/) by typing the following in a terminal window:
```
ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
```
* To make sure that homebrew is set up properly, type the following command and make the changes that homebrew recommends
```
brew doctor
```
* Update tar to use gnu-tar instead of Mac OSX bsd-tar
```
brew update;
brew install gnu-tar;
ln -s /usr/local/opt/gnu-tar/libexec/gnubin/tar /usr/local/bin/tar;
```
* Install brew cask
```
brew install caskroom/cask/brew-cask
```


### All OS Setup

* Install [virtualBox](https://www.virtualbox.org/) (free)[`brew cask install virtualbox`] or vmware [workstation (win/linux)](http://www.vmware.com/products/workstation) or [fusion professional (OSX)](http://www.vmware.com/products/fusion)
* Install [vagrant](http://www.vagrantup.com/) [`brew cask install vagrant; brew cask install vagrant-manager`]
* Install [packer](http://www.packer.io/) [`brew tap homebrew/binary; brew install packer`]
* Install [rvm](https://rvm.io) [`\curl -sSL https://get.rvm.io | bash -s stable`]
* Install [ruby*](https://www.ruby-lang.org) 2.0.0 using rvm [`rvm install 2.0.0-p481; rvm use 2.0.0-p481 --default`]
* Install [bundler](http://bundler.io/) [`sudo gem install bundler`]

If you encounter the 'rvm command not found' error after installing rvm, then chances are you in an older shell.  Please either open a new shell or type [`source ~/.rvm/scripts/rvm`] in your existing shell.  If you continue to see the same error after the fact then check to see if your .bash_profile has been mangled and either fix it manually or close and reopen terminal window or reinstall rvm.

If you plan on using VMWare with [vagrant](http://www.vagrantup.com/) then you will need to purchase a [VMWare Provider](https://www.vagrantup.com/vmware) for the kind of VMware that you will be using (fusion or workstation).  Upon purchasing your license, you will receive an email to explain how to install the provider and the license.

## Getting the Code

### Cloning a Tier Repository to work on

In order to get up to speed, identify which repository (i.e. ${GIT_REPO}) you want to start working with 

```
> git clone --recursive https://git.corp.adobe.com/cloudops/apiplatformcookbooks/${GIT_REPO}.git
```

It's important to specify the `--recursive` switch since these projects use git submodules.  If you forget to do this then you will need
to do a `git submodule update --init --recursive` while in the root directory afterwards.

In case of git outages, it is also helpful to have a copy of all git repos saved locally. To Clone all git repos, this shell code would help you:

```
# the git clone cmd used for cloning each repository
# the parameter recursive is used to clone submodules, too.
GIT_CLONE_CMD="git clone --recursive "

# fetch repository list via github api
# grep fetches the json object key ssh_url, which contains the ssh url for the repository
REPOLIST=`curl -H "Authorization: token <token>" https://git.corp.adobe.com/api/v3/orgs/Cloudops/repos?per_page=900 -q| grep "\"ssh_url\"" | awk -F': "' '{print $2}' | sed -e 's/",//g'`

# loop over all repository urls and execute clone
for REPO in $REPOLIST; do
echo ${REPO}
${GIT_CLONE_CMD}${REPO}
done
```
## One time Setup

Before you start writing any tests or code in any repository, you will need to run the following commands first:

### Tier Repository

In both the packer and vagrant directories:

```
> cd ${GIT_REPO}              # switch directories to where you did your clone
> bundle install              # pull down all the dependencies
```

## Going Forward

### Development Process

Now that you have pre-requisites installed, a respository cloned, and are ready to start developing, please refer to the [Development Guide](../../../README.md) on how to proceed.
