#!/usr/bin/env ruby

require 'net/ssh' # gem install net-ssh
require 'net/scp' # gem install net-scp
require 'colorize'
require 'shell-spinner'
require 'ruby-progressbar'

ENVIRONMENTS = {
  'dev' => 'dev',
  'demo' => 'demo',
  'staging' => 'staging',
  'disaster' => 'disaster'
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
  @ssh_address ||= (argument_is_file?(ARGV[2]) ? ENVIRONMENTS[ssh_env] : ARGV[2])
end

def dump_file_name
  @dump_file_name ||= begin
    (argument_is_file?(ARGV[2]) ? ARGV[2] : ARGV[3]) || (raise 'Please specify the dump file name as the third (or fourth if IP was provided) argument')
  end
end

def argument_is_file?(arg)
  arg.to_s.end_with?('.psql') || arg.to_s.end_with?('.gz')
end

def install_postgres(ssh)
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get update'
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get -y install postgresql-9.6'
end

def progress_bar
  ProgressBar.create(
    :title => 'Uploaded',
    :format         => "%a %b\u{15E7}%i %p%% %t",
    :progress_mark  => '#'.green,
    :remainder_mark => "\u{FF65}".yellow,
    :starting_at    => 0
  )
end

begin

  print 'Connecting to host %s as %s... ' % [ssh_address, ssh_user]
  ssh = Net::SSH.start ssh_address, ssh_user
  puts 'done'.green

  puts 'Uploading dump file %s to host %s' % [dump_file_name, ssh_address]
  bar = progress_bar
  ssh.scp.upload!(dump_file_name, "/home/#{ssh_user}/#{dump_file_name}" ) do |_channel, _name, sent, total|
    bar.progress = ((sent/total.to_f) * 100).round unless bar.progress >= 100
  end

  ShellSpinner 'Moving dump file into container' do
    puts ssh.exec!("sudo docker cp ~/#{dump_file_name} advocatedefencepayments:/usr/src/app/#{dump_file_name}")
    puts ssh.exec!("sudo rm -f ~/#{dump_file_name}")
  end

  ShellSpinner 'Installing postgresql in container' do
    install_postgres ssh
  end

  # NOTE: Errors encountered below related to COMMENTs and can be safely ignored
  #  ERROR: must be owner of extension plpgsql
  #  ERROR: must be owner of extension uuid-ossp
  # see https://www.ca.com/us/services-support/ca-support/ca-support-online/knowledge-base-articles.TEC1634878.html
  ShellSpinner "Restoring database using #{dump_file_name}" do
    puts ssh.exec!("sudo docker exec advocatedefencepayments rake db:restore[#{dump_file_name}]")
  end

rescue Exception => e
  puts 'Usage: ./db_upload username environment [IP] filename'
  puts e
ensure
  ShellSpinner "Deleting dump file" do
    puts ssh.exec!("sudo docker exec advocatedefencepayments rm /usr/src/app/#{dump_file_name.gsub('.gz','')}")
  end
  ShellSpinner 'Closing connection' do
    ssh.close if ssh
  end
end
