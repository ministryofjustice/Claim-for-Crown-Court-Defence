# Delete ECR images docker action

This action prints Deletes an ECR image with a tag matching the
deleted branch

**Required** Test input. Default `"World"`.

## Outputs

### `deleted-images`
JSON format list of images that were deleted - response form aws-cli

## Example workflow

```
name: Delete ecr image for branch
on: [delete]

jobs:
  delete-ecr-image:
    runs-on: ubuntu-latest
    name: A job to delete ECR image for deleted branch
    steps:
    - name: Checkout
      uses: actions/checkout@v2
    - name: delete-ecr-image
      id: ecr-deletion
      uses: ./.github/actions/delete-ecr-images
      env:
        AWS_DEFAULT_REGION: ${{ secrets.AWS_DEFAULT_REGION }}
        AWS_ACCESS_KEY_ID: ${{ secrets.AWS_ACCESS_KEY_ID }}
        AWS_SECRET_ACCESS_KEY: ${{ secrets.AWS_SECRET_ACCESS_KEY }}
        ECR_REPOSITORY_NAME: '<ecr-repository-name>'
    - name: Get the output
      run: |
        echo "${{ steps.ecr-deletion.outputs.deleted-images }}"

```