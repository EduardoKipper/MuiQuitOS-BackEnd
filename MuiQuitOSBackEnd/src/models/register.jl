module RegisterModule

using Dates
export Register

mutable struct Register
    user_id::String
    cep::String
    datetime::DateTime
    intensity::Int
    evidence::String
end

end
