require 'vagrant-simple_cloud/helpers/client'

module VagrantPlugins
  module SimpleCloud
    module Actions
      class Reload
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::simple_cloud::reload')
        end

        def call(env)
          # submit reboot droplet request
          result = @client.post("/v2/vps/#{@machine.id}/actions", {
            :type => 'reboot'
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_simple_cloud.info.reloading')
          @client.wait_for_event(env, result['action']['id'])

          @app.call(env)
        end
      end
    end
  end
end

