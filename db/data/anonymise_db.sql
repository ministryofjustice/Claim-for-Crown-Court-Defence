--
-- anonymises any data that could possibly
-- contain sensitive data:
--
-- * provider names
-- * user names
-- * defendant names
-- * messages
-- * message attachment file names
-- * document file names and paths
-- * claim addition information and provider references
--

\set chars_to_translate '\'' abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC '\''

UPDATE providers
SET name = translate(name, :chars_to_translate, :translation);

UPDATE users
SET first_name = translate(first_name, :chars_to_translate, :translation)
  , last_name = translate(last_name, :chars_to_translate, :translation);

UPDATE defendants
SET first_name = translate(first_name, :chars_to_translate, :translation)
  , last_name = translate(last_name, :chars_to_translate, :translation);

UPDATE messages
SET body = translate(body, :chars_to_translate, :translation);

UPDATE messages
SET attachment_file_name = translate(
      substr(attachment_file_name, 1, char_length(attachment_file_name) - position('.' in reverse(attachment_file_name))),
    :chars_to_translate,
    :translation
    )
    || substr(attachment_file_name,char_length(attachment_file_name) - position('.' in reverse(attachment_file_name)) + 1)
WHERE attachment_file_name IS NOT NULL;

UPDATE documents
SET document_file_name = translate(
      substr(document_file_name, 1, char_length(document_file_name) - position('.' in reverse(document_file_name))),
    :chars_to_translate,
    :translation
    )
    || substr(document_file_name,char_length(document_file_name) - position('.' in reverse(document_file_name)) + 1)
  , converted_preview_document_file_name = translate(
      substr(converted_preview_document_file_name, 1, char_length(converted_preview_document_file_name) - position('.' in reverse(document_file_name))),
    :chars_to_translate,
    :translation
    )
    || substr(converted_preview_document_file_name, char_length(converted_preview_document_file_name) - position('.' in reverse(converted_preview_document_file_name)) + 1)
  , file_path = translate(
      substr(file_path, 1, char_length(file_path) - position('.' in reverse(file_path))),
    :chars_to_translate,
    :translation
    )
    || substr(converted_preview_document_file_name, char_length(converted_preview_document_file_name) - position('.' in reverse(converted_preview_document_file_name)) + 1);

UPDATE claims
SET additional_information = translate(additional_information, :chars_to_translate, :translation)
WHERE additional_information IS NOT NULL
  AND length(regexp_replace(additional_information, '[\s\t\n]+', '', 'g')) > 0;

UPDATE claims
SET providers_ref = translate(providers_ref, :chars_to_translate, :translation)
WHERE providers_ref IS NOT NULL
  AND length(regexp_replace(providers_ref, '[\s\t\n]+', '', 'g')) > 0;
