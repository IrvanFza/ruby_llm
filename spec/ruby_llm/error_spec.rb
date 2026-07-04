# frozen_string_literal: true

require 'spec_helper'

RSpec.describe RubyLLM::Error do
  describe '#initialize' do
    context 'with a message' do
      it 'uses the message and leaves response nil' do
        error = described_class.new('something went wrong')
        expect(error.message).to eq('something went wrong')
        expect(error.response).to be_nil
      end

      it 'works with the standard raise convention' do
        expect { raise described_class, 'something went wrong' }
          .to raise_error(described_class, 'something went wrong')
      end
    end

    context 'with a message and a response' do
      let(:response) { Struct.new(:status, :body).new(500, '{"error":"server error"}') }

      it 'stores the response' do
        error = described_class.new('server error', response: response)
        expect(error.response).to eq(response)
      end

      it 'uses the provided message' do
        error = described_class.new('server error', response: response)
        expect(error.message).to eq('server error')
      end
    end

    context 'with a response only' do
      let(:response) { Struct.new(:status, :body).new(500, 'raw body') }

      it 'falls back to the response body for the message' do
        error = described_class.new(response: response)
        expect(error.message).to eq('raw body')
      end
    end

    context 'with no arguments' do
      it 'works without raising' do
        error = described_class.new
        expect(error.response).to be_nil
        expect(error.message).to eq('RubyLLM::Error')
      end
    end
  end

  describe 'subclasses' do
    it 'accepts a plain message' do
      error = RubyLLM::BadRequestError.new('bad request')
      expect(error.message).to eq('bad request')
      expect(error.response).to be_nil
    end
  end

  describe RubyLLM::UnsupportedAttachmentError do
    it 'uses a simple standard message with the unsupported type and guidance' do
      error = described_class.new('application/vnd.openxmlformats-officedocument.wordprocessingml.document')

      expect(error.message).to eq(
        'Unsupported attachment type: application/vnd.openxmlformats-officedocument.wordprocessingml.document. ' \
        'Consider using a model that supports this attachment type.'
      )
    end

    it 'omits the type when none is provided' do
      error = described_class.new

      expect(error.message).to eq(
        'Unsupported attachment type. Consider using a model that supports this attachment type.'
      )
    end
  end
end
