require 'spec_helper'

describe Webshot::Config do
  let(:config) { Webshot::Config.new }

  describe "#check_for_config" do
    it "should return a config hash" do
      expect(config.check_for_config).to be_kind_of(Hash)
    end

    describe "when there is no Shotfile" do
      it "should return {}" do
        Dir.chdir("spec") do
          expect(config.check_for_config).to eq({})
        end
      end
    end
  end

  describe "#create_config" do
    after(:all) { Dir.chdir("spec") { File.delete "Shotfile" } }

    it "should create a new Shotfile" do
      Dir.chdir("spec") do
        config.create_config
        created = File.exist?("Shotfile")

        expect(created).to be_true
      end
    end

    describe "when a Shotfile exists" do
      it "should return false" do
        expect(config.create_config).to be_false
      end

      describe "and when forced" do
        it "should overwrite the Shotfile" do
          pending "Find best way to check for overwrite"
        end
      end
    end
  end
end
