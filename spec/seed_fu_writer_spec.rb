require File.dirname(__FILE__) + '/spec_helper'

require "seed-fu/writer"
load(File.dirname(__FILE__) + '/schema.rb')

describe SeedFu::Writer do
  before :each do
    @seedfile = 'delete_this_file'
    # Force one to exist for this test
    SeededModel.seed_once(:id) do |s|
      s.id = 1
      s.login = "bob"
      s.first_name = "ignored"
      s.last_name = "ignored"
      s.title = "ignored"
    end
  end
  after :each do
    File.delete @seedfile
  end

  it "should seed many at a time" do
    seed_writer = SeedFu::Writer::SeedMany.new(
          :seed_file  => @seedfile,
          :seed_model => 'SeededModel',
          :seed_by    => [ :name ]
        )
    SeededModel.all.each do |model|
      # This test only included for symmetry with the expected-to-fail test below.
      assert_nothing_raised do
        seed_writer.add_seed( model.attributes )
      end
    end
    seed_writer.finish
  end

  it "should seed one at a time" do
    seed_writer = SeedFu::Writer::Seed.new(
          :seed_file  => @seedfile,
          :seed_model => 'SeededModel',
          :seed_by    => [ :name ]
        )
    SeededModel.all.each do |model|
      # expected to crash here with issue 9:
      #    "NoMethodError: undefined method `chunk_this_seed?' for #<SeedFu::Writer::Seed:0x1052bc888>"
      # see http://github.com/mbleigh/seed-fu/issues/#issue/9
      assert_nothing_raised do
        seed_writer.add_seed( model.attributes )
      end
    end
    seed_writer.finish
  end
end

