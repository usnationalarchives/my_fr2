class Documents::SearchController < SearchController
  skip_before_filter :authenticate_user!

  def show
    @presenter = SearchPresenter.new(params)
    @search = @presenter.search
    if valid_search? 
      redirect_to documents_search_path(
        conditions: clean_conditions(@search.valid_conditions),
        page: params[:page],
        order: params[:order],
        format: params[:format]
      )
    else
      respond_to do |wants|
        wants.html
        wants.rss do
          @feed_name = "Federal Register: Search Results"
          @feed_description = "Federal Register: Search Results"
          @entries = @search.results
          render :template => 'documents/index.rss.builder'
        end
        wants.csv do
          redirect_to "http://www.federalregister.gov/api/v1/articles.csv?" + {conditions: params[:conditions]}.to_param
        end
        wants.json do
          redirect_to "http://www.federalregister.gov/api/v1/articles.json?" + {conditions: params[:conditions]}.to_param
        end
      end
   end
  end
  
  def facets
    cache_for 1.day
    @presenter = SearchFacetPresenter.new(params)
    
    if params[:all]
      render :partial => "search/facet", :collection => @presenter.facets, :as => :facet
    else
      render :partial => "search/facets", :locals => {:facets => @presenter.facets, :name => @presenter.facet_name}, :layout => false
    end
  end
  
  def suggestions
    cache_for 1.day
    @presenter = SearchPresenter.new(params)
    @search = @presenter.search
    @search_details = @search.search_details
    # RW: necessary?  called from suggestion.html.erb, may have to add when PI is complete
    #if params[:conditions]
    #  @public_inspection_document_search = PublicInspectionDocumentSearch.new_if_possible(
    #    :conditions => @search.valid_conditions
    #  )
    #end
    render :layout => false
  end

  def help
    cache_for 1.day
    if params[:no_layout]
      render :layout => false
    else
      render
    end
  end

  private
  def valid_search?
    blank_conditions?(params[:conditions]) || ((params[:conditions].try(:keys) || []) - @search.valid_conditions.try(:keys)).present?
  end
end