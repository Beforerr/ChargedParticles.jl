using Mendeleev: isotopes_data, Isotopes, ChemElem

const calculated_properties = (:charge_number, :charge, :atomic_number, :element, :mass_energy, :mass, :symbol)
const properties_fn_map = Dict()
const synonym_properties = Dict(
    :A => :mass_number,
    :q => :charge,
    :z => :charge_number,
    :Z => :atomic_number,
    :ele => :element
)

"""Retrieve the mass of an element isotope."""
function mass(isotopes::Isotopes, mass_number)
    for iso in isotopes
        if iso.mass_number == mass_number
            return iso.mass
        end
    end
    throw(ArgumentError("No isotope found with mass number $mass_number for element $element"))
end

mass(element::ChemElem, mass_number) = mass(element.isotopes, mass_number)
mass(atomic_number::Integer, mass_number) = mass(isotopes_data[atomic_number], mass_number)


# Basic properties
"""Return the mass of the particle"""
function mass(p::AbstractParticle)
    base_mass = mass(atomic_number(p), mass_number(p))
    return base_mass - charge_number(p) * Unitful.me
end

charge_number(p::AbstractParticle) = p.charge_number

"""Return the electric charge of the particle in elementary charge units"""
charge(p::AbstractParticle) = p.charge_number * Unitful.q

"""
    atomic_number(p::AbstractParticle)

Return the atomic number (number of protons) of the particle.

# Examples
```julia
fe = Particle("Fe")
println(atomic_number(fe))  # 26

e = electron()
println(atomic_number(e))  # 0
"""
function atomic_number(p::AbstractParticle)
    e = element(p)
    return isnothing(e) ? 0 : e.atomic_number
end

"""
    mass_number(p::AbstractParticle)

Return the mass number (total number of nucleons) of the particle.

# Examples
```julia
fe56 = Particle("Fe-56")
println(mass_number(fe56))  # 56

e = electron()
println(mass_number(e))  # 0
```
"""
mass_number(p) = p.mass_number
mass_number(::Nothing) = nothing

element(::AbstractParticle) = nothing

function element(p::Particle)
    @match p.symbol begin
        :p => return elements[:H]
        _ => return elements[p.symbol]
    end
end

mass_energy(p::AbstractParticle) = _format_energy(uconvert(u"eV", p.mass * Unitful.c^2))

function Base.getproperty(p::AbstractParticle, s::Symbol)
    s in fieldnames(typeof(p)) && return getfield(p, s)
    s in calculated_properties && return eval(get(properties_fn_map, s, s))(p)
    s in keys(synonym_properties) && return getproperty(p, synonym_properties[s])
end

function Base.propertynames(::T) where {T<:AbstractParticle}
    (sort ∘ collect ∘ union)(keys(synonym_properties), calculated_properties, fieldnames(T))
end
