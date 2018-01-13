class RequestsController < ApplicationController
    def index
        @personal_tab = "requests"
        @requests = Booking.where(guide_id: current_user.id)
    end
end
