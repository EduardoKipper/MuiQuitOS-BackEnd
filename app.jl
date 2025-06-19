using MuiQuitOSBackEnd
using HTTP
using Sockets
using JSON3

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
