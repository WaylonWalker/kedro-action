FROM python:3

LABEL "com.github.actions.name"="Kedro"
LABEL "com.github.actions.description"="A Github Action to run kedro commands"
LABEL "com.github.actions.icon"="git-branch"
LABEL "com.github.actions.color"="black"

LABEL "repository"="http://github.com/WaylonWalker/kedro-action"
LABEL "maintainer"="Waylon Walker <waylon@waylonwalker.com>"


RUN apt-get update
RUN apt-get install -y jq

ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
