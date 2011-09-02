require 'spec_helper'

describe Resque do
  describe 'simple create' do
    before :each do
      Resque::Delayed.clear
    end

    it "should start with zero delayed jobs queued" do
      Resque::Delayed.count.should be_zero
    end

    it "should allow queueing at a specified time" do
      Resque.enqueue_at(Time.now + 1.day, SomeJob, 'foo', 'bar', 1234)
      Resque::Delayed.count.should == 1
    end

    it "should allow queuing after a specified delay" do
      Resque.enqueue_in(1.day, SomeJob, 'foo', 'bar', 1234)
      Resque::Delayed.count.should == 1
    end
  end
end
