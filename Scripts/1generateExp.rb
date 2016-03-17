/pattern/
/pattern/im

require 'csv'

def getSKU(row)
	#puts "exclusive - #{row['exclusive'].downcase}"
	sku = "#{row['name']}#{row['kind']}#{row['shift']}#{row['exclusive']}#{row['university_id']}#{row['campus_id']}#{row['level']}".downcase
	#puts sku
	return sku
end

def getPath(filePath)
	#puts filePath
	mutablePath = filePath
	countIndex = 0
	finished = false
	while !finished
		find = mutablePath .index('/')
		if find == nil
			finished = true
		else 
			endIndex = find
			countIndex += endIndex
			mutablePath  = mutablePath[endIndex+1,mutablePath.length]
		end
		#puts mutablePath 
	end
	path = filePath[0,countIndex+endIndex]
	return path
	
end

p ARGV
expPath = ARGV[0]
mdbPath = ARGV[1]

puts expPath
puts mdbPath
puts getPath(expPath)

puts "Keep MDB Headers? (0 ou 1)"
keepMDB = STDIN.gets.chomp

if keepMDB == '0'
	puts "Exclusive? (0 ou 1)"
	exclusive = STDIN.gets.chomp
	puts "New Partner? (0 ou 1)"
	newPartner = STDIN.gets.chomp
end

puts "Disable all courses from EXP? (0 ou 1)"
disableCoursesOnExp = STDIN.gets.chomp

checkHeaders = []
#checkHeaders = ["exclusive","enabled","enabled_for_seo"]

defaultHeaders = ["id", "name", "kind", "shift", "full_price", "offered_price", "exclusive", "period_kind", "max_periods", "university_id", "campus_id", "enabled", "enabled_for_seo", "level"]

exclusiveHeaders = ["exemption","total_seats", "visible_seats", "exclusivity_revision"]
newPartnerHeaders = ["extra_discount_text","extra_benefit","extra_warning"]

keepHeaders = defaultHeaders

exp = CSV.read(expPath, headers:true)
mdb = CSV.read(mdbPath, headers:true)
#puts "headers #{mdb.headers}"
if keepMDB == '1'
	
	#puts "mdb headers"
	keepHeaders = mdb.headers
else
	if exclusive == '1'
		keepHeaders += exclusiveHeaders
	end
	if newPartner == '1'
		keepHeaders += newPartnerHeaders
	end
end

deleteHeaders = exp.headers - keepHeaders
#p "All headers"
#p exp.to_s
deleteHeaders.each do |deleteHeader|
	exp.delete(deleteHeader)
end

#expSkus = Array.new() 
#mdbSkus = Array.new()


#p "Only headers that needss"
#p exp.to_s

matchedSkus = Array.new()

expElCount = 0
mdbElCount = 0
CSV.open(getPath(expPath)+"imp.csv", "wb") do |csv|
	csv << keepHeaders

	mdb.each do |mdbRow|
		mdbElCount += 1
		match = false
		exp.each do |expRow|
			if getSKU(mdbRow) == getSKU(expRow)
				match = true
				matchedSkus << getSKU(mdbRow)
				mdbRow['id'] = expRow['id']
				mdbRow['formatted_name'] = expRow['formatted_name']
			end
		end
		csv << mdbRow
	end



	exp.each do |expRow| 
		expElCount += 1
		if disableCoursesOnExp == '1' 
			expRow['enabled'] = 'FALSE'
		end
		match = false
		matchedSkus.each do |matchedSku|
			if getSKU(expRow) == matchedSku
				match = true
			end
		end
		if !match 
			csv <<  expRow
		end
	end
	
end

puts "Num EXP elements #{expElCount}"
puts "Num MDB elements #{mdbElCount}"
puts "Num of matches #{matchedSkus.length}"
puts matchedSkus

checkHeaders.each do |check|
	checkElements = exp[check]

	countElements = Hash.new(0)
	checkElements.each do |element|
		countElements[element] +=  1
	end
	puts "\nIn #{check}:"
	countElements.each do |element, count|
		puts "#{element} appears #{count} times"
	end
	#p checkElements
end



#puts mdb

#p deleteHeaders

=begin 
exp.each do |exp_row| 
	p exp_row['name']
end
=end

