# frozen_string_literal: true

RSpec.describe ModerateParameters do
  it 'has a version number' do
    expect(ModerateParameters::VERSION).not_to be nil
  end

  describe '#moderate' do
    let(:params) { ActionController::Parameters.new(person: { name: 'Francesco', age: '25' }) }
    let(:subject) { params.require(:person).moderate('foo', 'bar', :name) }

    it 'it logs to a file' do
      payload = notification_payload_for('moderate_parameters') { subject }
      expect(payload[:controller]).to eql('foo')
      expect(payload[:action]).to eql('bar')
      expect(payload[:message]).to eql('Top Level is missing: age')
    end
  end
end
