using Main.XSim


using CSV, DataFrames, LinearAlgebra, StatsBase

dt = CSV.read("data/genome_cattle.csv", DataFrame)
# dt = CSV.read("data/genome_pig.csv", DataFrame)


# Load genome
try
    SET("chromosome", dt.chr)
    SET("bp"        , dt.bp)
    SET("cM"        , dt.cM)
catch
    error("Missing required columns")
end

# Define MAF
if all(in(names(dt)).(["maf"]))
    SET("maf", dt.maf)
else
    SET("maf", fill(0.5, GLOBAL("n_loci")))
end



function fa(a::Int64; b::Int64)
    return a + b*2
end

function fa(a::Int64; c::Union{Array{Int64, 1}, Int64})
    return a + c*3
end

fa(1, b=3)
fa(1, c=3)



Vg = [1 0.5
      0.5 1]
h2 = [.5, .8]

Vg = matrix(.7)
h2 = .5

n_traits = size(Vg)[2]

ve = ((ones(n_traits) .- h2) .* diag(Vg)) ./ h2
handle_diagonal(ve[1], n_traits)


inputs = ve
# Formate variances to 2-D matrix
inputs = matrix(inputs)

# Cast variants of variances to a 2-D array
if length(inputs) == 1
    # When variances is a scaler, assign it as the diagonal of variances
    inputs = diagm(fill(inputs, n_traits))
else
    inputs = matrix(inputs)
    if size(inputs)[2] == 1
        # When variances is a vector, assign it as the diagonal of variances
        inputs = diagm(inputs[:, 1])
end

if size(inputs)[2] != n_traits
    error("Dimensions don't match between n_traits and variances/h2")
end

    return inputs






vg = h2*vg  + h2 * ve
(1 - h2)Vg / h2 = ve

effects = [0.3 0.5
            0 0.2
         -1.3 0.4]
freq = [0.5, 0.5, 0.5]

effects_sc = scale_effects(effects, freq, Vg)
get_Vg(effects_sc, freq)

Vg = matrix(3.0)
effects = matrix([0.3, 0.5, 0])
freq = [0.5, 0.5, 0.5]

effects_sc = scale_effects(effects, freq, Vg)

get_Vg(effects_sc, freq)



vec1 = [1,2,3]
vec2 = 34

isa(vec1, Array)


freq = [1,2,3,3,3,3,2,5,3,4]
sample(1:10, 11, replace=true)


function TU(mat ::Union{Array{Int64, 1}, Int64})
    print(mat)
end


TU([3, 6])

function ab(mat ::Array{Int64, N} where N = [1, 2])
    return mat
end

vfs([1 2 4
     1 2 6])


x = matrix([3, 5])
diagm(x)



isa([3.0], Array{Float64, 1})

fla(Float64)


mat = [1 2
       3.3 4]

       mat
diag(1)
isa(mat, Array)
isa(3, Array)

c("Gender", "Age") %in% names(df)

function funB(;
    a, b, c, d=3)
    return a+b+c+d
end

a = Array{Float64, 2}([1.0], 1, 1)
a[1, 1] = 3
(, 1, 1)

hcat(Diagonal([1])...)

funB(a       =3,
    b = 5, 
    c =     3)


compute_rec!(dt)
length(mat)
Diagonal()

mutable struct test
    a
    b
end

T = test(1, 3)
setfield!(T, Symbol("a"), 99)


# ```Append columns to dt```
# function compute_rec_prob(chromosomes::Array{Int64,   1},
#                           cM         ::Array{Flaot64, 1})
#     # --- Compute recombination rate
#     # Get diff cM
#     cM_diff = vcat(0, diff(cM))
#     n_loci = GLOBAL("n_loci")
#     for i in 1:n_loci
#         # diff(cM) < 0 when across chromosome
#         if cM_diff[i] < 0
#             cM_diff[i] = cM[i]
#         end

#         # diff(cM) == 0 when markers in the same LD block
#         if i < length(cM_diff) && cM_diff[i + 1] == 0
#             cM_diff[i + 1] = cM_diff[i]
#         end
#     end

#     # --- Compute standardized probability
#     probs = zeros(n_loci)
#     for chr in unique(chromosomes)
#         idx = chromosomes .== chr
#         probs[idx] = round.(    cM_diff[idx]/
#                             sum(cM_diff[idx]),
#                             digits=5)
#     end
#     return probs
# end

