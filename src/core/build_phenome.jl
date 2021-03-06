"""
# Quick Start
Quick setup by assigning number of `QTL`.

    build_phenome(n_qtls ::Union{Array{Int64, 1}, Int64};
                  args...)

### Arguments
- `n_qtls` : Number of simulated `QTLs`. It can be an array of integers for multiple traits.
- `vg` : Genetic (co)variances of `QTLs`.
- `h2` : Heritability of simulated traits. This will define the residual (co)variances.

### Examples
Single trait
```jldoctest
julia> build_phenome(10)
[ Info: --------- Phenome Summary ---------
[ Info: Number of Traits      : 1
[ Info: Heritability (h2)     : [0.5]
┌ Info:
│   Genetic_Variance =
│    1×1 Array{Float64,2}:
└     1.0
┌ Info:
│   Residual_Variance =
│    1×1 Array{Float64,2}:
└     1.0
[ Info: Number of QTLs        : [10]
```

Multi-trait with additional information
```jldoctest
julia> build_phenome([10, 15];
                     vg = [1 .5
                          .5  1],
                     h2 = [.3, .8])
[ Info: --------- Phenome Summary ---------
[ Info: Number of Traits      : 2
[ Info: Heritability (h2)     : [0.3, 0.8]
┌ Info:
│   Genetic_Variance =
│    2×2 Array{Float64,2}:
│     1.0  0.5
└     0.5  1.0
┌ Info:
│   Residual_Variance =
│    2×2 Array{Float64,2}:
│     2.33333  0.0
└     0.0      0.25
[ Info: Number of QTLs        : [10 25]
```
────────────────────────────────────────────────────────────────
# Define phenome by a file or a DataFrame
Define genome by providing a formatted dataframe or a path to the file.

    build_phenome(dt        ::DataFrame; args...)
    build_phenome(filename  ::String;    args...)

### Arguments
- `dt` : A `DataFrame` with required columns of `eff_` prefixed specifying marker effects.
- `filename` : A filepath to the file containing phenome information.

### Example of the `DataFrame`
```
4×7 DataFrame
 Row │ id      chr    bp       cM       MAF      eff_1    eff_2   
     │ String  Int64  Int64    Float64  Float64  Float64  Float64 
─────┼────────────────────────────────────────────────────────────
   1 │ snp 1       1  1818249     50.8      0.5      0.1      0.0
   2 │ snp 2       1  6557697     80.3      0.5      0.0     -0.3
   3 │ snp_3       2  2298800     39.2      0.5      0.2      0.0
   4 │ snp 4       2  5015698     66.3      0.5      0.0      0.5
```

### Examples
By a filepath
```jldoctest
julia> build_phenome("path/map.csv", h2 = [0.3, 0.5])
```
or a dataframe
```jldoctest
julia> using DataFrames
julia> data = CSV.read("path/map.csv", DataFrame)
julia> build_phenome(data, h2 = [0.3, 0.5])

[ Info: --------- Phenome Summary ---------
[ Info: Number of Traits      : 2
[ Info: Heritability (h2)     : [0.3, 0.5]
┌ Info: 
│   Genetic_Variance =
│    2×2 Array{Float64,2}:
│     1.0  0.0
└     0.0  1.0
┌ Info: 
│   Residual_Variance =
│    2×2 Array{Float64,2}:
│     2.33333  0.0
└     0.0      1.0
[ Info: Number of QTLs        : [2 2]
```

────────────────────────────────────────────────────────────────
# Define phenome by a matrix of QTL effects

    build_phenome(QTL_effects ::Union{Array{Float64}, SparseMatrixCSC}; args...)


### Arguments

- `QTL_effects` : A matrix storing marker effects with the dimension of individuals by markers.


### Examples


```jldoctest
julia> effects = [0.1  0.0
                  0.0 -0.3
                  0.2  0.0
                  0.0  0.5]
julia> build_phenome(effects)
[ Info: --------- Phenome Summary ---------
[ Info: Number of Traits      : 2
[ Info: Heritability (h2)     : [0.5, 0.5]
┌ Info: 
│   Genetic_Variance =
│    2×2 Array{Float64,2}:
│     1.0  0.0
└     0.0  1.0
┌ Info: 
│   Residual_Variance =
│    2×2 Array{Float64,2}:
│     1.0  0.0
└     0.0  1.0
[ Info: Number of QTLs        : [2 2]
```
It's also possible to add additional information such as heritability.

```jldoctest
julia> build_phenome(effects, h2=[0.1, 0.8])
[ Info: --------- Phenome Summary ---------
[ Info: Number of Traits      : 2
[ Info: Heritability (h2)     : [0.1, 0.8]
┌ Info: 
│   Genetic_Variance =
│    2×2 Array{Float64,2}:
│     1.0  0.0
└     0.0  1.0
┌ Info: 
│   Residual_Variance =
│    2×2 Array{Float64,2}:
│     9.0  0.0
└     0.0  0.25
[ Info: Number of QTLs        : [2 2]
```
"""
function build_phenome(QTL_effects  ::Union{Array{Float64}, SparseMatrixCSC};
                       vg           ::Union{Array{Float64}, Float64}=1.0,
                       h2           ::Union{Array{Float64}, Float64}=0.5)

    # Assign number of traits
    SET("n_traits", size(QTL_effects)[2])

    # Assign Vg
    vg = handle_diagonal(vg, GLOBAL("n_traits"))
    vg = Symmetric(vg)
    SET("Vg"      , Array(vg))

    # Assign QTL effects
    effects_scaled = scale_effects(matrix(QTL_effects),
                                   GLOBAL("maf"),
                                   GLOBAL("Vg"),
                                   is_sparse=true)
    SET("effects" , effects_scaled)

    # Assign Ve and heritability
    SET("Ve"      , get_Ve(GLOBAL("n_traits"), GLOBAL("Vg"), h2))
    SET("h2"      , length(h2) == 1 ? [h2] : h2)

    # Summary
    summary_phenome()
