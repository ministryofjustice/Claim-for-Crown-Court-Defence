describe('Modules.MultiFileUpload', () => {
  const module = moj.Modules.MultiFileUpload;
  
  it('...should exist', function () {
    expect(module).toBeDefined()
  })

  beforeEach(() => {
    container = document.querySelector('.moj-multi-file-upload');
    if (!container) {
      pending('Container is not defined');
    } else {
      fields = container.querySelector('.moj-multi-file__uploaded-fields');
      multiFileUpload = moj.Modules.MultiFileUpload.init();
    }
  });

  afterEach(() => {
    // Clean up the mock container element
    if (container) {
      container.parentNode.removeChild(container);
    }
  });

  it('should initialize the multi-file upload component', () => {
    expect(container).not.toBeNull();
    expect(fields).not.toBeNull();
  });

  describe('uploadFileExitHook', () => {
    it('should append a hidden input field with the file name', () => {
      const response = { file: { filename: 'test-file.txt' } };
      multiFileUpload.uploadFileExitHook(null, null, response);
      const input = fields.querySelector('input[type="hidden"]');
      expect(input).not.toBeNull();
      expect(input.name).toBe('message[document_ids][]');
      expect(input.value).toBe('test-file.txt');
    });
  });

  describe('uploadFileErrorHook', () => {
    it('should append a hidden input field with the error message', () => {
      const file = { name: 'test-file.txt' };
      const errorThrown = 'Error message';
      multiFileUpload.uploadFileErrorHook(null, file, null, null, errorThrown);
      const input = fields.querySelector('input[type="hidden"]');
      expect(input).not.toBeNull();
      expect(input.name).toBe('message[document_ids][]');
      expect(input.value).toBe(errorThrown);
    });

    it('should display an error message in the error summary', () => {
      const file = { name: 'test-file.txt' };
      const errorThrown = 'Error message';
      multiFileUpload.uploadFileErrorHook(null, file, null, null, errorThrown);
      const errorContainer = document.querySelector('.govuk-error-summary');
      expect(errorContainer.style.display).not.toBe('none');
      const error = errorContainer.querySelector('.govuk-list.govuk-error-summary__list span');
      expect(error).not.toBeNull();
      expect(error.innerHTML).toContain(file.name);
      expect(error.innerHTML).toContain(errorThrown);
    });
  });

  describe('fileDeleteHook', () => {
    it('should remove the corresponding input field', () => {
      const response = { file: { filename: 'test-file.txt' } };
      multiFileUpload.uploadFileExitHook(null, null, response);
      const input = fields.querySelector('input[type="hidden"]');
      expect(input).not.toBeNull();
      multiFileUpload.fileDeleteHook(null, response);
      expect(fields.querySelector('input[type="hidden"]')).toBeNull();
    });
  });
});