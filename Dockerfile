FROM python:3.7

LABEL "com.github.actions.name"="kedro-action"
LABEL "com.github.actions.description"="A Github Action to run kedro commands"
LABEL "com.github.actions.icon"="it-branch"
LABEL "com.github.actions.color"="black"

LABEL "repository"="http://github.com/WaylonWalker/kedro-action"
LABEL "maintainer"="Waylon Walker <waylon@waylonwalker.com>"

RUN apt-get update
RUN apt-get install -y jq

ADD entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]
