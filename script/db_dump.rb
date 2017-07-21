#!/usr/bin/env ruby

require 'net/ssh' # gem install net-ssh
require 'net/scp' # gem install net-scp
require 'colorize'
require 'shell-spinner'

ENVIRONMENTS = {
  'dev' => %w(dev adp_dev_new),
  'staging' => %w(staging adp_staging),
  'demo' => %w(demo adp_demo),
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
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get -y install postgresql-9.4'
end

begin
  ShellSpinner 'Connecting to host %s' % ssh_address do
    ssh = Net::SSH.start ssh_address, ssh_user
  end

  ShellSpinner 'Installing postgresql in container' do
    install_postgres ssh
  end

  ShellSpinner 'Dumping database...' do
    puts ssh.exec!("sudo docker exec advocatedefencepayments rake db:dump_anonymised[#{dump_file_name}]")
    puts ssh.exec!("sudo docker cp advocatedefencepayments:/usr/src/app/#{gzip_file_name} ~/")
  end

  puts 'Downloading dump file'
  success = ssh.scp.download!("/home/#{ssh_user}/#{gzip_file_name}", '.') do |_channel, _name, sent, total|
    puts "...downloading... #{sent}/#{total}... #{'done'.green}" if sent % 512_000 == 0
  end

  puts 'File %{file} download %{success}' % { file: gzip_file_name, success: success ? 'success'.green : 'failure'.red }

rescue Exception => e
  puts 'Usage: ./db_dump.rb username environment [IP]'
  puts e
ensure
  if !ssh.closed?
    ShellSpinner 'Deleting remote compressed dump file' do
      ssh.exec!("sudo docker exec advocatedefencepayments rm #{gzip_file_name}")
    end
    ShellSpinner 'Closing connection' do
      ssh.close
    end
  end
end
