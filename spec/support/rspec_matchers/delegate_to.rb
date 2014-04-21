# RSpec matcher to spec delegations.
#
# Usage:
#
#     describe Post do
#       it { should delegate(:name).to(:author).with_prefix } # post.author_name
#       it { should delegate(:month).to(:created_at) }
#       it { should delegate(:year).to(:created_at) }
#     end
# Stolen from AVETARS matchers, updated to new stub syntax
RSpec::Matchers.define :delegate do |method|
  match do |delegator|
    @method = @prefix ? :"#{@to}_#{method}" : method
    @delegator = delegator
    @receiver  = double('receiver')
    begin
      @delegator.send(@to)
    rescue NoMethodError
      raise "#{@delegator} does not respond to #{@to}!"
    end
    if @allow_nil
      allow(@delegator).to receive(@to) { nil }
      @delegator.send(@method).nil?
    else
      allow(@delegator).to receive(@to) { @receiver }
      allow(@receiver).to receive(method) { :called }
      @delegator.send(@method) == :called
    end
  end

  description do
    "delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message do |text|
    "expected #{@delegator} to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  failure_message_when_negated do |text|
    "expected #{@delegator} not to delegate :#{@method} to its #{@to}#{@prefix ? ' with prefix' : ''}"
  end

  chain(:to) { |receiver| @to = receiver }
  chain(:with_prefix) { @prefix    = true }
  chain(:allow_nil)   { @allow_nil = true }
end
