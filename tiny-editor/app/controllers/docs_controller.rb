class DocsController < ApplicationController
    before_action :require_login
    skip_before_action :require_login, only: [:get], :raise => false

    def get
        @doc = Document.find(params[:id]) or not_found
    end

    def edit
        @doc = get_by_id_user_id(params[:id])
    end

    def new
        @folder_id = params[:folder_id]
    end

    def save
        # validate params later
        if params[:id]
            update_doc(get_by_id_user_id(params[:id]), params[:doc_name], params[:doc_data])
        else
            update_doc(new_doc(params), params[:doc_name], params[:doc_data])
        end
    end

    def destroy
        Document.destroy(params[:id])
        redirect_to home_path_url
    end

private
    def get_by_id_user_id id
        Document.find_by(id: id, user_id: current_user.id) or not_found
    end

    def new_doc params
        return Document.new(
            folder_id: params[:folder_id].to_i,
            user_id: current_user.id,
        )
    end

    def update_doc doc, name, data
        doc.name = name
        doc.data = data
        if doc.save
            redirect_to "/docs/#{doc.id}"
        else
            internal_error
        end
    end
end
