require 'spec_helper'

describe Lexster::Config do
  context "config" do
    it "should store and read config" do
      Lexster.configure do |config|
        config.enable_subrefs = false
      end

      Lexster.config.enable_subrefs.should == false
    end
  end
end
