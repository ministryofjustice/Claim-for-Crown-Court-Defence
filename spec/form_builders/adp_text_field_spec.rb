require 'rails_helper'

class TestHelper < ActionView::Base; end

describe AdpTextField do

  context 'top level text fields' do
    let(:helper) { TestHelper.new }
    let(:resource)  { FactoryBot.create :claim, case_number: nil }
    let(:error_presenter) { ErrorPresenter.new(resource) }
    let(:builder)   { AdpFormBuilder.new(:claim, resource, helper, {} ) }

    context 'simple text field without hint' do
      it 'should produce expected html when resource is nil' do
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', errors: error_presenter)
        expect(atf.to_html).to eq squash(a100_no_value_no_hint)
      end

      it 'should produce expected result when resource has a value' do
        resource.case_number = 'X22334455'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', errors: error_presenter)
        expect(atf.to_html).to eq a200_value_no_hint
      end

      it 'should strip html tags from output value' do
        resource.case_number = '<b>X22334455</b>'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', errors: error_presenter)
        expect(atf.to_html).to eq a200_value_no_hint
      end

      def a100_no_value_no_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <input class="form-control " type="text" name="claim[case_number]" id="claim_case_number" />
        </div>
        eos
        squash(html)
      end

      def a200_value_no_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <input class="form-control " type="text" name="claim[case_number]" id="claim_case_number" value="X22334455" />
        </div>
        eos
        squash(html)
      end
    end

    context 'simple number field without hint' do
      it 'should produce expected html when resource is nil' do
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'number', errors: error_presenter)
        expect(atf.to_html).to eq squash(a100_no_value_no_hint)
      end

      it 'should produce expected result when resource has a value' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'number', errors: error_presenter)
        expect(atf.to_html).to eq a200_value_no_hint
      end

      def a100_no_value_no_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <input class="form-control " type="number" name="claim[case_number]" id="claim_case_number" min="0" max="99999" />
        </div>
        eos
        squash(html)
      end

      def a200_value_no_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <input class="form-control " type="number" name="claim[case_number]" id="claim_case_number" value="555" min="0" max="99999" />
        </div>
        eos
        squash(html)
      end
    end

    context 'simple currency field without hint' do
      it 'should produce expected html when resource is nil' do
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', errors: error_presenter)
        expect(atf.to_html).to eq squash(a100_no_value_no_hint)
      end

      it 'should produce expected result when resource has a value' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', errors: error_presenter)

        expect(atf.to_html).to eq a200_value_no_hint
      end

      it 'should produce expected result when disabled' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', input_disabled: true, errors: error_presenter)

        expect(atf.to_html).to eq a200_value_no_hint_disabled
      end

      def a100_no_value_no_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <span class="currency-indicator form-input-denote">&pound;</span>
          <input class="form-control " type="number" name="claim[case_number]" id="claim_case_number" min="0" max="99999" />
        </div>
        eos
        squash(html)
      end

      def a200_value_no_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <span class="currency-indicator form-input-denote">&pound;</span>
          <input class="form-control " type="number" name="claim[case_number]" id="claim_case_number" value="555" min="0" max="99999" />
        </div>
        eos
        squash(html)
      end

      def a200_value_no_hint_disabled
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
          </label>
          <span class="currency-indicator form-input-denote">&pound;</span>
          <input class="form-control " type="number" name="claim[case_number]" id="claim_case_number" value="555" min="0" max="99999" disabled />
        </div>
        eos
        squash(html)
      end
    end

    context 'simple text with hint' do
      it 'produces expected output with value' do
        resource.case_number = 'X22334455'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', hint_text: 'Hint text here', errors: error_presenter)
        expect(atf.to_html).to eq b100_with_value_with_hint
      end

      def b100_with_value_with_hint
        html = <<-eos
        <div class="form-group case_number_wrapper">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
            <span class="form-hint">Hint text here</span>
          </label>
          <input class="form-control " type="text" name="claim[case_number]" id="claim_case_number" value="X22334455" />
        </div>
        eos
        squash(html)
      end
    end

    context 'errored value with hint' do
      it 'produces error text' do
        resource.case_number = nil
        resource.errors.add(:case_number, 'Validation error here')
        error_presenter = ErrorPresenter.new(resource)
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', hint_text: 'Hint text here', errors: error_presenter)
        expect(atf.to_html).to eq c100_with_value_with_hint_and_error
      end

      def c100_with_value_with_hint_and_error
        html = <<-eos
        <div class="form-group case_number_wrapper field_with_errors form-group-error">
          <a id="case_number"></a>
          <label class="form-label-bold" for="claim_case_number">
            Case number
            <span class="form-hint">Hint text here</span>
            <span class="error error-message">Validation error here</span>
          </label>
          <input class="form-control " type="text" name="claim[case_number]" id="claim_case_number" />
        </div>
        eos
        squash(html)
      end
    end
  end

  def squash(html)
    html.gsub("\n", '').gsub(/\>\s+/, '>').gsub(/\s+\</, '<').chomp
  end
end


