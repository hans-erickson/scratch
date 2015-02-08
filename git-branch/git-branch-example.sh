#!/bin/bash

create_repo()
{
	GIT_DIR="$1"
	if [ -z "$GIT_DIR" ]
	then
		echo "Git directory missing! Exiting to prevent disaster!" 1>&2
		exit 1
	fi
	mv -bvf "$GIT_DIR" "$GIT_DIR".bak
	mkdir -vp "$GIT_DIR"
	cd "$GIT_DIR"
	git init .
}

create_readme()
{
	echo "Creating and committing readme.txt file"
	echo "$1" > readme.txt
	git add readme.txt
	git commit -m "$1"
}

create_branch()
{
	new_branch="$(echo $1 | sed 's/ /_/g')"
	base_branch="$(echo $2 | sed 's/ /_/g')"
	message="$1"

	ALL_BRANCHES="$ALL_BRANCHES $new_branch"

	if [ ! -z "$base_branch" ]
	then
		echo "Starting with branch $base_branch"
		git checkout "$base_branch"
	fi
	echo "Creating branch $new_branch"
	git checkout -b "$new_branch"
	create_readme "$message"
}

create_baseline()
{
	new_baseline="$(echo $1 | sed 's/ /_/g')"
	previous_baseline="$(echo $2 | sed 's/ /_/g')"
	git checkout "$previous_baseline"
	git baseline "$new_baseline"
}

merge()
{
# git branch task_7 initial_baseline; git checkout task_7; git merge -s ours task_2 task_3 task_4 -m "task 7"; echo "task 7" > readme.txt; git commit -a -m "task 7"

	initial_baseline="$(echo $1 | sed 's/ /_/g')"
	commit_text="$2"
	merge_task="$(echo $2 | sed 's/ /_/g')"
	first_merged="$(echo $3 | sed 's/ /_/g')"
	shift
	shift

	ALL_BRANCHES="$ALL_BRANCHES $merge_task"

	echo "Creating branch $merge_task"
	git branch "$merge_task" "$initial_baseline"
	git checkout "$merge_task"

	while [ ! -z "$1" ]
	do
		task_list="$task_list $(echo $1 | sed 's/ /_/g')"
		shift
	done

	echo "merging $task_list"
	git merge -s ours $task_list -m "$commit_text"

	echo "Creating readme.txt file"
	echo "$commit_text" > readme.txt
	git commit -a -m "fixup! $commit_text"

	GIT_EDITOR=/bin/cat git rebase --autosquash -i HEAD~2 --preserve-merges
}

remove_branches()
{
	while [ ! -z "$1" ]
	do
		git branch -d $1
		shift
	done
}

create_repo "/tmp/blah"
create_branch "initial baseline"
create_branch "task 1" "initial baseline"
create_branch "task 2" "task 1"
create_branch "task 3" "task 1"
create_branch "task 4" "task 1"
create_branch "task 5" "task 2"
create_branch "task 6" "initial baseline"
#create_branch "final baseline" "initial baseline"


#  git branch task_7 task_3
#  git checkout task_7
#  git merge -s ours task_3 task_4 task_5 -m "task 7"
merge "initial baseline" "task 7" "task 2" "task 3" "task 4"

merge "initial baseline" "final baseline" "task 1" "task 5" "task 6" "task 7"

remove_branches $ALL_BRANCHES
