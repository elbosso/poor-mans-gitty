# poor-mans-gitty

*poor-mans-gitty* is a CLI (actually: Bash) helper for git projects, that shows you issues, pull requests and much more at a quick glance. It uses the GitLab API.

This repo is heavily inspired by the one and only - the original: [gitty](https://github.com/muesli/gitty) - if you want to work with GitHub repos - please consider using the
[original](https://github.com/muesli/gitty)!

<!---
[![start with why](https://img.shields.io/badge/start%20with-why%3F-brightgreen.svg?style=flat)](http://www.ted.com/talks/simon_sinek_how_great_leaders_inspire_action)
--->
[![GitHub release](https://img.shields.io/github/release/elbosso/poor-mans-gitty/all.svg?maxAge=1)](https://GitHub.com/elbosso/poor-mans-gitty/releases/)
[![GitHub tag](https://img.shields.io/github/tag/elbosso/poor-mans-gitty.svg)](https://GitHub.com/elbosso/poor-mans-gitty/tags/)
[![made-with-bash](https://img.shields.io/badge/Made%20with-Bash-1f425f.svg)](https://www.gnu.org/software/bash/)
[![GitHub license](https://img.shields.io/github/license/elbosso/poor-mans-gitty.svg)](https://github.com/elbosso/poor-mans-gitty/blob/master/LICENSE)
[![GitHub issues](https://img.shields.io/github/issues/elbosso/poor-mans-gitty.svg)](https://GitHub.com/elbosso/poor-mans-gitty/issues/)
[![GitHub issues-closed](https://img.shields.io/github/issues-closed/elbosso/poor-mans-gitty.svg)](https://GitHub.com/elbosso/poor-mans-gitty/issues?q=is%3Aissue+is%3Aclosed)
[![contributions welcome](https://img.shields.io/badge/contributions-welcome-brightgreen.svg?style=flat)](https://github.com/elbosso/poor-mans-gitty/issues)
[![GitHub contributors](https://img.shields.io/github/contributors/elbosso/poor-mans-gitty.svg)](https://GitHub.com/elbosso/poor-mans-gitty/graphs/contributors/)
[![Github All Releases](https://img.shields.io/github/downloads/elbosso/poor-mans-gitty/total.svg)](https://github.com/elbosso/poor-mans-gitty)
[![Website elbosso.github.io](https://img.shields.io/website-up-down-green-red/https/elbosso.github.io.svg)](https://elbosso.github.io/)

The main script is `workWithGitlab.sh` - when called with argument `-?` - it shows this help:

```
usage: workWithGitlab.sh -h host  -p projectid  -x token -a action [ -n max_number_of_results ] | [-?]
valid operations:
    - issues
    - commits
    - branches
    - pipelines
    - milestones
    - merge_requests
    - tags
    - releases
    - commits_since_last_release
    - commits_since_last_tag
```

When called from within a working directory of a gitlab project - the options `-h` and `-p` can be omitted - the script fetches them itself from the environment and context.
The access token can be given by using parameter `-x`. Alternatively it is possible to set environment variable `GITLAB_ACCESS_TOKEN` accordingly.

An example call to list the 3 most recent issues would be for example (token value for illustration purposes only):

```
GITLAB_ACCESS_TOKEN=xxxx-xxxx-xxxxxxxxxx workWithGitlab.sh -a issues -n 3
```
