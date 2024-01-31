class DocsController < ApplicationController
    def get
        @doc = get_doc(params[:id])
    end

    def all
        @docs = Document.all.select("id", "name")
    end

    def edit
        @doc = get_doc(params[:id])
    end

    def save
        # validate params later
        d = get_doc(params[:id])
        if d
            d.name = params[:doc_name]
            d.data = params[:doc_data]

            if d.save
                redirect_to "/docs/#{params[:id]}"
                return
            else
                internal_error
                return
            end
        end

        redirect_to "/"
    end

    def new
        d = Document.new
        if d.save
            redirect_to "/docs/#{d.id}/edit"
        else
            internal_error
        end
    end

    def get_doc id
        begin
            return Document.find(params[:id])
        rescue
            not_found
        end
    end
end
