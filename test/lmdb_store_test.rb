# frozen_string_literal: true

require 'minitest/autorun'
require 'lmdb_store'
require 'fileutils'

class TestLmdbStore < Minitest::Test
  def setup
    FileUtils.rm_rf(db_path)
    FileUtils.mkdir_p(db_path)
  end

  def test_create
    LmdbStore.new(db_path)
  end

  def test_write
    c = LmdbStore.new(db_path)
    c.write('foo', 'bar')
  end

  def test_read
    c = LmdbStore.new(db_path)
    c.write('foo', 'bar')
    assert_equal 'bar', c.read('foo')
  end

  def test_delete
    c = LmdbStore.new(db_path)
    c.write('foo', 'bar')
    assert c.delete('foo')
  end

  def test_delete_non_existant
    c = LmdbStore.new(db_path)
    refute c.delete('foo')
  end

  def test_write_max_space
    c = LmdbStore.new(db_path, size: 64.kilobytes)
    assert_raises(LMDB::Error::MAP_FULL) do
      10000.times do |i|
        c.write("foo#{i}", i)
      end
    end
  end

  private

  def db_path
    @db_path ||= File.join(File.dirname(__FILE__), '..', 'tmp', 'test')
  end
end
