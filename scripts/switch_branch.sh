#!/bin/bash

function list_branch()
{
    # 获取本地分支列表
    local_branches=$(git branch --list)

    # 获取远程分支列表
    remote_branches=$(git branch -r)

    # 将本地和远程分支列表合并，并去重
    all_branches=$(echo -e "$local_branches\n$remote_branches" | sort -u)

    # 将分支列表转化为数组
    IFS=$'\n' read -rd '' -a branches_array <<<"$all_branches"

    # 打印分支列表
    echo -e "    Available branches:"
    for branch in "${branches_array[@]}"; do
    # 去除分支名前面的空格、*号和远程仓库名
    branch_name=$(echo "$branch" | sed 's/^[ *]*//; s/^[^\/]*\///')
    echo -e "    - $branch_name"
    done
}

if [ $# -ne 1 ]; then
    echo "Usage: $0 <branch_name>"
    list_branch
    exit 1
fi

branch_name=$1

# 切换主仓库分支
git checkout $branch_name
if [ $? -ne 0 ]; then
    echo "Failed to checkout branch $branch_name"
    exit 1
fi

# 更新子模块
git submodule update --init --recursive

echo "Switched to branch $branch_name and updated submodules."
