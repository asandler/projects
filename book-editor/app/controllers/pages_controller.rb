class PagesController < ApplicationController

  def show
    @book = Book.find(params[:book_id])
    @page = @book.pages[params[:page_number].to_i]
    redirect_to books_path if not @page
    @last_page = (params[:page_number].to_i == @book.pages.size - 1)
    @first_page = (params[:page_number].to_i == 0)
  end

  def edit_get
    @book = Book.find(params[:book_id])
    @page = @book.pages[params[:page_number].to_i]
    redirect_to books_path if not @page
  end

  def edit_post
    @book = Book.find(params[:book_id])
    @page = @book.pages[params[:page_number].to_i]
    @page.text = params[:text]
    @page.save
    redirect_to read_book_path(@book.id)
  end
end
