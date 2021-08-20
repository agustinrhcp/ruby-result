require './result'

def whats_the_best_starter_pokemon?(string)
  validate_input_is_a_string(string)
    .map { |string| string.strip.downcase }
    .then { |string| validate_is_a_starter(string) }
    .then { |string| validate_is_not_bulbasaur(string) }
    .when_ok { |string| "You are right, #{string.capitalize} is the best starter" }
    .when_error { |error| "Buuu, #{error}" }
end

def validate_input_is_a_string(string)
  if string.is_a?(String)
    Result.ok(string)
  else
    Result.error("input is not a string")
  end
end

def validate_is_a_starter(string)
  if ['charmander', 'squirtle', 'pikachu', 'bulbasaur'].include? string
    Result.ok(string)
  else
    Result.error("#{string.capitalize} is not a starter pokemon")
  end
end

def validate_is_not_bulbasaur(string)
  if string != "bulbasaur"
    Result.ok(string)
  else
    Result.error("you are wrong")
  end
end

puts whats_the_best_starter_pokemon?(1)
# => Buuu, input is not a string

puts whats_the_best_starter_pokemon?('Charmander')
# => You are right, Charmander is the best starter

puts whats_the_best_starter_pokemon?('Charmeleon')
# => Buuu, Charmeleon is not a starter pokemon

puts whats_the_best_starter_pokemon?('squirtle')
# => You are right, Squirtle is the best starter

puts whats_the_best_starter_pokemon?('PIKACHU')
# => You are right, Pikachu is the best starter

puts whats_the_best_starter_pokemon?('Bulbasaur')
# => Buuu, you are wrong
