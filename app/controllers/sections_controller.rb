class SectionsController < ApplicationController
  skip_before_action :authenticate_user!
  skip_before_action :verify_authenticity_token, only: :carousel_preview
  layout false, only: [:navigation]


  def show
    cache_for 1.day

    section = Section.find_by_slug!(params[:section])

    @presenter = SectionPagePresenter.new(
      section,
      DocumentIssue.current.publication_date
    )

    respond_to do |format|
      format.html
      format.rss do
        redirect_to RSSUrlBuilder.new(@presenter.slug).url,
          status: :moved_permanently
      end
    end
  end

  def homepage
    cache_for 1.day

    date = DocumentIssue.current.publication_date
    @presenters = Section.all.map do |section|
      RequestStore.store["section_page_#{section.slug}_#{date.to_s(:iso)}"] ||= section.highlighted_documents_for(date)
      SectionPagePresenter.new(section, date)
    end

    render layout: false
  end

  def significant_entries
    cache_for 1.day
    @presenter = SectionPresenter.new(params[:section])
    @section = @presenter.section

    respond_to do |wants|
      wants.rss do
        base_url = 'https://www.federalregister.gov/articles/search.rss?'
        options = "conditions[sections]=#{@section.id}&order=newest.com&conditions[significant]=1"
        redirect_to base_url + options, status: :moved_permanently
      end
    end
  end

  def carousel_preview
    @section = Section.find_by_slug(params[:slug])
    @highlighted_documents = JSON.parse(
      URI.unescape(params[:highlighted_documents])
    ).map{|h| OpenStruct.new(h)}

    if @highlighted_documents.present?
      render layout: "carousel_preview"
    else
      render plain: ""
    end
  end
end
