def senha
    'daniel12'
end

# encoding: utf-8

require 'watir-webdriver'
require 'csv'
require 'pry'
require 'open-uri'
require 'fileutils'

browser = Watir::Browser.new
browser.goto('http://redmine.redealumni.com/issues/4646')

browser.text_field(:id, 'username').set('daniel.adamis')
browser.text_field(:id, 'password').value = senha
browser.button(:type, 'submit').click()

atribuido_para = browser.links(:class => "user active").last.text
dono_parceria = browser.td(:class => "cf_9").text
titulo_task = browser.element(:css => "div.subject div h3").text
data = Time.new.strftime("%d.%m")
saved_dir = File.expand_path('~')+'/Downloads/'+dono_parceria+" - "+data+" - "
saved_dir += titulo_task+" - "+atribuido_para+"/"
FileUtils::mkdir_p saved_dir

browser.links.each { |a|
begin
  if a.href.include? "/attachments/download/"
    IO.copy_stream(open(a.href), saved_dir+a.text)
  end
end
}

browser.close
=begin
areas = browser.elements(:id, 'input').map do |element|
  if element.attribute_value('username') != ""
    [element.attribute_value('title'), element.attribute_value('href')]
  end
end

areas.compact!

CSV.open('uniara_pos_graduacao_presencial', 'w') do |csv|
  csv << ['nome','kind','shift','preco','duracao']

  areas.each do |name, link|

    browser.goto(link)
    courses = browser.elements(:css, 'ul.curto a').map do |element|
      [element.attribute_value('title'), element.attribute_value('href')]
    end

    courses.each do |course_name, course_link|
      puts course_name


      browser.goto(course_link)
      if browser.element(:css, 'a.curso_aba[rel="aba0"]').exists?
        browser.element(:css, 'a.curso_aba[rel="aba0"]').click
        if browser.element(:xpath, "//ul/li[contains(.,'parcelas')]").attribute_value('textContent') != nil
          textinho = browser.element(:xpath, "//ul/li[contains(.,'parcelas')]").attribute_value('textContent')

          preco = textinho[/([0-9]+)[[:space:]]+?parcelas[[:space:]]+?de[[:space:]]+?R\$[[:space:]]+?([0-9,]+)/,2]
          duracao = textinho[/([0-9]+)[[:space:]]+?parcelas[[:space:]]+?de[[:space:]]+?R\$[[:space:]]+?([0-9,]+)/,1]
          print "preco=", preco, " duracao=", duracao, "\n"
          puts "==============================="
          csv << [course_name, 'Presencial', 'Outro', preco, duracao]
        end
      end
    end
  end
end
=end
