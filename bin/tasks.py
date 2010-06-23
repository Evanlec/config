# Mercurial extension to provide the 'hg task' command
#
# Copyright 2009 Alex Unden <alu@zpuppet.org>
#
# Based on the bookmarks extension (http://bitbucket.org/segv/bookmarks/)
# Copyright 2009 David Soria Parra <dsp@php.net>
#
# This software may be used and distributed according to the terms
# of the GNU General Public License, incorporated herein by reference.

from mercurial.i18n import _
from mercurial.node import nullid, nullrev, hex, short
from mercurial import util, commands, localrepo, repair, extensions, hg
from mercurial import cmdutil, url, error, patch
import os, time, shutil, errno

def prettynode(ui, repo, node):
    if not node: return ''
    hexfn = ui.debugflag and hex or short
    return '%d:%s' % (repo.changelog.rev(node), hexfn(node))

def prettynodelist(ui, repo, nodes):
    return '[ ' + ', '.join([prettynode(ui, repo, n) for n in nodes]) + ' ]'

def parse(repo):
    # taskname,parentnode,startnode,endnode,state
    # mytask,a0a0,b1b1,c2c2,0
    # states:
    #     0 - empty /new
    #     1 - active (one or more csets)
    #     2 - completed (one or more csets and marked as completed)
    try:
        if repo._tasks:
            return repo._tasks
        repo._tasks = {}
        complete = False
        for line in repo.opener('tasks/tasks'):
            tname, parent, start, end, state = line.strip().split(',')
            repo._tasks[tname] = {
                    'parent': repo.lookup(parent),
                    'start': start and repo.lookup(start) or None,
                    'end': end and repo.lookup(end) or None,
                    'state': int(state) }
    except:
        pass
    return repo._tasks

def write(ui, repo, tasks):
    '''Write tasks

    Write the given task dictionary to the .hg/tasks/tasks file.

    We also store a backup of the previous state in .hg/tasks/undo.tasks that
    can be copied back on rollback.
    '''
    if os.path.exists(repo.join('tasks/tasks')):
        util.copyfile(repo.join('tasks/tasks'), repo.join('tasks/undo.tasks'))

    # is this needed here?
    if current(repo) not in tasks:
        setcurrent(ui, repo, None)

    if not os.path.isdir(repo.join('tasks')):
        try:
            os.mkdir(repo.join('tasks'))
        except OSError, inst:
            if inst.errno != errno.EEXIST:
                raise

    f = repo.opener('tasks/tasks', 'w+')
    for tname, tinfo in tasks.iteritems():
        # taskname,parentnode,startnode,endnode,state
        line = '%s,%s,%s,%s,%d\n' % (tname, hex(tinfo['parent']),
                tinfo['start'] and hex(tinfo['start']) or '',
                tinfo['end'] and hex(tinfo['end']) or '',
                tinfo['state'])
        f.write(line)
    f.close()

def current(repo):
    '''Get the current task

    This function returns the name of the currnet task if set. It
    is stored in .hg/tasks.current
    '''
    if repo._taskcurrent:
        return repo._taskcurrent
    task = None
    if os.path.exists(repo.join('tasks/current')):
        file = repo.opener('tasks/current')
        task = (file.readlines() or [''])[0]
        if task == '':
            task = None
        file.close()
    repo._taskcurrent = task
    return task

def setcurrent(ui, repo, task, msg=False):
    '''Set the current task

    Set the name of the task that we are currently doing (hg update <task>).
    The name is recorded in .hg/tasks.current
    '''
    if current(repo) == task:
        return

    tasks = parse(repo)

    # do not update if the task we update to is completed
    if (task and task in tasks and tasks[task]['state'] == 2):
        return
    # do not update if we do update to a rev equal to the current task
    if (task and task not in tasks and
        current(repo) and tasknode(repo, tasks[current(repo)]) ==
        repo.changectx('.').node()):
        return
    # we are clearing it here
    if task not in tasks:
        task = ''
    else:
        if msg: ui.status('current task: %s\n' % task)
    file = repo.opener('tasks/current', 'w+')
    file.write(task)
    file.close()
    repo._taskcurrent = task

def trackingcurrent(repo):
    tasks = parse(repo)
    currenttask = current(repo)
    return currenttask and \
            repo.changectx('.').node() == tasknode(repo, tasks[currenttask])

def tasknode(repo, tinfo):
    '''returns the task 'tip', used for updating and display'''
    if tinfo['end']: return tinfo['end']
    if tinfo['start']: return tinfo['start']
    return tinfo['parent']

