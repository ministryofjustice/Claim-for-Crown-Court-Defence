UPDATE providers
SET name = translate(name, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC', :translation);

UPDATE users
SET first_name = translate(first_name, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC', :translation)
  , last_name = translate(last_name, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC', :translation);

UPDATE defendants
SET first_name = translate(first_name, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC', :translation)
  , last_name = translate(last_name, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC', :translation);

-- messages can contain sensitive data
UPDATE messages
SET body = translate(body, 'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC', :translation);

--message attachment file names can contain sensitive data
UPDATE messages
SET attachment_file_name = translate(
      substr(attachment_file_name,1,char_length(attachment_file_name) - position('.' in reverse(attachment_file_name))),
    'abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZC',
    :translation
    )
    || substr(attachment_file_name,char_length(attachment_file_name) - position('.' in reverse(attachment_file_name)) + 1)
WHERE attachment_file_name IS NOT NULL;
