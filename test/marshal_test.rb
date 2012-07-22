require "helper"

class Book < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name
end

class Author < ActiveRecord::Base
  extend FriendlyId
  friendly_id :name

  has_many :books
end

class MarshalTest < MiniTest::Unit::TestCase
  include FriendlyId::Test

  test "friendly_id enabled class can be marshaled" do
    book = Book.create :name => 'The amazing feats of friendliness'

    data = Marshal.dump book
    loaded = Marshal.load data
  end

  test "friendly_id enabled class can be marshaled when relationship used" do
    author = Author.create :name => 'Philip'
    author.books.create :name => 'my book'

    data = Marshal.dump author
    loaded = Marshal.load data
  end
end