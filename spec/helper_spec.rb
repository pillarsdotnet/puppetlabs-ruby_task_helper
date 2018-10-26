require_relative '../lib/task_helper.rb'

class EmptyTask < TaskHelper; end

class ErrorTask < TaskHelper
  def task(name: nil)
    raise TaskHelper::Error.new('task error message',
                                'task/error-kind',
                                'Additional details')
  end
end

class EchoTask < TaskHelper
  def task(name: nil)
    { 'result': "Hi, my name is #{name}" }
  end
end

describe 'EmptyTask' do
  it 'returns no method when task() is not provided' do
    allow(STDIN).to receive(:read).and_return('{"name": "Lucy"}')
    out = '{"kind":"tasklib/not-implemented",' \
      '"msg":"The task author must implement the `task` method in the task",' \
      '"details":{}}'
    # This needs to be done before the process that exits is run
    expect(STDOUT).to receive(:print).with(out)

    begin
      EmptyTask.run
    rescue SystemExit => e
      expect(e.status).to eq(1)
    else
      raise 'The EmptyTask test did not exit 1 as expected'
    end
  end
end

describe 'ErrorTask' do
  it 'raises an error' do
    allow(STDIN).to receive(:read).and_return('{"name": "Lucy"}')
    out = '{"kind":"task/error-kind",' \
      '"msg":"task error message","details":"Additional details"}'
    # This needs to be done before the process that exits is run
    expect(STDOUT).to receive(:print).with(out)

    begin
      ErrorTask.run
    rescue SystemExit => e
      expect(e.status).to eq(1)
    else
      raise 'The ErrorTask test did not exit 1 as expected'
    end
  end
end

describe 'EchoTask' do
  it 'runs an echo task' do
    allow(STDIN).to receive(:read).and_return('{"name": "Lucy"}')
    expect(EchoTask).to receive(:run).and_return('{"result":
                                                 "Hello, my name is Lucy"}')
    EchoTask.run
  end
end