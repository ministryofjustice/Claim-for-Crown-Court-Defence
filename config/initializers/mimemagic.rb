# From the overlay.rb file from mimemagic, removed in version 0.3.7
# See https://github.com/mimemagicrb/mimemagic/commit/0c9132141901ceaa298a563cdcd72896067f1dd6

[
  [
    'application/vnd.openxmlformats-officedocument.presentationml.presentation',
    [[0, "PK\003\004", [[0..5000, '[Content_Types].xml', [[0..5000, 'ppt/']]]]]]
  ],
  [
    'application/vnd.openxmlformats-officedocument.spreadsheetml.sheet',
    [[0, "PK\003\004", [[0..5000, '[Content_Types].xml', [[0..5000, 'xl/']]]]]]
  ],
  [
    'application/vnd.openxmlformats-officedocument.wordprocessingml.document',
    [[0, "PK\003\004", [[0..5000, '[Content_Types].xml', [[0..5000, 'word/']]]]]]
  ]
].each do |magic|
  MimeMagic.add(magic[0], magic: magic[1])
end
