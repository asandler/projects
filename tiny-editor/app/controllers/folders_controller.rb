class FoldersController < ApplicationController
    before_action :require_login

    def get
        get_folder_contents(params[:id])
    end

    def edit
        @folder = get_by_id_user_id(params[:id])
        @all_folders = Folder.where(user_id: current_user.id)
    end

    def home
        redirect_to controller: "folders", action: "get", id: current_user.root_directory_id
    end

    def new
        @parent_folder_id = params[:parent_folder_id]
    end

    def save
        # validate params later
        if params[:id]
            update_folder(get_by_id_user_id(params[:id]), params)
        else
            update_folder(new_folder(params), params)
        end
    end

    def destroy
        Folder.destroy(params[:id])
        redirect_to home_path_url
    end

private
    def get_folder_contents id
        @folder = Folder.find(id) or not_found
        @child_folders = Folder.where(parent_folder_id: id)
        @docs = Document.where(folder_id: id)

        if @folder.parent_folder_id
            @parent_folder = Folder.find(@folder.parent_folder_id)
        end
    end

    def get_by_id_user_id id
        Folder.find_by(id: id, user_id: current_user.id) or not_found
    end

    def new_folder params
        return Folder.new(
            parent_folder_id: params[:parent_folder_id].to_i,
            user_id: current_user.id,
        )
    end

    def update_folder folder, params
        folder.name = params[:name]
        folder.parent_folder_id = params[:parent_folder_id]
        if folder.save
            redirect_to "/folders/#{folder.id}"
        else
            internal_error
        end
    end
end
