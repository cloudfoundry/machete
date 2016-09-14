require 'json'
require 'shellwords'
require 'tmpdir'

RSpec::Matchers.define :keep_credentials_out_of_droplet do
  match do |app_name|
    @output = inspect_app(app_name)
    @output.empty?
  end

  failure_message do |app_name|
    "expected #{app_name} to not write credentials to droplet, it does\n" +
    "output from failure:\n" +
    @output
  end
end

def inspect_app(app_name)
  app_guid = `cf app #{app_name} --guid`.chomp

  Dir.mktmpdir do |tmp_dir|
    Dir.chdir(tmp_dir) do
      system("cf curl /v2/apps/#{app_guid}/droplet/download --output droplet.tgz")
      raise 'Droplet could not be unarchive' unless system('tar xzf droplet.tgz 2>/dev/null')

      envs_json = JSON.parse(`cf curl /v2/apps/#{app_guid}/env`.chomp)
      logged_output = ''
      envs_json['system_env_json']['VCAP_SERVICES'].values.each do |services|
        services.each do |service|
          service['credentials'].each do |name, value|
            next if value.to_s.empty? || %w(hostname port).include?(name)

            output = `grep -s -l -r #{value.shellescape} .`
            files = output.split("\n")

            next if files.empty?

            logged_output += "FATAL: Found contents of credential '#{name}' in the following files:\n"
            files.each do |file|
              logged_output += "   #{file}\n"
            end
          end
        end
      end
      logged_output
    end
  end
end
