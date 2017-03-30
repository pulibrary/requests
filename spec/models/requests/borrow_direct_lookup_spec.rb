require 'spec_helper'
require 'borrow_direct'

describe Requests::BorrowDirectLookup do
  let(:subject) { described_class.new }

  context 'An available item in borrow direct' do
    let(:good_params) { 
      {
        :isbn => '0415296633'
      }
    }

    let(:good_bd_response) {
      instance_double('bd_find_item')
    }

    describe '#find' do
      it 'Returns a good BorrowDirect::FindItem response' do
        expect(subject).to receive(:find).with(good_params).and_return(good_bd_response)
        expect(subject.find(good_params)).to eq(good_bd_response)
      end
    end

    describe '#available?' do
      it 'is available for request' do
        expect(subject).to receive(:find).with(good_params).and_return(good_bd_response)
        expect(subject.find(good_params)).to eq(good_bd_response)
        expect(subject).to receive(:available?).and_return(true)
        expect(subject.available?).to be true
      end
    end
  end

  context 'An unavailable item in borrow direct' do
    let(:bad_params) { 
      {
        :isbn => '121313131313'
      }
    } 
    let(:bad_bd_response) {
      instance_double('bd_find_item')
    }
    let(:solr_doc) {
      {
        "id" => '12321323',
        'author_citation_display' => ['Student, Joe'],
        'title_citation_display' => ['A Test Title']
      }
    }
    let(:solr_doc_no_author) {
      {
        "id" => '12321323',
        'title_citation_display' => ['A Test Title']
      }
    }
    describe '#find' do
      it 'Returns a bad BorrowDirect::FindItem response' do
        expect(subject).to receive(:find).with(bad_params).and_return(bad_bd_response)
        expect(subject.find(bad_params)).to eq(bad_bd_response)
      end
    end

    describe '#available?' do
      it 'Is not available for request' do
        expect(subject).to receive(:find).with(bad_params).and_return(bad_bd_response)
        expect(subject.find(bad_params)).to eq(bad_bd_response)
        expect(subject).to receive(:available?).and_return(false)
        expect(subject.available?).to be false
      end
    end

    describe '#fallback_query_params' do
      it 'has a title and author parameters when both are present' do
        expect(subject.fallback_query_params(solr_doc).keys.size).to eq(2)
        expect(subject.fallback_query_params(solr_doc).key? :title).to be true
        expect(subject.fallback_query_params(solr_doc).key? :author).to be true
      end

      it 'has a title and author parameters when both are present' do
        expect(subject.fallback_query_params(solr_doc_no_author).keys.size).to eq(1)
        expect(subject.fallback_query_params(solr_doc_no_author).key? :title).to be true
        expect(subject.fallback_query_params(solr_doc_no_author).key? :author).to be false
      end
    end

    describe '#fallback_query' do
      it 'returns a borrow direct fallback query url' do
        params = {
          title: 'Test',
          author: 'Author, Test'
        }
        expect(subject.fallback_query(params)).to be_truthy
        expect(subject.fallback_query(params)).to include(BorrowDirect::Defaults.html_base_url)
        expect(subject.fallback_query(params)).to include(params[:title].downcase)
      end
    end
  end
end