# Author::    Sergio Fierens
# License::   MPL 1.1
# Project::   ai4r
# Url::       http://ai4r.org/

module GeneticAlgorithm
  class GeneticSearch

    attr_accessor :population


    def initialize(initial_population_size, generations)
      @population_size = initial_population_size
      @max_generation = generations
      @generation = 0
    end

    def run
      generate_initial_population                    #Generate initial population 
      @max_generation.times do
        selected_to_breed = selection                #Evaluates current population 
        offsprings = reproduction selected_to_breed  #Generate the population for this new generation
        replace_worst_ranked offsprings
      end
      return best_chromosome
    end


    def generate_initial_population
     @population = []
     @population_size.times do
       population << Chromosome.seed
     end
    end

    def selection
      @population.sort! { |a, b| b.fitness <=> a.fitness}
      best_fitness = @population[0].fitness
      worst_fitness = @population.last.fitness
      acum_fitness = 0
      if best_fitness-worst_fitness > 0
      @population.each do |chromosome| 
        chromosome.normalized_fitness = (chromosome.fitness - worst_fitness)/(best_fitness-worst_fitness)
        acum_fitness += chromosome.normalized_fitness
      end
      else
        @population.each { |chromosome| chromosome.normalized_fitness = 1}  
      end
      selected_to_breed = []
      ((2*@population_size)/3).times do 
        selected_to_breed << select_random_individual(acum_fitness)
      end
      selected_to_breed
    end

    # The reproduction will also call the Chromosome.mutate method with 
    # each member of the population. You should implement Chromosome.mutate
    # to only change (mutate) randomly. E.g. You could effectivly change the
    # chromosome only if 
    #     rand < ((1 - chromosome.normalized_fitness) * 0.4)
    def reproduction(selected_to_breed)
      offsprings = []
      0.upto(selected_to_breed.length/2-1) do |i|
        offsprings << Chromosome.reproduce(selected_to_breed[2*i], selected_to_breed[2*i+1])
      end
      @population.each do |individual|
        Chromosome.mutate(individual)
      end
      return offsprings
    end

    # Replace worst ranked part of population with offspring
    def replace_worst_ranked(offsprings)
      size = offsprings.length
      @population = @population [0..((-1*size)-1)] + offsprings
    end

    # Select the best chromosome in the population
    def best_chromosome
      the_best = @population[0]
      @population.each do |chromosome|
        the_best = chromosome if chromosome.fitness > the_best.fitness
      end
      return the_best
    end

    private 
    def select_random_individual(acum_fitness)
      select_random_target = acum_fitness * rand
      local_acum = 0
      @population.each do |chromosome|
        local_acum += chromosome.normalized_fitness
        return chromosome if local_acum >= select_random_target
      end
    end

  end

  class Chromosome

    attr_accessor :data
    attr_accessor :normalized_fitness

    def initialize(data)
      # NOTE: Modified for a node initial
      data[data.find_index(0)], data[0] = data[0], 0
      @data = data
    end

    def fitness
      return @fitness if @fitness
      last_token = @data[0]
      cost = 0
      @data[1..-1].each do |token|
        cost += @@costs[last_token][token]
        last_token = token
      end
      @fitness = -1 * cost
      return @fitness
    end

    def self.mutate(chromosome)
      if chromosome.normalized_fitness && rand < ((1 - chromosome.normalized_fitness) * 0.3)
        data = chromosome.data
        index = rand(data.length-1)
        data[index], data[index+1] = data[index+1], data[index]
        chromosome.data = data
        @fitness = nil
      end
    end

    def self.reproduce(a, b)
      data_size = @@costs[0].length
      available = []
      0.upto(data_size-1) { |n| available << n }
      token = a.data[0]
      spawn = [token]
      available.delete(token)
      while available.length > 0 do 
        #Select next
        if token != b.data.last && available.include?(b.data[b.data.index(token)+1])
          next_token = b.data[b.data.index(token)+1]
        elsif token != a.data.last && available.include?(a.data[a.data.index(token)+1])
          next_token = a.data[a.data.index(token)+1] 
        else
          next_token = available[rand(available.length)]
        end
        #Add to spawn
        token = next_token
        available.delete(token)
        spawn << next_token
        a, b = b, a if rand < 0.4
      end
      return Chromosome.new(spawn)
    end

    def self.seed
      data_size = @@costs[0].length
      available = []
      0.upto(data_size-1) { |n| available << n }
      seed = []
      while available.length > 0 do 
        index = rand(available.length)
        seed << available.delete_at(index)
      end
      return Chromosome.new(seed)
    end

    def self.set_cost_matrix(costs)
      @@costs = costs
    end
  end

end