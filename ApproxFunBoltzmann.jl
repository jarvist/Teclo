#module ApproxFunFromFile

#export ApproxFunFromFile

using ApproxFun

#pts=points(c,100) #This is a built in function; Approxfun would then do eg. vals=cos(pts) to get the values
#show(pts) # Density looks like a 'U' with greater sampling density near the extremes of the range

# From: https://github.com/ApproxFun/ApproxFun.jl/issues/275 , courtesy of private communication with Sheehan Olver
# Least squares approximation of data on an evenly spaced grid with Chebyshev series
function vandermonde(S,n,x::AbstractVector)
    V=Array(Float64,length(x),n)
    for k=1:n
        V[:,k]=Fun([zeros(k-1);1],S)(x)
    end
    V
end

function ApproxFunFromFile(filename)
    c=Chebyshev([0,360]) #Define Chebyshev domain in this range (to match data imported)

    # Standard two column data form
    df=readdlm(filename)
    
    pts=df[:,1] # Points
    vals=df[:,2] #Values at these points

    # For ...(this)... case, make sure `length(pts) >> n`.
    n=13
    V=vandermonde(c,n,pts)
    # Are you ready for the magic?
    af=Fun(V\vals,c) # Approximate Function (af)
    # me is now an ApproxFun representation of the tabulated data. 
    # As a Chebyshev polynomial fit we can do all sorts of differentiation + integration.
    return af,df
end


function graphFun(af,df)
    # Logscale version...
    plot(af,label="Chebyshev fn")
    plot!(df[:,1],df[:,2],label="Raw fn")
    yaxis!("Value fn(x)")
    xaxis!("x")
end

U,df=ApproxFunFromFile("test.dat")
using Plots
graphFun(U,df)

println(U)
println(df)
for i=0:360
    println(U(i))
end

#end