def addtasknode(repo, tinfo, node):
    '''adds a node to task and changes state accordingly'''
    if tinfo['state'] == 0:
        tinfo['start'] = node
        tinfo['state'] = 1
    else:
        tinfo['end'] = node

def tasknodes(repo, tinfo):
    '''returns all nodes associated with this task, start->finish'''
    if not tinfo['end']:
        return [ tinfo['start'] ]
    else:
        return repo.changelog.nodesbetween([tinfo['start']], [tinfo['end']])[0]

def task(ui, repo, task=None, rev=None, force=False, delete=False, info=None,
        all=False, complete=None, resume=None, delete_all=False,
        delete_complete=False, rename=None, trim=None, append=None,
        purge_stash=False):
    '''mercurial tasks

    Tasks are collections of contiguous changesets.  A task can be short or long
    lived, but its information is only available locally.  This extension
    overrides the behaviour of push so that it will not push incomplete tasks by
    default. A task can be in one of 3 states:
        * new - this task has no changesets only a parent node
        * active - a task with some changesets but not complete
        * complete - a task with some changesets and marked as complete

    Use 'hg tasks' to list all new and active tasks.  'hg tasks --all' will show
    completed tasks along with those that are new and active.

    This extension adds two new options to push:
            --all-tasks        will push all taks even incomplete ones
            --completed-tasks  will only push completed tasks

    Use 'hg update [TASK]' to update to the tip node of a task and set thate
    task as current.  When a task is set as current, all subsequent commits will
    be assoticated with the task.

    Use 'hg log [TASK]' to view a log of all changesets associated with the
    given task.

    Use 'hg export [TASK]' to export all changesets associated with the given
    task.

    Use 'hg email -t [TASK]' to create a patchbomb containing all changesets
    associated with the given task.

    Use 'hg transplant -t [TASK]' to transplant all associated changsets in a
    task.

    If the auto.track.new config option is True, newly created tasks will
    automatically be set as current.

    If the auto.stash config option is True, your working copy will
    automatically be stashed when you update away from the current task.  When
    returning to a previously stashed task by updating to it, your working copy
    will be restored from the stash.
    '''
    tasks = parse(repo)

    # all these options need a valid task name
    if delete or info or complete or resume or trim or append \
        or (purge_stash and not all):
        if task == None:
            raise util.Abort(_('task name required'))
        if task not in tasks:
            raise util.Abort(_('a task of this name does not exist'))

    # all these options don't want a task
    if delete_all or delete_complete or (purge_stash and all):
        if task:
            raise util.Abort(_('no task name required for this option'))

    # check for force when deleting tasks with stash
    if delete_all or delete_complete or delete:
        if not force:
            if delete_complete:
                deltasks = [t for t in tasks if tasks[t]['state'] == 2]
            elif delete_all:
                deltasks = tasks
            else:
                deltasks = [ task ]

            stashedtasks = [ t for t in deltasks if hasstash(repo, t) ]
            if len(stashedtasks):
                if delete:
                    raise util.Abort(
                        _('task has stash info, use -f to lose stash'))
                else:
                    raise util.Abort(_('deleting tasks with stash info, use -f'
                        ' to lose stashes\ntasks with stash info: %s' %
                        ' '.join(stashedtasks)))

    # delete all
    if delete_all:
        for t in tasks:
            removestashfiles(repo, t)
        write(ui, repo, {})
        return

    # delete complete
    if delete_complete:
        deltasks = [t for t in tasks if tasks[t]['state'] == 2]
        update = False
        for t in deltasks:
            removestashfiles(repo, t)
            del tasks[t]
            update = True
        if update:
            write(ui, repo, tasks)
        return

    # rename a task
    if rename:
        if rename not in tasks:
            raise util.Abort(_('a task of this name does not exist'))
        if task in tasks and not force:
            raise util.Abort(_('a task of the same name already exists'))
        if task is None:
            raise util.Abort(_('new task name required'))
        oldstash = stashfiles(repo, rename)
        newstash = stashfiles(repo, task)
        for i in range(len(oldstash)):
            if os.path.exists(repo.join(oldstash[i])):
                shutil.move(repo.join(oldstash[i]), repo.join(newstash[i]))

        tasks[task] = tasks[rename]
        del tasks[rename]
        if current(repo) == rename:
            setcurrent(ui, repo, task)
        write(ui, repo, tasks)
        return

    # delete a task
    if delete:
        if task == current(repo):
            setcurrent(ui, repo, None)
        removestashfiles(repo, task)
        del tasks[task]
        write(ui, repo, tasks)
        return

    # complete a task
    if complete:
        if tasks[task]['state'] == 2:
            raise util.Abort(_('task is already completed'))
        if tasks[task]['state'] == 0:
            raise util.Abort(_('no changesets in task'))
        if not force and hasstash(repo, task):
            raise util.Abort(_('task has stash, use -f to lose stash'))
        # when checking for working copy changes here, we are bit more lax and
        # not worried about unknown files...
        if not force and task == current(repo) and trackingcurrent(repo) \
            and bool(filter(None, repo.status())):
            raise util.Abort(_('uncommited changes in current task, use -f to '
                'complete anyway'))

        tasks[task]['state'] = 2
        if task == current(repo):
            setcurrent(ui, repo, None)
        write(ui, repo, tasks)
        removestashfiles(repo, task)
        return

    # resume a task  (should we set to current and update to it???)
    if resume:
        if not tasks[task]['state'] == 2:
            raise util.Abort(_('task is not completed'))
        tasks[task]['state'] = 1
        write(ui, repo, tasks)
        return

    # show info on a given task
    if info:
        tinfo = tasks[task]
        ui.write('task:            %s\n' % task)
        ui.write('parent:          %s\n' % prettynode(ui, repo,
            tinfo['parent']))

        if task == current(repo) and trackingcurrent(repo):
            stashstr = bool(filter(None, repo.status())) and ' + changes' or ''
        else:
            stashstr = hasstash(repo, task) and ' + stash' or ''

        if tinfo['state'] == 0: state = 'new'
        if tinfo['state'] == 1: state = 'active'
        if tinfo['state'] == 2: state = 'completed'
        ui.write('state:           %s%s\n' % (state, stashstr))
        if tinfo['state'] != 0:
            nodes = tasknodes(repo, tinfo)
            nodes.reverse()
            changesets = 'changesets (%d):' % len(nodes)
            ui.write('%-16s %s\n' % (changesets, prettynode(ui, repo,
                nodes[0])))
            for n in nodes[1:]:
                ui.write('                 %s\n' % prettynode(ui, repo, n))
        return

    # trim a task
    if trim:
        if not rev:
            raise util.Abort(_('revision required'))
        else:
            trimnode = repo.lookup(rev)
            tnodes = tasknodes(repo, tasks[task])
            if trimnode not in tnodes:
                raise util.Abort(_('revision not in task'))
            if trimnode == tasks[task]['start']:
                tasks[task]['start'] = None
                tasks[task]['end'] = None
                tasks[task]['state'] = 0
            else:
                newend = tnodes[tnodes.index(trimnode) - 1]
                if newend == tasks[task]['start']:
                    tasks[task]['end'] = None
                else:
                    tasks[task]['end'] = newend
                tasks[task]['state'] = 1
            write(ui, repo, tasks)
        return

    # append to task
    if append:
        if not rev:
            raise util.Abort(_('revision required'))
        anode = repo.lookup(rev)
        nodes = repo.changelog.nodesbetween([tasknode(repo, tasks[task])], [anode])[0]
        if len(nodes) < 2:
            raise util.Abort(_('no new revs to add'))
        if len ([n for n in nodes if repo.changelog.parents(n)[1] != nullid]):
            raise util.Abort(
                _('tasks cannot include merged nodes (nodes with two parents)'))

        # now actually append
        if tasks[task]['state'] == 0: # new
            tasks[task]['start'] = nodes[1]
            if len(nodes) > 2:
                tasks[task]['end'] = nodes[-1]
            tasks[task]['state'] = 1
        else:
            tasks[task]['end'] = nodes[-1]
        write(ui, repo, tasks)
        return

    # purge stash
    if purge_stash:
        purgetasks = all and tasks or [ task ]
        for t in purgetasks:
            removestashfiles(repo, t)
        return

    # create a task
    if task != None:
        if '\n' in task or ' ' in task or ',' in task:
            raise util.Abort(
                _('task name cannot contain newlines, spaces, or commas'))
        task = task.strip()
        if task in tasks and not force:
            raise util.Abort(_('a task of the same name already exists'))
        if ((task in repo.branchtags() or task == repo.dirstate.branch()) and
                not force):
            raise util.Abort(
                _('a task cannot have the name of an existing branch'))
        if (task in repo.tags() and not force):
            raise util.Abort(_('a tag of the same name already exists'))
        if rev:
            nodes = [ repo.lookup(r) for r in cmdutil.revrange(repo, [rev]) ]
            parentnode = nodes[0]
            endnode = None
            startnode = None
            state = 0
            if len(nodes) > 1:
                if len ([n for n in nodes[1:]
                    if repo.changelog.parents(n)[1] != nullid]):
                    raise util.Abort(_('tasks cannot include merged nodes '
                        '(nodes with two parents)'))
                startnode = nodes[1]
                state = 1
            if len(nodes) > 2:
                endnode = nodes[-1]
            tasks[task] = {'parent': parentnode, 'start': startnode, 'end':
                    endnode, 'state': state }
        else:
            tasks[task] = {'parent': repo.changectx('.').node(), 'start': None,
                    'end': None, 'state': 0 }
        write(ui, repo, tasks)

        # handle the auto tracking of newly created tasks on current node
        if ui.configbool('tasks', 'auto.track.new'):
            try:
                opts = {'rev':None, 'clean':False, 'date':None }
                tasksupdate(commands.update, ui, repo, *[ task ], **opts)
            except Exception, exception:
                raise type(exception)( str(exception)
                    + "\nwarning: new task '%s' created but not set to current"
                    %task)
        return

    # list tasks
    if task == None:
        if rev:
            raise util.Abort(_('task name required'))
        if len(tasks) == 0:
            ui.status('no tasks set\n')
        else:
            for t, tinfo in tasks.iteritems():
                if tinfo['state'] == 2 and not all: continue
                tnode = tasknode(repo, tinfo)

                if t == current(repo) and trackingcurrent(repo):
                    prefix = '*'
                    stashstr = bool(filter(None, repo.status())) and '+' or ' '
                else:
                    prefix = ' '
                    stashstr = hasstash(repo, t) and '+' or ' '

                if tinfo['start']:
                    nodeprefix = ' '
                    complete = (tinfo['state'] == 2) and ' - complete' or ''
                    if tinfo['end'] and tinfo['end'] != tinfo['start']:
                        ncsets = len(tasknodes(repo, tinfo))
                    else:
                        ncsets = 1
                    csets = ' (%d cset%s%s)' % \
                        (ncsets, (ncsets != 1) and 's' or '', complete)
                else:
                    nodeprefix = '>'
                    csets = ''
                ui.write(' %s %-12s %s%s%s%s\n' % (prefix, t, nodeprefix,
                    prettynode(ui, repo, tnode), stashstr, csets))

