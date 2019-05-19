# frozen_string_literal: true

require "bundler/inline"

gemfile(true) do
  source 'https://rubygems.org'

  git_source(:github) { |repo| "https://github.com/#{repo}.git" }

  gem 'activerecord', '5.2.3'
  gem 'sqlite3', '1.4.1'
  gem 'rspec', '3.8.0'
  gem 'pry'
end

require 'active_record'
require 'pry'

ActiveRecord::Base.establish_connection(adapter: 'sqlite3', database: ':memory:')
ActiveRecord::Migration.create_table(:users)
ActiveRecord::Migration.create_table(:roles) do |t|
  t.integer :user_id
end

class Role < ActiveRecord::Base
  belongs_to :user
end

class User < ActiveRecord::Base
  has_many :roles
end

# user = User.new
# binding.pry
# roles = user.roles.build
# binding.pry
# duplicated = user.roles.dup
# binding.pry

RSpec.describe 'change matcher' do
  let(:user) { User.new }
  let(:action) { ->{ user.roles.build } }

  let(:assert_before) { ->{ be_empty } }
  let(:assert_after) { ->{ contain_exactly(an_instance_of(Role)) } }

  it 'demonstrates change works properly' do
    sum = 0
    expect{ sum += 1 }.to change { sum }.from(0).to(1)
  end

  it 'works when tested without change syntax' do
    expect(user.roles).to(assert_before.call)
    action.call
    expect(user.roles).to(assert_after.call)
  end

  it 'works when tested with change syntax' do
    expect{ action.call }
      .to change{ user.roles }
      .from(assert_before.call)
      .to(assert_after.call)
  end
end

RSpec::Core::Runner.invoke

