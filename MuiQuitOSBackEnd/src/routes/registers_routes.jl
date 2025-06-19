function registers_routes(req)
    if startswith(req.target, "/registers")
        return handle_registers(req)
    end
    return nothing
end
