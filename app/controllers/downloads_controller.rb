class DownloadsController < ApplicationController
  def show
    authorize(book)
    render status: 204, location: book.download_url
  end

  private

  def book
    @book ||= Book.find_by!(id: params[:book_id])
  end
end