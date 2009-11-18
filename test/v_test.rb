require 'teststrap'

context 'V' do
  context 'git' do

    setup do
      @work_tree = Pathname.new "#{ File.dirname __FILE__ }/work_tree"
      @work_tree.rmtree if @work_tree.directory?
      @work_tree.mkpath

      V.git :work_tree => @work_tree
    end

    should 'initialize repository' do
      topic.init

      File.directory? topic.git_dir
    end
    should 'add files to index' do
      @work_tree.join('file').open('w') { |f| f << 0 }

      topic.add('file').include? 'file'
    end
    asserts 'content of committed file' do
      topic.index.commit 'commit file'
      blob = topic.head.tree / 'file'

      Integer blob.content
    end.equals 0

  end
end