def nodeexists(repo, node):
    ''' Determine if this node exists in the repo. '''
    try:
         repo.changelog.rev(node)
    except error.LookupError:
        return False
    else:
        return True

def strip(orig, ui, repo, node, backup='all'):
    '''Strip tasks if revisions are stripped using the mercurial.strip method.
    This usually happens during qpush and qpop.  If all task nodes are removed
    completely the task will be deleted.  If it is only partially stripped, it
    will be marked as uncomplete and trimmed.'''

    res = orig(ui, repo, node, backup)
    tasks = parse(repo)
    update = False
    emptytasks = []
    for tname, tinfo in tasks.iteritems():
        if not nodeexists(repo, tinfo['parent']):
            update = True
            emptytasks.append(tname)
        elif tinfo['start'] and not nodeexists(repo, tinfo['start']):
            update = True
            tinfo['end'] = None
            tinfo['start'] = None
            tinfo['state'] = 0
        elif tinfo['end'] and not nodeexists(repo, tinfo['end']):
            update = True
            tinfo['end'] = repo.heads(tinfo['start'])[0]
            if tinfo['end'] == tinfo['start']:
                tinfo['end'] = None
    if update:
        for et in emptytasks:
            del tasks[et]
        write(ui, repo, tasks)
    return res

def hasstash(repo, task):
    for f in stashfiles(repo, task):
        if os.path.exists(repo.join(f)):
            return True
    return False

