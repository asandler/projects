class UsersController < ApplicationController
    def new
    end

    def create
        @user = User.new(user_params)

        if @user.save
            auto_login(@user)
            cookies[:auth_token] = @user.auth_token
            redirect_to profile_path(@user.id)
        else
            redirect_to root_path
        end
    end

    def profile
        @user = User.find(params[:user_id])
        if current_user
            @me = (@user.id == current_user.id)
        else
            @me = false
        end
        @personal_tab = "profile"
    end

    def edit
        @user = current_user
        @personal_tab = "profile"
    end

    def update_profile
        @user = User.find(current_user.id)
        @user.update_attribute(:first_name, params[:first_name]) if params[:first_name]
        @user.update_attribute(:last_name, params[:last_name]) if params[:last_name]
        @user.update_attribute(:email, params[:email]) if params[:email]
        @user.update_attribute(:password, params[:password]) if params[:password]
        @user.update_attribute(:lang_array, params[:lang_tag]['tags'].keep_if{|s| not s.empty?}) if params[:lang_tag]['tags']
        @user.update_attribute(:about, params[:about]) if params[:about]
        @user.update_attribute(:avatar, params[:avatar]) if params[:avatar]
        @user.save
        redirect_to profile_path
    end


    def reply
        @user = User.find(params[:user_id])
        if current_user
            @me = (@user.id == current_user.id)
        else
            @me = false
        end
        @personal_tab = "replies"
    end

    def add_reply
    end

private
    # Never trust parameters from the scary internet, only allow the white list through.
    def user_params
        params.require(:user).permit(
            :id,
            :username,
            :email,
            :password,
            :password_confirmation,
            {:lang_tags => []},
            :about,
            :avatar
        )
    end
end
