using Test
using ChargedParticles
using ChargedParticles: is_electron, is_proton
using Unitful
using Unitful: q, me

using Mendeleev: elements

@testset "ChargedParticles.jl" begin
    @testset "Basic Particles" begin
        # Test electron
        e = electron()
        @test charge(e) == -q
        @test atomic_number(e) == 0
        @test mass_number(e) == 0
        @test mass(e) == me

        # Test proton
        p = proton()
        @test charge(p) == q
        @test atomic_number(p) == 1
        @test mass_number(p) == 1

        # Test neutron
        n = Particle("n")
        @test charge(n) == 0q
        @test atomic_number(n) == 0
        @test mass_number(n) == 1
    end
    @testset "Constructor" begin
        include("types.jl")
    end

    @testset "Properties" begin
        include("properties.jl")
    end

    @testset "Error Handling" begin
        # Test invalid particle strings
        @test_throws KeyError Particle("invalid")
        @test_throws KeyError Particle("Xx")

        # Test invalid mass numbers
        @test_throws MethodError Particle(:He, 2, -1)
    end

    @testset "String Representation" begin
        @test string(electron()) == "e⁻"
        @test string(proton()) == "p⁺"
        @test string(Particle("He2+")) == "He²⁺"
        @test string(Particle("Fe-56")) == "Fe"
        @test string(Particle("Fe-54")) == "Fe-54"
    end

    @testset "Isotope Mass" begin
        fe56 = elements[:Fe].isotopes[2]
        fe54 = elements[:Fe].isotopes[1]
        @test mass(Particle("Fe")) == fe56.mass
        @test mass(Particle("Fe-56")) == fe56.mass
        @test mass(Particle("Fe-54")) == fe54.mass
    end
end
