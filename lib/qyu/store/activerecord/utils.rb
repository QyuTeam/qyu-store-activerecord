require 'rake'

load 'tasks/db.rake'

module Qyu
  module Store
    module ActiveRecord
      class Utils
        def self.ensure_db_ready(db_config)
          begin
            ActiveRecord::Base.establish_connection(db_config).connection
          rescue ActiveRecord::NoDatabaseError
            Rake::Task['qyu:db:create'].invoke
          end

          begin
            Rake::Task['qyu:db:migrate_without_schema_update'].invoke
          rescue ActiveRecord::ConcurrentMigrationError
            ArcYu.logger.info 'Concurrent Qyu database migration running. Skipping...'
          end
        end
      end
    end
  end
end
