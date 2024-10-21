#!/bin/bash
#
# clone all the subrepo
#

function print_help(){
    echo "./init.sh [--release RELNAME | --source | -h]"
    echo ""
    echo "		--source            check out only the source code and not the entire GIT repo"
    echo "		--release RELNAME   download the RELNAME release of the code"
    echo ""
}


while [ $# -ge 1 ]; do
    case "$1" in
	--)
	    # No more options left.
	    shift
	    break
	    ;;
	--source)
	    SOURCE=true
	    baseURL="https://github.com/ljnk975"
	    ;;
	--release)
	    rel_name=$2
	    shift
	    ;;
	-h)
	    print_help
	    exit 0
	    ;;
    esac
    shift
done

SubModule=`cat .gitignore`

remote=`git remote -v|awk '{print $2}'|head -n 1`
baseRemote=`dirname $remote`

start_time=$(date +%s)

pushd src/roll
for i in $SubModule;
do 
    modName=`basename $i`
    if [ "$SOURCE" ]; then
	#if rel_name is not defined set it to master
	test $rel_name || rel_name=master
	if [ "$rel_name" == "master" ] ; then
	    wget -nv -O $modName.tar.gz $baseURL/$modName/archive/$rel_name.tar.gz || exit 1
	else
	    # maybe that branch is not defined for this repo let's skip it
	    wget -nv -O $modName.tar.gz $baseURL/$modName/archive/$rel_name.tar.gz || continue
	fi
	tar -xzf $modName.tar.gz || exit 1
	mv $modName-$rel_name $modName || exit 1
	rm $modName.tar.gz
    else
	echo "  Cloning $baseRemote/$modName.git repository" 
	git clone $baseRemote/$modName.git $modName || exit 1
	echo release name $rel_name
	if [ "$rel_name" ]; then
	    pushd $modName
	    git checkout "$rel_name"
	    popd
	fi
	
    fi
done
popd

finish_time=$(date +%s)
echo "Time duration: $((finish_time - start_time)) secs."

