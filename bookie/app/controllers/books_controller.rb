require 'rubygems'
require 'zip'

class String
    def good
        self.chars.each{|c| return true if c != "\n" and c != " "}
        return false
    end
end

def sect s, d
    d - s.split("/").keep_if{|s| s == "section"}.size
end

class BooksController < ApplicationController
  def index
    @books = Book.all
  end

  def show
    @book = Book.find(params[:id])
  end

  def personal_index
    @books = User.find(current_user).books
  end

  def new
    @book = Book.new
  end

  def edit
    @book = Book.find(params[:id])
  end

  def read_json
    page = Book.find(params[:book_id]).pages[params[:page_number].to_i]
    render json: page
  end

  def read_json_contents
    render json: Book.find(params[:book_id]).contents
  end

  def read
    bookmark = Bookmark.find_by_user_id_and_book_id(params[:user_id], params[:book_id])
    if not bookmark
      bookmark = Bookmark.new(user_id: params[:user_id], book_id: params[:book_id], page: 0, par: 0, pos: 0)
      redirect_to books_path if not bookmark.save
    end
    @user_id = params[:user_id].to_s
    @book_id = params[:book_id].to_s
    @page_number = bookmark.page.to_s
    @par = bookmark.par.to_s
    @pos = bookmark.pos.to_s
    @first_page = (@page_number == 0 and @par == 0 and bookmark.pos == 0)
    @last_page = false
    @depth = Book.find(params[:book_id]).depth.to_s
    @back = "1" if params[:back]
    @reading = true
  end

  def save_bookmark
    bookmark = Bookmark.find_by_user_id_and_book_id(params[:user_id], params[:book_id])
    if not bookmark
      bookmark = Bookmark.new(user_id: params[:user_id], book_id: params[:book_id], page: 0, par: 0, pos: 0)
    end
    bookmark.page = params[:page]
    bookmark.par = params[:par]
    bookmark.pos = params[:pos]
    bookmark.save
#deleting empty paragraphs
    page = Book.find(params[:book_id]).pages[params[:page].to_i]
    pars = page.text.split("\n")
    tags = page.tags.split("\n")
    text = []
    tg = []
    pars.each_with_index do |t, index|
        if t.squish.length > 0
            text << t.squish
            tg << tags[index]
        end
    end
    page.text = text.join("\n")
    page.tags = tg.join("\n")
    page.save
  end

  def save_paragraph
    page = Book.find(params[:book_id]).pages[params[:page].to_i]
    pars = page.text.split("\n")
    index = params[:par].to_i
    first = params[:first].to_i
    last = params[:last].to_i
    beak = pars[index].split(" ").first(first)
    tail = pars[index].split(" ")[last + 1..-1]
    pars[index] = beak.join(" ") + params[:text] + tail.join(" ")
    page.text = pars.join("\n")
    page.save
  end

  def add_to_personal
    user = User.find(params[:user_id])
    book = Book.find(params[:book_id])
    if not user.books.include?(book)
      user.books << book
      user.save
    end
    redirect_to personal_index_path
  end

  def create
    doc = nil
    if params[:upload][:datafile].content_type == "application/zip"
      Zip::File.open(params[:upload][:datafile].tempfile) do |zip_file|
        entry = zip_file.glob('*.fb2').first
        10.times{puts}
        p entry
        10.times{puts}
        doc = Nokogiri::XML(entry.get_input_stream)
      end
    elsif params[:upload][:datafile].content_type == "application/x-fictionbook+xml"
      doc = Nokogiri::XML(params[:upload][:datafile])
    end
    if not doc
        @not_fb2 = true
        render 'new'
        return
    end
    author = doc.css("description author first-name").text + ' ' + doc.css("description author last-name").text
    book_name = doc.css("description book-title").text
    description = doc.css("description annotation").text.squish
    @book = Book.new(title: book_name, author: author, description: description)
    @pars = []
    @depth = 0

    if @book.save
      ParseBook(doc.css("body")[0], [], 0)
      @book.depth = @depth
      render 'new' if not @book.save
      page_number = 0
      contents = []
      (0..@pars.size()).step(50).each do |start_index|
        page_text = @pars[start_index..start_index + 49].compact.map{|text, ar| text.squish}.join("\n")
        page_tags = @pars[start_index..start_index + 49].compact.map{|text, ar| ar.to_s}.join("\n")
        @pars[start_index..start_index + 49].compact.each_with_index{|a, index| contents << [page_number, index, a[0], sect(a[1], @depth)] if a[1].index("title")}
        @book.pages.create(number: page_number, text: page_text, tags: page_tags)
        page_number += 1
      end
      @book.contents = contents.to_json
      render 'new' if not @book.save
      redirect_to @book
    else
      render 'new'
    end
  end

  def update
    @book = Book.find(params[:book_id])

    if @book.update(book_params)
      redirect_to @book
    else
      render 'edit'
    end
  end

  def destroy
    book = Book.find(params[:id])
    book.destroy
    redirect_to books_path
  end

  def destroy_personal
    user = User.find(params[:user_id])
    user.books = user.books.to_a.keep_if{|book| book.id != params[:book_id].to_i}
    user.save
    redirect_to personal_index_path
  end

  private
    def ParseBook(element, path, is_partial)
      if element.children.empty? and element.node_name == "text" and element.text.good
        if is_partial > 1
          @pars[-1][0] += " " + element.text
        else
          @pars << [element.text, [path, element.node_name].flatten.join("/")]
        end
        @depth = [@depth, path.count("section")].max
      else
        has_partial_sibling = 0
        element.children.each do |child|
          has_partial_sibling = 2 if has_partial_sibling > 0
          has_partial_sibling = 1 if has_partial_sibling == 0 and child.next_sibling and child.next_sibling.node_name == "a"
          has_partial_sibling = 3 if has_partial_sibling > 0 and not child.next_sibling
          ParseBook(child, [path, element.node_name].flatten, [is_partial, has_partial_sibling].max)
        end
      end
    end

    def book_params
      params.permit(:title, :author, :description)
    end
end
