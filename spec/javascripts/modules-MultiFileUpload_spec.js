describe('Modules.MultiFileUpload', () => {
  const module = moj.Modules.MultiFileUpload
  const multiFileUploadFixtureDOM = $(['<div class="moj-multi-file-upload">',
    '<div class="moj-multi-file__uploaded-fields"></div>',
    '<div aria-labelledby="error-summary-title" class="govuk-error-summary govuk-visually-hidden" role="alert" tabindex="-1">',
    '<h2 class="error-summary-title govuk-error-summary__title">There is a problem</h2>',
    '<div class="govuk-list govuk-error-summary__list"></div>',
    '</div>',
    '<div class="moj-multi-file-upload__upload">',
    '<div class="govuk-form-group">',
    '<div class="moj-multi-file-upload__dropzone">',
    '<input class="govuk-file-upload moj-multi-file-upload__input" id="attachments" multiple="multiple" name="attachments" type="file">',
    '<div aria-live="polite" role="status" class="govuk-visually-hidden"></div>',
    '</div>',
    '</div>',
    '</div>',
    '</div>'].join(''))

  it('...should exist', function () {
    expect(module).toBeDefined()
  })

  let container
  let fields
  let multiFileUpload

  beforeEach(() => {
    $('body').append(multiFileUploadFixtureDOM)
    container = document.querySelector('.moj-multi-file-upload')
    fields = container.querySelector('.moj-multi-file__uploaded-fields')
    multiFileUpload = module.init()
  })

  afterEach(() => {
    // Clean up the container and fields elements set at the start of the test
    if (container) {
      container.parentNode.removeChild(container)
    }
    while (fields.firstChild) {
      fields.removeChild(fields.firstChild)
    }
  })

  it('should initialize the multi-file upload component', () => {
    expect(container).not.toBeNull()
    expect(fields).not.toBeNull()
  })

  describe('uploadFileExitHook', () => {
    it('should append a hidden input field with the file name', () => {
      const response = { file: { filename: 'test-file.txt' } }
      multiFileUpload.params.uploadFileExitHook(null, null, response)
      const input = fields.querySelector('input[type="hidden"]')
      expect(input).not.toBeNull()
      expect(input.name).toBe('message[document_ids][]')
      expect(input.value).toBe('test-file.txt')
    })
  })

  describe('uploadFileErrorHook', () => {
    const file = { name: 'test-file.txt' }
    const jqXHR = { status: 500 }
    const errorThrown = 'test-file.txt: Internal Server Error.<br>'

    it('should append a hidden input field with the error message', () => {
      multiFileUpload.params.uploadFileErrorHook(null, file, jqXHR, null, errorThrown)
      const input = fields.querySelector('input[type="hidden"]')
      expect(input).not.toBeNull()
      expect(input.name).toBe('message[document_ids][]')
      expect(input.value).toBe(errorThrown)
    })

    it('should display an error message in the error summary', () => {
      multiFileUpload.params.uploadFileErrorHook(null, file, jqXHR, null, errorThrown)
      const errorContainer = document.querySelector('.govuk-error-summary')
      expect(errorContainer).not.toHaveClass('govuk-visually-hidden')
      const error = errorContainer.querySelector('.govuk-list.govuk-error-summary__list span')
      expect(error).not.toBeNull()
      expect(error.innerHTML).toContain(file.name)
      expect(error.innerHTML).toContain(errorThrown)
    })
  })

  describe('fileDeleteHook', () => {
    it('should remove the corresponding input field', () => {
      const response = { file: { filename: 'test-file.txt' } }
      multiFileUpload.params.uploadFileExitHook(null, null, response)
      const input = fields.querySelector('input[type="hidden"]')
      expect(input).not.toBeNull()
      multiFileUpload.params.fileDeleteHook(null, response)
      expect(fields.querySelector('input[type="hidden"]')).toBeNull()
    })
  })
})