def stashfiles(repo, task):
    stashhex = util.sha1(task).hexdigest()
    return ( 'tasks/%s.stash' % stashhex, 'tasks/%s.dirstate' % stashhex )

def removestashfiles(repo, task):
    for f in stashfiles(repo, task):
        if os.path.exists(repo.join(f)):
            try:
                os.unlink(repo.join(f))
            except OSError, inst:
                ui.warn(_('error removing stash file: %s\n') % str(inst))

def unstash(ui, repo, task):
    '''Unstashes a working copy.  Returns True if a stash was found and applied,
    False if no stash exists.'''
    if not hasstash(repo, task):
        return False

    ui.write('unstashing task: %s\n' % task)
    ui.debug('unstashing %s from stash file: %s\n'
            % (task, stashfiles(repo, task)[0]))

    patchfile = repo.join(stashfiles(repo, task)[0])
    dirstatefile = repo.join(stashfiles(repo, task)[1])

    files = {}
    if os.path.exists(patchfile):
        try:
            fuzz = patch.internalpatch(patchfile, ui, strip = 1,
                               cwd = repo.root, files = files)
        except Exception, inst:
            ui.note(str(inst) + '\n')
            ui.warn('patch failed, unable to continue\n')
            ui.warn('see %s for stash patch\n' % patchfile)
            return False

        if files:
            patch.updatedir(ui, repo, files)

    if os.path.exists(dirstatefile):
        shutil.copyfile(dirstatefile, repo.join('dirstate'))

    removestashfiles(repo, task)
    return True

