









# TENDO DUAS STRINGS COM O COMEÇO IGAUL, ESTA FUNÇÃO RETORNA A DIFERENÇA DELAS (O FINAL DIFERENTE)
def diff(stra, strb)
	cont = 0
	str_resp = ""
	stra.each_char { |letra|
		if(letra != strb[cont])
			str_resp = strb[cont..strb.size]
			break
		end
		cont += 1
	}
	str_resp
end

str2 = "* &bull; A bolsa será cancelada definitivamente no caso de:
*    &bull; Inadimplência consecutiva de 2 parcelas."
str1 = "* &bull; A bolsa será cancelada definitivamente no caso de:
*    &bull; Trancamento de matrícula."

puts diff(str1, str2)












