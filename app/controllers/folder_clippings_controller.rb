class FolderClippingsController < ApplicationController
  skip_before_action :authenticate_user!, :only => :delete

  def create
    slug         = params[:folder_clippings][:folder_slug]
    clipping_ids = params[:folder_clippings][:clipping_ids]
    folder       = current_user.folders.find_by_slug(slug)

    if clipping_ids.is_a?(String)
      clipping_ids = clipping_ids.gsub(/\s/, '').split(',')
    end

    # my-clippings is a "nil" folder
    if (folder.present? || slug == "my-clippings") && clipping_ids.present?

      clipping_count = 0
      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?

        clipping_count = clipping_count + 1

        clipping.folder_id = folder.present? ? folder.id : nil
        clipping.save
      end

      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings",
                                   :slug => slug,
                                   :doc_count => clipping_count,
                                   :documents => clipping_ids } }
    elsif ! clipping_ids.present?
      render plain: "No clipping ids present", status: 400
    else
      render plain: "Unable to find folder with slug '#{slug}'", status: 404
    end
  end

  def delete
    slug         = params[:folder_clippings][:folder_slug]
    folder       = user_signed_in? ? current_user.folders.find_by_slug(slug) : nil

    if params[:folder_clippings][:clipping_ids].present? && !params[:folder_clippings][:document_numbers].present?
      clipping_ids = params[:folder_clippings][:clipping_ids].split(',')
    else
      if params[:folder_clippings][:document_number].present?
        document_number = params[:folder_clippings][:document_number]
      elsif params[:folder_clippings][:document_numbers].present?
        document_number = params[:folder_clippings][:document_numbers]
      end
    end

    # my-clippings is a "nil" folder
    if (folder.present? || slug == "my-clippings") && clipping_ids.present?
      clipping_count = 0

      clipping_ids.each do |id|
        clipping = Clipping.find_by_user_and_id(current_user, id)
        next unless clipping.present?

        clipping_count = clipping_count + 1
        clipping.destroy
      end

      render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings",
                                   :slug => slug,
                                   :doc_count => clipping_count,
                                   :documents => clipping_ids } }

    elsif (folder.present? || slug == "my-clippings") && document_number.present?
      # there should only be one clipping per document number in each folder - but we don't
      # currently enforce this (but will in the future), this action can only be triggered
      # from the FR2 document view so we want to delete all references to that document in
      # the given folder.
      folder_id = folder.present? ? folder.id : nil

      if user_signed_in?
        clippings = Clipping.where(
          user_id: current_user.id,
          folder_id: folder_id,
          document_number: document_number
        )
        clippings.each{|c| c.destroy}

        render :json => {:folder => {:name => folder.present? ? folder.name : "my-clippings",
                                     :slug => slug,
                                     :doc_count => clippings.count,
                                     :documents => document_number } }
      else
        document_numbers = Array(document_number)

        document_numbers.each do |document_number|
          remove_document_id_from_session(document_number)
        end

        render :json => {:folder => {:name => "my-clippings",
                                     :slug => slug,
                                     :doc_count => document_numbers.size,
                                     :documents => document_numbers } }
      end
    else
      render plain: "No clipping ids or document number present", :status => 400
    end
  end

  private

  def remove_document_id_from_session(document_number)
    if cookies[:document_numbers].present?
      old_cookie = JSON.parse(cookies[:document_numbers])
      new_cookie = []
      old_cookie.each do |doc_hash|
        new_cookie << doc_hash unless doc_hash.first[0] == document_number
      end
      cookies.permanent[:document_numbers] = new_cookie.to_json
    end
  end
end