def getdiff(ui, repo):
    m = cmdutil.match(repo)
    o = patch.diffopts(ui, {'git': True})
    return patch.diff(repo, match = m, opts = o)

def stash(ui, repo, task):
    '''Performs a stash if the working copy is dirty.  Returns True if a stash
    was performed otherwise False.'''

    st = repo.status()
    if not bool(filter(None, st)):
        return False # no stashing necessary

    ui.write('stashing task: %s\n' % task)

    # stash dirstate
    shutil.copyfile(repo.join('dirstate'), repo.join(stashfiles(repo, task)[1]))

    ui.debug('stashing %s to stash file: %s\n' %
        (task, stashfiles(repo, task)[0]))

    p = repo.opener(stashfiles(repo, task)[0], 'w')
    p.write('# stash of task %s\n' % task)
    p.write('# created %s\n#-\n' %
        time.strftime('%m/%d/%y %H:%M:%S', time.localtime()))
    for i in repo.status():
        for j in i:
            p.write('# %s %s\n' % (j, filesha(repo, j)))
    p.write('#-\n')

    # remove all missing files before getting diff, dirstate is already stashed
    repo.remove(st[3])

    # write out diffs
    hunks = getdiff(ui, repo)
    for hunk in hunks:
        p.write(hunk)
    p.close()
    return True

def filesha(repo, file):
    '''returns a sha1 of file contents'''
    f = util.pathto(repo.root, None, file)
    if os.path.exists(f):
        contents = open(f).read()
    else:
        contents = '';
    return util.sha1(contents).hexdigest()

def cleanup(repo):
    '''removes all changes from the working copy and makes it so
    there isn't a patch applied; copied from attic'''
    node = repo.dirstate.parents()[0]
    hg.clean(repo, node, False)

def reposetup(ui, repo):
    if not isinstance(repo, localrepo.localrepository):
        return

    # init a task cache as otherwise we would get a infinite reading
    # in lookup()
    repo._tasks = None
    repo._taskcurrent = None

    class task_repo(repo.__class__):
        def rollback(self):
            if os.path.exists(self.join('tasks/undo.tasks')):
                util.rename(self.join('tasks/undo.tasks'),
                    self.join('tasks/tasks'))
            return super(task_repo, self).rollback()

        def lookup(self, key):
            if self._tasks is None:
                self._tasks = parse(self)
            if key in self._tasks:
                key = tasknode(self, self._tasks[key])
            return super(task_repo, self).lookup(key)

        def commit(self, *k, **kw):
            '''Add a revision to the repository and
            move the task'''
            node  = super(task_repo, self).commit(*k, **kw)
            if node == None:
                return None
            parents = repo.changelog.parents(node)
            if parents[1] == nullid:
                parents = (parents[0],)

            tasks = parse(repo)
            currenttask = current(repo)
            update = False
            for tname, tinfo in tasks.items():
                if tasknode(self, tinfo) in parents:
                    if len(parents) > 1:
                        if tinfo['state'] == 1:
                            ui.write('completing task %s\n' % tname)
                            if hasstash(self, task):
                                ui.write('warning: task stash still present\n'
                                    ' update to task to retrieve stash')
                            tinfo['state'] = 2
                            if tname == currenttask:
                                setcurrent(ui, repo, None)
                    else:
                        if tname == currenttask:
                            addtasknode(self, tinfo, node)
                    update = True
            if update:
                write(ui, repo, tasks)
            return node

        def push(self, remote, force=False, revs=None, completed_tasks=False,
                all_tasks=False):
            if all_tasks:
                return super(task_repo, self).push(remote, force, revs)

            if completed_tasks and all_tasks:
                raise util.Abort(_('cannot specify both --all-tasks and '
                    '--completed-tasks'))

            # suppress output of this since it unfortunately gets called again
            ui.pushbuffer()
            out = self.findoutgoing(remote, None)
            ui.flush()
            ui.popbuffer()

            if not out:
                return super(task_repo, self).push(remote, force, revs)

            outnodes = repo.changelog.nodesbetween(out, revs)[0]

            # need a list of nodes inside incompleted tasks
            tasks = parse(self)
            itasknodes = []
            for tname, tinfo in tasks.iteritems():
                if tinfo['state'] == 1:
                    itasknodes += tasknodes(repo, tinfo)

            # no need to do anything if all tasks complete
            if not itasknodes:
                return super(task_repo, self).push(remote, force, revs)

            # check to see if we have any outgoing nodes that are in incompleted
            # tasks
            havebadnode = False
            for onode in outnodes:
                if onode in itasknodes:
                    havebadnode = True
                    break

            if not havebadnode:
                return super(task_repo, self).push(remote, force, revs)

            if not completed_tasks:
                raise util.Abort(_('pushing incomplete tasks\n'
                    '(use --all-tasks to force or --completed-tasks to prune)'))

            # ok now we prune
            ui.status('searching for completed tasks\n')
            nodestoremove = []
            for onode in outnodes:
                for tname, tinfo in tasks.iteritems():
                    if tinfo['state'] == 1:
                        if onode in tasknodes(repo, tinfo):
                            # we have to remove all nodes between this node and
                            # the end node for this task
                            for n in self.changelog.nodesbetween([ onode ],
                                    None)[0]:
                                nodestoremove.append(n)
            newoutnodes = [ n for n in outnodes if n not in nodestoremove ]
            return super(task_repo, self).push(remote, force, newoutnodes)

        def tags(self):
            '''Adds tasks to tags'''
            if self.tagscache:
                return self.tagscache

            tagscache = super(task_repo, self).tags()
            # make an array with fake tags
            for t, tinfo in parse(repo).iteritems():
                tagscache[t] = tasknode(self, tinfo)
            return tagscache

    repo.__class__ = task_repo


