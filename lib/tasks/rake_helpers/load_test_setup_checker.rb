module RakeHelpers

  class LoadTestSetupChecker

    WRAPPER_DIR = File.expand_path(File.join(Rails.root, '..', 'tsung-wrapper'))
    PARENT_DIR = File.expand_path(File.join(Rails.root, '..'))
    XML_CONFIG = File.expand_path(File.join(WRAPPER_DIR, 'config', 'project', 'adp', 'xml', 'staging-gradual-create_guilty_plea.xml'))


    def setup?
      exit unless directory_exists?
      exit unless xml_file_exists?
      puts csrf_warning.colorize(:green)
      print "Are you ready to start the load test? [y/n] "
      ans = STDIN.gets.chomp
      ans.upcase == 'Y'
    end

    private

    def directory_exists?
      puts 'Checking that tsung-wrapper git repo is installed in expected location......'.colorize(:green)
      if Dir.exist?(WRAPPER_DIR)
        puts "OK - installed tsung-wrapper found at #{WRAPPER_DIR}".colorize(:green)
        true
      else
        puts installation_instructions.colorize(:red)
        false
      end
    end

    def xml_file_exists?
      puts 'Checking that load test config file exists.....'.colorize(:green)
      if File.exist? XML_CONFIG
        puts "OK - using XML config at #{XML_CONFIG}".colorize(:green)
        true
      else
        puts config_file_not_found.colorize(:red)
        false
      end
    end

    def installation_instructions
      <<-EOS

        ERROR! tsung-wrapper not found!

        In order to run the load test for ADP, you need to have the tsung-wrapper repo
        installed at #{WRAPPER_DIR}.

        To install the repo, cd to #{PARENT_DIR} and
        execute 'git clone git@github.com:ministryofjustice/tsung-wrapper.git'.

        You will also need to install Erlang, and Perl Template toolkit. See the
        README file tsung_wrapper repo for installation details.

        EOS
    end


    def config_file_not_found
      <<-EOS

        ERROR! Unable to find XML config file for load test

        The load test needs an XML config file to run, and was expected to be located at
        #{XML_CONFIG}, but there is no such file.

        The file can be reconstructed by following these steps:

        - In the tsung-wrapper directory, execute "ruby tsung_runner.rb".

        - In response to the question "Select task", select "Generate session XML".

        - In response to the question "Select the project you want to load test", select "adp".

        - In response to the question "Select the environment to use", select "staging".

        - In response to the question "Select the load_profile to use", select "gradual".

        - In response to the question "Select the session to run", select "create_guilty_plea"

      This will regenerate the XML config file, and then you will be able to run this rake task again.

      EOS
    end

    def csrf_warning
      <<-EOS

      Have you built and deployed a version of the app without CSRF protection?

      You are about to start a load test on staging.  The load test requires that CSRF
      protection is disabled.  In order to do this, you need to:

      - Build a version of the app in Jenkins, setting the DISABLE_CSRF flag to 1

      - Deploy that build to staging


      EOS
    end
  end
end