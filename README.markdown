v
=

v is for versioned. It's is currently only a threaded wrapper for the git
commands or procedures. In the future it should provide a generic interface
for diverse VCSs.

This Project does not have a separate test suite. This projects version-tracks
itself when everything works as expected.

All operations are designed to be reimplemented as pure ruby version and their
interface is almost 1:1 mapped to their ruby derivate.

Install
-------

    gem install v

or unless you installed gemcutter

    gem install gemcutter
    gem tumble
    gem install v

Interface
---------

    require 'v'

    V.git do
      add '.'
      commit 'Initial commit!'
    end

Git::Environment uses git returned by `which git` by default (\*n\*ix).

### Change the git executable globally

    V::Adapters::Git::Environment.which_git = '/usr/local/bin/git'

### Change the git executable locally

    env = V.git :which_git => '/usr/local/bin/git'

    # or

    V.git do
      @which_git = '/usr/local/bin/git'
      # ...
    end

### Working with futures...

    V.git do
      # initialize repository and return environment (as future)
      init == self

      # add root to index return a index future
      proxy = add '.'
      # wait for result and return index
      proxy.value == index
      # shortcut for add '.'
      index == index << '.'

      # commit index and return commit future
      proxy = commit 'initial commit' 
      # wait for result and return commit
      commit = proxy.value

      # Queries:
      init.add('.').commit 'First argument is always the message!'
    end

_See auto\_commit.rb for more examples._

Supported Operations
--------------------

 * add
 * branch
 * commit
 * diff-index => diff\_index (partially)
 * init
 * ls-files => ls\_files (what does -v mean?)
 * ls-tree => ls\_tree (alias for args)
 * push
 * rm
 * reset
 * log (partially)
 * show
 * tag

Git Objects
-----------

 * normal git objects
    * Blob
    * Commit
    * Tag
    * Tree
 * convenience objects
    * Head
    * Index
    * Branch
    * Branches
    * Commits

TODO
----

 * implement global cache / branch && git\_dir flag expired by branch mtime
 * implement non-blocking queries
 * implement all git operations
 * ALL operations should return raw results which can be used by the convenience objects
 * implement Convenience objects (git objects call commands with arguments set, ...)
 * add Documentation and Examples
 * Long-Term: reimplement all ops in ruby, starting with plumbing

Note on Patches/Pull Requests
-----------------------------

 * Fork the project.
 * Make your feature addition or bug fix.
 * Add tests for it. This is important so I don't break it in a
   future version unintentionally.
 * Commit, do not mess with rakefile, version, or history.
   (if you want to have your own version, that is fine but
   bump version in a commit by itself I can ignore when I pull)
 * Send me a pull request. Bonus points for topic branches.

Required
--------

 * git 1.6+
 * fastthread

Thanks
------

Linus, matz and mojombo.

Copyright
---------

Copyright (c) 2009 Florian Aßmann, Fork Unstable Medie, Oniversus Media.
See LICENSE for details.
