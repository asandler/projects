class FoldersController < ApplicationController
    before_action :require_login

    def get
        get_folder_contents(params[:id])
    end

    def edit
        @folder = get_or_not_found(params[:id])
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
            update_folder(Folder.find(params[:id]), params[:name])
        else
            update_folder(new_folder(params), params[:name])
        end
    end

    def destroy
        Folder.destroy(params[:id])
        redirect_to home_path_url
    end

private
    def get_folder_contents id
        @folder = get_or_not_found(id)
        @child_folders = Folder.where(parent_folder_id: id)
        @docs = Document.where(folder_id: id)

        if @folder.parent_folder_id
            @parent_folder = Folder.find(@folder.parent_folder_id)
        end
    end

    def get_or_not_found id
        begin
            return Folder.find(id)
        rescue
            not_found
        end
    end

    def new_folder params
        return Folder.new(
            parent_folder_id: params[:parent_folder_id].to_i,
            #user_id: current_user.id,
        )
    end

    def update_folder folder, name
        folder.name = name
        if folder.save
            redirect_to "/folders/#{folder.id}"
        else
            internal_error
        end
    end
end
