require 'csv'
if ARGV.empty?
    puts "Missing argument. Rode algo como: ruby Parcerias_to_MBD.rb <arquivo a ser lido>"
    exit
end

def pathName
    path = ""
    mbdName = ""
    lastSlash = 0
    for i in 0...ARGV[0].length
        if ARGV[0][i] == '/'
            lastSlash = i
        end
    end
    for i in 0..lastSlash
        path << ARGV[0][i]
    end
    for i in lastSlash+1...ARGV[0].length
        mbdName << ARGV[0][i]
    end
    pathname = path + mbdName + " - MBD"
end

par = CSV.read(ARGV[0],headers:true)


#Verificando se a existe bolsa => colocar as colunas extras
exclusive = false
par.each do |row| if row['bolsa exclusiva? (colocar "t" ou "f")'] == 'T'; exclusive = true; break; end; end

hashArray = Array.new
par.each do |par|
    if par['nome do curso']!= nil #evita que leia linha nula
        mbdLine = Hash.new
        mbdLine['id'] = par['id']
        mbdLine['name'] = par['nome do curso'].strip   #strip remove o primeiro e ultimo espaco em branco se houver
        mbdLine['kind'] = par['tipo'].strip
        mbdLine['shift'] = par['turno'].strip
        mbdLine['full_price'] = par['preço cheio']
        mbdLine['offered_price'] = par['preço com desconto']
        mbdLine['exemption'] = par['isenção (colocar "t" ou "f") '].upcase==('T'||'t')?'TRUE':'FALSE'
        mbdLine['total_seats'] = par['vagas']
        mbdLine['visible_seats'] = 0
        mbdLine['exclusive'] = par['bolsa exclusiva? (colocar "t" ou "f")'].upcase==('T'||'t')?'TRUE':'FALSE'
        mbdLine['exclusivity_revision'] = nil 
        mbdLine['period_kind'] = par['peridiocidade'].downcase.strip
        mbdLine['max_periods'] = par['max_periods']
        mbdLine['university_id'] = par['nome da universidade']
        mbdLine['campus_id'] = par['nome do campus']
        mbdLine['enabled'] = 'TRUE'
        mbdLine['enabled_for_seo'] = 'TRUE'
        mbdLine['level'] = par['nível'].strip
        hashArray << mbdLine 
    end
end

#Verificando se a existe bolsa exclusiva/isencao=> manter as colunas extras. senao, eliminar
exclusive = false
par.each do |row| if row['bolsa exclusiva? (colocar "t" ou "f")'] == 'T'; exclusive = true; break; end; end
if !exclusive
    hashArray.each do |hash| hash.delete('total_seats') end
    hashArray.each do |hash| hash.delete('visible_seats') end
    hashArray.each do |hash| hash.delete('exclusivity_revision') end
end

exemption = false
par.each do |row| if row['bolsa exclusiva? (colocar "t" ou "f")'] == 'T'; exemption = true; break; end; end
if !exemption
    hashArray.each do |hash| hash.delete('exemption') end
end

mbdresult = CSV.open(pathName,"wb",headers:true)
mbdresult << hashArray.first.keys
hashArray.each do |hash| mbdresult << hash.values end
