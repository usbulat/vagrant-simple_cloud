module VagrantPlugins
  module SimpleCloud
    class Config < Vagrant.plugin('2', :config)
      attr_accessor :token
      attr_accessor :image
      attr_accessor :region
      attr_accessor :size
      attr_accessor :private_networking
      attr_accessor :ipv6
      attr_accessor :backups_enabled
      attr_accessor :ca_path
      attr_accessor :serviceaddr
      attr_accessor :ssh_key_name
      attr_accessor :setup
      attr_accessor :user_data

      alias_method :setup?, :setup

      def initialize
        @token              = UNSET_VALUE
        @image              = UNSET_VALUE
        @region             = UNSET_VALUE
        @size               = UNSET_VALUE
        @private_networking = UNSET_VALUE
        @ipv6               = UNSET_VALUE
        @backups_enable     = UNSET_VALUE
        @ca_path            = UNSET_VALUE
        @serviceaddr        = UNSET_VALUE
        @ssh_key_name       = UNSET_VALUE
        @setup              = UNSET_VALUE
        @user_data          = UNSET_VALUE
      end

      def finalize!
        @token              = ENV['DO_TOKEN'] if @token == UNSET_VALUE
        @image              = '26' if @image == UNSET_VALUE
        @region             = 'miran' if @region == UNSET_VALUE
        @size               = '1' if @size == UNSET_VALUE
        @private_networking = false if @private_networking == UNSET_VALUE
        @ipv6               = false if @ipv6 == UNSET_VALUE
        @backups_enabled    = false if @backups_enabled == UNSET_VALUE
        @ca_path            = nil if @ca_path == UNSET_VALUE
        @serviceaddr        = nil if @serviceaddr == UNSET_VALUE
        @ssh_key_name       = 'Vagrant' if @ssh_key_name == UNSET_VALUE
        @setup              = true if @setup == UNSET_VALUE
        @user_data          = nil if @user_data == UNSET_VALUE
      end

      def validate(machine)
        errors = []
        errors << I18n.t('vagrant_simple_cloud.config.token') if !@token
        
        errors << I18n.t('vagrant_simple_cloud.config.serviceaddr') if !@serviceaddr

        key = machine.config.ssh.private_key_path
        key = key[0] if key.is_a?(Array)
        if !key
          errors << I18n.t('vagrant_simple_cloud.config.private_key')
        elsif !File.file?(File.expand_path("#{key}.pub", machine.env.root_path))
          errors << I18n.t('vagrant_simple_cloud.config.public_key', {
            :key => "#{key}.pub"
          })
        end

        { 'SimpleCloud Provider' => errors }
      end
    end
  end
end
