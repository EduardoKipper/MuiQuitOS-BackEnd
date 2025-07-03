module MuiQuitOSBackEnd

include("models/user.jl")
include("models/register.jl")
using .RegisterModule: Register
include("controllers/users_controller.jl")
include("controllers/registers_controller.jl")
include("controllers/registers_graphs_controller.jl")
include("controllers/login_controller.jl")
include("routes/users_routes.jl")
include("routes/registers_routes.jl")
include("routes/login_routes.jl")

# Exporta o submódulo para acesso externo
export users_routes, registers_routes, login_routes, RegistersGraphsController

end # module