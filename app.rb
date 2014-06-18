class Skipping < Sinatra::Base
  
  GENERAL_TITLE = "The General synopsis at midnight"
  AREA_TITLE = "The area forecasts for the next 24 hours"
  AREAS = ["Viking", "North Utsire", "South Utsire", "Forties", "Cromarty", "Forth", "Tyne",  "Dogger", "Fisher", "German Bight",  "Humber", "Thames", "Dover", "Wight", "Portland", "Plymouth",  "Biscay",  "Trafalgar",  "FitzRoy",  "Sole", "Lundy", "Fastnet",  "Irish Sea",  "Shannon",  "Rockall", "Malin",  "Hebrides", "Bailey",  "Fair Isle", "Faeroes", "South-east Iceland"]


  @@markov = MarkyMarkov::TemporaryDictionary.new(2)
  corpus = File.read('corpus.txt')
  @@markov.parse_string corpus

  get '/' do

    output = []
    output << GENERAL_TITLE
    output << @@markov.generate_n_sentences(3)

    areas = AREAS.shuffle

    areas.each_slice(rand(4)+1) do |a|

      output << a.join(", ")
      temp_string = @@markov.generate_n_sentences(3)

      all_areas_regex = Regexp.new(AREAS.join("|"))

      temp_string.scan(all_areas_regex).each do |match|
        if !a.include?(match)
          temp_string = temp_string.gsub(match, a.shuffle[0])
        end
      end


      output << temp_string
    end

    time = Time.now.utc.strftime("%H%M")

    erb :index, :locals => {:forecast_lines => output, :time => time}
  end

end
