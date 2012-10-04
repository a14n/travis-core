# in travis-hub/handler/request:
#
# ::Request.receive(type, data, credentials['token']) if authenticated?
#
# Services::Requests::Create.new(user, :event_type => event_type, :payload => data, :token => token)

module Travis
  module Services
    module Requests
      class Receive < Base
        extend Travis::Instrumentation

        attr_reader :request

        def run
          create if accept?
          request.start! if request
          request
        end
        instrument :run

        def accept?
          payload.accept?
        end

        private

          def payload
            @payload ||= Travis::Github::Payload.for(event_type, params[:payload])
          end

          def event_type
            @event_type ||= (params[:event_type] || 'push').gsub('-', '_')
          end

          def create
            @request = repo.requests.create!(payload.request.merge(
              :event_type => event_type,
              :state => :created,
              :commit => commit,
              :owner => owner,
              :token => params[:token]
            ))
          end

          def owner
            @owner ||= service(payload.owner[:type].pluralize, :by_github, payload.owner).run
          end

          def repo
            @repo ||= service(:repositories, :by_github, payload.repository.merge(:owner => owner)).run
          end

          def commit
            @commit = repo.commits.create!(payload.commit) if payload.commit
          end

          Travis::Notification::Instrument::Services::Requests::Receive.attach_to(self)
      end
    end
  end
end
