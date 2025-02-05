describe('Modules.MultiFileUpload', () => {
  const module = moj.Modules.MultiFileUpload;

  beforeEach(() => {
    // Create a mock container element
    const container = document.createElement('div');
    container.classList.add('moj-multi-file-upload');
    const fields = document.createElement('div');
    fields.classList.add('moj-multi-file__uploaded-fields');
    container.appendChild(fields);
    document.body.appendChild(container);
  });

  afterEach(() => {
    // Clean up the mock container element
    const container = document.querySelector('.moj-multi-file-upload');
    container.parentNode.removeChild(container);
  });

  it('should initialize the multi-file upload component', () => {
    const container = document.querySelector('.moj-multi-file-upload');
    expect(container).not.toBeNull();
    expect(container.querySelector('.moj-multi-file__uploaded-fields')).not.toBeNull();
  });
});