class AddOutputFileToDpm < ActiveRecord::Migration
  def change
    add_column :dpms, :output_file, :string
  end
end
