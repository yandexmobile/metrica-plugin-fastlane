require 'fastlane/action'

module Fastlane
  module Actions
    class UploadSymbolsToAppmetricaAction < Action
      def self.run(params)
        find_binary(params)

        Dir.mktmpdir do |temp_dir|
          self.run_helper(temp_dir, params)
        end
      end

      def self.run_helper(temp_dir, params)
        unless params[:package_output_path].nil?
          package_output_path = File.absolute_path(params[:package_output_path])
        end

        files = Array(params[:files]) +
                Array(Actions.lane_context[SharedValues::DSYM_OUTPUT_PATH]) +
                Array(Actions.lane_context[SharedValues::DSYM_PATHS])

        files = files.compact.map { |file| self.process_file(file, temp_dir) }

        cmd = [params[:binary_path], "--post-api-key=#{params[:post_api_key]}"]
        cmd << "--verbose" if params[:verbose]
        cmd << "--package-output-path=#{package_output_path.shellescape}" unless package_output_path.nil?
        cmd += files unless files.empty?

        UI.message("Starting helper")
        Actions.sh(cmd)
      end

      def self.process_file(file_path, temp_dir)
        if File.extname(file_path) == ".zip"
          output_path = File.join(temp_dir, SecureRandom.uuid)
          Dir.mkdir(output_path)
          Actions.sh("unzip -o #{file_path.shellescape} -d #{output_path.shellescape} 2>/dev/null")
          return output_path
        end
        return File.absolute_path(file_path)
      end

      def self.find_binary(params)
        params[:binary_path] ||= Dir["./Pods/**/*MobileMetrica/helper"].last

        unless params[:binary_path]
          UI.user_error!("Failed to find 'helper' binary. Install YandexMobileMetrica 3.8.0 pod or higher. "\
            "You may specify the location of the binary by using the binary_path option")
        end

        params[:binary_path] = File.expand_path(params[:binary_path]).shellescape

        cli_version = Gem::Version.new(`#{params[:binary_path]} --version`.strip)
        unless Gem::Requirement.new(Fastlane::Appmetrica::CLI_VERSION) =~ cli_version
          UI.user_error!("Your 'helper' is outdated, please upgrade to at least version "\
            "#{Fastlane::Appmetrica::CLI_VERSION} and start again!")
        end
      end

      #####################################################
      # @!group Documentation
      #####################################################

      def self.description
        "Upload dSYM symbolication files to AppMetrica"
      end

      def self.authors
        ["Yandex, LLC"]
      end

      def self.details
        "This plugin allows uploading dSYM symbolication files to AppMetrica. It should be applied if you use Bitcode"
      end

      def self.available_options
        [
          FastlaneCore::ConfigItem.new(key: :binary_path,
                                       description: "The path to 'helper' binary in AppMetrica framework",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :post_api_key,
                                       env_name: "APPMETRICA_POST_API_KEY",
                                       description: "Post API key. This mandatory parameter is "\
                                       "used to upload dSYMs to AppMetrica",
                                       optional: false,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :package_output_path,
                                       description: "The path where temporary archives are stored. "\
                                       "If not specified, default system's temporary directory used instead",
                                       optional: true,
                                       type: String),
          FastlaneCore::ConfigItem.new(key: :verbose,
                                       description: "Verbose mode. Displays additional information",
                                       optional: true,
                                       type: Boolean),
          FastlaneCore::ConfigItem.new(key: :files,
                                       description: "An optional list of dSYM files or directories that "\
                                       "contain these files to upload. If not specified, "\
                                       "the local working directory used by default",
                                       optional: true,
                                       type: Array)
        ]
      end

      def self.is_supported?(platform)
        [:ios, :mac].include?(platform)
      end
    end
  end
end
