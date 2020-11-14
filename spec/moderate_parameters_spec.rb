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
    describe '#moderate' do
      let(:permission_keys) { valid_permission_keys }
      let(:subject) { params.require(:person).moderate('controller', 'action', *permission_keys) }
      it 'sets the moderate_params_object_id instance variable on the original params object' do
        params.require(:person).moderate('controller', 'action', *permission_keys)
        expect(params[:person].instance_variable_get(:@moderate_params_object_id)).to be_a Integer
        expect(payload[:controller]).to eql('controller')
        expect(payload[:action]).to eql('action')
        expect(payload[:message]).to start_with('.moderate has already been called on params:')
      end

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

    describe '#require' do
      let(:subject) { params.require(:person) }

      it 'sets an instance variable on the child object' do
        expect(subject.instance_variable_get(:@moderate_params_parent_key)).to eql(:person)
      end

      context 'when the require is passed an array' do
        let(:params) { ActionController::Parameters.new({ person: { foo: :bar }, other: { baz: :bang } }) }
        let(:subject) { params.require([:person, :other]) }

        it 'sets an instance variable on each child object' do
          expect(subject.map { |o| o.instance_variable_get(:@moderate_params_parent_key) }).to eql([:person, :other])
        end
      end

      context 'when the require is called on params with a blank value' do
        let(:params) { ActionController::Parameters.new(person: nil) }
        let(:subject) { params.require(:person) }

        it 'sets an instance variable on each child object' do
          expect { subject }.to raise_error(ActionController::ParameterMissing, "param is missing or the value is empty: person")
        end
      end
    end
  end

  describe '::Breadcrumbs' do
    let(:subject) { a(params[:person]) }

    before(:each) do
      ModerateParameters.configure do |c|
        c.breadcrumbs_enabled = true
      end
      params.require(:person).moderate('controller', 'action', *valid_permission_keys)
    end

    describe '#[]=' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params[:age] = nil
      end

      context 'with the key already being set' do
        it 'logs to a file' do
          expect(payload[:message]).to start_with('age is being overwritten on:')
          expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
        end
      end

      context 'without the key already being set' do
        let(:params) do
          ActionController::Parameters.new(
            {
              person: {
                name: 'Francesco',
                sub_array: %i[foo bar],
                sub_hash: { baz: :bang }
              }
            }
          )
        end

        it 'logs to a file' do
          expect(payload[:message]).to start_with('age is being added on:')
          expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
        end
      end
    end

    describe '#merge!' do
      let(:other_hash) { { name: 'Sophie'} }
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.merge!(other_hash)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with("merge! is being called with #{other_hash.keys} on:")
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#reverse_merge!' do
      let(:other_hash) { { name: 'Alyssa'} }
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.reverse_merge!(other_hash)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with("reverse_merge! is being called with #{other_hash.keys} on:")
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#extract!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.extract!(:name)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('extract! is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#slice!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.slice!(:name)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('slice! is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#delete' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.delete(:name)
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('delete is being called with [:name] on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#reject!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.reject! { |k, _v| k == :name }
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('reject! is being called with a block on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#delete_if' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.delete_if { |k, _v| k == :name }
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('delete_if is being called with a block on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#select!' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.select! { |k, _v| k == :name }
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('select! is being called with a block on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end

    describe '#keep_if' do
      let(:relative_line) { __LINE__ + 2 }
      def a(test_params)
        test_params.keep_if { |k, _v| k == :name }
      end

      it 'logs to a file' do
        expect(payload[:message]).to start_with('keep_if is being called with a block on:')
        expect(payload[:caller_locations][0].to_s).to end_with("spec/moderate_parameters_spec.rb:#{relative_line}:in \`a'")
      end
    end
  end
end
