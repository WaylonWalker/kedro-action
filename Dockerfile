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


RUN apt-get update
RUN apt-get install -y jq

ENV PYENV_ROOT /root/.pyenv
ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
RUN curl -L https://github.com/pyenv/pyenv-instaUR
### INSTALL PYTHON ###
RUN pyenv install 3.7.6
RUN pyenv global 3.7.6
RUN python -m pip install --upgrade pip
RUN pip install kedro
RUN pip install kedro-viz
RUN pip install kedro-static-viz

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
