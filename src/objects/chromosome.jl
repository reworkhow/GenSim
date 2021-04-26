mutable struct Chromosome
    index       ::Int64
    haplotype   ::Array{AlleleIndexType, 1}
    ori         ::Array{Int64          , 1}
    pos         ::Array{Float64        , 1}
    mut         ::Array{Float64        , 1}

    function Chromosome(i_chr     ::Int64;
                        ori       ::Int64=1,
                        is_founder::Bool=false)
        n_loci = GLOBAL.G.chr[i_chr].numLoci
        if is_founder
            # when it's a founder's chromosome
            chromosome = new(i_chr,
                             Array{AlleleIndexType}(undef, n_loci),
                             [ori],
                             [0.0],
                             Array{Float64}(undef, 0))
            set_alleles(chromosome, i_chr, n_loci)
        else
            # when it's a progeny's chromosome
            chromosome = new(i_chr,
                             Array{AlleleIndexType}(undef, n_loci),
                             Array{Int64          }(undef, 0),
                             Array{Float64        }(undef, 0),
                             Array{Float64        }(undef, 0))
        end
        return chromosome
    end

    Chromosome(
            index       ::Int64,
            haplotype   ::Array{AlleleIndexType, 1},
            ori         ::Array{Int64          , 1},
            pos         ::Array{Float64        , 1},
            mut         ::Array{Float64        , 1}) =
        new(index, haplotype, ori, pos, mut)

    function set_alleles(chromosome::Chromosome,
                         index     ::Int,
                         n_loci    ::Int)
        for j in 1:n_loci
            p = Bernoulli(GLOBAL.G.chr[index].loci[j].allele_freq[1])
            chromosome.haplotype[j] = convert(AlleleIndexType, rand(p))
        end
    end
end
