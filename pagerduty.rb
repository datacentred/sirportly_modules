module Sirportly
  module Modules
    module Custom
      class Pagerduty < Module

        ## Set the module properties which are displayed to the user in the configration tools.
        module_name "Pagerduty"
        description "Page the on-call engineer to important tickets using Pagerduty"
        author "Rob Greenwood <rob.greenwood@datacentred.co.uk>"
        publicise

        ## Public information
        icon "/images/modules/pagerduty.png"
        public_description "Pagerduty integration allows you to use ticket macros to automatically create incidents within Pagerduty"
        url "http://www.pagerduty.com"

        ## Defines the required configuration options for this module
        config_option :devops_service_key, "DevOps PagerDuty Service Key", "PagerDuty Service Key for the DevOps Team", :required => true
        config_option :ops_service_key, "Ops PagerDuty Service Key", "PagerDuty Service Key for the Ops Team", :required => true
       
        ## Require all the needed libraries when the module is defined into the application
        def self.loaded
          require 'uri'
          require 'net/https'
          require 'json'
        end

        add_macro_action :pagerduty_alert_devops, "Page the DevOps Team" do |config, macro, ticket, options|
          Sirportly::Modules::Custom::Pagerduty.send_alert(config[:devops_service_key], ticket)
        end

        add_macro_action :pagerduty_alert_ops, "Page the Ops Team" do |config, macro, ticket, options|
          Sirportly::Modules::Custom::Pagerduty.send_alert(config[:ops_service_key], ticket)
        end

        def self.send_alert(service_key, ticket)
          payload = {
            "service_key"  => service_key,
            "incident_key" => ticket.id,
            "event_type"   => "trigger",
            "description"  => "Emergency Ticket #{ticket.reference}: #{ticket.subject}",
          }

          uri = URI.parse("https://events.pagerduty.com/generic/2010-04-15/create_event.json")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          req = Net::HTTP::Post.new(uri.path)
          response = http.post(uri.path, payload.to_json, {"Content-Type" => "application/json"})
        end

      end
    end
  end
end
