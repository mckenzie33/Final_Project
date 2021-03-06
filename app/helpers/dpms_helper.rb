#The following functions are used to facilitate the data processing
#module implemented in Matlab by the MSE team.  These functions will 
#be mostly called by the views for graphing purposes (currently using
#Chartick gem for graphing, which takes sets of hashes as input for 
#graphs). 

module DpmsHelper
	include Math
	#param filename is a string representing the file path.
	#The output is an array of hashes (x=>y values)
	#The user picks one graph for the dpm process.
	def create_hash(filename)
		graphs = [] #array of all graphs
		graph = [] #array of points
		point = [] #points
		hash = {}
		noYcolumns = 0
		file = File.open(filename, 'r')
		while !file.eof?
			line = file.readline
			line = line.split(",").collect {|x| x.strip}
			noYcolumns = line.length-1
			for t in 0...noYcolumns #iterate over Y columns in row
				point[t] = [line[0].to_f, line[t+1].to_f] #get x,y1/2/3/...; save in point	
				graph.push(point[t]) #store each point in a graph
			end
			graphs.push(graph) #store graph created in graphs array
			graph = [] #clear the graph array
		end
		#graphs.length = num rows, graphs[i].length = num cols
		for i in 0...noYcolumns #for each column i
			for j in 0...graphs.length #for each row j
				hash.store(graphs[j][0][0], graphs[j][i][1]) #let x point to y1/2/3/...
			end
			graph[i] = hash
			hash = {}
		end
		file.close
		graph
	end

	#returns the last point in the hash
	#takes a hash as input 
	#output is array with x as 0 index and y as index 1
	def getLastPoint myhash
			#sort the hash and get the x values
			dummy = myhash.keys.sort
			#save the x value of the last point 
			xval = dummy.last
			#get the y value of the last point
			yval = myhash[xval]
			return [xval, yval]
	end
	#simple function that takes a hash as input.
	#Returns an array with the min and max values
	#in the hash.  This function is mostly used to 
	#adjust the graph axes.
	def getMaxMin(graph)
		dummy=[]
		dummy[0]=graph.values.max
		dummy[1]=graph.values.min
		dummy
	end


	# tstrain=log(1+strain);
	# tstress=stress * (1+strain);
	# pstrain=tstrain-(tstress./youngsmodulus);
	# youngs_modulus needs to always be multiplied by 1000
	#this functions returns the tstrain (array) 
	#and pstrain vs tstress (hash) values
	#trial is a hash 
	#youngs is youngs modulus to calculate tstress
	#the return value is a hash {tstrain => pstrainvststress}
	def tp_strain trial, youngs
		pstrain = Hash.new
		trial.each do |key, value| 
			#change stress values first (y values)
			new_value = value * (1 + key)
			#change the strain values to tstrain values
			new_key = Math.log(1 + key)
			#change the tstrain to pstrain
			new_key = new_key - (new_value / (youngs * 1000))
			pstrain.store(new_key, new_value)
		end
		return pstrain
	end	

	#this function takes a hash of points as input
	#and returns an array of tstrain values
	def getTstrain trial
		tstrain = Array.new
		trial.each do |key, value|
			#change the key to the tstrain
			new_key = Math.log(1 + key)
			tstrain << new_key
		end
		return tstrain
	end
	#takes a hash of points and number of desired
	#decimal places.  
	#output is the input hash with rounded keys
	#used to trim X axis labels
	def rounder graph, precision
		rtn = Hash.new
		graph.each do | key, value |
			new_key = key.round(precision)
			new_value = value.round(precision)
			rtn.store(new_key, new_value)
		end
		rtn
	end

	#Input is a hash of points representing a graph
	#Outputs a new hash representing the derivative
	#of the input graph.
	def deriv trial
		dummy = Hash.new
		trial.sort
		keys = trial.keys
		values = trial.values
		#getting derivative minus first and last points
		for i in 1...keys.length - 2
			derivy_val = (values[i + 1] - values[i]) / (keys[i + 1] - keys[i])
			dummy.store(keys[i], derivy_val )
		end
		dummy
	end

	#Input is two hashes and a threshold value
	#Trial is a hash representing a curve on a graph
	#Derivative is a hash representing the derivative of trial
	#thresh is the acceptable percent difference between 
	#two points with the same x values on these graphs.  This
	#method is used to recommend a necking point 
	def intersection trial, derivative, thresh
		dummy = Hash.new
		trial.each do |key, value|
			deriv_val = 0.0
			if derivative.key?(key)
				deriv_val = derivative[key]
			end
			#compare the value in trial with deriv
			if (((value - deriv_val).abs / value) < thresh)
				dummy.store(key, value)
			end
		end
		dummy
	end
	# Returns the value of f(x)
	# f(x) = (a+x)/(b+x))^(b+x) - c/d
	# f(x) is the function used to find swift
	# coefficients. This particular equation is 
	# associated with finding swift coefficients
	def equationValue(a, b, c, d, x)
		f = ((a+x)/(b+x))**(b + x)
		f = f - (c/d)
		return f
	end

	# This is for checking that we're working with the right side of our asymptope
	# The point is to give more accurate error message
	def isLeftSideOfAsymptote(a, b, c, d)
		hasError = false

		f1 = E**(a-b)
		f2 = c/d
		
		if (f1 < f2)
			hasError = true
	    end
		return hasError
	end
	#This function uses a bisection method to approximate 
	# a solution for finding swift coefficients. There are other
	# methods of approximation that may work better with the
	# functionality of this DPM, so these should be looked into.
	#Input is four variables representing eps_pf, eps_pn, sigma_f, sigma_n
	#Output is the value of eps_o.  n and k are found afterward using sub
	def solve(a, b, c, d)
		p=0.0
		q=200.0
		errorV=0.00001

		if isLeftSideOfAsymptote(a, b, c, d)
			puts "Data error:  should not produce negative eps_o."
			return nil
		end

		fp = equationValue(a, b, c, d, p)
		fq = equationValue(a, b, c, d, q)

		# This is checking if there's a root (eps_o) can be found
	    if fp > 0
	    	puts "No roots found"
	    	return nil
	    end

		# Ensure fp and fq have different signs, in order to guarantee
		# that a root will be found between them
		while !(fp * fq < 0) do
			q = q * 2
		    fq = equationValue(a, b, c, d, q)
		end
		
		midpoint = (q + p) / 2
	    fMidpoint = equationValue(a, b, c, d, midpoint)

		while !(fMidpoint.abs < errorV) do
			if fp * fMidpoint < 0
				q = midpoint
			    fq = equationValue(a, b, c, d, q)
			else
				p = midpoint
			    fp = equationValue(a, b, c, d, p)
			end

			midpoint = (q + p) / 2
			fMidpoint = equationValue(a, b, c, d, midpoint)
		end
		
	    return midpoint
	end

	#this function will return the swift coefficients
	#the input of this function is the four variables needed
	# to solve the system of equations
	#these are needed to create the final output
	#the output of this function is [eps_o, n, k]
	def getSwifts epsPF, epsPN, sigF, sigN
	    rtn = Array.new
	    #first get eps_o using the solver
	    eps_o = solve(epsPF, epsPN, sigF, sigN)
	    if eps_o == nil
	    	return nil
	    end
	    rtn << eps_o
	    #back solve for n
	    n = eps_o + epsPN
	    rtn << n
	    #back solve for k
	    k = sigF / ((eps_o + epsPF)**n)
	    rtn << k
	    rtn
	end

	#this function will remove all key/value pairs in 
	#the hash where the key is greater than xval
	#the return is a hash of only key/value pairs 
	#that satisfy this condition
	#This is used to cutoff points after necking point
	def removePastX myhash, xval
		rtn = Hash.new
		myhash.each do |key, value|
			if key < xval
				rtn.store(key, value)
			end	
		end
		rtn
	end

	#Input is loaded, and this function does a lot at once
	# stress => hash created from input file of dpm => stress vs strain
	# pstrain => hash representing tstress vs pstrain
	# tstrain => array of x values representing tstrain
	# hardstress => hash representing hardstress vs hardstrain
	# neckingpoint => this is the saved necking point of the dpm 
	# gauge => gaugelength in mm => saved in dpm 
	# fitparam => this is the fitting_parameter of the dpm as a float
	# youngs => this youngs modulus saved in dpm (in GPa, remember to convert to MPa when using)
	def getSystemVars stress, pstrain, tstrain, hardstress, neckingpoint, gauge, fitparam, youngs
		
		neckindex = hardstress.length - 1 		#get the index of the last point in hardstress
		df = getLastPoint(pstrain)[0]   		#last x value pstrain curve
		dn = tstrain.sort[neckindex]			#tstrain value at necking point
		eps_pn = getLastPoint(hardstress)[0]	#x value at last point of hardstress
		sigma_n = pstrain[pstrain.keys.sort[neckindex]]	#tstress value at necking point
		laststresspoint = getLastPoint(stress)	#last point on the stress-strain graph
		sigma_ef = laststresspoint[1]			
		eps_en = laststresspoint[0]
		df_dn = ((E**df) * gauge) - ((E**dn) *gauge)	
		eps_f = Math.log(eps_en + 1 + (df_dn/fitparam))
		sigma_f = sigma_ef * (eps_en + 1 + (df_dn/fitparam))
		eps_pf = eps_f - (sigma_f/(youngs*1000))
		return [eps_pf, eps_pn, sigma_f, sigma_n]
	end

	#Input
	# firstX => this is the first value on the graph that we want to start at
	# totalpoints => number of points we want our graph to use total
	# currentsize => this is the total number of points already in our graph
	# swiftsco => array of swift coefficients to generate y values [eps_o n k]
	#Output is a hash of points for the swift portion of the final graph
	def createSwiftPoints firstX, totalpoints, currentsize, swiftsco
		#we want evenly spaced points and their corresponding swift values
		rtn = Hash.new
		#get the spacing for the x values 
		spacing = (1.0 - firstX) / (totalpoints - currentsize)
		for i in 0..(totalpoints - currentsize)
			#create a series of equally spaced points using swift equation as y's
			#y = k * (eps_o + x)**n
			xval = firstX + (i * spacing)
			yval = swiftsco[2] * (swiftsco[0] + xval)**swiftsco[1]
			rtn.store(xval, yval)
		end
		rtn
	end

	#input is one large hash associated with dpm attributes
	#Hash order is { person, filename, outputhash,
	#                mid, ro, eee, pr, sigy, etan, fail, tdel, 
	#                c, p, lcss, lcsr, vp, lcf,
	#                eps1, eps2, eps3, eps4, eps5, eps6, eps7, eps8,
	#                es1, es2, es3, es4, es5, es6, es7, es8,
	#                lcid, sidr, sfa, sfo, offa, offo, dattyp }
	#this function is called to create the output file
	def outputFile(myhash, filepath, filename)

		dirname = File.dirname(filepath)
		unless File.directory?(dirname)
  		FileUtils.mkdir_p(dirname)
		end
		filename = filepath + filename
		File.open(filename + ".k", "w") do |f|
	    	f.puts("\$\# LS-DYNA Keyword File created by " + myhash["person"].to_s + " at "+ Time.now.asctime) #List time
	    	f.puts("\*KEYWORD")
	    	f.puts("\*MAT_PIECEWISE_LINEAR_PLASTICITY_TITLE")
	    	f.puts("\$\#\tmid\tro\te\tpr\tsigy\tetan\tfail\ttdel")
	    	f.puts("\t" + myhash["mid"].to_s + "\t" + myhash["ro"].to_s + "\t" + myhash["eee"].to_s + "\t" + myhash["pr"].to_s + "\t" +
	             myhash["sigy"].to_s + "\t" + myhash["etan"].to_s + "\t" + myhash["fail"].to_s + "\t" + myhash["tdel"].to_s)
	    	f.puts("\$\#\tc\tp\tlcss\tlcsr\tvp\tlcf")
	        f.puts("\t" + myhash["c"].to_s + "\t" + myhash["p"].to_s + "\t" + myhash["lcss"].to_s + "\t" + myhash["lcsr"].to_s + "\t" +
	            	myhash["vp"].to_s + "\t" + myhash["lcf"].to_s)
	        f.puts("\$\#\teps1\teps2\teps3\teps4\teps5\teps6\teps7\teps8")
	        f.puts("\t" + myhash["eps1"].to_s + "\t" + myhash["eps2"].to_s + "\t" + myhash["eps3"].to_s + "\t" + myhash["eps4"].to_s + "\t" +
	            	 myhash["eps5"].to_s + "\t" + myhash["eps6"].to_s + "\t" + myhash["eps7"].to_s + "\t" + myhash["eps8"].to_s)
	        f.puts("\$\#\tes1\tes2\teps3\tes4\tes5\tes6\tes7\tes8")
	        f.puts("\t" + myhash["es1"].to_s + "\t" + myhash["es2"].to_s + "\t" + myhash["es3"].to_s + "\t" + myhash["es4"].to_s + "\t" +
	            	 myhash["es5"].to_s + "\t" + myhash["es6"].to_s + "\t" + myhash["es7"].to_s + "\t" + myhash["es8"].to_s)
	        f.puts("\*DEFINE_CURVE")
	        f.puts("\$\#\tlcid\tsidr\tsfa\tsfo\toffa\toffo\tdattyp")
	        f.puts("\t" + myhash["lcid"].to_s + "\t" + myhash["sidr"].to_s + "\t" + myhash["sfa"].to_s + "\t" + myhash["sfo"].to_s + "\t" +
	            	 myhash["offa"].to_s + "\t" + myhash["offo"].to_s + "\t" + myhash["dattyp"].to_s)
	        f.puts("\$\#\ta1\to1")
	    	myhash["outputhash"].each do |key, value| 
	        	f.puts("\t#{key}\t#{value}")
	    	end
	        f.puts("\*END")
		end
	end
	#this long function is used to setup the attrHash
	#Refer to Mat24 LSDyna information for the arguments mid, ro ...+
	#the attrHash is later passed as argument to output the final file
	def getFinals(person, outputhash, attrHash, mid, ro, eee, pr, sigy, etan, fail, tdel, c, p, lcss, lcsr, vp, lcf, eps1, eps2, eps3, eps4, eps5, eps6, eps7, eps8, es1, es2, es3, es4, es5, es6, es7, es8, lcid, sidr, sfa, sfo, offa, offo, dattyp)
		attrHash["person"] = person
		attrHash["outputhash"] = Marshal.load(Marshal.dump(outputhash))
		attrHash["mid"] = mid
		attrHash["ro"] = ro
		attrHash["eee"] = eee
		attrHash["pr"] = pr
		attrHash["sigy"] = sigy
		attrHash["etan"] = etan
		attrHash["fail"] = fail
		attrHash["tdel"] = tdel
		attrHash["c"] = c
		attrHash["p"] = p
		attrHash["lcss"] = lcss
		attrHash["lcsr"] = lcsr
		attrHash["vp"] = vp
		attrHash["lcf"] = lcf
		attrHash["eps1"] = eps1
		attrHash["eps2"] = eps2
		attrHash["eps3"] = eps3
		attrHash["eps4"] = eps4
		attrHash["eps5"] = eps5
		attrHash["eps6"] = eps6
		attrHash["eps7"] = eps7
		attrHash["eps8"] = eps8
		attrHash["es1"] = es1
		attrHash["es2"] = es2
		attrHash["es3"] = es3
		attrHash["es4"] = es4
		attrHash["es5"] = es5
		attrHash["es6"] = es6
		attrHash["es7"] = es7
		attrHash["es8"] = es8
		attrHash["lcid"] = lcid
		attrHash["sidr"] = sidr
		attrHash["sfa"] = sfa
		attrHash["sfo"] = sfo
		attrHash["offa"] = offa
		attrHash["offo"] = offo
		attrHash["dattyp"] = dattyp
	end
end