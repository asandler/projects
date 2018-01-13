class BookingsController < ApplicationController
    def index
        @personal_tab = "bookings"
        @bookings = Booking.where(user_id: current_user.id)
        @names = ""
    end

    def new
        b = Booking.new(:route_id => params[:route_id], :user_id => current_user.id, :date => "2015/11/29", :guide_id => params[:guide_id])
        if b.save
            if (params[:message] and params[:message] != "")
                Message.new(:booking_id => b.id, :user_id => current_user.id, :message => params[:message]).save
            end
            redirect_to personal_booking_path(current_user.id)
        else
            redirect_to book_route_path(params[:route_id])
        end
    end

    def new_message
        if not params[:refresh]
            Message.new(:booking_id => params[:booking_id], :user_id => current_user.id, :message => params[:message]).save
        end
        @messages = Message.where(booking_id: params[:booking_id])

        b = Booking.find(params[:booking_id])
        @names = b.user_id.to_s + ":"
        @names += User.find(b.user_id).first_name.to_s + ":"
        @names += b.guide_id.to_s + ":"
        @names += User.find(b.guide_id).first_name.to_s

        respond_to do |format|
            format.html {}
            format.js {}
        end
    end

    def destroy
        @b = Booking.find(params[:booking_id])
        @b.destroy
        redirect_to personal_booking_path(:user_id => current_user.id)
    end
end
