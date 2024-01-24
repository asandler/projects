class DocsController < ApplicationController
    def get
        @doc = Document.find(params[:id]) or not_found
    end

    def edit
        @doc = Document.find(params[:id]) or not_found
    end

    def save
        # validate params
        d = Document.find(params[:id])
        if d
            d.name = params[:doc_name]
            d.data = params[:doc_data]
            d.save
            redirect_to "/docs/#{params[:id]}"
            return
        end

        redirect_to "/"
    end
end
