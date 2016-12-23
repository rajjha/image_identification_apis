class FlowerIdentifier
  require "rest-client"
  require 'cloudsight'
  require 'json'
  #CLOUDSIGHT will provide only name in response
  #flower_path and flower_id is identifiable  image record .
  def self.cloudsight_identification(flower_path,flower_id)
	identification = {}
	Cloudsight.oauth_options = {
	  consumer_key: 'XXXXXXXXXXXXXXXXXXXXXXXXXXXXXXX',
	  consumer_secret: 'YYYYYYYYYYYYYYYYYYYYYYYYYYYYY'
	}

	requestData = Cloudsight::Request.send(locale: 'en', file: File.open(flower_path))
	Cloudsight::Response.retrieve(requestData['token']) do |responseData|
	  identification = responseData
	end  
	save_to_db(identification,"cloudsight",flower_id)
  end
  
  #JUSTVISUAL response will return many identical/related results
  def self.justvisual_identification(flower_path,flower_id)
	identification = {}
	response = RestClient.post 'http://garden.vsapi01.com/api-search?apikey=0101007d-2059-4279-ba8a-f34b8a1d3178',
	{:file => File.new(flower_path, 'rb'), :multipart => true}
	identification = JSON.parse(response.body)
	save_to_db(identification,"justvisual",flower_id)
  end

  #this is to enrich our DB.
  def self.save_to_db(identification_hash,response_from,flower_id)
     if response_from == "cloudsight" && identification_hash != {}
	   f = FlowerInfo.new({:title => identification_hash["name"],:url => identification_hash["url"],:flower_id => flower_id})
	   f.save
     elsif response_from == "justvisual" && identification_hash != {}
	identification_hash["images"].each{|image|
	  f = FlowerInfo.new({:plantname => image["plantNames"], :title => image["title"],:url => image["imageUrl"],:wiki_link => image["pageUrl"],:botanical_name => image["plantNames"],:description =>  image["description"],:flower_id => flower_id})
	  f.save
	}
     end
  end
  end
