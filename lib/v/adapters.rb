module V
  module Adapters
    autoload :Git, "#{ File.dirname __FILE__ }/adapters/git"
  end

  # Initialize a git environment.
  #
  #   Attributes => Default
  #   :bare      => false
  #   :work_tree => ENV || Dir.getwd
  #   :git_dir   => ENV || bare? ? work_tree : File.join(work_tree, '.git')
  #   :which_git => `which git`
  def self.git(attrs = {}, &block)
    env = Adapters::Git::Environment.new attrs

    if not block_given?
      env
    elsif not block.arity.between?(-1, 0)
      yield env
    else
      env.instance_eval(&block)
    end
  end

end
