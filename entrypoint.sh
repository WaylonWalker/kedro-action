#!/bin/bash

print_step(){
    if $verbose
    then
    echo -e "\n\n\n-----$1-----\n"
    fi
}

success(){
    echo -e "✔ $1"
}

install_python_version(){
    print_step "Install Python Version"
    pyenv install $INPUT_PYTHON_VERSION > /dev/null 2&>1
    pyenv global $INPUT_PYTHON_VERSION > /dev/null 2&>1
}


install_kedro(){
    print_step "Install kedro library"
    if $verbose
    then
    python -m pip install --upgrade pip
    pip install kedro
    else
    python -m pip install --upgrade pip --quiet
    pip install kedro --quiet
    fi
    
}

install_project(){
    print_step "Install kedro project"
    if $verbose
    then
    kedro install
    else
    kedro install > /dev/null 2&>1
    fi
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
    if [ $INPUT_SHOULD_PACKAGE ]; then
        print_step "kedro package"
        kedro package
    fi
}

install_nodejs(){
        print_step "install node"
	print_step "node version"
	if $verbose
	then
	apt-get install curl -y
	curl -sL https://deb.nodesource.com/setup_11.x | bash -
	apt-get install nodejs -y
	else
	apt-get install curl -y  > /dev/null 2&>1
	curl -sL https://deb.nodesource.com/setup_11.x | bash - > /dev/null 2&>1
	apt-get install nodejs -y  > /dev/null 2&>1
	fi
}

kedro_viz(){
    if [ $INPUT_SHOULD_VIZ ]; then
        print_step "kedro viz"
	pip install kedro-viz
        kedro viz --save-file pipeline.json
        print_step "cat pipeline"
        cat pipeline.json
	install_nodejs
	mkdir build_dir && cd build_dir
	git clone https://github.com/WaylonWalker/kedro-static-viz.git --quiet
        rm kedro-static-viz/src/pages/pipeline.json
        cp ../pipeline.json kedro-static-viz/src/pages/pipeline.json
	cd kedro-static-viz
        print_step "cat pages"
        ls src/pages/
	npm install --silent
	npm install -g gatsby-cli --silent
	gatsby build > /dev/null 2&>1
	# mkdir ../../kedro-static-viz
	mv public ../../kedro-static-viz
    fi
    }


install_python_version
install_kedro
install_project
success setup python
kedro_lint
kedro_test
kedro_build_docs
kedro_package
kedro_viz
