require 'securerandom'

module Qyu
  module Store
    module ActiveRecord
      class Adapter < Qyu::Store::ActiveRecord.interface
        TYPE = :active_record

        class << self
          def valid_config?(config)
            ConfigurationValidator.new(config).valid?
          end
        end

        cattr_reader :db_configuration

        def initialize(config)
          init_client(config)
        end

        def find_or_persist_task(name, queue_name, payload, job_id, parent_task_id)
          id = nil
          transaction do
            id_payload_combos = Task.where(
              name: name,
              queue_name: queue_name,
              job_id: job_id,
              parent_task_id: parent_task_id
            ).pluck(:id, :payload)

            id_payload_combos.each do |t_id, t_payload|
              if compare_payloads(t_payload, payload)
                id = t_id
                break
              end
            end

            if id.nil?
              id = Task.create!(name: name, queue_name: queue_name, payload: payload, job_id: job_id, parent_task_id: parent_task_id).id
            end

            yield(id)
          end

          id
        end

        def persist_workflow(name, descriptor)
          with_connection do
            Workflow.create!(name: name, descriptor: descriptor).id
          end
        end

        def persist_job(workflow, payload)
          with_connection do
            Job.create!(payload: payload, workflow_id: workflow.id).id
          end
        end

        def find_workflow(id)
          wflow = Workflow.find_by(id: id)
          deserialize_workflow(wflow)
        end

        def find_workflow_by_name(name)
          wflow = Workflow.find_by(name: name)
          deserialize_workflow(wflow)
        end

        def find_task(id)
          task = Task.find_by(id: id)
          deserialize_task(task)
        end

        def find_task_ids_by_job_id_and_name(job_id, name)
          Task.where(job_id: job_id, name: name).pluck(:id)
        end

        def find_task_ids_by_job_id_name_and_parent_task_ids(job_id, name, parent_task_ids)
          Task.where(job_id: job_id, name: name, parent_task_id: parent_task_ids).pluck(:id)
        end

        def find_job(id)
          j = Job.find_by(id: id)
          return if j.nil?

          wflow = Workflow.find_by(id: j.workflow_id)
          return if wflow.nil?

          deserialize_job(j, wflow)
        end

        def select_jobs(limit, offset, order = :asc)
          Job.includes(:workflow).order(id: order).limit(limit).offset(offset).as_json(include: :workflow)
        end

        def select_tasks_by_job_id(job_id)
          Task.where(job_id: job_id).as_json
        end

        def count_jobs
          Job.count
        end

        def lock_task!(id, lease_time)
          Qyu.logger.debug '[LOCK] lock_task!'

          uuid = SecureRandom.uuid
          Qyu.logger.debug "[LOCK] uuid = #{uuid}"

          locked_until = seconds_after_time(lease_time)
          Qyu.logger.debug "[LOCK] locked_until = #{locked_until}"

          results = Task.where('id = ? AND (locked_until < now() OR locked_until IS NULL)', id).update(locked_by: uuid, locked_until: locked_until)

          return [nil, nil] if results.empty?

          locked_until = results[0].locked_until
          Qyu.logger.debug "[LOCK] locked_until from DB = #{locked_until}"

          [uuid, locked_until]
        end

        def unlock_task!(id, lease_token)
          results = Task.where(id: id, locked_by: lease_token).update(locked_by: nil, locked_until: nil)
          !results.empty?
        end

        def renew_lock_lease(id, lease_time, lease_token)
          Qyu.logger.debug "renew_lock_lease id = #{id}, lease_time = #{lease_time}, lease_token = #{lease_token}"

          results = with_connection do
            Task.where('id = ? AND locked_until > now() AND locked_by = ?', id, lease_token).update(locked_until: seconds_after_time(lease_time))
          end

          Qyu.logger.debug "renew_lock_lease results = #{results}"

          return nil if results.empty?

          results[0].locked_until
        end

        def update_status(id, status)
          results = Task.where(id: id).update(status: status)

          results.any? && results[0].status == status
        end

        def with_connection
          ::ActiveRecord::Base.connection_pool.with_connection do
            yield
          end
        end

        def transaction
          ::ActiveRecord::Base.transaction do
            yield
          end
        end

        private

        def compare_payloads(payload1, payload2)
          sort(payload1) == sort(payload2)
        end

        def sort(payload)
          payload
        end

        # t['payload'] = JSON.parse(t['payload'])
        def deserialize_task(task)
          return if task.nil?

          task.as_json
        end

        # j['payload'] = JSON.parse(j['payload'])
        # j['descriptor'] = JSON.parse(j['descriptor'])
        def deserialize_job(job, workflow)
          j = job.as_json
          j['workflow'] = deserialize_workflow(workflow)
          j
        end

        def deserialize_workflow(workflow)
          return if workflow.nil?

          wflow = workflow.as_json
          # wflow['descriptor'] = JSON.parse(wflow['descriptor'])
          wflow
        end

        def init_client(config)
          @@db_configuration = {
            adapter:  config[:db_type],
            database: config[:db_name],
            username: config[:db_user],
            host:     config[:db_host],
            port:     config[:db_port],
            pool:     config.fetch(:db_pool) { 5 }
          }

          @@db_configuration[:password] = config[:db_password] if config[:db_password]

          Utils.ensure_db_ready(@@db_configuration)
        end

        def seconds_after_time(seconds, start_time = Time.now.utc)
          start_time + seconds
        end
      end
    end
  end
end

Qyu::Config::StoreConfig.register(Qyu::Store::ActiveRecord::Adapter) if defined?(Qyu::Config::StoreConfig)
Qyu::Factory::StoreFactory.register(Qyu::Store::ActiveRecord::Adapter) if defined?(Qyu::Factory::StoreFactory)
