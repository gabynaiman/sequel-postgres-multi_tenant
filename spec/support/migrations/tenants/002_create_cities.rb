Sequel.migration do 
  change do
    create_table(:cities) do
      primary_key :id
      foreign_key :country_id, :countries
      String :name, null: false
    end
  end
end