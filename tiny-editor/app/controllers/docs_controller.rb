class DocsController < ApplicationController
    def get
        @doc = get_or_not_found(params[:id])
    end

    def all
        @docs = Document.all.select("id", "name")
    end

    def edit
        @doc = get_or_not_found(params[:id])
    end

    def new
    end

    def save
        # validate params later
        if params[:id]
            update_doc(Document.find(params[:id]), params[:doc_name], params[:doc_data])
        else
            update_doc(Document.new, params[:doc_name], params[:doc_data])
        end
    end

    def delete
        Document.delete(params[:id])
        redirect_to "/"
    end

private
    def get_or_not_found id
        begin
            return Document.find(params[:id])
        rescue
            not_found
        end
    end

    def update_doc doc, name, data
        doc.name = params[:doc_name]
        doc.data = params[:doc_data]
        if doc.save
            redirect_to "/docs/#{doc.id}"
        else
            internal_error
        end
    end
end
