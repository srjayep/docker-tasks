[\[Top\]](../README.md)

## Overview
...To build a Docker image from a given repository (ex. Open Source repo github.com/adobe-apiplatform/apigateway or an intranet git.corp repo)\
 
## General Approach
...In the spirit of keeping API Gateway's docker build-process interaction as simple as possible, if you are in the repository directory, the general way of building the solution is to follow:
```
> rake prepare_fixtures  
> rake docker:build

```

Type rake -T to see a list of possible tasks that you can run. (ones in grey are under development)

```
rake build                        Build docker-tasks-0.1.0.gem into the pkg directory / Perform any steps necessary to build the project
rake  clean                       Remove any temporary products
rake clean:container              Clean up local Docker containers
rake clean:images                 Clean up artifacts and local Docker images
rake clobber                      Remove any generated files
rake docker:build                 Build a Docker container from this repo
rake docker:push                  Push the recently tagged Docker container from this repo to the registry
rake docker:release               Build Docker image for release, tag it, push it to registry
rake docker:tag                   Tag a Docker container from this repo 
rake install                      Build and install docker-tasks-0.1.0.gem into system gems
rake install:local                Build and install docker-tasks-0.1.0.gem into system gems without network access
rake lint                         Run all lint checks against the code
rake lint:bundler-audit           Run bundler-audit against the Gemfile
rake lint:cloc                    Show LOC metrics for project using cloc
rake lint:rubocop                 Run Rubocop against the codebase
rake prepare_fixtures             Copying the git repo into current directory
rake release[remote]              Create tag v0.1.0 and build and push docker-tasks-0.1.0.gem to Rubygems in artifactory
```
## To build docker image locally on your workstation
```
..- Setup your mac
..- Install Docker
..- Clone repository
..- Setup environment for docker-tasks
..- Run tasks to build docker image
```

### 1. OSX Setup
1. Download and install Xcode from the App Store
2. Command Line Tools for Xcode Install : xcode-select --install

3. Install homebrew by typing the following in a terminal window:
     ..*ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"
4. To make sure that homebrew is set up properly, type the following command and make the changes that homebrew recommends
     ..*brew doctor
5. Update tar to use gnu-tar instead of Mac OSX bsd-tar
     ..*brew update;
     ..*brew install gnu-tar;
     ..*ln -s /usr/local/opt/gnu-tar/libexec/gnubin/tar /usr/local/bin/tar;
6. Install brew cask
     ..*brew install caskroom/cask/brew-cask
7. Install rvm 
     ..*\curl -sSL https://get.rvm.io | bash -s stable

9. Install ruby* 2.3.1 using rvm 
     ..*rvm install 2.3.1; rvm use 2.3.1 --default

10. Install bundler 
     ..*sudo gem install bundler
...If you encounter the 'rvm command not found' error after installing rvm, then chances are you in an older shell. Please either open a new shell or type [source ~/.rvm/scripts/rvm] in your existing shell. If you continue to see the same error after the fact then check to see if your .bash_profile has been mangled and either fix it manually or close and reopen terminal window or reinstall rvm.
 
### 2. Install Docker

..*https://download.docker.com/mac/stable/Docker.dmg
..*Double-click Docker.dmg to open the installer, then drag Moby the whale to the Applications folder.  (https://docs.docker.com/docker-for-mac/)

####Install Docker app
...You will be asked to authorize Docker.app with your system password during the install process. Privileged access is needed to install networking components and links to the Docker apps.

..*Double-click Docker.app to start Docker in Applications.
...The whale in the top status bar indicates that Docker is running.


### 3. Setup Rakefile.local 
...In general, running rake <tasks> should just "work"; however, there are times that it's helpful to produce only specific artifacts or enable debugging. This can be done by maintaining a Rakefile.local in the root of your [docker-tasks] directory. Note: the Rakefile.local file should be listed in the repo's .gitignore file and should never be committed.
```
ENV["FORCE_TAG"] = "0"                                                 # Will force docker tag if 1
ENV['DOCKER_REPO'] = "docker-api-platform-snapshot/apiplatform"        # repo name 
ENV['DOCKER_TAG'] = "snapshot-`date +'%Y%m%d-%H%M'`"                   # Name your tag image
ENV['GIT_REPO'] = "adobe-apiplatform/apigateway"                       # Git oranization/Repo name 
ENV['GIT_TYPE'] = "PUBLIc"                                             # public (github.com) or private (git.corp.adobe.com) - ignore case
ENV['FORCE_PUSH'] = "1"                                                # Forcibly overwrite a tag on the registry
ENV['FORCE_TAG=1] = "1"                                                # Forcibly  re-tag locally
ENV["RELEASE_VERSION"] = <version>                                     # Tag the release version
```
### 4. Run task to build image

..*bundle install              # pull down all the dependencies
..*rake prepare_fixtures       # pull required git repository from Rakefile.local to build docker image from
..*rake docker:build           # builds docker image locally
 


### FAQ
Q: When I run rake, I'm seeing gem related or missing require errors, what do I do?
bundle install    # the Gemfile may have been updated - come up to date
Q: My previous build may have not finished properly and now I'm seeing weird errors when I run rake, what do I do?
rake clobber      # does a rake clean followed by deleting any downloaded dependencies 
Q: How do I get more information from rake?
rake [<task> ...] --trace

