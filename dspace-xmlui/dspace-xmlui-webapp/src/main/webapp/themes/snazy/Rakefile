task :compile do
  puts `haml -f html5 index.haml index.html`
  puts `compass compile`
end

task :watch do
  comands = [
    'compass watch',
    'coffee --watch --output js --compile coffee/*.coffee'
  ].map do |cmd|
    Thread.new do
      puts "Running command: `#{cmd}` . . ."
      system(cmd)
    end
  end
end

task :coffee do
  cmd = 'coffee --watch --output js --compile coffee/*.coffee'
  puts "Running command: `#{cmd}` . . ."
  system(cmd)
end


task :default => :compile
