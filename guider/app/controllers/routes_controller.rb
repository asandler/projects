class RoutesController < ApplicationController
    def index
        @user = User.find(params[:user_id])
        if current_user
            @me = (@user.id == current_user.id)
        else
            @me = false
        end
        @personal_tab = "routes"
        @routes = @user.routes
    end

    def new
        @cities = City.all
        @personal_tab = "routes"
        @route = Route.new
    end

    def create
        @personal_tab = "routes"
        params["route"]["date_array"] = params["route"]["date_array"].split(", ")
        @route = Route.new(route_params)
        @route.city_tags.keep_if{|s| not s.empty?}
        @user = current_user
        if @route.save
            if not @user.is_guide
                @user.is_guide = true
            end
            if @user.save
                redirect_to routes_path
            else
                redirect_to new_route_path
            end
        else
            redirect_to new_route_path
        end
    end

    def update_route
        @route = Route.find(id = params[:route_id])
        @cities = City.all
        @personal_tab = "routes"
        @dates = @route.date_array
    end

    def update
        @route = Route.find(id = params[:route_id])
        @route.update_attribute(:name, params[:name]) if params[:name]
        @route.update_attribute(:price, params[:price]) if params[:price]
        @route.update_attribute(:hours, params[:hours]) if params[:hours]
        @route.update_attribute(:minutes, params[:minutes]) if params[:minutes]
        @route.update_attribute(:description, params[:description]) if params[:description]
        @route.update_attribute(:city_tags, params[:city_tag]['tags'].keep_if{|s| not s.empty?}) if params[:city_tag]['tags']
        @route.update_attribute(:date_array, params[:date_array].split(", ")) if params[:date_array]
        if params['photo']
            @new_photo = RoutePhoto.new(:route_id => params[:route_id], :photo => params[:photo], :description => params[:photo_description])
            @new_photo.save
        end
        @route.save
        redirect_to routes_path
    end

    def book
        @route = Route.find(params[:route_id])
        @guide = User.find(@route.user_id)
    end

    def destroy
        @route = Route.find(params[:route_id])
        @route.destroy
        redirect_to routes_path
    end

private
    # Never trust parameters from the scary internet, only allow the white list through.
    def route_params
        params.require(:route).permit(
            :id,
            :city_id,
            :price,
            :hours,
            :minutes,
            :description,
            {:city_tags => []},
            :name,
            :user_id,
            {:date_array => []}
        )
    end
end
