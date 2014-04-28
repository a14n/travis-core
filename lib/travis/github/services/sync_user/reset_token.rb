require "gh"

module Travis
  module Github
    module Services
      class SyncUser < Travis::Services::Base
        class ResetToken
          attr_writer :gh, :config

          def initialize(user, config = Travis.config.oauth2)
            @user = user
            @config = config
            @gh = GH.with(username: @config.client_id, password: @config.client_secret)
          end

          def run
            @user.update_attributes!(github_oauth_token: new_token)
          end

          private

          def new_token
            @new_token ||= @gh.post("/applications/#{client_id}/tokens/#{@user.github_oauth_token}", {})["token"]
          end

          def client_id
            @config.client_id
          end

          def client_secret
            @config.client_secret
          end
        end
      end
    end
  end
end
