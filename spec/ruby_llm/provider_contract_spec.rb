# frozen_string_literal: true

require 'spec_helper'

# The Provider base leaves api_base abstract (it raises NotImplementedError).
# Verify every registered provider overrides it, so a provider that forgets its
# base URL fails at load time rather than on the first request.
RSpec.shared_examples 'a provider' do |provider_class|
  it 'overrides the abstract #api_base' do
    expect(provider_class.instance_method(:api_base).owner).not_to eq(RubyLLM::Provider)
  end
end

RSpec.describe RubyLLM::Provider do
  RubyLLM::Provider.providers.each do |name, provider_class| # rubocop:disable RSpec/DescribedClass
    describe(name) { it_behaves_like 'a provider', provider_class }
  end
end
