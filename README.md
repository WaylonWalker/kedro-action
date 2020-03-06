# Kedro-Action

A GitHub Action to `lint`, `test`, `build-docs`, `package`, and `run` your [kedro](https://github.com/quantumblacklabs/kedro) pipelines. Supports any Python version you'll give it (that is also supported by [pyenv](https://github.com/pyenv/pyenv)). 

Inspired by [mariamrf/py-package-publish-action](https://github.com/mariamrf/py-package-publish-action).

# Use

## Pre-requisits

In order for the Action to have access to the code, you must use the actions/checkout@master job before it. See the example below.

## Inputs

* python_version:
    * description: a Python version that is supported by pyenv
    * default: '3.7.0'
* should_lint:
    * description: runs `kedro lint`
    * default: true
* should_test:
    * description: runs `kedro test`
    * default: true
* should_build_docs:
    * description: runs `kedro build-docs`
    * default: true
* should_package:
    * description: runs `kedro package`
    * default: true
* should_run:
    * description: runs `kedro run`
    * default: false

## Example Workflow

``` yaml
name: kedro

on:
  push:
    branches:
      - master

jobs:
  kedro:

    runs-on: ubuntu-latest
    
    steps:
    - uses: actions/checkout@master
    - name: Kedro
      uses: WaylonWalker/kedro-action@1.0.3
      with:
        python_version: '3.7.0'
# OPTIONAL
# Deploy docs to gh-pages branch
    - name: Deploy-docs
      uses: crazy-max/ghaction-github-pages@v1.3.0
      with:
        target_branch: gh-pages-docs
        build_dir: docs/build/html
      env:
        GITHUB_PAT: ${{ secrets.GITHUB_PAT }}

```
