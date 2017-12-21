module IdSequenceResettable
  extend ActiveSupport::Concern

  included do
    def sequence_resets
      tables.each_with_object([]) do |table_name, memo|
        memo << reset_sql(table_name)
        yield memo.last if block_given?
      end
    end

    def append_sequence_resets(file_name)
      sequence_resets do |sql|
        open(file_name, 'a') do |file|
          file.puts sql
        end
      end
    end

    private

    def tables_sql
      <<~SQL
        SELECT table_name
        FROM information_schema.columns
        WHERE column_default LIKE 'nextval(''' || table_name || '_id_seq''%';
      SQL
    end

    def tables
      ActiveRecord::Base
        .connection
        .execute(tables_sql)
        .each_with_object([]) do |rec, memo|
          memo << rec['table_name']
          yield memo.last if block_given?
        end
    end

    def reset_sql(table_name)
      <<~SQL
        SELECT pg_catalog.setval(pg_get_serial_sequence('#{table_name}', 'id'), (SELECT MAX(id) FROM #{table_name}));
      SQL
    end
  end
end
