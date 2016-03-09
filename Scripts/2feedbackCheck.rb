require 'csv'

def checkHeaders(mdbheaders,fmdbheaders)
	if mdbheaders != fmdbheaders
		puts "\nHeaders: DIFFERENT"
		headersJustInMDB = mdbheaders - fmdbheaders
		headersJustInFMDB = fmdbheaders - mdbheaders

		puts "- Headers just in MDB \t#{headersJustInMDB}"
		puts "- Headers just in FMDB \t#{headersJustInFMDB}"
	else 
		puts "\nHeaders: EQUAL"
	end
	puts ""
end

def getSKU(row)
	sku = ""
	$headers.each do |header|
		elem = row[header]
		if header = 'full_price' || header = 'offered_price'
			sku += "#{elem.to_f}"
		else
			sku += "#{elem}"
		end
		
	end
	#puts sku
	return sku.downcase
end

mdb = CSV.read('imp.csv', headers:true)
fmdb = CSV.read('impf.csv', headers:true)



#puts mdb.headers

#puts fmdb.headers

checkHeaders(mdb.headers,fmdb.headers)

$headers = mdb.headers

numOfLinesMDB = 0
numOfLinesFMDB = 0
numOfMatches = 0

idsInMDB = Array.new()
idsInFMDB = Array.new()

mdb.each do |mdbRow|
	idsInMDB << mdbRow['id']
end

fmdb.each do |fmdbRow|
	idsInFMDB << fmdbRow['id']
end

#puts justInMDB
#puts justInFMDB

matches = Array.new()

fmdb.each do |fmdbRow|
	numOfLinesFMDB += 1
	#puts fmdbRow
	numOfLinesMDB = 0
	mdb.each do |mdbRow|
		numOfLinesMDB += 1
		#puts "\n#{fmdbRow}#{mdbRow}"
		if getSKU(fmdbRow) == getSKU(mdbRow)
			numOfMatches += 1
			#puts "Match: #{fmdbRow['id']} #{fmdbRow['name']}"
			matches << fmdbRow['id']
		end
	end

end

justInMDB = idsInMDB - matches
justInFMDB = idsInFMDB - matches

puts "Ids Just in MDB "
justInMDB.each do |id|
	elem = mdb.find {|row| row['id'] == id}
	puts elem
end
puts ""

puts "Ids Just in FMDB"
justInFMDB.each do |id|
	elem =  fmdb.find {|row| row['id'] == id}
	puts elem
end
puts ""

puts "\nDifferent elements for the same id: "
justInMDB.each do |mdbId|
	justInFMDB.each do |fmdbId|
		if mdbId == fmdbId
			elemmdb = mdb.find {|row| row['id'] == mdbId}
			elemfmdb = fmdb.find {|row| row['id'] == fmdbId}

			headers = elemfmdb.headers
			#puts "\nDifferent elements for id #{mdbId}: "
			puts "\n#{mdbId}"
			headers.each do |header|
				if elemmdb[header] != nil && elemfmdb[header] != nil
					if elemmdb[header].downcase != elemfmdb[header].downcase
						puts "Header: #{header} MDB: #{elemmdb[header]} FMDB: #{elemfmdb[header]}"
					end	
				end
			end


		end
	end
end
puts ""

#puts mdb
#puts "----------------------------------------"
#puts fmdb
#puts ""
puts "Num Of Elements on MDB #{numOfLinesMDB}"
puts "Num Of Elements on FMDB #{numOfLinesFMDB}"
puts "Num Of Matches #{numOfMatches}"
puts ""
puts "Generate CSV? (0 or 1)"
generateCSV = gets.chomp()

emptyLine = Array.new(mdb.headers.length)
#puts emptyLine

if generateCSV == '1'
	CSV.open("impdiff.csv", "wb") do |csv|
		csv << mdb.headers
		#csv << emptyLine
		justInMDB.each do |id|
			elem = mdb.find {|row| row['id'] == id}
			csv << elem
		end
		csv << emptyLine
		justInFMDB.each do |id|
			elem = fmdb.find {|row| row['id'] == id}
			csv << elem
		end
	end
end