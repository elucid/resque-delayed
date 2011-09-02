require 'spec_helper'

describe Resque::Delayed do
  describe 'simple create' do
    before :each do
      Resque::Delayed.clear
    end

    it "should start with zero delayed jobs queued" do
      Resque::Delayed.count.should be_zero
    end

    it "should allow queueing at a specified time" do
      Resque::Delayed.create_at(Time.now + 1.day, SomeJob, 'foo', 'bar', 1234)
      Resque::Delayed.count.should == 1
    end

    it "should allow queuing after a specified delay" do
      Resque::Delayed.create_in(1.day, SomeJob, 'foo', 'bar', 1234)
      Resque::Delayed.count.should == 1
    end
  end

  describe 'availability' do
    before :each do
      Resque::Delayed.clear
      @one_day_from_now = Time.now + 1.day
      Resque::Delayed.create_at(@one_day_from_now, SomeJob, 'foo', 'bar', 1234)
    end

    it "should not make items available before create time" do
      Resque::Delayed.next.should be_nil
      Resque::Delayed.next_at(Time.now).should be_nil
    end

    it "should make items available at create time" do
      Resque::Delayed.next_at(@one_day_from_now).should_not be_nil
    end

    it "should make items available after create time" do
      Resque::Delayed.next_at(@one_day_from_now + 1.minute).should_not be_nil
    end
  end

  describe 'dequeueing' do
    before :each do
      Resque::Delayed.clear
      @one_hour_ago = Time.now - 1.hour
      Resque::Delayed.create_at(@one_hour_ago, SomeJob, 'foo', 'bar', 1234)
    end

    it "should deserialize properly" do
      job = Resque::Delayed.next
      job.should == ["SomeJob", "foo", "bar", 1234]
      Resque::Delayed.count.should be_zero
    end
  end
end
