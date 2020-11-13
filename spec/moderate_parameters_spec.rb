# frozen_string_literal: true

RSpec.describe ModerateParameters do
  let(:params) do
    ActionController::Parameters.new(
      {
        person: {
          name: 'Francesco',
          age: '25',
          sub_array: %i[foo bar],
          sub_hash: { baz: :bang }
        }
      }
    )
  end
  let(:payload) { notification_payload_for('moderate_parameters') { subject } }
  let(:valid_permission_keys) { [:name, :age, { sub_array: [], sub_hash: {} }] }

  it 'has a version number' do
    expect(ModerateParameters::VERSION).to be_an_instance_of(String)
  end

  describe '::Parameters' do
    let(:permission_keys) { valid_permission_keys }
    let(:subject) { params.require(:person).moderate('controller', 'action', *permission_keys) }

    describe '#moderate' do
      context 'with permitted params properly specified' do
        it 'does not log to a file' do
          expect(payload).to be nil
        end
      end

      context 'without a top level key' do
        let(:permission_keys) { [:name, { sub_array: [], sub_hash: {} }] }
        it 'logs to a file' do
          expect(payload[:controller]).to eql('controller')
          expect(payload[:action]).to eql('action')
          expect(payload[:message]).to eql('Top Level is missing: age')
        end
      end

      context 'key present but missing array value' do
        let(:permission_keys) { [:name, :age, :sub_array, { sub_hash: {} }] }

        it 'logs to a file' do
          expect(payload[:controller]).to eql('controller')
          expect(payload[:action]).to eql('action')
          expect(payload[:message]).to eql('Top Level is missing: [] value for sub_array')
        end
      end

      context 'key present but missing hash value' do
        let(:permission_keys) { [:name, :age, { sub_array: [] }, :sub_hash] }

        it 'logs to a file' do
          expect(payload[:controller]).to eql('controller')
          expect(payload[:action]).to eql('action')
          expect(payload[:message]).to eql('Top Level is missing: {} value for sub_hash')
        end
      end
    end
  end

  describe '::Breadcrumbs' do
    let(:subject) { a(params) }

    before(:each) do
      ModerateParameters.configure do |c|
        c.breadcrumbs_enabled = true
      end
    end

    describe '#[]=' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.require(:person).permit(*valid_permission_keys)[:age] = nil
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('age is being overwritten on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#extract!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.require(:person).permit(*valid_permission_keys).extract!(:name)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('extract! is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#delete' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.require(:person).permit(*valid_permission_keys).delete(:name)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('delete is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#reject!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.require(:person).permit(*valid_permission_keys).reject! { |k, _v| k == :name }
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('reject! is being called with a block on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end
  end
end
