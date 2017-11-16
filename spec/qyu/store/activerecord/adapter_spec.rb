RSpec.describe Qyu::Store::ActiveRecord::Adapter do
  let(:db_config) do
    config = Qyu::Store::ActiveRecord::Adapter.db_configuration.dup
    {
      db_type: config[:adapter],
      db_host: config[:host],
      db_port: config[:port],
      db_name: config[:database],
      db_user: config[:username],
      db_password: config[:password]
    }
  end

  let(:adapter) { described_class.new(db_config) }

  context '# class methods' do
    describe '#valid_config?' do
      context 'input config is valid' do
        it do
          expect(described_class.valid_config?(db_config)).to be true
        end
      end

      context 'input config is invalid' do
        it do
          db_config.delete(:db_host)
          expect(described_class.valid_config?(db_config)).not_to be true
        end
      end
    end
  end

  context '# instance methods' do
    describe '#persist_workflow' do
      it { expect { adapter.persist_workflow('name', 'descriptor') }.to change { Qyu::Store::ActiveRecord::Workflow.count } }
    end

    describe '#persist_job' do
      let(:workflow) { create(:workflow) }

      it { expect { adapter.persist_job(workflow, 'payload') }.to change { Qyu::Store::ActiveRecord::Job.count } }
    end

    describe '#find_workflow' do
      let(:workflow) { create(:workflow) }

      it { expect(adapter.find_workflow(workflow.id)['name']).to eq workflow.name }
      it { expect(adapter.find_workflow(workflow.id)['descriptor']).to eq workflow.descriptor }
    end

    describe '#find_workflow_by_name' do
      let(:workflow) { create(:workflow) }

      it { expect(adapter.find_workflow_by_name(workflow.name)['id']).to eq workflow.id }
      it { expect(adapter.find_workflow_by_name(workflow.name)['descriptor']).to eq workflow.descriptor }
    end

    describe '#find_task' do
      let(:task) { create(:task) }

      it { expect(adapter.find_task(task.id)['name']).to eq task.name }
      it { expect(adapter.find_task(task.id)['payload']).to eq task.payload }
    end

    describe '#find_or_persist_task' do
      let!(:task) { create(:task) }
it { expect(adapter.find_or_persist_task(task.name, task.queue_name, task.payload, task.job.id, task.parent_task_id){ 1 + 1 }).to eq task.id }
      it { expect { adapter.find_or_persist_task(task.name, task.queue_name, task.payload, task.job.id, task.parent_task_id) { 1 + 1 } }.to_not change { Qyu::Store::ActiveRecord::Task.count } }
      it { expect { adapter.find_or_persist_task(task.name + '_updated', task.queue_name, task.payload, task.job.id, task.parent_task_id) { 1 + 1 } }.to change { Qyu::Store::ActiveRecord::Task.count } }
    end

    describe '#find_task_ids_by_job_id_and_name' do
      let(:task) { create(:task) }

      it { expect(adapter.find_task_ids_by_job_id_and_name(task.job.id, task.name).count).to eq 1 }
    end

    describe '#find_task_ids_by_job_id_name_and_parent_task_ids' do
      let(:parent_task) { create(:task) }
      let(:task) { create(:task, parent_task_id: parent_task.id) }

      it { expect(adapter.find_task_ids_by_job_id_name_and_parent_task_ids(task.job.id, task.name, parent_task.id).count).to eq 1 }
    end

    describe '#find_job' do
      let(:job) { create(:job) }

      it { expect(adapter.find_job(job.id)['payload']).to eq job.payload }
    end

    describe '#select_jobs' do
      let!(:job) { create(:job) }
      let!(:job2) { create(:job) }

      it { expect(adapter.select_jobs(1, 0).count).to eq 1 }
      it { expect(adapter.select_jobs(1, 1).first['id']).to eq job2.id }
      it { expect(adapter.select_jobs(1, 1, :desc).first['id']).to eq job.id }
    end

    describe '#select_tasks_by_job_id' do
      let(:task) { create(:task) }

      it { expect(adapter.select_tasks_by_job_id(task.job.id).count).to eq 1 }
    end

    describe '#count_jobs' do
      let!(:job) { create(:job) }

      it { expect(adapter.count_jobs).to eq 1 }
    end

    describe '#update_status' do
      let(:task) { create(:task) }

      it { expect(task.status).to eq('queued') }
      it { expect { adapter.update_status(task.id, 'completed') }.to change { task.reload.status }.from('queued').to('completed') }
      it { expect(adapter.update_status(task.id, 'completed')).to eq true }
    end

    describe '#lock_task' do
      let(:task) { create(:task) }

      it { expect(adapter.lock_task!(task.id, 60).count).to eq 2 }
      it { expect(adapter.lock_task!(task.id, 60).first).to_not be_blank }
      it { expect(adapter.lock_task!(task.id, 60).last.to_i).to be == (Time.now + 60.seconds).to_i }
      it { expect { adapter.lock_task!(task.id, 60) }.to change { task.reload.locked_by } }
      it { expect { adapter.lock_task!(task.id, 60) }.to change { task.reload.locked_until } }
    end

    describe '#lock_task' do
      let(:lease_token) { 'lease_token' }
      let(:task) { create(:task, locked_by: lease_token, locked_until: Time.now + 1.hour ) }

      it { expect(adapter.unlock_task!(task.id, lease_token)).to eq true }
      it { expect { adapter.unlock_task!(task.id, lease_token) }.to change { task.reload.locked_by } }
      it { expect { adapter.unlock_task!(task.id, lease_token) }.to change { task.reload.locked_until } }
    end

    describe '#renew_lock_lease' do
      let(:lease_token) { 'lease_token' }
      let(:lease_time) { 60 }
      let(:task) { create(:task, locked_by: lease_token, locked_until: Time.now + 1.hour ) }

      it { expect(adapter.renew_lock_lease(task.id, lease_time, lease_token).to_i).to eq (Time.now + lease_time).to_i }
      it { expect { adapter.renew_lock_lease(task.id, lease_time, lease_token) }.to_not change { task.reload.locked_by } }
      it { expect { adapter.renew_lock_lease(task.id, lease_time, lease_token) }.to change { task.reload.locked_until } }
    end
  end
end
