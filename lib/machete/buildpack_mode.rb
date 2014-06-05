module Machete
  module BuildpackMode
    class << self
      def buildpack_mode
        return @buildpack_mode if @buildpack_mode

        @buildpack_mode = (ENV['BUILDPACK_MODE'] || :online).downcase.to_sym
        Machete.logger.info("BUILDPACK_MODE not specified.\nDefaulting to '#{@buildpack_mode}'") unless ENV['BUILDPACK_MODE']
        @buildpack_mode
      end

      def offline?
        !online?
      end

      def online?
        buildpack_mode == :online
      end
    end
  end
end