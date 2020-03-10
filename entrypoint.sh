#!/bin/bash

print_step(){
    if $INPUT_VERBOSE
    then
    echo -e "\n\n\n-----$1-----\n"
    fi
}

success(){
    echo -e "✅ $@"
}

fail(){
    echo -e "❌ $@"
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
    if [ $INPUT_SHOULD_PACKAGE ]; then
        print_step "kedro package"
        kedro package
    fi
}

install_nodejs(){
        print_step "install node"
	print_step "node version"
	apt-get install curl -y
	curl -sL https://deb.nodesource.com/setup_11.x | bash -
	apt-get install nodejs -y
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

if $INPUT_VERBOSE
then
echo "\n\n\n STARTING \n\n\n"

echo "INPUT_SHOULD_LINT: $INPUT_SHOULD_LINT"
echo "INPUT_SHOULD_TEST: $INPUT_SHOULD_TEST"
echo "INPUT_SHOULD_BUILD_DOCS: $INPUT_SHOULD_BUILD_DOCS"
echo "INPUT_SHOULD_PACKAGE: $INPUT_SHOULD_PACKAGE"
echo "INPUT_SHOULD_VIZ: $INPUT_SHOULD_VIZ"
echo "INPUT_VERBOSE: $INPUT_VERBOSE"
fi

if $INPUT_VERBOSE
	then
	install_python_version && success successfully installed python || fail failed to install python
	else
	install_python_version > /dev/null 2>&1 || fail failed to install python
fi

if $INPUT_VERBOSE
	then
	install_kedro && success successfully installed kedro || fail failed to install kedro
	else
	install_kedro > /dev/null 2>&1 || fail failed to install kedro
fi

if $INPUT_VERBOSE
	then
	install_project > /dev/null 2>&1 || fail failed to install project
	else
	install_project && success successfully installed project || fail failed to install project
fi

if $INPUT_VERBOSE
	then
	kedro lint && success successfully linted || fail failed to lint
	else
	kedro_lint > /dev/null 2>&1 && success successfully linted || fail failed to lint
	
fi

kedro_test
kedro_build_docs
kedro_package
kedro_viz
