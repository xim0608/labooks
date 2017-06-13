class FavoritesController < ApplicationController

  def create
    @user_id = current_user.id
    @book_id = Book.find(params[:id]).id
    @favorite = Favorite.new(book_id: @book_id, user_id: @user_id)
    @favorite.save
  end

  def destroy
    @favorite = Favorite.find(params[:id])
    @favorite.destroy
  end

  def index
    @user = current_user
    # @favorites = Favorite.where(user_id: @user.id).all
    @books = Book.includes(:favorites).where(favorites: {user_id: @user.id})
  end

  def show_clips
    @book = Book.find(params[:id])
    @users = User.includes(:favorites).where(favorites: {book_id: @book.id})
  end
end