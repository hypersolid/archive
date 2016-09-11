class SplitTopicsIntoMultipleTables < ActiveRecord::Migration
  def change
    reversible do |dir|
      dir.up do
        sql = <<-SQL
          CREATE FUNCTION block_direct_topics_insert()
            RETURNS trigger AS
          $func$
          BEGIN
            RAISE EXCEPTION 'Insert into topics blocked'
              USING HINT = 'Please use CREATE RULE to rewrite inserts to the child table';
            RETURN NULL;
          END;
          $func$ LANGUAGE plpgsql;

          CREATE TRIGGER block_direct_topics_insert_trigger
            BEFORE INSERT ON topics
            FOR EACH STATEMENT EXECUTE PROCEDURE block_direct_topics_insert();

          CREATE FUNCTION check_for_topic_dups()
            RETURNS trigger AS
          $func$
          BEGIN
            PERFORM 1 FROM topics where NEW.id=id;
            IF FOUND THEN
              RAISE unique_violation USING MESSAGE = 'Duplicate ID: ' || NEW.id;
              RETURN NULL;
            END IF;

            PERFORM 1 FROM topics where NEW.gid IS NOT NULL AND NEW.gid=gid;
            IF FOUND THEN
              RAISE unique_violation USING MESSAGE = 'Duplicate GID: ' || NEW.gid;
              RETURN NULL;
            END IF;

            IF (NEW.type NOT LIKE 'Gazeta::%') THEN
              RAISE unique_violation USING MESSAGE = 'Duplicate GID: ' || NEW.gid;
              RETURN NULL;
            END IF;
          RETURN NEW;
          END;
          $func$ LANGUAGE plpgsql;
        SQL
        execute(sql)
      end
      dir.down do
        sql = <<-SQL
          DROP FUNCTION IF EXISTS check_for_topic_dups();
          DROP TRIGGER IF EXISTS block_direct_topics_insert_trigger ON topics;
          DROP FUNCTION IF EXISTS block_direct_topics_insert();
        SQL
        execute(sql)
      end
    end

    Gazeta::Topic.descendants.each do |topic_type|
        reversible do |dir|
         dir.up do
           sql = <<-SQL
             CREATE TABLE #{topic_type.table_name} ( CHECK (type='#{topic_type}') ) INHERITS (topics);
             CREATE RULE redirect_insert_to_#{topic_type.table_name} AS
               ON INSERT TO topics WHERE
                  (type='#{topic_type}')
              DO INSTEAD
                INSERT INTO #{topic_type.table_name} VALUES (NEW.*);

              CREATE TRIGGER check_uniquiness_#{topic_type.table_name}
                BEFORE INSERT ON #{topic_type.table_name}
                FOR EACH ROW EXECUTE PROCEDURE check_for_topic_dups();
           SQL

           execute(sql)
         end
         dir.down do
          sql = <<-SQL
            DROP RULE IF EXISTS redirect_insert_to_#{topic_type.table_name} ON topics;
            DROP TRIGGER IF EXISTS check_uniquiness_#{topic_type.table_name} ON #{topic_type.table_name};
            DROP TABLE IF EXISTS #{topic_type.table_name};
          SQL
          execute(sql)
         end
       end
    end
  end
end
