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
    mbdName.slice!('.csv')  #retira o .csv do nome
    pathname = path + mbdName + " - MBD.csv"
end

par = CSV.read(ARGV[0],headers:true)

def getOfferedPrice(total,discount)
        if discount.include?'%';    discount = (discount.to_f)/100
        elsif discount.to_f > 1;    return discount.to_f     #se desconto for maior que 1, provavelmente sera o preco ja com desconto
        end         
        return total*(1-discount.to_f)  
end

#Retorna nil se o campo estiver em branco. O tratamento deve ser realizado manualmente
def getValue(value)
    return if value==nil 
    return value
end

#Verificando se a existe bolsa => colocar as colunas extras
exclusive = false
par.each do |row| if row['bolsa exclusiva? (colocar "t" ou "f")'] == 'T'; exclusive = true; break; end; end

hashArray = Array.new
par.each do |par|
    if par['nome do curso']!= nil #evita que leia linha nula
        mbdLine = Hash.new
        mbdLine['id'] = getValue(par['id'])
        mbdLine['name'] = getValue(par['nome do curso']).strip   #strip remove o primeiro e ultimo espaco em branco se houver
        mbdLine['kind'] = getValue(par['tipo']).strip
        mbdLine['shift'] = getValue(par['turno']).strip
        mbdLine['full_price'] = getValue(par['preço cheio'])
        mbdLine['offered_price'] = getOfferedPrice(mbdLine['full_price'],par['preço com desconto']) if getValue(par['preço cheio'])!=nil
        mbdLine['exemption'] = getValue(par['isenção (colocar "t" ou "f") ']).upcase==('T')?'TRUE':'FALSE' if getValue(par['isenção (colocar "t" ou "f") '])!=nil
        mbdLine['total_seats'] = getValue(par['vagas'])
        mbdLine['visible_seats'] = 0
        mbdLine['exclusive'] = par['bolsa exclusiva? (colocar "t" ou "f")'].upcase==('T')?'TRUE':'FALSE' if getValue(par['bolsa exclusiva? (colocar "t" ou "f")'])!=nil
        mbdLine['exclusivity_revision'] = nil 
        mbdLine['period_kind'] = getValue(par['peridiocidade']).downcase.strip
        mbdLine['max_periods'] = getValue(par['max_periods'])
        mbdLine['university_id'] = getValue(par['nome da universidade'])
        mbdLine['campus_id'] = getValue(par['nome do campus'])
        mbdLine['enabled'] = 'TRUE'
        mbdLine['enabled_for_seo'] = 'TRUE'
        mbdLine['level'] = getValue(par['nível']).strip
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
