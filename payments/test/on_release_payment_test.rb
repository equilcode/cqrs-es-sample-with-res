require_relative 'test_helper'

module Payments
  class OnReleasePaymentTest < ActiveSupport::TestCase
    include TestCase

    cover 'Payments::OnReleasePayment*'

    test 'capture payment' do
      transaction_id = SecureRandom.hex(16)
      order_id = SecureRandom.uuid
      stream = "Payments::Payment$#{transaction_id}"

      arrange(stream, [PaymentAuthorized.new(data: {transaction_id: transaction_id, order_id: order_id})], expected_version: -1)
      published = act(stream, ReleasePayment.new(transaction_id: transaction_id, order_id: order_id))

      assert_changes(published, [PaymentReleased.new(data: {transaction_id: transaction_id, order_id: order_id})])
    end
  end
end
