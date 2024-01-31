class ApplicationController < ActionController::Base
    def not_found
        render :file => "#{Rails.root}/public/404.html", layout: false, status: :not_found
    end

    def internal_error
        render :file => "#{Rails.root}/public/500.html", layout: false, status: :internal_error
    end
end
