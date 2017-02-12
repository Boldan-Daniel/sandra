class StripeConnector
  def initialize(purchase)
    @purchase = purchase
    Stripe.api_key ||= ENV['STRIPE_API_KEY']
  end

  def charge
    @purchase.sent!
    create_charge
    @purchase
  end

  private

  def create_charge
    begin
      charge = Stripe::Charge.create(stripe_hash, { idempotency_key: @purchase.idempotency_key })
      @purchase.confirm!(charge.id)
      charge
    rescue Stripe::CardError => e
      body = e.json_body
      @purchase.error!(body[:error])
      body
    end
  end

  def stripe_hash
    {
        amount: @purchase.price.fractional,
        currency: @purchase.price.currency.to_s,
        source: @purchase.token,
        metadata: { purchase_id: @purchase.id },
        description: description
    }
  end

  def description
    "Charge for #{@purchase.book.title} (Purchase ID #{@purchase.id})"
  end
end