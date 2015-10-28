module Sirportly
  module Modules
    module Custom
      class Jira < Module

        ## Set the module properties which are displayed to the user in the configration tools.
        module_name "Jira"
        description "Create tickets on-demand in Jira"
        author "Sean Handley <sean.handley@datacentred.co.uk>"
        publicise

        ## Public information
        icon "/images/modules/jira.png"
        public_description "Jira integration allows you to use ticket macros to automatically create tickets within Jira"
        url "http://datacentred.atlassian.net"

        ## Defines the required configuration options for this module
        config_option :basic_auth_username, "Basic Auth Username", "Username to authenticate with the JIRA REST API", :required => true
        config_option :basic_auth_password, "Basic Auth Password", "Password to authenticate with the JIRA REST API", :required => true
       
        ## Require all the needed libraries when the module is defined into the application
        def self.loaded
          require 'uri'
          require 'net/https'
          require 'json'
        end

        add_macro_action :jira_create_ticket, "Create Ticket In Jira" do |config, macro, ticket, options|
          Sirportly::Modules::Custom::Jira.create_ticket(config[:basic_auth_username], config[:basic_auth_password], ticket, options)
        end

        def self.create_ticket(username, password, ticket, options)
          # <Ticket id: 1398, department_id: 3, priority_id: 3, status_id: 2, sla_id: 2, contact_id: 232, contact_method_id: 234, ticket_source_id: 1, team_id: 1, user_id: 11, subject: "Missing connectivity between instances on different...", reply_due_at: nil, resolution_due_at: nil, message_id: "1fe17eeb-4080-6d6d-452b-db552aa8f090@helpdesk.datac...", created_at: "2015-10-23 14:07:07", updated_at: "2015-10-23 15:19:26", update_count: 7, last_respondant: "contact", reference: "OH-893846", account_id: 1, auth_code: "m0bn04h7a30p", ticket_source_type: "ApiToken", additional_recipients: nil, last_update_posted_at: "2015-10-23 15:19:26", first_response_time: #<BigDecimal:85f5930,'0.3052E2',18(18)>, first_resolution_time: #<BigDecimal:85f57f0,'0.4081E2',18(18)>, resolution_time: #<BigDecimal:85f5778,'0.4081E2',18(18)>,

          # checklist_id: nil, status_type: 0, public: false, tag_list: nil, original_tweet_id: nil, deleted_at: nil, deleted_by_id: nil, spam: false, index_at: nil> {:current_user=>#<User id: 2, account_id: 1, username: "sean.handley", first_name: "Sean", last_name: "Handley", email_address: "sean.handley@datacentred.co.uk", atech_identity_key: nil, invite_code: "da4d8749-2194-9c1f-b9e4-c30ffcdf5f52", created_at: "2014-09-12 14:55:38", updated_at: "2014-12-12 17:07:45", enabled: true, time_zone: "London", admin_access: true, reporting_access: true, tickets_access: true, display_welcome: true, ticket_display_mode: "descending", mobile: nil, hashed_password: "f2122658001621096a28f7e21e3eaaa9f581488d", salt: "d8phih", api_allowed: false, restrictions: nil, avatar: nil, contacts_access: true, feed_token: "a84e52fb-49c2-2fad-4dab-8c9a09d14f96", last_session_id: "dd526be5a867e42b17803a3e3a3bfd6c", last_session_ip: "185.43.216.241", last_session_path: "/staff/tickets/OH-893846/poll", last_session_time: "2015-10-28 14:36:18", time_format: "default", keyboard_shortcuts: true, language: "en", noti_token: nil, job_title: "Cloud Applications Engineer", ui_colour: nil, default_ui: 2, mobile_push_notifications: true, mobile_push_sound: false>}
          payload = { "fields" => {
                 "project" =>
                 { 
                    "key" => "PD"
                 },
                 "summary" => ticket.subject,
                 "description" => ticket.updates.first.message,
                 "issuetype" => {
                    "name" => "Story"
                 },
                 "assignee" => {
                  "name" => options[:current_user].username
                 }
             }
          }

          basic_auth = Base64.strict_encode64("#{username}:#{password}")

          uri = URI.parse("https://datacentred.atlassian.net/rest/api/2/issue/")
          http = Net::HTTP.new(uri.host, uri.port)
          http.use_ssl = true
          http.verify_mode = OpenSSL::SSL::VERIFY_NONE
          response = http.post(uri.path, payload.to_json, {"Content-Type" => "application/json", "Authorization" => "Basic #{basic_auth}"})
        end

      end
    end
  end
end
