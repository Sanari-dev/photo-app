class WelcomeController < ApplicationController
  skip_before_action :authenticate_user!, only: [:index]
  def index
    # result = Midtrans.create_snap_token(
    #   transaction_details: {
    #     order_id: "test-transaction-order-111",
    #     gross_amount: 10,
    #     secure: true
    #   }
    # )
    # @token = result.token
  end
end
