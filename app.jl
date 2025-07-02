using MuiQuitOSBackEnd
using HTTP
using Sockets
using JSON3

# Gera os gráficos ao iniciar o app
try
    MuiQuitOSBackEnd.RegistersGraphsController.generate_registers_graphs()
    println("Gráficos gerados em ./cache")
catch e
    @warn "Erro ao gerar gráficos" exception=(e, catch_backtrace())
end

function router(req)
    res = users_routes(req)
    if res !== nothing
        return res
    end
    res = registers_routes(req)
    if res !== nothing
        return res
    end
    res = login_routes(req)
    if res !== nothing
        return res
    end
    return HTTP.Response(404, "Not found")
end

println("Iniciando servidor em http://localhost:8080 ...")
HTTP.serve(router, Sockets.localhost, 8080)
