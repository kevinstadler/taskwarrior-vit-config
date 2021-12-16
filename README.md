# a taskwarrior / `vit` / vimwiki pipeline

This repository is a `homes(h)ick` castle for taskwarrior/vit configuration files and related scripts that I use for task and project management.

## history

* in spring 2021 I started using [taskwarrior](https://taskwarrior.org) with [vit](https://github.com/vit-project/vit) as an interactive frontend
* while taskwarrior works great for managing individual tasks, I never found a good way to organise groups of tasks into projects, or keeping track of what projects I was currently working on (in Agile lingo: I couldn't find a good way to assign tasks to sprints, schedule and manage sprints etc.)
* for managing hierarchies of dependent tasks (typical for project organisation) I tried out [taskwiki](https://github.com/tools-life/taskwiki), but I found it to be very slow and it [does not support batch updating of tasks](https://github.com/tools-life/taskwiki/issues/196#issuecomment-634789028)
* in the end I implemented a [custom script for populating/parsing tasks](bin/taskproject) which I call from `vit`. it populates a vimwiki file with task lists which I can then edit interactively in `vipe`, on exit it parses changes and writes them into the taskwarrior database before returning to `vit`.

## workflow

My `vit`/`task` database doubles as [both parts of task and project management](https://medium.com/strong-opinions/daily-planning-the-bulletproof-system-54367a45b422): on one hand (more unusally) a *personal dashboard* for long-term tracking of ideas which turn into projects/goals and grow more and more specific tasks. This permanent storage archive ends up producing my actual *to do list*, which feeds into my paper-based daily bullet journalling which I use to organize my days.

### part 1: dashboard workflow
#### goals

* [X] specific, measureable long-term goals are tasks with a `+goal` tag. they should certainly have a `scheduled` (start) date, and optionally also a `due` date (if there is an actual deadline)
* [X] the `:goals` report shows all current and future goals sorted by their `scheduled` dates
* completed/deleted goals at the bottom

#### idea / project workflow

To understand the meaning of the taskwarrior tags (e.g. `+ACTIVE`), see [virtual tag logic](https://kevinstadler.github.io/notes/taskwarrior-virtual-tag-logic/).

* idea -> project/goal
  * [X] undeveloped ideas are tasks with an `+idea` tag. they don't need to be specific or measurable like goals. I add them as I go along.
  * [X] dedicated `:ideas` report shows ideas/projects in all states, with their annotations
  * [X] `+idea` tasks are hidden from `:next` even if they're `+ACTIVE`
  * [ ] ~~how will I add annotations to an idea to turn it into a concrete project/goal? -- look at onenote~~
  * [X] once I start working on an idea it will be tagged as `+project`, assigned a `project:` which all consequent goals/tasks will be grouped under as well, and (usually) made `+ACTIVE` by setting a `start:` date

In a previous paper-based project journal I kept track (and a check on the number) of currently active projects by grouping them in different stages. The different stages (and their corresponding taskwarrior states) are:

* ongoing (`+ACTIVE`)
* blocked (`+blocked`)
* filed (`+WAITING`)
* completed (`+COMPLETED`)
* scrapped (`+DELETED`)

### part 2: project phase / task workflow

within a project, tasks are organized in two ways:

1. they are grouped into task dependency hierarchies (a big goal will have it's sub-goals or tasks as dependencies). neither taskwarrior nor vit have the ability to display dependency hierarchies, so while I might add individual tasks from within vit, the hierarchy visualisation and management are all done by [taskproject script](bin/taskproject).
2. tasks go through a series of *states* that are meaningful within the project (but obviously also makes them show up in my `next` report todo list whenever it's appropriate
  1. a pending task can be marked for inclusion in the next sprint by adding `+next`
  2. when a sprint is started, all `+next` tasks of the project get `scheduled:now` and a `due:` date that needs be set from within vit *and that is propagated to all `+next` dependency tasks*

within `taskproject`, the project task state can be distinguished in the following way:

* goals (`+goal or +idea`) are the big (visualisable) outcomes that I am working towards
* `[*]` current (`+DUE or +OVERDUE or +ACTIVE or (+SCHEDULED (+READY or +BLOCKED))`) are already ongoing or scheduled. when a project task is scheduled, it should also be given a due: date 
* `[+]` queued (`+next` and `due:`) are tasks that are marked for a spring that hasn't started yet
* `[ ]` pending are ALL `-WAITING` tasks (including all of the ones above)
* `[W]` filed (`+WAITING`)

#### distinguishing sprint-deadline tasks from "real" deadline tasks

(TODO is this necessary? if I simply propagate due dates through the task dependency hierarchies, is the `+next` tag not enough?) many non-project-related tasks have a due date. in order to be able to quickly filter out these "real" deadline tasks from sprint-deadline tasks, sprint tasks get a scheduled: date at the time when their corresponding sprint is started

Modelling this hierarchy with urgency:

* `+OVERDUE`, `+DUE` tasks (urgency 100)
* `+ACTIVE` tasks (extra urgency...30?)
* `+SCHEDULED` tasks (-50 to distinguish from 'real' deadlines
* `+BLOCKING` tasks +10 because they are more important than loose tasks? (is this necessary?)
* `+next` tasks (+10)
* `+WAIING` tasks (-100ish?)

In the `next` report, *hide* `+project` and `+BLOCKED` tasks

### workflow keybindings

general idea:

* lower case letters for:
  1. navigating to reports
    * `q`: `:next` (return to home page)
    * `i`: `:ideas` list
    * `j`: `:pj` project journal
    * `k`: `:goals` list
    * `p`: `:project` project task list (prompts project name)
  2. basic (non-context dependent) operations
    * defaults such as `a`, `m`
* upper case letters for:
  * context/project-dependent operations
    * `A`: add task with the same `project:` as the current task
    * `'`: add a new child task (a task which is a dependency of the current task)
    * `P`: make task a `+project` and give it a project name
    * `I`: add an `+idea`
    * `Shift+Right`: open `:project` report of the current task's project

