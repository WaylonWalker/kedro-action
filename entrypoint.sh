#!/bin/bash

print_step(){
    echo -e "\n\n\n-----$1-----\n"
}

install_python_version(){
    print_step "Install Python Version"
	pyenv install $INPUT_PYTHON_VERSION
	pyenv global $INPUT_PYTHON_VERSION
}


install_kedro(){
    print_step "Install kedro library"
    python -m pip install --upgrade pip
    pip install kedro
}

install_project(){
    print_step "Install kedro project"
    kedro install
}

kedro_lint(){
    if [ $INPUT_SHOULD_LINT ]; then
        print_step "kedro lint"
        kedro lint
    fi
}

kedro_test(){
    if [ $INPUT_SHOULD_TEST ]; then
        print_step "kedro test"
        kedro test
    fi
}

kedro_build_docs(){
    if [ $INPUT_SHOULD_BUILD_DOCS ]; then
        print_step "kedro build-docs"
        kedro build-docs
    fi
}

kedro_package(){
    if [ $INPUT_SHOULD_PACKAGE]; then
        print_step "kedro package"
        kedro package
    fi
}


install_python_version
install_kedro
install_project
kedro_lint
kedro_test
kedro_build_docs
kedro_package