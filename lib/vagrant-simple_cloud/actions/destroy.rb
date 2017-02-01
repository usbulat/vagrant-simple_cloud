require 'vagrant-simple_cloud/helpers/client'

module VagrantPlugins
  module SimpleCloud
    module Actions
      class Destroy
        include Helpers::Client

        def initialize(app, env)
          @app = app
          @machine = env[:machine]
          @client = client
          @logger = Log4r::Logger.new('vagrant::simple_cloud::destroy')
        end

        def call(env)
          # submit destroy droplet request
          @client.delete("/v2/vps/#{@machine.id}")

          env[:ui].info I18n.t('vagrant_simple_cloud.info.destroying')

          # set the machine id to nil to cleanup local vagrant state
          @machine.id = nil

          @app.call(env)
        end
      end
    end
  end
end
