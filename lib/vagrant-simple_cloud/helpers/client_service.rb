require 'vagrant-simple_cloud/helpers/result'
require 'faraday'
require 'json'

module VagrantPlugins
  module SimpleCloud
    module Helpers
      module ClientService
        def clientservice
          @clientservice ||= ApiClientService.new(@machine)
        end
      end

      class ApiClientService

        def initialize(machine)
          @logger = Log4r::Logger.new('vagrant::simple_cloud::apiclientservice')
          @config = machine.provider_config
          @clientservice = Faraday.new({
            :url => 'http://89.223.30.241:8181/',
            :ssl => {
              :ca_file => @config.ca_path
            }
          })
        end

        def post(path, params = {}, method = :post)
          @clientservice.headers['Content-Type'] = 'application/json'
          request(path, params, :post)
        end

        def request(path, params = {}, method = :get)
          begin
            @logger.info "Request: #{path}"
            result = @clientservice.send(method) do |req|
              req.url path, params
              req.headers['Authorization'] = "Bearer #{@config.token}"
            end
          rescue Faraday::Error::ConnectionFailed => e
            # TODO this is suspect but because farady wraps the exception
            #      in something generic there doesn't appear to be another
            #      way to distinguish different connection errors :(
            if e.message =~ /certificate verify failed/
              raise Errors::CertificateError
            end

            raise e
          end

          begin
            body = JSON.parse(result.body)
            @logger.info "Response: #{body}"
            next_page = body["links"]["pages"]["next"] rescue nil
            unless next_page.nil?
              uri = URI.parse(next_page)
              new_path = path.split("?")[0]
              next_result = self.request("#{new_path}?#{uri.query}")
              req_target = new_path.split("/")[-1]
              body["#{req_target}"].concat(next_result["#{req_target}"])
            end
          rescue JSON::ParserError => e
            raise(Errors::JSONError, {
              :message => e.message,
              :path => path,
              :params => params,
              :response => result.body
            })
          end

          unless /^2\d\d$/ =~ result.status.to_s
            raise(Errors::APIStatusError, {
              :path => path,
              :params => params,
              :status => result.status,
              :response => body.inspect
            })
          end

          Result.new(body)
        end
      end
    end
  end
end
