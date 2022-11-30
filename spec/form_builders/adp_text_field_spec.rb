require 'rails_helper'

class TestHelper < ActionView::Base; end

RSpec.describe AdpTextField do
  context 'top level text fields' do
    let(:helper) do
      TestHelper.new(
        ActionView::LookupContext.new([]), # lookup_context
        {}, # assigns
        ActionController::Base.new() # controller
      )
    end
    let(:resource) { create(:claim, case_number: nil) }
    let(:error_presenter) { ErrorMessage::Presenter.new(resource) }
    let(:builder)   { AdpFormBuilder.new(:claim, resource, helper, {}) }

    context 'simple text field without hint' do
      it 'produces expected html when resource is nil' do
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', errors: error_presenter)
        expect(atf.to_html).to eq squash(a100_no_value_no_hint)
      end

      it 'produces expected result when resource has a value' do
        resource.case_number = 'X22334455'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', errors: error_presenter)
        expect(atf.to_html).to eq a200_value_no_hint
      end

      it 'strips html tags from output value' do
        resource.case_number = '<b>X22334455</b>'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', errors: error_presenter)
        expect(atf.to_html).to eq a200_value_no_hint
      end

      def a100_no_value_no_hint
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <input class="form-control " type="text" name="claim[case_number]" id="case_number" value="" />
          </div>
        HTML
        squash(html)
      end

      def a200_value_no_hint
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <input class="form-control " type="text" name="claim[case_number]" id="case_number" value="X22334455" />
          </div>
        HTML
        squash(html)
      end
    end

    context 'simple number field without hint' do
      it 'produces expected html when resource is nil' do
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'number', errors: error_presenter)
        expect(atf.to_html).to eq squash(a100_no_value_no_hint)
      end

      it 'produces expected result when resource has a value' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'number', errors: error_presenter)
        expect(atf.to_html).to eq a200_value_no_hint
      end

      def a100_no_value_no_hint
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="" min="0" max="99999" />
          </div>
        HTML
        squash(html)
      end

      def a200_value_no_hint
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="555" min="0" max="99999" />
          </div>
        HTML
        squash(html)
      end
    end

    context 'simple currency field without hint' do
      it 'produces expected html when resource is nil' do
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', errors: error_presenter)
        expect(atf.to_html).to eq squash(a100_no_value_no_hint)
      end

      it 'produces expected result when resource has a value' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', errors: error_presenter)

        expect(atf.to_html).to eq a200_value_no_hint
      end

      it 'produces expected result when disabled' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', input_disabled: true, errors: error_presenter)

        expect(atf.to_html).to eq a200_value_no_hint_disabled
      end

      it 'produces expected result when readonly' do
        resource.case_number = '555'
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'currency', input_readonly: true, errors: error_presenter)

        expect(atf.to_html).to eq a200_value_no_hint_readonly
      end

      def a100_no_value_no_hint
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <span class="currency-indicator form-input-denote">&pound;</span>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="" min="0" max="99999" />
          </div>
        HTML
        squash(html)
      end

      def a200_value_no_hint
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <span class="currency-indicator form-input-denote">&pound;</span>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="555" min="0" max="99999" />
          </div>
        HTML
        squash(html)
      end

      def a200_value_no_hint_disabled
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <span class="currency-indicator form-input-denote">&pound;</span>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="555" min="0" max="99999" disabled />
          </div>
        HTML
        squash(html)
      end

      def a200_value_no_hint_readonly
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
            </label>
            <span class="currency-indicator form-input-denote">&pound;</span>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="555" min="0" max="99999" readonly />
          </div>
        HTML
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
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
              <span class="form-hint govuk-hint" >Hint text here</span>
            </label>
            <input class="form-control " type="text" name="claim[case_number]" id="case_number" value="X22334455" />
          </div>
        HTML
        squash(html)
      end
    end

    context 'errored value with hint' do
      it 'produces error text' do
        resource.case_number = nil
        resource.errors.add(:case_number, 'Validation error here')
        error_presenter = ErrorMessage::Presenter.new(resource)
        atf = AdpTextField.new(builder, :case_number, label: 'Case number', hint_text: 'Hint text here', errors: error_presenter)
        expect(atf.to_html).to eq c100_with_value_with_hint_and_error
      end

      def c100_with_value_with_hint_and_error
        html = <<~HTML
          <div class="form-group case_number_wrapper field_with_errors form-group-error">
            <label class="form-label-bold" for="case_number">
              Case number
              <span class="form-hint govuk-hint" >Hint text here</span>
              <span class="error error-message">Validation error here</span>
            </label>
            <input class="form-control " type="text" name="claim[case_number]" id="case_number" value="" />
          </div>
        HTML
        squash(html)
      end
    end

    context 'simple number field with hint' do
      subject(:html_output) { adp_text_field.to_html }

      context 'shown' do
        let(:adp_text_field) { AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'number', hint_text: 'Hint text here', errors: error_presenter) }

        it { is_expected.to eq squash(d100_no_value_hint_shown) }
      end

      context 'hidden' do
        let(:adp_text_field) { AdpTextField.new(builder, :case_number, label: 'Case number', input_type: 'number', hint_text: 'Hint text here', hide_hint: true, errors: error_presenter) }

        it { is_expected.to eq squash(e100_no_value_hint_hidden) }
      end

      def d100_no_value_hint_shown
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
              <span class="form-hint govuk-hint" >Hint text here</span>
            </label>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="" min="0" max="99999" />
          </div>
        HTML
        squash(html)
      end

      def e100_no_value_hint_hidden
        html = <<~HTML
          <div class="form-group case_number_wrapper">
            <label class="form-label-bold" for="case_number">
              Case number
              <span class="form-hint govuk-hint" style="display: none;">Hint text here</span>
            </label>
            <input class="form-control " type="number" name="claim[case_number]" id="case_number" value="" min="0" max="99999" />
          </div>
        HTML
        squash(html)
      end
    end
  end

  def squash(html)
    html.delete("\n").gsub(/>\s+/, '>').gsub(/\s+</, '<').chomp
  end
end
