# frozen_string_literal: true

require 'lmdb'
require 'active_support/cache'

class LmdbStore < ActiveSupport::Cache::Store
  def initialize(path, options = nil)
    options ||= {}
    super(options)
    @path = path
    @max_size = options[:size] || 32.megabytes
    @name = options[:name] || 'cache'
    @env = LMDB.new(path, mapsize: @max_size, nosync: true, writemap: true)
    @db = @env.database(@name, create: true)
  end

  private

  def read_entry(key, **options)
    if data = @db.get(key)
      Marshal.load(data)
    else
      nil
    end
  end

  def write_entry(key, entry, **options)
    @db.put(key, Marshal.dump(entry).to_s)
  end

  def delete_entry(key, **options)
    @db.delete(key)
    true
  rescue LMDB::Error
    false
  end

  def clear
    @db.clear
  end
end

