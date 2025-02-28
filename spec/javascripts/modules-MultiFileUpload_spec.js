/* global File */

describe('Modules.MultiFileUpload', () => {
  const module = moj.Modules.MultiFileUpload
  const multiFileUploadFixtureDOM = $([
    '<div class="moj-multi-file-upload">',
    '  <div class="moj-multi-file__uploaded-fields"></div>',
    '  <div aria-labelledby="error-summary-title" class="govuk-error-summary govuk-visually-hidden" role="alert" tabindex="-1">',
    '    <h2 class="error-summary-title govuk-error-summary__title">There is a problem</h2>',
    '    <div class="govuk-list govuk-error-summary__list"></div>',
    '  </div>',
    '  <div class="moj-multi-file-upload__upload">',
    '    <div class="govuk-form-group">',
    '      <div class="moj-multi-file-upload__dropzone">',
    '        <input class="govuk-file-upload moj-multi-file-upload__input" id="attachments" multiple="multiple" name="attachments" type="file">',
    '        <div aria-live="polite" role="status" class="govuk-visually-hidden"></div>',
    '        <div class="moj-multi-file__uploaded-files">',
    '          <div class="moj-multi-file-upload__list"></div>',
    '        </div>',
    '      </div>',
    '    </div>',
    '  </div>',
    '</div>'].join(''))

  let container, fields, fileList, multiFileUpload

  beforeEach(() => {
    $('body').append(multiFileUploadFixtureDOM)
    container = document.querySelector('.moj-multi-file-upload')
    fields = container.querySelector('.moj-multi-file__uploaded-fields')
    fileList = container.querySelector('.moj-multi-file-upload__list')
    multiFileUpload = module.init()
  })

  afterEach(() => {
    if (container) {
      container.parentNode.removeChild(container)
    }
    if (fields) {
      fields.replaceWith(fields.cloneNode(false))
    }
    if (fileList) {
      fileList.replaceWith(fileList.cloneNode(false))
    }
  })

  it('...should exist', function () {
    expect(module).toBeDefined()
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

  describe('uploadFile', () => {
    let file, item

    beforeEach(() => {
      file = new File(['file content'], 'test-file.txt', { type: 'text/plain' })

      spyOn($, 'ajax').and.callFake((params) => {
        const mockResponse = { success: { messageText: 'Upload successful', messageHtml: 'Upload successful' }, file: { filename: 'test-file.txt' } }
        setTimeout(() => {
          params.success(mockResponse)
        }, 0)
      })

      spyOn(multiFileUpload, 'getFileRowHtml').and.callFake(() => {
        item = $('<div class="moj-multi-file-upload__row"><div class="moj-multi-file-upload__message"></div></div>')
        return item[0]
      })

      spyOn(multiFileUpload.params, 'uploadFileEntryHook').and.callThrough()
      spyOn(multiFileUpload.params, 'uploadFileExitHook').and.callThrough()
      spyOn(multiFileUpload.params, 'uploadFileErrorHook').and.callThrough()
      multiFileUpload.uploadFile(file)
    })

    it('should call uploadFileEntryHook before uploading', () => {
      expect(multiFileUpload.params.uploadFileEntryHook).toHaveBeenCalledWith(multiFileUpload, file)
    })

    it('should add the file row to the upload list', () => {
      expect(fileList).not.toBeNull()
      expect(fileList.children.length).toBe(1)
      expect(fileList.children[0]).toEqual(item[0])
    })

    it('should handle a successful upload response', (done) => {
      setTimeout(() => {
        expect(multiFileUpload.params.uploadFileExitHook).toHaveBeenCalled()
        expect(fields.querySelector('input[type="hidden"]')).not.toBeNull()
        expect(fields.querySelector('input[type="hidden"]').value).toBe('test-file.txt')

        const uploadedItem = fileList.querySelector('.moj-multi-file-upload__row')
        expect(uploadedItem).not.toBeNull()

        const message = uploadedItem.querySelector('.moj-multi-file-upload__message')
        expect(message).not.toBeNull()
        expect(message.textContent).toContain('Upload successful')

        done()
      }, 10)
    })

    it('should handle an error response', (done) => {
      $.ajax.and.callFake((params) => {
        setTimeout(() => {
          const mockError = { status: 500 }
          params.error(mockError, 'error', 'Internal Server Error')
        }, 0)
      })

      multiFileUpload.uploadFile(file)

      setTimeout(() => {
        expect(multiFileUpload.params.uploadFileErrorHook).toHaveBeenCalled()

        done()
      }, 10)
    })
  })
})
