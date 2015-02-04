require 'net/ldap'
require 'devise/strategies/authenticatable'

module Devise
  module Strategies
    class LdapAuthenticatable < Authenticatable
      def authenticate!
        if params[:user]
          if Rails.application.config.allow_ldap_auth
            ldap = Net::LDAP.new
            user = authenticate_with_ldap(email, password)
          else
            return
          end
          if !user
            success!(user)
          else
            fail(:invalid_login)
          end
        end
      end

      def email
        params[:user][:email]
      end

      def password
        params[:user][:password]
      end

      def user_data
        {:email => email, :password => password, :password_confirmation => password}
      end

      protected
        def authenticate_with_ldap(email, password)
          Rails.logger.info "LDAP login with '#{email}'"

          # First query ldap to get the user's info
          ldap_user = find_in_ldap(email)
          return nil if !ldap_user

          # Then try to bind with user's password
          Rails.logger.debug "Trying to bind with user\'s password"
          conn = create_ldap_connection
          conn.auth ldap_user[:dn], password

          if conn.bind
            Rails.logger.info "LDAP authentication successful"
            ldap_user[:password] = password
            return User.find_by_email(email) || create_from_ldap(ldap_user)
          else
            return nil
          end
        end
        # Search LDAP for given email and if finds create account (for invitations)
        def find_in_ldap_and_create(email)
          ldap_user = find_in_ldap(email)
          ldap_user ? create_from_ldap(ldap_user) : nil
        end

        def find_in_ldap(email)
          conf = Rails.application.config.ldap_auth_settings

          conn = create_ldap_connection
          filter = Net::LDAP::Filter.eq(conf[:email_key], email)
          attributes = [:dn, conf[:first_name_key], conf[:last_name_key], conf[:email_key], conf[:identifier_key]]

          Rails.logger.debug "Searching #{conf[:identifier_key]}=#{email},#{conf[:base_dn]} on #{conf[:host]}:#{conf[:port]}"
          result = conn.search(:base => conf[:base_dn], :filter => filter, :attributes => attributes)

          if !result || result.empty?
            Rails.logger.debug conn.get_operation_result
            return nil
          end

          dn = result.first.dn

          first_name = result.first[ conf[:first_name_key] ][0]
          last_name = result.first[ conf[:last_name_key] ][0]
          name = result.first[ conf[:identifier_key] ][0]

          Rails.logger.debug "Found #{dn}: #{first_name}, #{last_name}, #{email}"
          if !dn || !first_name || !last_name || !email
            Rails.logger.info "One of the required attributes in LDAP entry is null"
            return nil
          end

          # Net::LDAP doesn't return string object; to_str is really necessary (tested)
          return {
            :dn => dn,
                  :first_name => first_name.to_str,
                  :last_name => last_name.to_str,
            :email => email.to_str,
                  :name => name.to_str
          }
        end

        def create_ldap_connection
          conf = Rails.application.config.ldap_auth_settings

          conn = Net::LDAP.new
          conn.host = conf[:host]
          conn.port = conf[:port]
          
          if conf[:encryption]
            conn.encryption(conf[:encryption])
          end


          if conf[:bind_dn] && conf[:bind_password]
                  conn.auth conf[:bind_dn], conf[:bind_password]
          end
          return conn
        end

        # Create account for user from LDAP
        def create_from_ldap(ldap_user)
          Rails.logger.info "Creating new user account for '#{ldap_user[:name]}' with LDAP authentication"

          user = User.create({
            :email => ldap_user[:email],
            :name => ldap_user[:name],
            :password => ldap_user[:password],
            :password_confirmation => ldap_user[:password],
          })
          return user
        end
          end
        end
end

Warden::Strategies.add(:ldap_authenticatable, Devise::Strategies::LdapAuthenticatable)
