[\[Top\]](../README.md)

# Development

## Overview

## General Approach

In the spirit of keeping API Gateway's docker build-process interaction as simple as possible, if you are in the repository directory, the general way of building the solution is to follow:

```
> rake test       # runs code quality checks, unit tests, build artifacts, systems tests
```

Type `rake -T` to see a list of possible tasks that you can run.

### Rakefile.local

In general, running `rake test` should just "work"; however, there are times that it's helpful to produce only specific artifacts or enable debugging.  This can be done by maintaining a `Rakefile.local` in the root of your [`docker-tasks`] directory. Note: the `Rakefile.local` file should be listed in the repo's `.gitignore` file and should never be committed.

#### 

```
ENV["FORCE_TAG"] = "0"                                                 # Will force docker tag if 1
ENV['DOCKER_REPO'] = "docker-api-platform-snapshot/apiplatform"        # repo name 
ENV['DOCKER_TAG'] = "snapshot-`date +'%Y%m%d-%H%M'`"                   # Name your tag image
ENV['GIT_REPO'] = "adobe-apiplatform/apigateway"                       # Git oranization/Repo name 
ENV['GIT_TYPE'] = "PUBLIc"                                             # public (github.com) or pivate (git.corp.adobe.com) - ignore case
ENV['FORCE_PUSH'] = "1"                                                # Forcibly overwrite a tag on the registry
ENV['FORCE_TAG=1] = "1"                                                # Forcibly  re-tag locally
ENV["RELEASE_VERSION"] = <version>                                     # Tag the release version
```

#### All

Q: When I run `rake`, I'm seeing gem related or missing `require` errors, what do I do?

```
bundle install    # the Gemfile may have been updated - come up to date
```

Q: My previous build may have not finished properly and now I'm seeing weird errors when I run rake, what do I do?

```
rake clobber      # does a rake clean followed by deleting any downloaded dependencies 
```

Q: How do I get more information from `rake`?

```
rake [<task> ...] --trace
```
