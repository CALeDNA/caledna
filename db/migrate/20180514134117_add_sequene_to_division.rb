class AddSequeneToDivision < ActiveRecord::Migration[5.0]
  def change
    execute 'CREATE SEQUENCE ncbi_divisions_id_seq;'
    execute "ALTER TABLE ncbi_divisions ALTER COLUMN id SET DEFAULT nextval('ncbi_divisions_id_seq');"
    execute 'ALTER TABLE ncbi_divisions ALTER COLUMN id SET NOT NULL;'
  end
end
