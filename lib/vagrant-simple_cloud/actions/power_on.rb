require 'vagrant-simple_cloud/helpers/client'

module VagrantPlugins
  module SimpleCloud
    module Actions
      class PowerOn
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::simple_cloud::power_on')
        end

        def call(env)
          # submit power on droplet request
          result = @client.post("/v2/vps/#{@machine.id}/actions", {
            :type => 'power_on'
          })

          # wait for request to complete
          env[:ui].info I18n.t('vagrant_simple_cloud.info.powering_on') 
          @client.wait_for_event(env, result['action']['id'])

          # refresh droplet state with provider
          Provider.droplet(@machine, :refresh => true)

          @app.call(env)
        end
      end
    end
  end
end


