module Payments
  class Payment
    include AggregateRoot

    AlreadyAuthorized = Class.new(StandardError)
    NotAuthorized = Class.new(StandardError)
    AlreadyCaptured = Class.new(StandardError)
    AlreadyReleased = Class.new(StandardError)

    def authorize(transaction_id, order_id)
      raise AlreadyAuthorized if authorized?
      apply(PaymentAuthorized.new(data: {
        transaction_id: transaction_id,
        order_id: order_id
      }))
    end

    def capture
      raise AlreadyCaptured if captured?
      raise NotAuthorized unless authorized?
      apply(PaymentCaptured.new(data: {
        transaction_id: @transaction_id,
        order_id: @order_id
      }))
    end

    def release
      raise AlreadyReleased if released?
      raise AlreadyCaptured if captured?
      raise NotAuthorized unless authorized?
      apply(PaymentReleased.new(data: {
        transaction_id: @transaction_id,
        order_id: @order_id
      }))
    end

    private

    on PaymentAuthorized do |event|
      @state = :authorized
      @transaction_id = event.data.fetch(:transaction_id)
      @order_id = event.data.fetch(:order_id)
    end

    on PaymentCaptured do |event|
      @state = :captured
    end

    on PaymentReleased do |event|
      @state = :released
    end

    def authorized?
      @state.equal?(:authorized)
    end

    def captured?
      @state.equal?(:captured)
    end

    def released?
      @state.equal?(:released)
    end
  end
end

