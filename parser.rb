#!/usr/bin/env ruby
require 'rubygems'
require 'nokogiri'
require 'open-uri'
require 'mechanize'

instructors = []
(1..50).each do |number|
  begin
    doc = Nokogiri::HTML(open("http://uniweb.ru/instructor/"+ number.to_s))
    name = doc.css('table.tbl td.instructor_info h2').text
    degree = doc.css('table.tbl td.instructor_info label > span').text
    universities = []
    doc.css('table.tbl td.instructor_info label  a').each_with_index do |link, index|
      universities[index] = link.children.text
    end
    avatar = "http://uniweb.ru/"
    doc.css('table.tbl td.instructor_info div.image img').each do |img|
      avatar += img['src']
    end
    description = ""
    doc.css('table.tbl td.info_description').children.each do |node|
      description += node.to_s
    end
    knowledges = []
    doc.css('table.tbl div.right-side-inner div.tags-list span').each_with_index do |tag, index|
      knowledges[index] = tag.text
    end
    publications = []
    doc.css('table.tbl div.right-side-inner ul.publications-list li').each_with_index do |li, index|
      if li.css('a').empty?()
        hash = { link: index, text: li.children.text}
      else
        hash = { link: li.css('a @href').text, text: li.children.text}
      end
      publications[index] = hash 
    end

    instructor = { name: name, degrede: degree, universities: universities, avatar: avatar, knowledges: knowledges, publications: publications, description: description.strip}
    instructors[number] = instructor
  rescue OpenURI::HTTPError => e
    instructors[number] = 'null'
  end
end


File.open("instructor.json","w") do |f|
  f.write(instructors)
end
