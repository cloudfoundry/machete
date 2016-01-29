# encoding: utf-8
module Machete
  module BuildpackMode
    class << self
      def buildpack_mode
        return @buildpack_mode if @buildpack_mode

        @buildpack_mode = (ENV['BUILDPACK_MODE'] || :cached).downcase.to_sym
        Machete.logger.info("BUILDPACK_MODE not specified.\nDefaulting to '#{@buildpack_mode}'") unless ENV['BUILDPACK_MODE']
        @buildpack_mode
      end

      def cached?
        !uncached?
      end

      def uncached?
        buildpack_mode == :uncached
      end
    end
  end
end
