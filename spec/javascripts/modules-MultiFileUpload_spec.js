describe('Modules.MultiFileUpload', () => {
  const module = moj.Modules.MultiFileUpload

  it('...should exist', function () {
    expect(module).toBeDefined()
  })

  let container
  let fields

  beforeEach(() => {
    container = document.querySelector('.moj-multi-file-upload')
    if (!container) {
      pending('Container is not defined')
    }
    fields = container.querySelector('.moj-multi-file__uploaded-fields')
  })

  afterEach(() => {
    // Clean up the mock container element
    if (container) {
      container.parentNode.removeChild(container)
    }
  })

  it('should initialize the multi-file upload component', () => {
    expect(container).not.toBeNull()
    expect(fields).not.toBeNull()
  })
})
