module RegisterModule

using Dates
export Register

mutable struct Register
    register_id::Int
    user_id::String
    cep::String
    datetime::DateTime
    intensity::Float64
    evidence::Union{Nothing, String}
    latitude::Float64
    longitude::Float64
    city::String
    state::String
    neighbourhood::String
    access_difficulty::Int
    focus_size::Int
    larvae::Bool
end

end
