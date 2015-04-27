

#input is one large hash associated with dpm attributes
#Hash order is { person, filename, outputhash,
#                mid, ro, eee, pr, sigy, etan, fail, tdel, 
#                c, p, lcss, lcsr, vp, lcf,
#                eps1, eps2, eps3, eps4, eps5, eps6, eps7, eps8,
#                es1, es2, es3, es4, es5, es6, es7, es8,
#                lcid, sidr, sfa, sfo, offa, offo, dattyp }
def outputFile(myhash)
	File.open(myhash["filename"]+".k", "w") do |f|
    	f.puts("\$\# LS-DYNA Keyword File created by" + myhash["person"].to_s + " at "+ Time.now.asctime) #List time
    	f.puts("\*KEYWORD")
    	f.puts("\*MAT_PIECEWISE_LINEAR_PLASTICITY_TITLE")
    	f.puts("\$\#\tmid\tro\teee\tpr\tsigy\tetan\tfail\ttdel")
    	f.puts("\t" + myhash["mid"].to_s + "\t" + myhash["ro"].to_s + "\t" + myhash["eee"].to_s + "\t" + myhash["pr"].to_s + "\t" 
            + myhash["sigy"].to_s + "\t" + myhash["etan"].to_s + "\t" + myhash["fail"].to_s + "\t" + myhash["tdel"].to_s)
    	f.puts("\$\#\tc\tp\tlcss\tlcsr\tvp\tlcf")
        f.puts("\t" + myhash["c"].to_s + "\t" + myhash["p"].to_s + "\t" + myhash["lcss"].to_s + "\t" + myhash["lcsr"].to_s + "\t" 
            + myhash["vp"].to_s + "\t" + myhash["lcf"].to_s)
        f.puts("\$\#\teps1\teps2\teps3\teps4\teps5\teps6\teps7\teps8")
        f.puts("\t" + myhash["eps1"].to_s + "\t" + myhash["eps2"].to_s + "\t" + myhash["eps3"].to_s + "\t" + myhash["eps4"].to_s + "\t" 
            + myhash["eps5"].to_s + "\t" + myhash["eps6"].to_s + "\t" + myhash["eps7"].to_s + "\t" + myhash["eps8"].to_s)
        f.puts("\$\#\tes1\tes2\teps3\tes4\tes5\tes6\tes7\tes8")
        f.puts("\t" + myhash["es1"].to_s + "\t" + myhash["es2"].to_s + "\t" + myhash["es3"].to_s + "\t" + myhash["es4"].to_s + "\t" 
            + myhash["es5"].to_s + "\t" + myhash["es6"].to_s + "\t" + myhash["es7"].to_s + "\t" + myhash["es8"].to_s)
        f.put("\*DEFINE_CURVE")
        f.puts("\$\#\tlcid\tsidr\tsfa\tsfo\toffa\toffo\tdattyp")
        f.puts("\t" + myhash["lcid"].to_s + "\t" + myhash["sidr"].to_s + "\t" + myhash["sfa"].to_s + "\t" + myhash["sfo"].to_s + "\t" 
            + myhash["offa"].to_s + "\t" + myhash["offo"].to_s + "\t" + myhash["dattyp"].to_s)
        f.put("\$\#\t\ta1\t\to1")
    	myhash["outputhash"].each{|key, value| {
        	f.puts("\t#{key}\t#{value}")
    	}
        f.puts("\*END")
	end
end

def printHash(myhash)
    puts myhash["person"].to_s
end

#test
abc = {"person" => 1}
printHash(abc)

