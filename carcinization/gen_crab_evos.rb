require "json"

FINAL_CRABS = [
    47, # parasect
    99, # kingler
    141, # kabutops
    342, # crawdaunt
    558, # crustle
    693, # clawitzer
    740, # crabominable
    950 # klawf
]

FORCED_REPLACEMENTS = {
    154 => 47, # meganium -> parasect
    157 => 558, # typhlosion -> crustle
    160 => 99 # feraligatr -> kingler
}


# mappings based entirely by reasonably types
tier1_evo_mappings = {
    "Dark" => [342],
    "Ghost" => [342],
    "Bug" => [47],
    "Grass" => [47],
    "Poison" => [47],
    "Ice" => [740],
    "Fighting" => [740],
    "Rock" => [141, 558],
    "Ground" => [141, 558],
    "Water" => [99, 693],
    "Normal" => [99, 693],
}

# mappings based on more abstract choices
tier2_evo_mappings = {
    "Electric" => [141],
    "Flying" => [141],
    "Fire" => [740],
    "Steel" => [558],
    "Dragon" => [],
    "Pyschic" => [693],
    "Fairy" => [],
}

def not_evolved?(pokemon)
    $pokedex[pokemon["id"]]["evolution"]["prev"].nil?
end

def can_evolve?(pokemon)
    !$pokedex[pokemon["id"]]["evolution"]["next"].nil?
end

def base_stat_diff(p1, p2)
    diffs = ["HP", "Attack", "Defense", "Sp. Attack", "Sp. Defense", "Speed"].map do |stat|
        (p1["base"][stat] - p2["base"][stat]).abs()
    end

    # only take into account the diffs in one of physical vs special attack and one of phys vs spec defense
    if diffs[1] > diffs[3]
        diffs[1] = 0
    else
        diffs[3] = 0
    end

    if diffs[2] > diffs[4]
        diffs[2] = 0
    else
        diffs[4] = 0
    end

    return diffs.reduce(&:+)
end

# choose crab to evolve to based on priority list of properties
# first type (obvious type matching) -> second type (obvious type matching) -> first type (non-obvious type matching)
def crab_evo_for_v1(pokemon)
    $pokedex[47]
end

# choose crab evo based on which final crab has the closest base stats to the intended evo
def crab_evo_for_v2(pokemon)
    # if not_evolved?(pokemon)
    #     return $pokedex[950] # klawf
    # end

    # remove klawf from the list, it should only be used to replace single-stage pokemon
    crab_list = $final_crabs#.reject{|c| c["id"] == 950}
    crab_list.map do |crab|
        [crab, base_stat_diff(pokemon, crab)]
    end.min do |a, b|
        a[1] <=> b[1]
    end[0]
end

def evolution_text(base, evo, method)
    "#{base["name"]["english"]} (##{base["id"]}) --> #{evo["name"]["english"]} (##{evo["id"]}) [#{method}]\n"
end

def replacement_text(pokemon, crab)
    "#{pokemon["name"]["english"]} (#{pokemon["id"]}) gets replaced with #{crab["name"]["english"]} (#{crab["id"]})"
end

def choose_crab_evo(pokemon)
    # return if pokemon["id"] > 809 # db doesn't have stats for gen 8+ pokemon
    return if pokemon["id"] > 493 # only up to gen 4 pokemon are naturally present in the game anyway

    text = ""
    if !can_evolve?(pokemon)
        crab = crab_evo_for_v2(pokemon)
        # text = replacement_text(pokemon, crab)
        # puts text
        # return text
        return crab
    else
        return nil
        # pokemon["evolution"]["next"].each do |evo|
        #     id = evo[0]
        #     method = evo[1]
        #     evo_poke = $pokedex[id.to_i]

        #     if can_evolve?(evo_poke) # don't change
        #         text += evolution_text(pokemon, evo_poke, method)
        #     else
        #         crab_evo = crab_evo_for(pokemon)
        #         text += evolution_text(pokemon, crab_evo, method)
        #     end
        # end
    end
    # if it's the first
    # if it evolves exactly once, choose appropriate final stage crab
        # final stage crab chosen based on type

    # output format: base --> evo (method)
    # print text
    # text
end

def choose_all_evos
    data = JSON.parse(File.read("pokedex.json"))
    data.each do |pokemon|
        $pokedex[pokemon["id"]] = pokemon
    end
    $final_crabs = FINAL_CRABS.map do |crab|
        $pokedex[crab]
    end 

    counts = Hash.new(0)
    evos = data.map do |pokemon|
        if FORCED_REPLACEMENTS[pokemon["id"]]
            crab = $pokedex[FORCED_REPLACEMENTS[pokemon["id"]]]
            next "#{pokemon["name"]["english"]},#{crab["name"]["english"]}"
        end

        crab = choose_crab_evo(pokemon)
        next nil if crab.nil?
        
        counts[crab["name"]["english"]] += 1
        # replacement_text(pokemon, crab)
        "#{pokemon["name"]["english"]},#{crab["name"]["english"]}"
    end.compact

    # counts = Hash.new(0)
    # evos.each{|poke| counts[poke["name"]["english"]] += 1}
    # puts evos
    puts $final_crabs.map {|crab|  bst = crab["base"].map{|k, v| v}.reduce(&:+); [crab["name"]["english"], crab["base"]]}
    puts counts
    File.write("crab_evos.csv", "original,replacement\n" + evos.join("\n"))
end

$pokedex = {}
$final_crabs = []
choose_all_evos()

