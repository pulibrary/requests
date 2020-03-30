describe Requests::Illiad, vcr: { cassette_name: 'request_models', record: :new_episodes } do
  let(:params) do
    {
      system_id: '8880549',
      mfhd: '8805567',
      user: user
    }
  end
  let(:request_with_holding_item) { described_class.new(params) }

  class SolrDocument
    include Requests::Bibdata
    attr_reader :solr_document

    def initialize(id:)
      @solr_document = solr_doc(id)
    end
  end

  after(:all) do
    Object.send(:remove_const, :SolrDocument)
  end

  let(:ctx) do
    document = SolrDocument.new(id: '8880549')
    Requests::SolrOpenUrlContext.new(solr_doc: document.solr_document).ctx
  end

  it "provides an ILLiad URL" do
    illiad = Requests::Illiad.new(enum: "Volume foo", chron: "Chronicle 1")
    expect(illiad.illiad_request_url(ctx)).to start_with(Requests.config[:ill_base])
  end

  it "provides illiad query parameters with enumeration" do
    illiad = Requests::Illiad.new(enum: "Volume foo", chron: "Chronicle 1")
    expect(illiad.illiad_query_parameters(ctx)).to include(CGI.escape("Volume foo"))
  end
end
