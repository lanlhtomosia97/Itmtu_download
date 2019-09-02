require 'nokogiri'
require 'open-uri'
require 'csv'
require 'thread'
require 'pry'

class Notice

  def insert_number
    "= = = = = = = = = = INSERT NUMBER = = = = = = = = = = = = = = = ="
  end

  def insert_last_page
    "= = = = = = = INSERT LAST PAGE = = = MAX IS 21 PAGE = = = = = = = "
  end

  def nil_link
    "= = = = = = = = = = LINK NILL = = = = = = = = = = = = = = = = ="
  end

  def not_availability_last_page
    "= = = = = = = = = = LAST PAGE NOT AVAILABILITY = = = = = = = = = ="
  end

  def complete_get_image
    "= = = = = = = = = = COMPLETE CRAWL IMAGE = = = = = = = = = = = ="
  end

  def download
    "= = = = = = = = = = INSERT TO FOLDER = = = = = = = = = = = = = ="
  end

  def complete
    "= = = = = = = = = = COMPLETE = = = = = = = = = = = = = = = = = = ="
  end

  def loading
    "== "
  end

  def error
    "= = = = = = = = = = ERROR = = = TRY AGAIN LATER = = = = = = = = = "
  end
end

class InsertData < Notice
  attr_accessor :link, :last_page

  def initialize
    puts insert_number
    @link = gets.chomp.to_s
    puts insert_last_page
    @last_page = gets.chomp.to_i
  end
end


class GetLink
  attr_accessor :urls
  
  def initialize(insert_data)
    $retries = 3
    $completed = true
    $title
    @urls = []
    $total_link = []
    insert_data.last_page.times {|i| urls.push("http://www.itmtu.com/mm/#{insert_data.link}/#{i+1}")}
  end
end

insert_data = InsertData.new
get_data = GetLink.new(insert_data)

begin
  class Parser < Notice
    def initialize(insert_data)
      ## Function
      insert_data.urls.each { |url|
        raw_page = Nokogiri::HTML(open(url))
        items = raw_page.css(".main > .main_inner > .main_left > .content > .content_left > .image_div").search("img").first.attributes.values.first.value
        $title = raw_page.css(".main > .main_inner > .main_left > .content > .content_left > .image_div").search("img").first.attributes.values.last.value
        link_array = []
        link_array << items
        $total_link = $total_link + link_array
        print loading
      }
      puts complete_get_image
      puts download
    end
  end

parser_data = Parser.new(get_data)

rescue => exception
  puts exception
  puts "Wait for 3 minutes and Retry"
  sleep 180 # 3 minutes
  $retries -= 1
  retry if $retries > 0 
  $completed = false
  puts "#{exception}, TRY AGAIN LATER" 
end

class Download < Notice
  def initialize(insert_data)
    directory_name = $title
    Dir.mkdir(directory_name) unless File.exists?(directory_name)
    Dir.chdir(directory_name)  
    count = 0
    $total_link.each do |item|
      File.write("#{count}.jpg", open("#{item}").read, {mode: 'wb'})
      count = count + 1
    end
    puts complete
  end
end
Download.new(insert_data)
