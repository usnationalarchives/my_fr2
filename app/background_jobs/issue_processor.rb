class IssueProcessor
  include CacheUtils
  attr_reader :date

  def self.perform(date)
    new(date).perform
  end

  def initialize(date)
    @date = date
  end

  private

  def compile_all_html
    documents(date).each do |document|
      HtmlCompilator::Hyperlinks.perform(document)
      HtmlCompilator::DocumentFullText.perform(document)
      HtmlCompilator::TableOfContents.perform(document)
    end

    document_numbers = documents(args[:date]).map(&:document_number)
    TableXmlExtractor.compile(document_numbers, date)
    HtmlCompilator::Tables.compile(document_numbers, date)
  end

  def documents(date)
    @documents ||= Document.search(
      date: date,
      fields: %w(document_number publication_date start_page images),
      cache_buster: Time.now.to_i
    )
  end
end
