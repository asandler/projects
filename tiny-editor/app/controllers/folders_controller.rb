class FoldersController < ApplicationController
    before_action :require_login

    def get
        get_folder_contents(params[:id])
    end

    def home
        redirect_to controller: "folders", action: "get", id: current_user.root_directory_id
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
end
