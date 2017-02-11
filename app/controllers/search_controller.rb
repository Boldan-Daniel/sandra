class SearchController < ApplicationController
  skip_before_action :authenticate_user

  def index
    @text = params[:text]
    scope = PgSearch.multisearch(@text).includes(:searchable)
    documents = orchestrate_query(scope)
    render serialize(documents).merge(status: :ok)
  end
end