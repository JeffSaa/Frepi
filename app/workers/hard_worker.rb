class HardWorker
  include Sidekiq::Worker
  def perform
    p  'hi' * 50
  end
end