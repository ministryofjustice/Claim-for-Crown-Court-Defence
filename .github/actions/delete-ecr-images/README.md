# Delete ECR images docker action

This action prints Deletes an ECR image with a tag matching the
deleted branch

## Inputs

### `my-input`

**Required** Test input. Default `"World"`.

## Outputs

### `my-output`

Test output

## Example usage

```
jobs:
  delete-ecr-image:
    runs-on: ubuntu-latest
    name: A job to delete ECR image for deleted branch
    steps:
    # To use this repository's private action, you must check out the repository
    - name: Checkout
      uses: actions/checkout@v1
    - uses: ./.github/ # Uses an action in the `.github` dir
    - name: delete-ecr-image
      id: ecr-deletion
      uses: actions/delete-ecr-images-action@v1
      with:
        my-input: 'my test input from job arg'
    # Use the output from the `ecr-deletion` step
    - name: Get the output
      run: echo "The time was ${{ steps.ecr-deletion.outputs.my-output }}"
```