class AddMidToDpm < ActiveRecord::Migration
  def change
    add_column :dpms, :mid, :float, default: 0.0
    add_column :dpms, :ro, :float, default: 0.0
    add_column :dpms, :eee, :float, default: 0.0
    add_column :dpms, :pr, :float, default: 0.0
    add_column :dpms, :sigy, :float, default: 0.0
    add_column :dpms, :etan, :float, default: 0.0
    add_column :dpms, :fail, :float, default: 1000000000000000000000.0
    add_column :dpms, :tdel, :float, default: 0.0
    add_column :dpms, :c, :float, default: 0.0
    add_column :dpms, :p, :float, default: 0.0
    add_column :dpms, :lcss, :float, default: 0.0 
    add_column :dpms, :lcsr, :float, default: 0.0
    add_column :dpms, :vp, :float, default: 0.0
    add_column :dpms, :lcf, :float, default: 0.0
    add_column :dpms, :eps1, :float, default: 0.0
    add_column :dpms, :eps2, :float, default: 0.0
    add_column :dpms, :eps3, :float, default: 0.0
    add_column :dpms, :eps4, :float, default: 0.0
    add_column :dpms, :eps5, :float, default: 0.0
    add_column :dpms, :eps6, :float, default: 0.0
    add_column :dpms, :eps7, :float, default: 0.0
    add_column :dpms, :eps8, :float, default: 0.0
    add_column :dpms, :es1, :float, default: 0.0
    add_column :dpms, :es2, :float, default: 0.0
    add_column :dpms, :es3, :float, default: 0.0
    add_column :dpms, :es4, :float, default: 0.0
    add_column :dpms, :es5, :float, default: 0.0
    add_column :dpms, :es6, :float, default: 0.0
    add_column :dpms, :es7, :float, default: 0.0
    add_column :dpms, :es8, :float, default: 0.0
    add_column :dpms, :lcid, :float, default: 0.0
    add_column :dpms, :sidr, :float, default: 0.0
    add_column :dpms, :sfa, :float, default: 0.0
    add_column :dpms, :sfo, :float, default: 0.0
    add_column :dpms, :offa, :float, default: 0.0 
    add_column :dpms, :offo, :float, default: 0.0
    add_column :dpms, :dattyp, :float, default: 0.0
    add_column :dpms, :person, :string
  end
end
