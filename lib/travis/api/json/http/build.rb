module Travis
  module Api
    module Json
      module Http
        class Build
          class Job
            include Formats

            attr_reader :job, :commit

            def initialize(job)
              @job = job
              @commit = job.commit
            end

            def data
              {
                'id' => job.id,
                'number' => job.number,
                'config' => job.config.stringify_keys,
                'started_at' => format_date(job.started_at),
                'finished_at' => format_date(job.finished_at),
                'log' => job.log.content
              }
            end
          end

          include Formats

          attr_reader :build, :commit, :request, :repository

          def initialize(build, options = {})
            @build = build
            @commit = build.commit
            @request = build.request
            @repository = build.repository
          end

          def data
            {
              'id' => build.id,
              'repository_id' => repository.id,
              'number' => build.number,
              'config' => build.config.stringify_keys,
              'state' => build.state.to_s,
              'result' => build.status,
              'status' => build.status,
              'started_at' => format_date(build.started_at),
              'finished_at' => format_date(build.finished_at),
              'duration' => build.duration,
              'commit' => commit.commit,
              'branch' => commit.branch,
              'message' => commit.message,
              'committed_at' => format_date(commit.committed_at),
              'author_name' => commit.author_name,
              'author_email' => commit.author_email,
              'committer_name' => commit.committer_name,
              'committer_email' => commit.committer_email,
              'compare_url' => commit.compare_url,
              'event_type' => request.event_type,
              'matrix' => build.matrix.map { |job| Job.new(job).data },
            }
          end
        end
      end
    end
  end
end
