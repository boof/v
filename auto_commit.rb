require 'rubygems'
require 'lib/v.rb'
require 'benchmark'
Thread.abort_on_exception = true

Benchmark.bm do |results|
  results.report "Auto-Commit\n" do
    # TODO: check bare repository
    # V.git 'test.git' do ...

    V.git do
      # write version
      File.open('VERSION', 'w') { |f| f << "#{ V::VERSION * '.' }" }

      # add all files and reset those that should not appear in tree
      add 'lib'
      index.add 'VERSION', 'LICENSE', 'auto_commit.rb'
      index << '.' # << is like: add '.'
      index.reset 'commit_message', 'test.git', '*.gem*'

      not index.include? 'v.gemspec' or
      raise 'expected index not to include gem specific files'

      not index.include? 'commit_message' or
      raise 'expected index not to include commit_message'

      # check for new version
      new_version = (index - head).modified? 'VERSION'

      # build subject
      subject = "'#{ ENV['USER'] }' says: "
      subject += ARGV.first || File.read('commit_message')

      # tip of current branch for later use (this is a future)
      parent = head.commit

      parent == parent or raise 'expected == to work'

      # raises IndexError if path does not exist
      head.tree / 'lib/v/adapters/git.rb'

      # initialize a test branch
      test_branch = branches['test']
      test_branch.destroy

      test_branch.create
      test_branch.exists? or
      raise 'expected branch to exist after being created'

      first_two_commits = commits.first 2
      first_two_commits.last.parents.member? first_two_commits.first.name or
      raise 'expected first to be correctly ordered'

      last_two_commits = commits.last 2
      last_two_commits.last.parents.member? last_two_commits.first.name or
      raise 'expected last to be correctly ordered'

      # commit changes, returns commit future but schedules after head.commit
      head_commit = commit subject

      commits.include? parent or
      raise 'expected commits to include parent'
      commits.last == head_commit or
      raise 'expected last commit to be head_commit'

      commits.all? { |commit| commit.is_a? V::Adapters::Git::Object } or
      raise ' expected all commits to be kind of Git::Object'

      # raises an exception if commits.last.to_s is not a String.
      String(commits.last)

      head_commit.parents[parent.name] or begin
        p parent, head_commit, head_commit.parents
        raise 'expected parents to include previous'
      end

      head_commit == head.commit or
      raise 'expected head to represent current state'

      head_commit.tree.content.keys.
      all? { |basename| basename != 'commit_message' } or
      raise 'expected content not to include commit_message'

      test_branch.update head.commit
      test_branch.head == head or
      raise 'expected branch start at head after update'

      head_commit.subject == subject.split("\n").first or begin
        p subject.split("\n").first, head_commit, head_commit.subject
        raise 'expected subject to be correctly quoted'
      end

      head_commit.committer.role == :committer or
      raise 'expected role to be :committer'

      test_branch.destroy
      not test_branch.exists? and
      raise 'expected branch not to exist after being destroyed'

      if new_version
        tag "v#{ V::VERSION * '.' }"
        push :tags => true
#        remotes[:origin].push :all
        # build gem and push it to gemcutter
      else
#        remotes[:origin].branches["#{ head.branch }"].commits
#        remotes[:origin].branches[ head.branch.name ].commits
#        remotes[:origin].commits
#        origin.commits

#        push if commits.size - origin.commits.size > 6
      end
    end
  end
end

__END__
if __FILE__ == $0
  begin
    test_path = "#{ __DIR__ }/../test.git"
    V.git :work_tree => test_path do
      bare == true or raise TypeError, 'test.git should be bare'
      init and add('config').value
    end
  rescue V::ENOTWTREE
    # and here we bam'ed :D
  ensure
    FileUtils.rm_r test_path if File.directory? test_path
    raise if $!
  end
end; end
