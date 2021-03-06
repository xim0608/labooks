class RentalsController < ApplicationController
  def show_by_student_id
    @user = User.find_by_student_id(params[:student_id])
    @rental_books = @user.rentals.now
    # @rentals_now = @rental_books.unread
    @rental_histories = @user.rentals.history
    render :layout => false
  end

  def change_unread_flag
    user = User.find_by_student_id(params[:student_id])
    rental_histories = user.rental_histories.unread
    rentals_now = user.rentals.unread
    rental_histories.update_all(unread: false)
    rentals_now.update_all(unread: false)
  end

  def show
    @user = User.find(params[:user_id])
    @rentals = @user.rentals.now
    @rental_histories = @user.rentals.history
  end
end

