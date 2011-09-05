require 'spec_helper'

describe Resque::Delayed::Worker do
  describe "harvest timing" do
    before :each do
      Resque::Delayed.clear
      @worker = Resque::Delayed::Worker.new
    end

    after :each do
      @worker.shutdown!
    end

    it "should not harvest future jobs" do
      Resque.enqueue_in(1.hour, SomeJob, 'future')
      @worker.work(0)
      Resque::Delayed.count.should == 1
    end

    it "should harvest past jobs" do
      Resque.enqueue_at(Time.now - 1.hour, SomeJob, 'past')
      @worker.work(0)
      Resque::Delayed.count.should == 0
    end
  end

  describe "Resque interface" do
    before do
      Resque::Delayed.clear
      @worker = Resque::Delayed::Worker.new
      Resque.enqueue_at(Time.now - 1.hour, SomeJob, 'past')
      Resque.enqueue_at(Time.now - 1.hour, SomeOtherJob, 'past')
    end

    after do
      @worker.shutdown!
    end

    it "should queue delayed jobs in appropriate Resque queues after harvest" do
      Resque::Job.should_receive(:create).with('jobs', 'SomeJob', 'past')
      Resque::Job.should_receive(:create).with('other_jobs', 'SomeOtherJob', 'past')
      @worker.work(0)
    end
  end
end
