# CI-helpers

Inspired by the [astropy's ci-helpers](https://github.com/astropy/ci-helpers)
package. This repository provides a set of scripts to build certain dependencies
needed on CI platforms like [Travis](https://travis-ci.com).


## How to use

### Travis

Basic use requires to add the following lines to your `.travis.yml` file:

```yaml
install:
  - git clone --depth 1 git://github.com/UCL-RSDG/ci-helpers.git
  - source ci-helpers/travis/setup.sh
```

If you want to take advantage of caching what this installs, then you would
also need to add such information on your `.travis.yml` file:

```yaml

cache:
  directories:
    - $HOME/ci-helpers
```
