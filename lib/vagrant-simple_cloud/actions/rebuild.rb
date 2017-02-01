require 'vagrant-simple_cloud/helpers/client'

module VagrantPlugins
  module SimpleCloud
    module Actions
      class Rebuild
        include Helpers::Client
        include Vagrant::Util::Retryable

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::simple_cloud::rebuild')
        end

        def call(env)

          # submit rebuild request
          result = @client.post("/v2/vps/#{@machine.id}/actions", {
            :type => 'rebuild',
            :image => @machine.provider_config.image
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_simple_cloud.info.rebuilding')
          @client.wait_for_event(env, result['action']['id'])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

          # wait for ssh to be ready
          switch_user = @machine.provider_config.setup?
          user = @machine.config.ssh.username
          @machine.config.ssh.username = 'root' if switch_user

          retryable(:tries => 120, :sleep => 10) do
            next if env[:interrupted]
            raise 'not ready' if !@machine.communicate.ready?
          end

          @machine.config.ssh.username = user

          @app.call(env)
        end
      end
    end
  end
end
