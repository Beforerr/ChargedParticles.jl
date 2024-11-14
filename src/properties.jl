"""Retrieve the mass of an element isotope."""
function mass(element, mass_number)
    for iso in element.isotopes
        if iso.mass_number == mass_number
            return iso.mass
        end
    end
    throw(ArgumentError("No isotope found with mass number $mass_number for element $element"))
end


# Basic properties
"""Return the mass of the particle in atomic mass units"""
mass(p::AbstractParticle) = p.mass

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

function element(p::AbstractParticle)
    @match p.symbol begin
        x, if x in ELEMENTARY_PARTICLES
        end => return nothing
        :p => return elements[:H]
        _ => return elements[p.symbol]
    end
end