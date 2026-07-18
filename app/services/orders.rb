module Orders
  class Error < StandardError; end
  class AlreadyProcessedError < Error; end
  class NotEnoughBalance < Error; end
end