def uisetup(ui):
    extensions.wrapfunction(repair, 'strip', strip)
    extensions.wrapcommand(commands.table, 'update', tasksupdate)
    extensions.wrapcommand(commands.table, 'log', taskslog)
    extensions.wrapcommand(commands.table, 'export', tasksexport)
    entry = extensions.wrapcommand(commands.table, 'push', taskspush)
    entry[1].append(('', 'completed-tasks', None,
        _('push all heads that have completed tasks only')))
    entry[1].append(('', 'all-tasks', None,
        _('push all heads including those with incomplete tasks')))

    try:
        transplant = extensions.find('transplant')
        if transplant:
            entry = extensions.wrapcommand(transplant.cmdtable, 'transplant',
                taskstransplant)
            entry[1].append(('t', 'task', '',
                _('transplant all changesets in task TASK')))
    except:
        pass
    try:
        patchbomb = extensions.find('patchbomb')
        if patchbomb:
            entry = extensions.wrapcommand(patchbomb.cmdtable, 'email',
                tasksemail)
            entry[1].append(('t', 'task', '',
                _('email all changesets in task TASK')))
    except:
        pass

def tasksemail(orig, ui, repo, *revs, **opts):
    if opts['task']:
        if revs or opts['rev']:
            raise util.Abort(_('cannot specify rev and task'))
        tasks = parse(repo)
        if opts['task'] not in tasks:
            raise util.Abort(_('invalid task name'))

        if tasks[opts['task']]['state'] == 0:
            raise util.Abort(_('task has no changesets'))

        tnodes = tasknodes(repo, tasks[opts['task']])
        opts['rev'] = ['%d:%d' %
            (repo.changelog.rev(tnodes[0]), repo.changelog.rev(tnodes[-1]))]
    return orig(ui, repo, *revs, **opts)

def tasksexport(orig, ui, repo, *revs, **opts):
    if len(revs) == 1:
        tasks = parse(repo)
        if revs[0] in tasks:
            if tasks[revs[0]]['state'] == 0:
                raise util.Abort(_('no changesets in task %s' % revs[0]))
            tnodes = tasknodes(repo, tasks[revs[0]])
            revs = [ '%d:%d' %
                (repo.changelog.rev(tnodes[0]), repo.changelog.rev(tnodes[-1]))]
    return orig(ui, repo, *revs, **opts)

