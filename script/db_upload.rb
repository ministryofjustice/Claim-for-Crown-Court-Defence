#!/usr/bin/env ruby

require 'net/ssh' # gem install net-ssh
require 'net/scp' # gem install net-scp

ENVIRONMENTS = {
  'dev' => %w(dev adp_dev_new),
  'staging' => %w(staging adp_staging)
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
  @ssh_address ||= (ARGV[2].to_s.end_with?('.psql') ? ENVIRONMENTS[ssh_env].first : ARGV[2])
end

def dump_file_name
  @dump_file_name ||= begin
    (ARGV[2].to_s.end_with?('.psql') ? ARGV[2] : ARGV[3]) || (raise 'Please specify the dump file name as the third (or fourth if IP was provided) argument')
  end
end

def install_postgres(ssh)
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get update'
  ssh.exec! 'sudo docker exec advocatedefencepayments apt-get -y install postgresql-9.4'
end

begin
  puts 'Preparing to upload to host %s dump file %s' % [ssh_address, dump_file_name]
  ssh = Net::SSH.start ssh_address, ssh_user

  puts 'Installing postgres in container (this might take a minute)...'
  install_postgres ssh

  puts 'Uploading dump file %s...' % dump_file_name
  Net::SCP.upload! ssh_address, ssh_user, dump_file_name, "/home/#{ssh_user}/#{dump_file_name}"

  # Note: Docker 1.8 support cp command to copy a file from the host to the container, but we are using Docker 1.6
  puts 'Copying dump file into container...'
  puts ssh.exec!("cat #{dump_file_name} | sudo docker exec -i advocatedefencepayments sh -c 'cat > /usr/src/app/#{dump_file_name}'")
  puts ssh.exec!("rm -f /home/#{ssh_user}/#{dump_file_name}")

  puts 'Running task db:restore (this might take some minutes)...'
  puts ssh.exec!("sudo docker exec advocatedefencepayments rake db:restore[#{dump_file_name}]")

  puts 'Dump %s was successfully restored' % dump_file_name
  ssh.close
rescue Exception => e
  puts 'Usage: ./db_upload username environment [IP] filename'
  puts e
end