end


```
A quick start by assigning number of qtls,
vg and h2 can be optional to provide
```
function build_phenome(n_qtls       ::Union{Array{Int64, 1}, Int64};
                       args...)

    # Handle different length of n_qtls and Vg
    if isa(n_qtls, Array)
        n_traits = length(n_qtls)
    else
        n_traits = 1
    end

    # Instantiate QTL effects
    n_loci      = GLOBAL("n_loci")
    QTL_effects = spzeros(n_loci, n_traits)

    # Assign QTL effects
    if (n_traits > 1) & (length(n_qtls) == 1)
        # When n_qtls is a scaler, assign same number of QTLs for all traits
        idx_qtl = sample(1:n_loci, n_qtls, replace=false)
        for i in 1:n_traits
            QTL_effects[idx_qtl, i] = randn(n_qtls[i])
        end

    else
        # When n_qtls is a vector, assign different QTL locations for multiple traits
        for i in 1:n_traits
            idx_qtl = sample(1:n_loci, n_qtls[i], replace=false)
            QTL_effects[idx_qtl, i] = randn(n_qtls[i])
        end

    end

    # build_genome
    build_phenome(QTL_effects; args...)
end

```
Load dataframe to define effects
```
function build_phenome(dt            ::DataFrame; args...)
    QTL_effects = from_dt_to_eff(dt)
    build_phenome(QTL_effects; args...)
end

```
Load file to define effects
```
function build_phenome(filename     ::String; args...)
     build_phenome(
        CSV.read(filename, DataFrame);
        args...)
end




function summary_phenome()
    n_traits = GLOBAL("n_traits")
    n_qtls   = sum(GLOBAL("effects") .!=0, dims=1)
    Vg       = GLOBAL("Vg")
    Ve       = GLOBAL("Ve")

    if GLOBAL("n_traits") == 1
        h2 = Vg / (Vg + Ve)
    else
        h2 = diag(Vg ./ (Vg + Ve))
    end

    if !GLOBAL("silent")
        LOG("--------- Phenome Summary ---------")
        LOG("Number of Traits      : $n_traits")
        LOG("Heritability (h2)     : $h2")
        @info "" Genetic_Variance=Vg
        @info "" Residual_Variance=Ve
        LOG("Number of QTLs        : $n_qtls")
    end
end

function from_dt_to_eff(dt::DataFrame)
    columns = names(dt)
    idx_eff = [occursin("eff", s) for s in columns]
    return Matrix(dt[:, idx_eff])
end




