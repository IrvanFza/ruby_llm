# frozen_string_literal: true

require 'spec_helper'

# The Protocol base leaves its wire seams abstract (they raise
# NotImplementedError). These examples verify a protocol actually overrides the
# universal chat seams, rather than inheriting the raising stubs, catching a
# missing implementation at load time instead of on the first request.
RSpec.shared_examples 'a protocol' do |family|
  %i[render_payload completion_url parse_completion_body].each do |seam|
    it "overrides the abstract ##{seam}" do
      expect(family.instance_method(seam).owner).not_to eq(RubyLLM::Protocol)
    end
  end
end

RSpec.describe RubyLLM::Protocol do
  {
    'Chat Completions' => RubyLLM::Protocols::ChatCompletions,
    'Responses' => RubyLLM::Protocols::Responses,
    'Anthropic' => RubyLLM::Protocols::Anthropic,
    'Gemini' => RubyLLM::Protocols::Gemini,
    'Converse' => RubyLLM::Protocols::Converse
  }.each do |name, family|
    describe name do
      it_behaves_like 'a protocol', family
    end
  end
end