def taskstransplant(orig, ui, repo, *revs, **opts):
    if not opts['task']:
        return orig(ui, repo, *revs, **opts)

    if revs: raise util.Abort(_('cannot specify revs and task'))
    if opts['branch']: raise util.Abort(_('cannot specify branch and task'))
    if opts['source']: raise util.Abort(_('cannot specify source and task'))

    tasks = parse(repo)

    if opts['task'] not in tasks:
        raise util.Abort(_('invalid task name'))

    if tasks[opts['task']]['state'] == 0:
        raise util.Abort(_('task has no changesets'))

    tnodes = tasknodes(repo, tasks[opts['task']])
    revs = [ '%d:%d' %
        (repo.changelog.rev(tnodes[0]), repo.changelog.rev(tnodes[-1])) ]
    return orig(ui, repo, *revs, **opts)

def taskslog(orig, ui, repo, *args, **opts):
    '''allows you to use 'hg log [NAME]' '''
    if len(args) > 0:
        tasks = parse(repo)
        if args[0] in tasks:
            nodes = tasknodes(repo, tasks[args[0]])
            args = [ n for n in args[1:] ]
            if len(nodes) < 1:
                return
            opts['rev'] = ['%d:%d' %
                (repo.changelog.rev(nodes[-1]), repo.changelog.rev(nodes[0]))]
    return orig(ui, repo, *args, **opts)

def stashshas(repo, task):
    '''retrieve sha values from task stash'''
    stashpatch = stashfiles(repo, task)[0]
    shas = {}
    if os.path.exists(repo.join(stashpatch)):
        f = repo.opener(stashpatch)
        shasection = False
        for line in f:
            if line == '#-\n':
                if shasection:
                    break
                else:
                    shasection = True
                    continue
            if shasection:
                hash, task, shastring = line.strip().split(' ')
                shas[task] = shastring
        f.close()
    return shas

def tasksupdate(orig, ui, repo, *args, **opts):
    '''Set the current task
    If the user updates to a task we update the .hg/tasks.current
    file.
    '''

    ontask = trackingcurrent(repo)
    currenttask = current(repo)
    tasks = parse(repo)
    if not opts['rev'] and len(args) > 0 and args[0] in tasks:
        totask = args[0]
    else:
        totask = None

    # if we are not stashing, short circuit to regular update
    if not ui.configbool('tasks', 'auto.stash'):
        res =  orig(ui, repo, *args, **opts)
        setcurrent(ui, repo, totask, True)
        return res

    untrackedinstash = []

    if totask:
        # if we are updating to a task, and not on a task that will be stashed,
        # let's see if we should bail out before going through the trouble of
        # creating a stash
        # we are changing hg behaviour here, maybe people like the auto-merging?
        if not ontask and bool(filter(None, repo.status())) \
            and not 'clean' in opts:
            raise util.Abort(_('uncommited changed in working copy, '
                'use --clean to abandon changes'))

        # check for untracked files that will be clobbered
        untracked = repo.status(unknown = True)[4]
        if len(untracked) > 0:
            shas = stashshas(repo, totask)
            for f in untracked:
                if f in shas:
                    untrackedinstash.append(f)
                    if filesha(repo, f) != shas[f]:
                        raise util.Abort(_('untracked file in working '
                            'directory differs from file in requested '
                            'revision: \'%s\'' % f))

    # store all untracked files that are also in stash
    storeuntracked(repo, untrackedinstash)

    if ontask:
        # we are waiting for the --cross option to be introduced into hg, we
        # would add it to the update command as updating as tasks are often on
        # different branches
        if stash(ui, repo, currenttask):
            # cleanup is safe as we have stashed all changes
            cleanup(repo)
    try:
        res = orig(ui, repo, *args, **opts)
    except:
        # revert all damage we may have done to current state
        if ontask:
            unstash(ui, repo, currenttask)
            restoreuntracked(repo, untrackedinstash)
        # now we can bail
        raise

    removeuntracked(repo)

    # update now complete, unstash and change current
    setcurrent(ui, repo, totask, totask)
    if totask:
        unstash(ui, repo, totask)

    return res

def storeuntracked(repo, untracked):
    if not untracked:
        return
    os.mkdir(repo.join('tasks/untrackedbackup'))
    for f in untracked:
        shaname = util.sha1(f).hexdigest()
        util.copyfile(util.pathto(repo.root, None, f),
            repo.join('tasks/untrackedbackup/%s' % shaname))
        util.unlink(util.pathto(repo.root, None, f))

def restoreuntracked(repo, untracked):
    for f in untracked:
        shaname = util.sha1(f).hexdigest()
        util.copyfile(repo.join('tasks/untrackedbackup/%s' % shaname),
            util.pathto(repo.root, None, f))

