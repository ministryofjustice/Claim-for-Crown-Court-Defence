#!/usr/bin/env ruby

require 'net/ssh' # gem install net-ssh
require 'net/scp' # gem install net-scp
require 'colorize'
require 'shell-spinner'
require 'ruby-progressbar'

ENVIRONMENTS = {
  'dev' => %w(dev adp_dev_new),
  'staging' => %w(staging adp_staging),
  'api-sandbox' => %w(api-sandbox adp_api-sandbox),
  'demo' => %w(demo adp_demo),
  'disaster' => %w(disaster adp_disaster),
  'gamma' => %w(gamma adp_gamma)
}

def ssh_user
  @ssh_user ||= (ARGV[0] || (raise 'Please specify the ssh username as the first argument'))
end

def ssh_env
  @ssh_env ||= begin
    ENVIRONMENTS.keys.include?(ARGV[1]) ||
        (raise 'Please specify the env name (%s) as the second argument and optionally the IP as the third argument' % ENVIRONMENTS.keys.join(','))
    ARGV[1]
  end
end

def ssh_address
  @ssh_address ||= (ARGV[2] || ENVIRONMENTS[ssh_env].first)
end

def dump_file_name
  @dump_file_name ||= "#{ENVIRONMENTS[ssh_env].last}_dump.psql"
end

def gzip_file_name
  "#{dump_file_name}.gz"
end

def install_postgres(ssh)
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get update'
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get -y install postgresql-9.6'
end

def delete_file_question
  print 'Do you want to delete the remote dump file after it has been downloaded (yes/no)? '
  @delete_file = STDIN.gets.chomp
end

def delete_file?
  ['y', 'yes', 'true'].include? @delete_file.downcase
end

def progress_bar
  ProgressBar.create(
    :title => 'Downloaded',
    :format         => "%a %b\u{15E7}%i %p%% %t",
    :progress_mark  => '#'.green,
    :remainder_mark => "\u{FF65}".yellow,
    :starting_at    => 0
  )
end

begin
  delete_file_question

  print 'Connecting to host %s... ' % ssh_address
  ssh = Net::SSH.start(ssh_address, ssh_user)
  puts 'done'.green

  ShellSpinner 'Installing postgresql in container' do
    install_postgres ssh
  end

  ShellSpinner 'Dumping database' do
    puts ssh.exec!("sudo docker exec advocatedefencepayments rake db:dump_anonymised[#{dump_file_name}]")
    puts ssh.exec!("sudo docker cp advocatedefencepayments:/usr/src/app/#{gzip_file_name} ~/")
    puts ssh.exec!("sudo docker exec advocatedefencepayments rm /usr/src/app/#{gzip_file_name}") if delete_file?
  end

  puts 'Downloading dump file %s from host %s' % [gzip_file_name, ssh_address]

  bar = progress_bar
  success = ssh.scp.download!("/home/#{ssh_user}/#{gzip_file_name}", '.') do |_channel, _name, sent, total|
    bar.progress = ((sent/total.to_f) * 100).round unless bar.progress >= 100
  end

  puts 'File %{file} download... %{success}' % { file: gzip_file_name, success: success ? 'done'.green : 'fail'.red }

rescue Exception => e
  puts 'Usage: ./db_dump.rb username environment [IP]'
  puts e
ensure
  if ssh
    ShellSpinner 'Deleting remote compressed dump file' do
      ssh.exec!("sudo rm /home/#{ssh_user}/#{gzip_file_name}")
    end if delete_file?

    ShellSpinner 'Closing connection' do
      ssh.close
    end
  end
end
