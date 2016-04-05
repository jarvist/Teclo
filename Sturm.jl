# Julia code to calculate spectrum of tridiagonal 'DoS' TB matrices with Sturm sequences
# See section 5, p38: http://arxiv.org/pdf/math-ph/0510043v2.pdf

module Sturm

println("Sturm Library...")

export sturm,randexp,randH

# Calculates number of eigenvalues less than 'sigma' in tridiagonal matrix 
# described by: diagm(E.^0.5,-1)+diagm(D)+diagm(E.^0.5,1)
# Nb: Off digonal elements E are supplied elementally squared for computational speed
function sturm(D,E_squared,sigma)
    t=0.0
    countnegatives=0
    
    t=D[1]-sigma #first term of sequence calculated differently, to avoid needing E[0], t[0]
    if t<0.0
        countnegatives=countnegatives+1
    end

    for i=2:length(D)
        t=D[i]-sigma-E_squared[i-1]/t   # Sturm sequence, overwriting temporary values...
        if t<0.0                     # if t<0, we've found another eigenvalue
            countnegatives=countnegatives+1 
        end
    end

    return countnegatives
end

function randexp(N) # random exponential with the ln(X) 0<X<1 method
    return (log(rand(N)))
end

# Generate a random tridiagonal TightBinding Hamiltonian, in a form suitable for the Sturm sequence
# Given: 
#   SiteEnergy - scalar eV; reference for site energy of monomer
#   disorder - scalar eV ; amount of Gaussian / normal energetic disorder, for trace of Hamiltonian
#   B - scalar (units?); Thermodynamic (B)eta, used to populate Probability Density Function
#   Z - scalar (units?); Partition function, weighting for absolute Boltzmann populations
#   U - function(theta angle); Free energy function, used to generate Bolztmann populations
#   N - integar ; size of diagonal of Hamiltonian
function randH(SiteEnergy, disorder,B,Z,U,N)
# Random Trace / diagonal elements
    D=SiteEnergy + disorder*randn(N)
# Random Off-diag elements
#E=0.1+0.05*randn(N-1)

#Generate thetas...
#    thetas=randexp(N-1)
    thetas=Float64[]
    for i=1:N-1 #number of thetas we need for off-diagonal element
        theta=0.0
        samples=0
        while true # this is a do-while loop, Julia styleee
            theta=360.0 * rand()     #random theta angle [DEGREES]; rand is on [0,1]
            p=exp(-U(theta)*B)/Z  #probability by stat mech
            p>rand() && break     #rejection sampling of distribution
            samples=samples+1
        end
        @printf("Theta: %f Took %d samples\n",theta,samples)
        push!(thetas,theta)       #tack theta onto end of list of thetas
    end

#Transfer integral from
    J0=0.800 #Max Transfer integral
    E=(J0*cos(thetas)).^2 
# Squared (element wise) for the Sturm algorithm...
    E= E.^2
    return (D,E)
end

end
