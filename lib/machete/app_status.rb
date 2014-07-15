module Machete
  class AppStatus
    UNKNOWN = 0
    RUNNING = 1
    STAGING_FAILED = 2

    def execute(app)
      instances_command = CF::Instances.new(app)
      instances = instances_command.execute

      return STAGING_FAILED if staging_failure(instances_command)

      return RUNNING if has_one_running_instance(instances)

      return UNKNOWN
    end

    private

    def staging_failure(instances_command)
      instances_command.error == 'CF-BuildpackCompileFailed'
    end

    def has_one_running_instance(instances)
      instances.detect do |instance|
        instance.state == 'RUNNING'
      end
    end
  end
end
