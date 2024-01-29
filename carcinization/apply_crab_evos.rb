mappings = File.read("crab_evos.csv").split("\n").map{|m| m.split(",")}.drop(1)
evo_data = File.read("../armips/data/evodata.s")

mappings.each do |mapping|
    original = "SPECIES_" + mapping[0].upcase
    replacement = "SPECIES_" + mapping[1].upcase

    evo_data.gsub!(Regexp.new("(evolution.*?) #{original}$"), "\\1 #{replacement}")
end

File.write("evodata.s", evo_data)
