# Run "ruby -I . -I lib/ benchmark_test.rb"
require "benchmark/ips"
require "sqlite3"
require "active_record"
require "rspec/its"
require_relative "lib/active_model_serializers_cancancan"


ActiveRecord::Base.establish_connection(
  adapter: 'sqlite3',
  database: ':memory:'
)
ActiveRecord::Base.logger = Logger.new(STDOUT)
ActiveRecord::Base.logger.level = Logger::DEBUG

ActiveRecord::Schema.define do
  create_table :users, force: true do |t|
    t.string :name
  end

  create_table :projects, force: true do |t|
    t.string :name
    t.belongs_to :user, index: true
    t.belongs_to :category, index: true
  end

  create_table :categories, force: true do |t|
    t.string :name
    t.belongs_to :user, index: true
    t.belongs_to :project, index: true
  end
end

class User < ActiveRecord::Base
  has_many :projects
  has_many :categories
end

class Project < ActiveRecord::Base
  belongs_to :user, required: false
  belongs_to :category, required: false
  has_many :categories
end

class Category < ActiveRecord::Base
  belongs_to :user, required: false
  belongs_to :project, required: false
  has_many :projects
end

CategorySerializer = Class.new(ActiveModel::Serializer) do
  attributes :id
  has_many :projects
  has_one :project
end

ProjectSerializer = Class.new(ActiveModel::Serializer) do
  attributes :id
end

UserSerializer = Class.new(ActiveModel::Serializer) do
  attributes :name
  has_many :categories
end

Ability = Class.new do
  include CanCan::Ability
  def initialize(user)
    can :read, :category
    can :read, :project
  end
end

user1 = User.create!(name: "Alice")
user2 = User.create!(name: "Bob")

category = Category.create!(name: "Cat A", project: Project.create!(user: user2))

project1 = Project.create!(name: "Project X", user: user1, category: category)
Project.create!(name: "Project Y", user: user2, category: category)

n = 5000
Benchmark.ips do |x|
  x.report("CategorySerializer") { n.times do; CategorySerializer.new(category, scope: user1).serializable_hash; end }
  x.report("ProjectSerializer") { n.times do; ProjectSerializer.new(project1, scope: user1).serializable_hash; end }
  x.report("UserSerializer") { n.times do; UserSerializer.new(user1, scope: user1).serializable_hash; end }
end
