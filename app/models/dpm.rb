class Dpm < ActiveRecord::Base
	mount_uploader :filename, DpmFileUploader
	attr_accessible :filename, :graph_number,:person, :output_file, :youngs_modulus, :id, :gauge_length, :necking_point, :fitting_param, :threshold,:mid, :ro, :eee, :pr, :sigy, :etan, :fail, :tde, :c, :p, :lcss, :lcsr, :vp, :lcf, :eps1, :eps2, :eps3, :eps4, :eps5, :eps6, :eps7, :eps8, :es1, :es2, :es3, :es4, :es5, :es6, :es7, :es8, :lcid, :sidr, :sfa, :sfo, :offa, :offo, :dattyp
end
