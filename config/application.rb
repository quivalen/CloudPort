require File.expand_path('../boot', __FILE__)

require 'rails/all'

# Require the gems listed in Gemfile, including any gems
# you've limited to :test, :development, or :production.
Bundler.require(*Rails.groups)

#
# Global constants
#
HOSTNAME_REGEX = /\A[a-z0-9][a-z0-9\.\-]+\z/
IP_ADDR_REGEX  = /\A((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?))\z/
IP_PORT_REGEX  = /\A((?:(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)\.){3}(?:25[0-5]|2[0-4][0-9]|[01]?[0-9][0-9]?)):([0-9]{1,4}|[1-5][0-9]{4}|6[0-4][0-9]{3}|65[0-4][0-9]{2}|655[0-2][0-9]|6553[0-5])\z/

module CloudPort
  class Application < Rails::Application
    # Settings in config/environments/* take precedence over those specified here.
    # Application configuration should go into files in config/initializers
    # -- all .rb files in that directory are automatically loaded.

    # Set Time.zone default to the specified zone and make Active Record auto-convert to this zone.
    # Run "rake -D time" for a list of tasks for finding time zone names. Default is UTC.
    # config.time_zone = 'Central Time (US & Canada)'

    # The default locale is :en and all translations from config/locales/*.rb,yml are auto loaded.
    # config.i18n.load_path += Dir[Rails.root.join('my', 'locales', '*.{rb,yml}').to_s]
    # config.i18n.default_locale = :de

    # Do not swallow errors in after_commit/after_rollback callbacks.
    config.active_record.raise_in_transactional_callbacks = true

    # Base SSH port to start assignment from
    config.ssh_base_port = 10000

    # An offset between SSH server and exposed ports
    config.ssh_port_offset = config.ssh_base_port

    # Docker image used to create containers from
    config.docker_image = 'rastasheep/ubuntu-sshd:14.04'

    # A command used to create tailored p.t.u. builds
    config.ptu_tailor_command = ENV.fetch('PTU_TAILOR_COMMAND', 'script/tailor')

    # Detects CloudPort server hostname
    #
    # param [String] file name to extract hostname from
    #
    # return [String] CloudPort Server hostname
    def cloudport_hostname(file_name = '/etc/cloudport_hostname')
      return ENV['CLOUDPORT_HOSTNAME'].strip if ENV['CLOUDPORT_HOSTNAME']

      return IO.read(file_name).split(%r{\n})[0].strip if File.exist?(file_name)

      '127.0.0.1'
    end

    # Reads CloudPort WWW administrator's password
    #
    # param [String] file name to read password from
    #
    # return [String] CloudPort WWW administrator's password
    def web_admin_password(file_name = '/etc/cloudport_password')
      return IO.read(file_name).split(%r{\n})[0].strip if File.exist?(file_name)

      'portcloud'
    end

    # return [String] path to iptables binary
    def iptables
      return ENV['IPTABLES'] if ENV['IPTABLES']

      'sudo /sbin/iptables'
    end

    # Should we invoke iptables binary?
    # Outside production and staging we usually do not.
    #
    # return [Boolean] true, if we do invoke / false, if don't
    def invoke_iptables?
      return true if Rails.env.production?
      return true if ENV['INVOKE_IPTABLES']

      false
    end

    # Hostname to be tailored into p.t.u. builds
    config.hostname = cloudport_hostname
  end
end
