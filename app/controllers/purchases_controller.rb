class PurchasesController < ApplicationController
  before_action :authorize_actions

  def index
    purchases = orchestrate_query(policy_scope(Purchase))
    render serialize(purchases)
  end

  def show
    render serialize(purchase)
  end

  def create
    purchase.user = current_user

    if purchase.save
      completed_purchase = StripeConnector.new(purchase).charge

      if completed_purchase.error.any?
        unprocessable_entity!(completed_purchase, purchase.error)
      else
        render serialize(completed_purchase).merge({ status: :created, location: completed_purchase })
      end
    else
      unprocessable_entity!(purchase)
    end
  end

  private

  def purchase
    @purchase ||= params[:id] ? Purchase.find_by!(id: params[:id]) :
                                Purchase.new(purchase_params)
  end
  alias_method :resource, :purchase

  def purchase_params
    params.require(:data).permit(:book_id, :token)
  end
end