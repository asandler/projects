class MainController < ApplicationController
    def find
        @user = User.new
        @cities = City.all
        @main_page = true
    end

    def search
        @user = User.new

        has_arrive_date = (params['arrive'] and params['arrive'] != "")
        has_depart_date = (params['depart'] and params['depart'] != "")
        dates = []

        if has_arrive_date || has_depart_date
            if has_arrive_date
                arv = params['arrive'].split('/')
                arrive = Date.new(arv[2].to_i, arv[0].to_i, arv[1].to_i)
            else
                arrive = Date.today
            end

            if has_depart_date
                dpt = params['depart'].split('/')
                depart = Date.new(dpt[2].to_i, dpt[0].to_i, dpt[1].to_i)
            else
                depart = Date.today.advance(:months => 1)
            end

            arrive.upto(depart).each do |date|
                a = date.iso8601.split('-')
                dates << [a[1], a[2], a[0]].join('/')
            end
        end

        price_from, price_to = 0, 100000000

        has_price_from = params[:price_from] && params[:price_from] != ""
        has_price_to = params[:price_to] && params[:price_to] != ""
        has_price = params['price'] && params['price'] != ""

        price_from = params[:price_from] if has_price_from
        price_to = params[:price_to] if has_price_to
        price_from, price_to = params[:price].split(';')[0], params[:price].split(';')[1] if params['price']

        do_filter_price = has_price_from || has_price_to || has_price

        city_tags = []
        city_tags = params['city_tag']['tags'].keep_if{|t| t != ""} if params['city_tag']
        lang_tags = []
        lang_tags = params['lang_tag']['tags'].keep_if{|t| t != ""} if params['lang_tag']

        @search_results = Route.where(:city_id => (params[:city_id] || params[:city_id_2]))

        @min_price = @search_results.map{|res| res.price}.min
        @max_price = @search_results.map{|res| res.price}.max
        if @max_price and @min_price and @max_price == @min_price
            @min_price -= 2000
            @max_price += 2000
        end

        @search_results = @search_results.where('price >= ? AND price <= ?', price_from, price_to) if do_filter_price

        @search_results = @search_results.where.overlap(city_tags: city_tags) if city_tags.any?

        user_ids = User.where.overlap(lang_array: lang_tags).map(&:id) if lang_tags.any?
        @search_results = @search_results.where(user_id: user_ids) if lang_tags.any?

        @search_results = @search_results.where.overlap(date_array: dates) if dates.any?

        if params[:json]
            s = "["
            @search_results.each do |route|
                cur = route.to_json(:except => [:created_at, :updated_at])
                cur = cur[0..-2] + ",\"images_number\":#{RoutePhoto.where(:route_id => route.id).size}},"
                s += cur
            end
            render json: s[0..-2] + "]"
            return
        end

        respond_to do |format|
            format.html {}
            format.js {}
        end
    end

    def route_promo
        @user = User.new
    end
end
