class ApiController < ApplicationController
    def cities
        @cities = City.all
        s = "["
        @cities.each do |city|
            s += "{\"id\": #{city.id}, \"name\": \"#{city.name}\", \"routes_number\": #{Route.where(city_id: city.id).length}}, ";
        end
        s = s[0..-3] + ']'
        render json: s
    end

    def user_info
        render json: User.find(params[:id]).to_json(:only => [:id, :first_name, :last_name, :is_guide, :lang_array, :about])
    end

    def user_routes
        s = "["
        User.find(params[:id]).routes.each do |r|
            s += r.to_json(:except => [:created_at, :updated_at])[0..-2] + ",\"images_number\":#{RoutePhoto.where(:route_id => r.id).size}},"
        end
        render json: s[0..-2] + "]"
    end

    def user_avatar
        send_file User.find(params[:id]).avatar.path, disposition: 'inline'
    end

    def route_info
        r = Route.find(params[:id])
        s = r.to_json(:except => [:created_at, :updated_at])
        render json: s[0..-2] + ",\"images_number\":#{RoutePhoto.where(:route_id => params[:id]).size}}" 
    end

    def route_image
        ph = RoutePhoto.where(:route_id => params[:route_id])[params[:index].to_i]
        if ph
            send_file ph.photo.path, disposition: 'inline'
        else
            send_file Rails.root.to_s + "/app/assets/images/no-image-300-400.png", disposition: 'inline'
        end
    end
end
