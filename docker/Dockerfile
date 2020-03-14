FROM python:3.7-slim

LABEL "com.github.actions.name"="kedro-action"
LABEL "com.github.actions.description"="A Github Action to run kedro commands"
LABEL "com.github.actions.icon"="it-branch"
LABEL "com.github.actions.color"="black"

LABEL "repository"="http://github.com/WaylonWalker/kedro-action"
LABEL "maintainer"="Waylon Walker <waylon@waylonwalker.com>"

RUN apt-get update
RUN apt-get install -y jq
RUN apt-get install -y curl

# ENV PYENV_ROOT /root/.pyenv
# ENV PATH $PYENV_ROOT/shims:$PYENV_ROOT/bin:$PATH
# RUN curl -L https://github.com/pyenv/pyenv-installer/raw/master/bin/pyenv-installer | bash

### INSTALL PYTHON ###
# RUN pyenv install 3.7.6
# RUN pyenv global 3.7.6
RUN python -m pip install --upgrade pip
RUN pip install kedro
RUN pip install kedro-viz

### INSTALL NODEJS ###
RUN apt-get install curl -y
RUN curl -sL https://deb.nodesource.com/setup_11.x | bash -
RUN apt-get install nodejs -y

### CLONE KEDRO-STATIC-VIZ ###
RUN mkdir ~/build_dir && cd ~/build_dir
RUN git clone https://github.com/WaylonWalker/kedro-static-viz.git
RUN cd kedro-static-viz
RUN npm install -g gatsby-cli
RUN cd kedro-static-viz && npm install && npm audit fix
