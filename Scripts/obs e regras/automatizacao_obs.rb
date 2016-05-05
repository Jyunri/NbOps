# encoding: UTF-8
#!/usr/bin/env ruby

require 'csv'
if ARGV.length < 1
    puts "Missing argument. Rode algo como: ruby automatizacao_obs.rb <Numero_resposta>"
    exit
end

# TENDO DUAS STRINGS COM O COMEÇO IGAUL, ESTA FUNÇÃO RETORNA A DIFERENÇA DELAS (O FINAL DIFERENTE).
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

# CRIA UM VETOR COM O NÚMERO DAS RESPOSTAS QUE DEPENDEM DE n_resp.
def vetor_dependencias(n_resp)
	vet_dps = []
	$arquivo_correspondencias.map { |e| 
		vet_dps.push(e[3]) unless e[0].to_i != n_resp
	}
	vet_dps
end

# PEGA UMA RESPOSTA JÁ MONTADA E COLOCA NO PADRÃO ESPERADO NO ARQUIVO FINAL.
def padroniza_resp(resposta_x)
	str = ""
	resposta_x.strip!
	resposta_x.split(";").each { |alternativa_x|
		str += "* &bull; " + alternativa_x + ".\n\n"
	}
	str
end

# SUBSTITUI A RESPOSTA RECEBIDA PELA CORRESPONDÊNCIA ESPECIFICADA NO ARQUIVO DE CORRESPONDÊNCIAS.
def correspondencia_resps(respostas_originais, n_resp)
	#vet_dps = vetor_dependencias(n_resp)
	final = ""
	respostas_originais[n_resp].split(";").each { |alternativa_resp_original|
		$arquivo_correspondencias.map { |linha_ac|
			if(linha_ac[0].to_i == n_resp) && (alternativa_resp_original.to_s.include? linha_ac[1].to_s)
				final += linha_ac[2]
				dp = linha_ac[3].to_i
				if(dp != 0)
					resposta_dependente = respostas_originais[dp.to_i].to_s
					$arquivo_correspondencias.map { |linha_dp|
						if(linha_dp[0].to_i == dp.to_i) && (resposta_dependente.include? linha_dp[1].to_s)
							final += "%%"+linha_dp[2].to_s
						end
					}
				end
				final = final + ";"
			end
		}
	}
	final = padroniza_resp(final).gsub("<BULL>", "&bull;").gsub("<IES>", $universidade) unless final.length == 0
end

### INICIANDO MONTAGEM DO ARQUIVO ###

# ABRINDO PLANILHA DE CORRESPONDÊNCIAS TEXTUAIS.
$arquivo_correspondencias = CSV.read("correspondencias.csv",headers:false)

# ABRINDO PLANILHA DE RESPOSTAS.
filename = "FORMULÁRIO\ REGRAS\ E\ OBSERVAÇÕES\ -\ PARCERIAS\ QUERO\ BOLSA.csv"
arquivo_completo = CSV.read(filename,headers:false)
n_linha = ARGV[0]

# PEGANDO A LINHA DA RESPOSTA DESEJADA.
respostas = arquivo_completo[n_linha.to_i]

# ARMAZENANDO O NOME DA UNIVERSIDADE.
$universidade 	= respostas[2]

# CABEÇALHO 
resposta_final = "### " + respostas[0] + ", " + $universidade + "\n\n"

# MONTANDO O OBSERVAÇÕES E REGRAS
resposta_final += "#### **Quem pode ter a bolsa?**\n"
[4, 8].each { |p|
	resposta_final += correspondencia_resps(respostas, p).to_s
}

resposta_final += "\n#### **Quem pode perder a bolsa?**\n"
[11, 13, 14].each { |p|
	resposta_final += correspondencia_resps(respostas, p).to_s
}

if(not respostas[16].empty?)
	resposta_final += correspondencia_resps(respostas, 16).to_s
end

resposta_final += "\n#### **Quais são as características da bolsa?**\n"
resposta_final += correspondencia_resps(respostas, 17).to_s
desconto = respostas[21].to_i
if(desconto > 1)
	resposta_final += padroniza_resp("A faculdade oferece um desconto de pontualidade de " + desconto.to_s + "%").to_s
	[18, 20].each { |p|
		resposta_final += correspondencia_resps(respostas, p).to_s
	}
end

[22, 23].each { |p|
	resposta_final += correspondencia_resps(respostas, p).to_s
}

resposta_final += "\n#### **Como fazer para garantir a bolsa?**\n"
resposta_final += correspondencia_resps(respostas, 24).to_s
resposta_final += padroniza_resp("A entrega do cupom deve ser feita no setor " + respostas[25] + " da faculdade").to_s

puts "\n** Concluído **\n\n"

# SALVANDO TXT
txt = File.new("obs_regras.txt", "w")
txt.puts(resposta_final)
txt.close