require 'open3'

Dir.chdir File.dirname(__FILE__)
File.open('commit_message', 'a').close

watch(/(?:commit_message)/)  { |*|

  puts 'Running syntax checks...'
  Dir['lib/**/*.rb'].inject(true) do |check, path|
    Open3.popen3('ruby', '-c', path) { |_, o, stderr|
      errors = stderr.read

      if errors.empty? then check
      else
        puts errors
        false
      end
    }
  end and begin
    puts 'Running integration tests and release...'
    system('ruby', 'auto_commit.rb')
  end

}
