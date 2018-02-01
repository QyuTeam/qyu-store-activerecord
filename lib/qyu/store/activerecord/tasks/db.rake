# frozen_string_literal: true

require 'qyu/store/activerecord'
require 'uri'
require 'cgi'

namespace :qyu do
  namespace :db do
    migrations_path = "#{__dir__}/../db/migrate/"

    db_config = Qyu::Store::ActiveRecord::Adapter.db_configuration
    db_config ||= begin
                    url = ENV['QYU_DB_URL']

                    if !url.nil?
                      db_url = URI(url)
                      db_params = CGI::parse(db_url.query.to_s)

                      db_type = db_url.scheme == 'postgres' ? 'postgresql' : db_url.scheme
                      db_host = db_url.host
                      db_port = db_url.port
                      db_name = db_url.path[1..-1]
                      db_user = db_url.user
                      db_password = db_url.password
                      db_pool = db_params['pool'].first
                    else
                      db_type = ENV['QYU_DB_ADAPTER']
                      db_host = ENV['QYU_DB_HOST']
                      db_port = ENV['QYU_DB_PORT']
                      db_name = ENV['QYU_DB_NAME']
                      db_user = ENV['QYU_DB_USERNAME']
                      db_password = ENV['QYU_DB_PASSWORD']
                      db_pool = ENV['QYU_DB_POOL']
                    end

                    db_config = {
                      adapter:  db_type,
                      database: db_name,
                      username: db_user,
                      host:     db_host,
                      port:     db_port,
                      pool:     db_pool
                    }

                    db_config[:password] = db_password if db_password
                  end

    desc 'Create the database'
    task :create do
      ActiveRecord::Base.establish_connection(db_config.merge(database: 'postgres'))
      ActiveRecord::Base.connection.create_database(db_config[:database])

      puts 'Qyu Database created.'
    end

    desc 'Migrate the database'
    task :migrate do
      ActiveRecord::Base.establish_connection(db_config)
      ActiveRecord::Migrator.migrate(migrations_path)

      Rake::Task['qyu:db:structure'].invoke

      puts 'Qyu database migrated.'
    end

    desc 'Setup the database'
    task :setup do
      Rake::Task['arc_yu:db:create'].invoke
      Rake::Task['arc_yu:db:migrate'].invoke
      puts 'Qyu database set up.'
    end

    desc 'Migrate the database w/o updating the schema'
    task :migrate_without_schema_update do
      ActiveRecord::Base.establish_connection(db_config)
      ActiveRecord::Migrator.migrate(migrations_path)

      puts 'Qyu database migrated.'
    end

    desc 'Rollback the database'
    task :rollback do
      ActiveRecord::Base.establish_connection(db_config)
      ActiveRecord::Migrator.rollback(migrations_path)

      Rake::Task['qyu:db:structure'].invoke

      puts 'Qyu migration reverted.'
    end

    desc 'Drop the database'
    task :drop do
      ActiveRecord::Base.establish_connection(db_config.merge(database: 'postgres'))
      ActiveRecord::Base.connection.drop_database(db_config[:database])

      puts 'Qyu database deleted.'
    end

    desc 'Reset the database'
    task reset: %i(drop create migrate)

    desc 'Create a db/structure.sql, this file specific for PostgreSQL and contains all custom columns definitions'
    task :structure do
      ActiveRecord::Base.establish_connection(db_config)

      file = "#{__dir__}/structure.sql"

      db_config.stringify_keys!
      ActiveRecord::Base.schema_format = :sql
      ActiveRecord::Tasks::PostgreSQLDatabaseTasks.new(db_config).structure_dump(file, {})
    end

    namespace :g do
      desc 'Generate migration'
      task :migration do
        name = ARGV[1] || fail('Specify name: rake g:migration your_migration')
        timestamp = Time.now.strftime('%Y%m%d%H%M%S')
        path = File.join([migrations_path, "{timestamp}_#{name}.rb"])
        migration_class = name.split('_').map(&:capitalize).join

        File.open(path, 'w') do |file|
          file.write <<-EOF.gsub(' ' * 12, '')
            class #{migration_class} < ActiveRecord::Migration[5.0]
              def up
              end

              def down
              end
            end
          EOF
        end

        puts "Qyu migration #{path} created"
        abort # needed stop other tasks
      end
    end
  end
end
