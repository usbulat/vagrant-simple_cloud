require 'vagrant-simple_cloud/actions/check_state'
require 'vagrant-simple_cloud/actions/create'
require 'vagrant-simple_cloud/actions/destroy'
require 'vagrant-simple_cloud/actions/shut_down'
require 'vagrant-simple_cloud/actions/power_off'
require 'vagrant-simple_cloud/actions/power_on'
require 'vagrant-simple_cloud/actions/rebuild'
require 'vagrant-simple_cloud/actions/reload'
require 'vagrant-simple_cloud/actions/setup_user'
require 'vagrant-simple_cloud/actions/setup_sudo'
require 'vagrant-simple_cloud/actions/setup_key'
require 'vagrant-simple_cloud/actions/modify_provision_path'

module VagrantPlugins
  module SimpleCloud
    module Actions
      include Vagrant::Action::Builtin

      def self.destroy
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            else
              b.use Call, DestroyConfirm do |env2, b2|
                if env2[:result]
                  b2.use Destroy
                  b2.use ProvisionerCleanup if defined?(ProvisionerCleanup)
                end
              end
            end
          end
        end
      end

      def self.ssh
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use SSHExec
            when :off
              env[:ui].info I18n.t('vagrant_simple_cloud.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            end
          end
        end
      end

      def self.ssh_run
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use SSHRun
            when :off
              env[:ui].info I18n.t('vagrant_simple_cloud.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            end
          end
        end
      end

      def self.provision
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Provision
              b.use ModifyProvisionPath
              b.use SyncedFolders
            when :off
              env[:ui].info I18n.t('vagrant_simple_cloud.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            end
          end
        end
      end

      def self.up
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              env[:ui].info I18n.t('vagrant_simple_cloud.info.already_active')
            when :off
              b.use PowerOn
              b.use provision
            when :not_created
              b.use SetupKey
              b.use Create
              b.use SetupSudo
              b.use SetupUser
              b.use provision
            end
          end
        end
      end

      def self.halt
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              if env[:force_halt] 
                b.use PowerOff
              else
                b.use ShutDown
              end
            when :off
              env[:ui].info I18n.t('vagrant_simple_cloud.info.already_off')
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            end
          end
        end
      end

      def self.reload
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active
              b.use Reload
              b.use provision
            when :off
              env[:ui].info I18n.t('vagrant_simple_cloud.info.off')
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            end
          end
        end
      end

      def self.rebuild
        return Vagrant::Action::Builder.new.tap do |builder|
          builder.use ConfigValidate
          builder.use Call, CheckState do |env, b|
            case env[:machine_state]
            when :active, :off
              b.use Rebuild
              b.use SetupSudo
              b.use SetupUser
              b.use provision
            when :not_created
              env[:ui].info I18n.t('vagrant_simple_cloud.info.not_created')
            end
          end
        end
      end
    end
  end
end
