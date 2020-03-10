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

push_to_branch() {
	
	target_branch=$1
	deploy_directory=$2
        REMOTE="https://${INPUT_GITHUB_PAT}@github.com/${GITHUB_REPOSITORY}.git"
        COMMITER_NAME="${GITHUB_ACTOR}-github-actions"
        COMMITER_EMAIL="${GITHUB_ACTOR}-@users.noreply.github.com"
        REMOTE_BRANCH_EXISTS=$(git ls-remote --heads ${REMOTE} ${target_branch} | wc -l)        
        
        mkdir /tmp/cloned
        cd /tmp/cloned
        
        if $keep_history && [ $REMOTE_BRANCH_EXISTS -ne 0 ]
        then
        git clone --quiet --branch ${target_branch} --depth 1 ${REMOTE} .
        else
        echo remote does not exist
        echo initialize repo
        git init .
        git checkout --orphan $target_branch
        fi
	
	cp -r $deploy_directory .
        
        DIRTY=$(git status --short | wc -l)
        
        if $keep_history &&  [ $REMOTE_BRANCH_EXISTS -ne 0 ] && [ $DIRTY = 0 ]
        then
        echo '⚠️ There are no changes to commit, stopping.'
        else
        git config user.name ${COMMITER_NAME}
        git config user.email ${COMMITER_EMAIL}
        git add --all .
        git commit -m "DIST to ${target_branch}"

        echo 🏃 Deploying ${build_dir} directory to ${target_branch} branch on ${repo} repo
        
        if [ $keep_history == false]
        then
        git push --quiet ${REMOTE} ${target_branch}
        else
        git push --quiet --force ${REMOTE} ${target_branch}
        fi
        echo 🎉 Content of ${build_dir} has been deployed to GitHub Pages.
        fi

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
    	mkdir ~/kedro-action/test-report/
        print_step "kedro test"
	pip install pytest-html
        kedro test --html=~/kedro-action/test-report/index.html
    fi
}

kedro_build_docs(){
    if [ $INPUT_SHOULD_BUILD_DOCS ]; then
        print_step "kedro build-docs"
        kedro build-docs
	mv docs/build/html ~/kedro-action/docs
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
	mkdir ~/build_dir && cd ~/build_dir
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
	mv public ~/kedro-action/viz
    fi
    }


##############################
############ MAIN ############
##############################

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

 mkdir ~/kedro-action # files to be hosted will go here.
 status=0
 
if $INPUT_VERBOSE
	then
	install_python_version && success successfully installed python || fail failed to install python && status=1
	else
	install_python_version > /dev/null 2>&1 || fail failed to install python && status=1
fi

if $INPUT_VERBOSE
	then
	install_kedro $INPUT_DEPLOY_BRANCH $ && success successfully installed kedro || fail failed to install kedro && status=1
	else
	install_kedro > /dev/null 2>&1 || fail failed to install kedro && status=1
fi

if $INPUT_VERBOSE
	then
	install_project  && success successfully installed project || fail failed to install project && status=1
	else
	install_project > /dev/null 2>&1 || fail failed to install project && status=1
fi

if $INPUT_VERBOSE
	then
	kedro lint && success successfully linted || fail failed to lint && status=1
	else
	kedro_lint > /dev/null 2>&1 && success successfully linted || fail failed to lint && status=1
	
fi

if $INPUT_VERBOSE
	then
	kedro_test && success successfully ran tests || fail failed to run tests && status=1
	else
	kedro_test > /dev/null 2>&1 && success successfully ran tests || fail failed to run tests && status=1
fi

if $INPUT_VERBOSE
	then
	kedro_build_docs && success successfully built docs || fail failed to build docs && status=1
	else
	kedro_build_docs > /dev/null 2>&1 && success successfully built docs || fail failed to build docs && status=1
fi

if $INPUT_VERBOSE
	then
	kedro_package && success successfully packaged || fail failed to package && status=1
	else
	kedro_package > /dev/null 2>&1 && success successfully packaged || fail failed to package && status=1
fi

if $INPUT_VERBOSE
	then
	kedro_viz && success successfully built visualization || fail failed to build visualization && status=1
	else
	kedro_viz > /dev/null 2>&1 && success successfully built visualization || fail failed to build visualization && status=1
fi

if $INPUT_VERBOSE
	then
	push_to_branch $INPUT_DEPLOY_BRANCH ~/kedro-action && success successfully deployed to $INPUT_DEPLOY_BRANCH || fail failed to deploy to $INPUT_DEPLOY_BRANCH && status=1
	else
	push_to_branch $INPUT_DEPLOY_BRANCH ~/kedro-action > /dev/null 2>&1 && success successfully deployed to $INPUT_DEPLOY_BRANCH || fail failed to deploy to $INPUT_DEPLOY_BRANCH && status=1
fi

exit $status
