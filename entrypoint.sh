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
    if [[ "$*" == *"--exit"* ]]
    then
	message=$(echo $* | sed 's/--exit//g')
	echo -e "❌ $message"
	exit 1
    else
	echo -e "❌ $@"
	status=1
    fi
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
	# Remove everything except .git
	ls -a | xargs -i echo {} | grep -vw "." | grep -vw ".git" | xargs rm -rf {}
        else
        echo remote does not exist
        echo initialize repo
        git init .
        git checkout --orphan $target_branch
        fi
	
        rm -rf ./*
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

kedro_run (){
    if [ $INPUT_SHOULD_RUN ]; then
        print_step "kedro run"
        kedro run
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

kedro_viz(){
    if [ $INPUT_SHOULD_VIZ ]; then
        print_step "kedro viz"
	pip install kedro-viz
	pip install kedro-static-viz
	kedro static-viz --no-serve --directory ~/kedro-action/kedro-static-viz
    fi
    }


##############################
############ MAIN ############
##############################

if $INPUT_VERBOSE
then
echo -e "\n\n\n STARTING \n\n\n"

echo "INPUT_SHOULD_LINT: $INPUT_SHOULD_LINT"
echo "INPUT_SHOULD_TEST: $INPUT_SHOULD_TEST"
echo "INPUT_SHOULD_BUILD_DOCS: $INPUT_SHOULD_BUILD_DOCS"
echo "INPUT_SHOULD_PACKAGE: $INPUT_SHOULD_PACKAGE"
echo "INPUT_SHOULD_VIZ: $INPUT_SHOULD_VIZ"
echo "INPUT_VERBOSE: $INPUT_VERBOSE"

echo -e "\n\n existing files\n\n"
echo -e "\npwd \n\n" && ls pwd
echo -e "\nls pwd \n\n" && ls
echo -e "\nhome \n\n" && ls ~/
echo -e "\nroot \n\n" && ls /
echo -e "\nkedro-static-viz \n\n" && ls kedro-static-viz


fi

 mkdir ~/kedro-action # files to be hosted will go here.
 status=0
 
 
 
##### INSTALL PYTHON #####
# if $INPUT_VERBOSE
# 	then
# 	install_python_version && success successfully installed python || fail failed to install python --exit
# 	else
# 	install_python_version > /dev/null 2>&1 || fail failed to install python --exit
# fi

##### INSTALL KEDRO #####
if $INPUT_VERBOSE
	then
	install_kedro $INPUT_DEPLOY_BRANCH $ && success successfully installed kedro || fail failed to install kedro --exit
	else
	install_kedro > logs/kedro_install.log 2>&1 || fail failed to install kedro --exit
fi

##### INSTALL PROJECT #####
if $INPUT_VERBOSE
	then
	install_project  && success successfully installed project || fail failed to install project --exit
	else
	install_project > logs/project_install.log 2>&1 || fail failed to install project --exit
fi

##### LINT PROJECT #####
if $INPUT_VERBOSE
	then
	kedro_lint && success successfully linted || fail failed to lint --exit
	else
	kedro_lint > logs/lint.log 2>&1 && success successfully linted || fail failed to lint --exit
fi

##### TEST PROJECT #####
if $INPUT_VERBOSE
	then
	kedro_test && success successfully ran tests || fail failed to run tests --exit
	else
	kedro_test > logs/test.log 2>&1 && success successfully ran tests || fail failed to run tests --exit
fi

##### RUN PROJECT #####
if $INPUT_VERBOSE
	then
	kedro_run && success successfully ran pipeline || fail failed to run pipeline
	else
	kedro_run > logs/run.log 2>&1 && success successfully ran pipeline || fail failed to run pipeline
fi

##### BUILD DOCS #####
if $INPUT_VERBOSE
	then
	kedro_build_docs && success successfully built docs || fail failed to build docs
	else
	kedro_build_docs > logs/build_docs.log 2>&1 && success successfully built docs || fail failed to build docs
fi

##### PACKAGE PROJECT #####
if $INPUT_VERBOSE
	then
	kedro_package && success successfully packaged || fail failed to package
	else
	kedro_package > logs/package.log 2>&1 && success successfully packaged || fail failed to package
fi

##### DEPLOY BRANCH #####
mv logs ~/kedro-action/logs
if $INPUT_VERBOSE
	then
	push_to_branch $INPUT_DEPLOY_BRANCH ~/kedro-action && success successfully deployed to $INPUT_DEPLOY_BRANCH || fail failed to deploy to $INPUT_DEPLOY_BRANCH
	else
	push_to_branch $INPUT_DEPLOY_BRANCH ~/kedro-action > /dev/null 2>&1 && success successfully deployed to branch - $INPUT_DEPLOY_BRANCH || fail failed to deploy to branch - $INPUT_DEPLOY_BRANCH
fi

exit $status