def removeuntracked(repo):
    if os.path.exists(repo.join('tasks/untrackedbackup')):
        for f in os.listdir(repo.join('tasks/untrackedbackup')):
            os.unlink('%s/%s' % (repo.join('tasks'), f))
        os.rmdir(repo.join('tasks/untrackedbackup'))

def debugtask(ui, repo, task=None, showstash=False, purge=False, force=False):
    '''tasks debug'''

    def showtask(ui, repo, tname, tinfo):
        ui.write('%s\n' % tname)
        ui.write(' state:  %d\n' % tinfo['state'])
        ui.write(' parent: %s\n' % prettynode(ui, repo, tinfo['parent']))
        ui.write(' start:  %s\n' % prettynode(ui, repo, tinfo['start']))
        ui.write(' end:    %s\n' % prettynode(ui, repo, tinfo['end']))
        ui.write(' stash files:\n')
        showstashfiles(ui, repo, tname)
        ui.write('\n')

    def showstashfile(ui, repo, sf):
        if os.path.exists(repo.join(sf)):
            existsstr = ' - exists'
        else:
            existsstr = ' - does not exist'
        ui.write('  %s %s\n' % (sf, existsstr))

    def showstashfiles(ui, repo, tname):
        for sf in stashfiles(repo, tname):
            showstashfile(ui, repo, sf)


    if purge and not force:
        raise util.Abort(_('this will wipe out all your tasks info, the '
            'entire\n.hg/tasks directory, if you are sure, use -f to force'))

    if purge:
        for f in os.listdir(repo.join('tasks')):
            os.unlink('%s/%s' % (repo.join('tasks'), f))
        os.rmdir(repo.join('tasks'))
        return

    if showstash and not task:
        raise util.Abort(_('must specify task with --showstash'))

    tasks = parse(repo)

    if not task:
        ui.write('current task: %s\n\n' % str(current(repo)))
        ui.write('number of tasks: %d\n\n' % len(tasks))
        for tname, tinfo in tasks.iteritems():
            showtask(ui, repo, tname, tinfo)
        return

    if task not in tasks:
        raise util.Abort(_('task does not exist'))

    if showstash:
        ui.write('stash for %s:\n' % task)
        sfiles = stashfiles(repo, task)
        for sf in sfiles:
            showstashfile(ui, repo, sf)
        if os.path.exists(repo.join(sfiles[0])):
            ui.write('---------------\n')
            ui.write(open(repo.join(sfiles[0])).read())
        return

    showtask(ui, repo, task, tasks[task])
    return

def taskspush(orig, ui, repo, dest=None, **opts):
    ''' Task push
    Calls custom push command with new custom args'''
    # all copied from mercurial/commands.py
    dest, revs, checkout = hg.parseurl(
        ui.expandpath(dest or 'default-push', dest or 'default'),
        opts.get('rev'))
    cmdutil.setremoteconfig(ui, opts)

    other = hg.repository(ui, dest)
    ui.status(_('pushing to %s\n') % url.hidepassword(dest))
    if revs:
        revs = [repo.lookup(rev) for rev in revs]
    # add in our new options
    r = repo.push(other, opts.get('force'), revs=revs,
        completed_tasks=opts.get('completed_tasks'),
        all_tasks=opts.get('all_tasks'))
    return r == 0

cmdtable = {
    'tasks':
        (task,
        [
        ('f', 'force', False, _('force')),
        ('r', 'rev', '', _('revision')),
        ('d', 'delete', False, _('delete a given task')),
        ('c', 'complete', False, _('complete a given task')),
        ('u', 'resume', False, _('resume a given task')),
        ('A', 'delete-all', False, _('deletes all tasks')),
        ('C', 'delete-complete', False, _('deletes all completed tasks')),
        ('m', 'rename', '', _('rename a given task')),
        ('i', 'info', False, _('gives info a given task')),
        ('a', 'all', False, _('all tasks including completed tasks')),
        ('n', 'append', False, _('append revisions to task')),
        ('t', 'trim', False, _('trim revisions from given task')),
        ('',  'purge-stash', False, _('purge stash information from given task'))
        ],
        _('hg tasks [-f] [-d] [-i] [-c] [-u] [-A] [-C] [-i] [-a] [-m OLDNAME'
            ' NEWNAME] [-r REV] [NAME] [-n REV] [-t REV] [--purge-stash] ')),
    'debugtasks':
        (debugtask,
        [
        ('',  'showstash', False, _('show stash info')),
        ('',  'purge', False, _('purge all tasks')),
        ('f', 'force', False, _('force'))
        ],
        _('hg debugtasks [-f] [--showstash] [--purge] [NAME]')),
}

