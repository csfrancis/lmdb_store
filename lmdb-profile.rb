#!/usr/bin/env ruby
# frozen_string_literal:true

require 'lmdb'
require 'pry'

# Customize these things
DURATION = 5
NUM_WORKERS = 16
UPDATE_SLEEP = 0.001


class Worker
  class Result
    attr_accessor :count, :duration
    attr_reader :worker_num

    def initialize(worker_num)
      @count = 0
      @worker_num = worker_num
    end

    def increment_count
      @count = @count + 1
    end

    def to_s
      "worker: #{worker_num}\tduration: #{format("%.4f", duration)}\tread_count: #{count}"
    end
  end

  @worker_count = 0
  class <<self
    attr_accessor :worker_count
  end

  def initialize(db_name, duration)
    @db_name = db_name
    @duration = duration
    @rd, @wr = IO.pipe
    @worker_num = self.class.worker_count
    self.class.worker_count += 1
  end

  def start
    fork do
      @rd.close
      env = LMDB.new(@db_name)
      @db = env.database
      @wr.write Marshal.dump(work)
      @wr.close
    end
    @wr.close
  end

  def result
    result = Marshal.load(@rd.read)
    @rd.close
    result
  end

  private

  def work
    result = Result.new(@worker_num)
    start = Time.now.to_f
    while Time.now.to_f < (start + @duration) do
      @db["working_bin"]
      result.increment_count
    end

    result.duration = Time.now.to_f - start
    result
  end
end


env = LMDB.new('db')
m = env.database

workers = []
NUM_WORKERS.times { workers << Worker.new('db', DURATION) }

workers.each(&:start)

count = 1
start = Time.now.to_f
stop =  start + DURATION
while Time.now.to_f < stop do
  m["working_bin"] = count.to_s
  count += 1
  sleep UPDATE_SLEEP
end