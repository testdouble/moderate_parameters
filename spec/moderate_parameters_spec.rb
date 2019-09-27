# frozen_string_literal: true

RSpec.describe ModerateParameters do
  let(:params) { ActionController::Parameters.new(person: { name: 'Francesco', age: '25' }) }

  it 'has a version number' do
    expect(ModerateParameters::VERSION).not_to be nil
  end

  describe '#moderate' do
    let(:subject) { params.require(:person).moderate('controller', 'action', :name) }

    it 'logs to a file' do
      payload = notification_payload_for('moderate_parameters') { subject }
      expect(payload[:controller]).to eql('controller')
      expect(payload[:action]).to eql('action')
      expect(payload[:message]).to eql('Top Level is missing: age')
    end
  end

  describe '#[]' do
    def a(test_params)
      test_params[:person]
    end

    let(:subject) { a(params) }
    it 'logs to a file' do
      payload = notification_payload_for('moderate_parameters') { subject }
      expect(payload[:message]).to start_with('person is being read on:')
      expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:23:in \`a'")
    end
  end

  describe '#[]=' do
    def a(test_params)
      b = test_params[:person]
      b[:age] = 27
    end

    let(:subject) { a(params) }

    it 'logs to a file' do
      payload = notification_payload_for('moderate_parameters') { subject }
      expect(payload[:message]).to start_with('age is being overwritten on:')
      expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:37:in \`a'")
    end
  end

  describe '#extract!' do
    def a(test_params)
      b = test_params.require(:person)
      b.extract!(:name)
    end

    let(:subject) { a(params) }

    it 'logs to a file' do
      payload = notification_payload_for('moderate_parameters') { subject }
      expect(payload[:message]).to start_with('extract! is being called with [:name] on:')
      expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:52:in \`a'")
    end
  end
end
