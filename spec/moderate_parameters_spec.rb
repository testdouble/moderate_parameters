# frozen_string_literal: true

RSpec.describe ModerateParameters do
  let(:params) { ActionController::Parameters.new(person: { name: 'Francesco', age: '25', sub_array: [:foo, :bar], sub_hash: { baz: :bang } }) }

  it 'has a version number' do
    expect(ModerateParameters::VERSION).not_to be nil
  end

  describe '::Parameters' do
    let(:subject) { params.require(:person).moderate('controller', 'action', :name, { sub_array: [], sub_hash: {} }) }
    describe '#moderate' do
      # params.permit(:name, {:emails => []}, :friends => [ :name, { :family => [ :name ], :hobbies => [] }])
      it 'logs to a file' do
        payload = notification_payload_for('moderate_parameters.default') { subject }
        expect(payload[:controller]).to eql('controller')
        expect(payload[:action]).to eql('action')
        expect(payload[:message]).to eql('Top Level is missing: age')
      end

      context 'key present but missing array value' do
        let(:subject) { params.require(:person).moderate('controller', 'action', :name, :age, :sub_array, { sub_hash: {} }) }
        it 'logs to a file' do
          payload = notification_payload_for('moderate_parameters.default') { subject }
          expect(payload[:controller]).to eql('controller')
          expect(payload[:action]).to eql('action')
          expect(payload[:message]).to eql('Top Level is missing: [] value for sub_array')
        end
      end

      context 'key present but missing hash value' do
        let(:subject) { params.require(:person).moderate('controller', 'action', :name, :age, { sub_array: [] }, :sub_hash) }
        it 'logs to a file' do
          payload = notification_payload_for('moderate_parameters.default') { subject }
          expect(payload[:controller]).to eql('controller')
          expect(payload[:action]).to eql('action')
          expect(payload[:message]).to eql('Top Level is missing: {} value for sub_hash')
        end
      end
    end
  end

  describe '::Breadcrumbs' do
    before(:each) do
      ModerateParameters.configure do |c|
        c.breadcrumbs_enabled = true
      end
    end

    describe '#[]=' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params[:person] = nil
      end

      let(:subject) { a(params) }

      it 'logs to a file' do
        payload = notification_payload_for('moderate_parameters.breadcrumbs.[]=') { subject }
        expect(payload[:message]).to start_with('person is being overwritten on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#extract!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.require(:person).extract!(:name)
      end

      let(:subject) { a(params) }

      it 'logs to a file' do
        payload = notification_payload_for('moderate_parameters.breadcrumbs.extract!') { subject }
        expect(payload[:message]).to start_with('extract! is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#slice!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.require(:person).slice!(:name)
      end

      let(:subject) { a(params) }

      it 'logs to a file' do
        payload = notification_payload_for('moderate_parameters.breadcrumbs.slice!') { subject }
        expect(payload[:message]).to start_with('slice! is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end
  end
end
